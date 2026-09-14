"""Add reciprocal language navigation and verify every local HTML link and asset."""
import argparse
import hashlib
import json
from pathlib import Path
from urllib.parse import unquote, urlsplit
import posixpath
from bs4 import BeautifulSoup

parser = argparse.ArgumentParser()
parser.add_argument("site")
parser.add_argument("--kind", choices=["r", "python"], required=True)
args = parser.parse_args()
root = Path(args.site).resolve()
if not (root / "index.html").exists() or not (root / "en/index.html").exists(): raise SystemExit("Both language homes are required")
canonical = "https://adatar-do.github.io/renviron/" if args.kind == "r" else "https://adatar-do.github.io/endompy/"
pages = sorted(root.rglob("*.html"))
# Normalize affected Spanish template strings from the Windows pkgdown catalog.
# Body content and element identifiers remain untouched.
SPANISH_TEMPLATE = {"ArtC-culos": "Artículos", "CC3digo": "Código", "CC3mo": "Cómo",
    "Cndice": "Índice", "pC!gina": "página", "GuC-a": "Guía", "cC3digo": "código", "MC!s": "Más"}
if args.kind == "r":
    # Search must follow the served edition, including previews and subpaths.
    # pkgdown writes canonical absolute result URLs by default.
    for index in (root / "search.json", root / "en/search.json"):
        english = index.parent.name == "en"
        edition_prefix = canonical + ("en/" if english else "")
        entries = json.loads(index.read_text(encoding="utf-8"))
        entries = [entry for entry in entries if isinstance(entry.get("path"), str)]
        for entry in entries:
            if entry["path"].startswith(edition_prefix):
                entry["path"] = entry["path"][len(edition_prefix):]
            if urlsplit(entry["path"]).scheme or entry["path"].startswith("/"):
                raise SystemExit("Unexpected search target: " + entry["path"])
            if not english:
                entry["dir"] = {"Reference": "Referencia", "Changelog": "Registro de cambios", "Articles": "Artículos"}.get(entry.get("dir", ""), entry.get("dir", ""))
        # This pkgdown build omits article bodies from search. Index each rendered
        # guide in its own edition, replacing prior entries on repeated runs.
        entries = [entry for entry in entries if not entry["path"].startswith("articles/")]
        for guide in sorted((index.parent / "articles").glob("*.html")):
            if guide.name == "index.html": continue
            article = BeautifulSoup(guide.read_text(encoding="utf-8"), "html.parser")
            main = article.select_one("main")
            if main is None or main.h1 is None: raise SystemExit("Missing article body: " + str(guide))
            title = main.h1.get_text(" ", strip=True)
            code = " ".join(node.get_text(" ", strip=True) for node in main.select("pre"))
            for node in main.select("pre, style, script"): node.decompose()
            entries.append({"path": "articles/" + guide.name, "id": None,
                "dir": "Articles" if english else "Artículos", "previous_headings": "",
                "what": title, "title": title, "text": main.get_text(" ", strip=True), "code": code})
        index.write_text(json.dumps(entries, ensure_ascii=False), encoding="utf-8")
        script = index.parent / "pkgdown.js"
        javascript = script.read_text(encoding="utf-8")
        marker = "    var data = await response.json();"
        replacement = marker + '''
    // ENFT: resolve results relative to this edition's search index.
    data = data.map(function(item) {
      item.path = new URL(item.path, response.url).href;
      return item;
    });'''
        if "// ENFT: resolve results" not in javascript:
            if javascript.count(marker) != 1:
                raise SystemExit("Review changed pkgdown search initialization")
            javascript = javascript.replace(marker, replacement)
        old_target = '    window.location.href = s.path + "?q=" + q + "#" + s.id;'
        if "// ENFT: encode the query" not in javascript:
            if javascript.count(old_target) != 1:
                raise SystemExit("Review changed pkgdown result navigation")
            javascript = javascript.replace(old_target, '''    // ENFT: encode the query and omit absent section anchors.
    var destination = new URL(s.path, window.location.href);
    destination.searchParams.set("q", q);
    destination.hash = s.id || "";
    window.location.href = destination.href;''')
        if not english:
            javascript = javascript.replace('dir:"Sorry 😿"', 'dir:"Búsqueda"').replace('"No results found."', '"No se encontraron resultados."')
        if "// ENFT: share the initial index request" not in javascript:
            start = javascript.find("  var fuse;\n")
            end = javascript.find("  // Use algolia autocomplete", start)
            if start < 0 or end < 0: raise SystemExit("Review changed pkgdown search loading")
            javascript = javascript[:start] + '''  // ENFT: share the initial index request with the first typed query.
  var fuse;
  var fuseLoading;
  function loadSearchIndex() {
    if (!fuseLoading) {
      fuseLoading = (async function() {
        var response = await fetch($("#search-input").data("search-index"));
        if (!response.ok) throw new Error("Search index could not be loaded");
        var data = await response.json();
        // ENFT: resolve results relative to this edition's search index.
        data = data.map(function(item) {
          item.path = new URL(item.path, response.url).href;
          return item;
        });
        fuse = new Fuse(data, {keys: ["what", "text", "code"], ignoreLocation: true,
          threshold: 0.1, includeMatches: true, includeScore: true});
        return fuse;
      })();
    }
    return fuseLoading;
  }
  $("#search-input").focus(async function(e) {
    $(e.target).addClass("loading");
    try { await loadSearchIndex(); }
    finally { $(e.target).removeClass("loading"); }
  });

''' + javascript[end:]
            if javascript.count("  await fuse;") != 1: raise SystemExit("Review changed pkgdown search callback")
            javascript = javascript.replace("  await fuse;", "  await loadSearchIndex();")
        script.write_text(javascript, encoding="utf-8")
pairs = 0
for page in pages:
    relative = page.relative_to(root).as_posix()
    language = "en" if relative.startswith("en/") else "es"
    counterpart = relative[3:] if language == "en" else "en/" + relative
    if not (root / counterpart).is_file():
        raise SystemExit("Missing language counterpart: " + relative)
    soup = BeautifulSoup(page.read_text(encoding="utf-8"), "html.parser")
    soup.html["lang"] = language
    if args.kind == "r" and language == "es":
        for node in list(soup.find_all(string=True)):
            if node.parent.name in ("script", "style", "code"): continue
            repaired = str(node)
            for wrong, correct in SPANISH_TEMPLATE.items(): repaired = repaired.replace(wrong, correct)
            if repaired != str(node): node.replace_with(repaired)
    if args.kind == "r":
        edition = root / "en" if language == "en" else root
        if language == "en":
            for node in soup.select('a[href]'):
                node['href'] = node['href'].replace(
                    'https://github.com/adatar-do/renviron/blob/HEAD/vignettes/',
                    'https://github.com/adatar-do/renviron/blob/HEAD/pkgdown/i18n/en/vignettes/')
        # Content hashes invalidate cached indexes/scripts after a static deployment.
        for node in soup.select("[data-search-index]"):
            search_path = ("en/" if language == "en" else "") + "search.json"
            node["data-search-index"] = posixpath.relpath(search_path, posixpath.dirname(relative) or ".") + "?v=" + hashlib.sha256((edition / "search.json").read_bytes()).hexdigest()[:16]
        for node in soup.select("script[src]"):
            value = urlsplit(node["src"])
            if posixpath.basename(value.path) == "pkgdown.js":
                script_path = ("en/" if language == "en" else "") + "pkgdown.js"
                node["src"] = posixpath.relpath(script_path, posixpath.dirname(relative) or ".") + "?v=" + hashlib.sha256((edition / "pkgdown.js").read_bytes()).hexdigest()[:16]
        if language == "es":
            for node in soup.select('[aria-label="Search site"]'): node["aria-label"] = "Buscar en el sitio"
            for node in soup.select('[aria-label="Site navigation"]'): node["aria-label"] = "Navegación del sitio"
    # pkgdown's current template may reference optional favicon formats that an
    # older package icon set does not contain. Keep only existing local icons.
    if args.kind == "r":
        for icon in soup.select('link[rel="icon"], link[rel="manifest"]'):
            icon_path = page.parent / unquote(urlsplit(icon.get("href", "")).path)
            if not icon_path.is_file(): icon.decompose()
        existing_icon = root / "favicon-32x32.png"
        if existing_icon.exists() and not soup.select_one('link[rel="icon"][sizes="32x32"]'):
            soup.head.append(soup.new_tag("link", rel="icon", type="image/png", sizes="32x32",
                href=posixpath.relpath("favicon-32x32.png", posixpath.dirname(relative) or ".")))
    for node in soup.select("[data-enft-language], link[hreflang]"): node.decompose()
    for lang, target in ((language, relative), ("es" if language == "en" else "en", counterpart)):
        node = soup.new_tag("link", rel="alternate", hreflang=lang, href=canonical + target)
        soup.head.append(node)
    href = posixpath.relpath(counterpart, posixpath.dirname(relative) or ".")
    link = soup.new_tag("a", href=href, attrs={"data-enft-language": "true", "hreflang": "es" if language == "en" else "en"})
    link.string = "Español" if language == "en" else "English"
    if args.kind == "r":
        navs = soup.select(".navbar-nav")
        if not navs:
            if soup.find("meta", attrs={"http-equiv": "refresh"}) is None: raise SystemExit("Missing R navbar: " + relative)
        else:
            item = soup.new_tag("li", attrs={"class": "nav-item", "data-enft-language": "true"})
            link["class"] = "nav-link"; item.append(link); navs[-1].append(item)
    else:
        nav = soup.select_one(".md-header__inner")
        if nav is None: raise SystemExit("Missing Python header: " + relative)
        link["class"] = "md-header__button"
        link["style"] = "font-size: .7rem; font-weight: 600; white-space: nowrap"
        nav.append(link)
    page.write_text(str(soup), encoding="utf-8")
    if language == "es": pairs += 1

ids = {}
for page in pages:
    soup = BeautifulSoup(page.read_text(encoding="utf-8"), "html.parser")
    ids[page] = {tag["id"] for tag in soup.select("[id]")} | {tag["name"] for tag in soup.select("a[name]")}
errors, checked = [], 0
for page in pages:
    soup = BeautifulSoup(page.read_text(encoding="utf-8"), "html.parser")
    for tag in soup.select("[href], [src]"):
        value = tag.get("href", tag.get("src", ""))
        url = urlsplit(value)
        if url.scheme or url.netloc or not value or value == "#": continue
        path = unquote(url.path)
        if path.startswith("/"):
            prefix = "/renviron/" if args.kind == "r" else "/endompy/"
            path = path[len(prefix):] if path.startswith(prefix) else path.lstrip("/")
            target = root / path
        else: target = page.parent / path if path else page
        target = target.resolve()
        if target.is_dir(): target /= "index.html"
        if not target.is_relative_to(root) or not target.is_file():
            errors.append(f"{page.relative_to(root)}: missing {value}"); continue
        checked += 1
        if url.fragment and target.suffix == ".html" and unquote(url.fragment) not in ids.get(target, set()):
            errors.append(f"{page.relative_to(root)}: missing anchor {value}")
search = [str(path.relative_to(root)) for path in root.rglob("*search*.json")]
search_targets = 0
search_guides = 0
if args.kind == "r":
    for index in (root / "search.json", root / "en/search.json"):
        for entry in json.loads(index.read_text(encoding="utf-8")):
            target = (index.parent / unquote(entry["path"])).resolve()
            if not target.is_relative_to(index.parent) or not target.is_file():
                errors.append(f"{index.relative_to(root)}: missing result {entry['path']}")
            elif entry.get("id") and entry["id"] not in ids.get(target, set()):
                errors.append(f"{index.relative_to(root)}: missing result anchor {entry['path']}#{entry['id']}")
            search_targets += 1
            if entry["path"].startswith("articles/"): search_guides += 1
else:
    for index in (root / "search/search_index.json", root / "en/search/search_index.json"):
        edition = index.parent.parent
        for entry in json.loads(index.read_text(encoding="utf-8"))["docs"]:
            location = urlsplit(entry["location"])
            target = (edition / unquote(location.path or "index.html")).resolve()
            if location.scheme or not target.is_relative_to(edition) or not target.is_file():
                errors.append(f"{index.relative_to(root)}: missing result {entry['location']}")
            elif location.fragment and unquote(location.fragment) not in ids.get(target, set()):
                errors.append(f"{index.relative_to(root)}: missing result anchor {entry['location']}")
            search_targets += 1
report = {"kind": args.kind, "pages": len(pages), "language_pairs": pairs,
          "local_links_and_assets": checked, "search_indexes": search,
          "verified_search_targets": search_targets, "indexed_guides": search_guides, "errors": sorted(set(errors))}
(root / "site-check.json").write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
print(json.dumps(report, indent=2, ensure_ascii=False))
if errors: raise SystemExit(1)
