"""Generate paired, executable package guides and release documentation."""
from pathlib import Path
root = Path(__file__).resolve().parents[1]
def write(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text.strip()+'\n', encoding='utf-8')

guides = {
'renviron': ('Leer, cargar y editar', 'Read, load and edit', '''
`renviron 0.6.0` administra archivos `.Renviron` y nombres personalizados. La lectura devuelve una lista sin modificar la sesión; la carga aplica solo las claves elegidas. Los ejemplos usan datos inventados y archivos temporales.

| Función | Lee el archivo | Cambia la sesión | Guarda el archivo |
|---|---|---|---|
| `renviron_read()` | Sí | No | No |
| `renviron_get()`, `renviron_exists()`, `renviron_list()` | Si no se pasa una lista | No | No |
| `renviron_load()` | Sí | Claves seleccionadas | No |
| `renviron_add()`, `renviron_delete()` | Si no se pasa una lista | Solo la clave indicada | Con `in_place=TRUE` |
| `renviron_save()` | No interpreta el contenido previo | No | Reemplazo completo |
| `renviron_unset_all()` | Sí | Retira las claves seleccionadas | No |

`renviron_list()` devuelve una máscara constante por variable. `renviron_read()` y `renviron_get()` devuelven valores reales: evite imprimir sus resultados cuando contengan información privada. El enmascaramiento es una ayuda de presentación; no cifra archivos.

## Recorrido completo

El guardado de una clave conserva comentarios y expresiones de las otras claves. El valor dependiente se recalcula al leer de nuevo; su versión en la sesión solo cambia al cargarlo explícitamente.
''', '''
`renviron 0.6.0` manages `.Renviron` files and custom filenames. Reading returns a list without changing the session; loading applies only selected keys. The examples use invented data and temporary files.

| Function | Reads the file | Changes the session | Writes the file |
|---|---|---|---|
| `renviron_read()` | Yes | No | No |
| `renviron_get()`, `renviron_exists()`, `renviron_list()` | Unless a list is supplied | No | No |
| `renviron_load()` | Yes | Selected keys | No |
| `renviron_add()`, `renviron_delete()` | Unless a list is supplied | Only the selected key | With `in_place=TRUE` |
| `renviron_save()` | Does not parse previous contents | No | Full replacement |
| `renviron_unset_all()` | Yes | Unsets selected keys | No |

`renviron_list()` returns a fixed mask for each variable. `renviron_read()` and `renviron_get()` return actual values: avoid printing them when they contain private information. Masking is a display aid; it does not encrypt files.

## Complete workflow

Editing one key preserves comments and expressions for other keys. A dependent value is recalculated on the next read; its session value changes only when explicitly loaded.
'''),
'archivos': ('Ámbitos y sintaxis de archivos', 'Scopes and file syntax', '''
## Selección de ruta

`renviron_path()` consulta `scope` en el orden proporcionado y devuelve el primer archivo existente. No fusiona archivos. Si no existe ninguno, devuelve la primera ruta candidata para permitir su creación. El orden predeterminado es `c("user", "project")`; para priorizar el proyecto use `c("project", "user")`.

`project=getwd()` usa el directorio de trabajo actual, sin detectar raíces ni activar proyectos de usethis. Puede pasar `project` y `user` explícitamente. Una `.file` absoluta siempre selecciona ese archivo. Para el nombre predeterminado `.Renviron` en el ámbito de usuario, `R_ENVIRON_USER` tiene prioridad salvo que se proporcione `user`. Los nombres personalizados nunca se redirigen por esa variable. `scoped_path_r()` se conserva para construir rutas de un único ámbito.

## Interpretación nativa

La lectura usa `readRenviron()` en otro proceso de R, iniciado con `--vanilla`. No ejecuta perfiles de inicio ni modifica el entorno del proceso principal. Hereda el entorno actual para resolver referencias y procesa las asignaciones en orden. Las referencias pueden utilizar claves que no estén en `.vars`: el filtro se aplica al resultado.

Se admiten valores con `=`, comillas simples o dobles, barras, Unicode UTF-8, comentarios de línea y referencias `${VAR}`, `${VAR-default}` y `${VAR:-default}`. También se acepta `export KEY=value` como extensión; R por sí solo no necesita ese prefijo. Una línea `KEY=` sin valor se ignora, mientras `KEY=''` declara una cadena vacía. Un `#` al final de una asignación forma parte del valor. Las claves repetidas siguen la última asignación efectiva de R.

En Windows una cadena vacía puede representarse como variable ausente en el entorno del proceso. La lista devuelta conserva la clave y `""`. Una expansión sin comillas que produzca vacío puede ser ignorada por R y mantener un valor heredado; use comillas para expresar intención. Los valores devueltos no son una copia textual de expresiones del archivo.

Consulte la [documentación de inicio de R](https://stat.ethz.ch/R-manual/R-devel/library/base/html/Startup.html) para las reglas del lector nativo. El paquete no ejecuta comandos de shell ni interpreta scripts.

## Guardado y límites

Los valores suministrados a `renviron_save()` y `renviron_add()` son **literales**: `${VARIABLE}` se guarda para recuperar ese mismo texto. Las ediciones de una clave mantienen las expresiones ajenas sin resolverlas ni volverlas literales. Si pasa una lista a un editor con `in_place=TRUE`, esa lista modificada reemplaza todo el documento.

Se requieren nombres portables `[A-Za-z_][A-Za-z0-9_]*` y valores escalares de caracteres sin NA ni saltos de línea. Se rechazan bytes NUL, UTF-8 inválido y líneas codificadas de más de 99900 bytes. Los archivos ausentes o vacíos devuelven `list()`; una asignación inválida detiene toda la operación con el número de línea, sin incluir su valor.

El guardado prepara un temporal en el mismo directorio y reemplaza el destino; comprueba cambios desde la lectura y conserva permisos de archivos existentes. No proporciona bloqueo entre escritores concurrentes: coordine un solo escritor por archivo. No escribe a través de enlaces simbólicos. El directorio debe existir; los nuevos archivos usan modo 0600 donde se soporta y las ACL heredadas siguen aplicándose en Windows. Las ediciones normalizan finales de línea a LF y UTF-8.

Cada lectura inicia un proceso de R: para consultar muchas claves, lea una vez y reutilice la lista. La llamada necesita una instalación de R ejecutable y tiene un límite de 60 segundos.
''', '''
## Path selection

`renviron_path()` searches `scope` in the supplied order and returns the first existing file. It does not merge files. If none exists, it returns the first candidate so it can be created. The default is `c("user", "project")`; use `c("project", "user")` to prefer the project.

`project=getwd()` uses the current working directory without detecting roots or activating a usethis project. Both `project` and `user` can be provided explicitly. An absolute `.file` always selects that file. For the default `.Renviron` name in user scope, `R_ENVIRON_USER` takes precedence unless `user` is supplied. Custom filenames are never redirected by that variable. `scoped_path_r()` remains available to construct a path in a single scope.

## Native interpretation

Reading uses `readRenviron()` in a separate R process started with `--vanilla`. It does not execute startup profiles or alter the parent environment. The worker inherits the current environment for reference expansion and processes assignments in order. References may use keys outside `.vars`: filtering applies to the result.

Supported input includes values containing `=`, single and double quotes, backslashes, UTF-8 Unicode, full-line comments and references `${VAR}`, `${VAR-default}` and `${VAR:-default}`. The optional `export KEY=value` prefix is an extension; native R does not require it. A bare `KEY=` is ignored, whereas `KEY=''` declares an empty string. A trailing `#` belongs to the value. Repeated keys follow R's last effective assignment.

On Windows an empty string may be represented as an unset process variable. The returned list retains its key and `""`. An unquoted expansion producing an empty value may be ignored by R and retain an inherited value; use quotes to express intent. Returned values are not textual copies of the expressions in the file.

See [R startup documentation](https://stat.ethz.ch/R-manual/R-devel/library/base/html/Startup.html) for native reader rules. The package does not execute shell commands or interpret scripts.

## Writing and limits

Values supplied to `renviron_save()` and `renviron_add()` are **literal**: `${VARIABLE}` is encoded to recover that exact text. Single-key edits preserve other expressions without resolving or converting them to literals. Supplying a list to an editor with `in_place=TRUE` replaces the whole document with the modified list.

Names must match `[A-Za-z_][A-Za-z0-9_]*`; values must be scalar character strings without NA or line breaks. NUL bytes, invalid UTF-8 and encoded lines longer than 99900 bytes are rejected. Missing or empty files return `list()`; invalid assignments stop the operation with a line number and no value in the diagnostic.

Writing prepares a temporary file in the destination directory, checks for changes since reading, then replaces the destination while retaining existing file permissions. It does not provide locking between concurrent writers: coordinate one writer per file. Symbolic-link destinations are rejected. The directory must exist; new files use mode 0600 where supported, and inherited Windows ACLs still apply. Edits normalize line endings to LF and UTF-8.

Every read starts an R process. To query many keys, read once and reuse the list. Reading requires an executable R installation and has a 60-second timeout.
'''),
'migracion': ('Migrar desde 0.5.1', 'Migrate from 0.5.1', '''
La versión 0.6.0 conserva las funciones públicas previas y el operador `%>%`, e incorpora `renviron_read()`. Cambia comportamientos que antes eran ambiguos o producían efectos laterales. Revise estos puntos al actualizar.

| Tema | 0.5.1 | 0.6.0 |
|---|---|---|
| Consultas get/exists/list | Podían cargar todas las variables en la sesión | Solo consultan; use `renviron_load()` para cargar |
| Clave ausente en get | Podía devolver un valor ajeno de Sys.getenv | Devuelve `NULL` |
| Valor vacío | Podía confundirse con una clave ausente | La lista conserva `""`; exists devuelve TRUE |
| Archivo vacío/ausente | `NULL` en varias rutas | `list()`; list devuelve `character()` |
| Ámbitos múltiples | Solo elegía el primero mediante match.arg | Busca el primer archivo existente en el orden indicado |
| Proyecto | Dependía del proyecto activo de usethis | Directorio de trabajo o `project` explícito |
| Edición persistente | Reescribía todas las variables cargadas | Sin lista suministrada, conserva las otras líneas |
| Confirmación cancelada | La sesión podía haber cambiado | No aplica la edición a la sesión |
| Valores con `=` y comillas | Podían truncarse o guardarse mal | Lectura nativa y serialización verificada |
| Sintaxis inválida | Podía ignorarse silenciosamente | Error antes de cargar o editar |
| `renviron_save()` | Resultado de write_lines | Ruta guardada invisible o NULL al cancelar |

`in_place` sigue siendo **FALSE** tanto en add como en delete. La documentación antigua de delete decía TRUE aunque el código usaba FALSE. Ambas funciones siguen modificando la clave seleccionada de la sesión; `in_place=TRUE` añade persistencia. `confirm=TRUE` requiere una sesión interactiva; en scripts debe indicar `confirm=FALSE`. El paquete no cambia la sesión antes de que el guardado termine.

Una lista obtenida mediante lectura contiene valores resueltos. Guardarla con `renviron_save()` reemplaza el documento y convierte esos valores en literales. Para conservar comentarios y referencias, edite por clave sin suministrar `.renviron`. La edición tampoco recalcula automáticamente las variables dependientes ya cargadas; cargue las claves necesarias después.

La lista de retorno de add/delete conserva los valores leídos antes de editar, salvo la clave modificada. Para obtener nuevamente todos los valores derivados del archivo actualizado, llame a `renviron_read()`.
''', '''
Version 0.6.0 retains the existing public functions and `%>%` operator and adds `renviron_read()`. It changes behaviors that were ambiguous or had side effects. Review these points when updating.

| Topic | 0.5.1 | 0.6.0 |
|---|---|---|
| get/exists/list queries | Could load every file variable into the session | Read only; use `renviron_load()` to load |
| Missing get key | Could return an unrelated Sys.getenv value | Returns `NULL` |
| Empty value | Could be confused with a missing key | The list retains `""`; exists returns TRUE |
| Empty/missing file | `NULL` on several paths | `list()`; list returns `character()` |
| Multiple scopes | Chose only the first through match.arg | Searches for the first existing file in supplied order |
| Project | Depended on the active usethis project | Working directory or explicit `project` |
| Persistent edit | Rewrote all loaded variables | Without a supplied list, preserves other lines |
| Cancelled confirmation | The session could already have changed | Does not apply the session edit |
| Values containing `=` or quotes | Could be truncated or written incorrectly | Native reading and verified serialization |
| Invalid syntax | Could be silently ignored | Error before loading or editing |
| `renviron_save()` | Result from write_lines | Invisible saved path or NULL on cancellation |

`in_place` remains **FALSE** for both add and delete. Previous delete documentation said TRUE although the implementation used FALSE. Both functions still update the selected session key; `in_place=TRUE` adds persistence. `confirm=TRUE` requires interactive R; scripts must pass `confirm=FALSE`. The session is not changed until the write succeeds.

A list returned by reading contains resolved values. Saving it with `renviron_save()` replaces the document and encodes those values literally. To retain comments and references, edit by key without supplying `.renviron`. An edit does not automatically recalculate dependent variables already loaded into the session; load the required keys afterwards.

The list returned by add/delete retains values read before editing, except for the edited key. Call `renviron_read()` again to obtain every derived value from the updated file.
'''),
'deployment': ('Instalación y publicación', 'Installation and publishing', '''
La entrega contiene `renviron_0.6.0.tar.gz`, el binario Windows `renviron_0.6.0.zip`, las fuentes, el sitio bilingüe generado, informes de validación y un manifiesto SHA-256. El binario se verifica en Windows con R 4.5.1. Para otras plataformas use el paquete fuente y ejecute las comprobaciones correspondientes; la matriz de CI queda configurada, pero una validación local no demuestra resultados remotos.

## Instalar

Desde la carpeta extraída ejecute `Rscript install.R ruta/a/biblioteca` en Windows, o añada `source` como segundo argumento para instalar la fuente. El instalador verifica el archivo y las dependencias obligatorias antes de crear la biblioteca. Usa exclusivamente el paquete local. Las dependencias externas se enumeran en `external-dependencies.txt`; deben estar disponibles de antemano. Añada la biblioteca a `.libPaths()` antes de `library(renviron)` y reinicie R si actualiza una versión ya cargada.

También puede usar `install.packages("packages/renviron_0.6.0.tar.gz", repos=NULL, type="source", lib="ruta/a/biblioteca")`. La entrega local no implica que 0.6.0 ya esté disponible en CRAN, GitHub o r-universe.

## Reconstruir y publicar la documentación

El repositorio mantiene README, ayuda de todas las funciones, cuatro guías ejecutables, cambios y traducciones completas. Español se sirve en la raíz e inglés en `en/`. Ambas ediciones tienen búsqueda local y enlaces recíprocos en cada página.

En el workspace ENDOM: ejecute `Rscript renviron/scripts/check-release.R`, `Rscript renviron/scripts/build-docs.R` y `python renviron/scripts/check-sites.py artifacts/renviron-release/sites/r --kind r`. La construcción usa roxygen2, pkgdown, knitr, rmarkdown, desc y jsonlite; la auditoría Python requiere beautifulsoup4. El script `scripts/release.ps1` ejecuta la secuencia completa de validación, documentación e instaladores usando las herramientas indicadas.

Para publicar, sirva el contenido de `site/` como archivos estáticos, manteniendo `en/`, `search.json`, JavaScript y estilos. Si cambia la URL canónica, actualice DESCRIPTION, ambos `_pkgdown.yml`, `scripts/build-docs.R` y la constante `canonical` de `scripts/check-sites.py` antes de reconstruir. El workflow manual de documentación genera un artefacto; no publica automáticamente.

La entrega y sus sumas permiten revisar el resultado antes del despliegue. No incluye archivos `.Renviron` ni `.env` locales, ni realiza una instalación global o publicación remota.
''', '''
The delivery contains `renviron_0.6.0.tar.gz`, the Windows binary `renviron_0.6.0.zip`, source files, the generated bilingual site, validation reports and a SHA-256 manifest. The binary is verified on Windows with R 4.5.1. Use the source package and run the relevant checks on other platforms; a CI matrix is configured, but local validation does not prove remote results.

## Install

From the extracted folder run `Rscript install.R path/to/library` on Windows, or append `source` as the second argument to install from source. The installer verifies the archive and mandatory dependencies before creating the library. It uses the local package only. External dependencies are listed in `external-dependencies.txt` and must already be available. Add the library to `.libPaths()` before `library(renviron)` and restart R when updating an already loaded version.

You can also use `install.packages("packages/renviron_0.6.0.tar.gz", repos=NULL, type="source", lib="path/to/library")`. The local delivery does not imply that 0.6.0 is already available on CRAN, GitHub or r-universe.

## Rebuild and publish documentation

The repository contains the README, help for every function, four executable guides, changelog and complete translations. Spanish is served at the root and English under `en/`. Both editions have local search and reciprocal links on every page.

From the ENDOM workspace run `Rscript renviron/scripts/check-release.R`, `Rscript renviron/scripts/build-docs.R`, and `python renviron/scripts/check-sites.py artifacts/renviron-release/sites/r --kind r`. Building uses roxygen2, pkgdown, knitr, rmarkdown, desc and jsonlite; the Python audit requires beautifulsoup4. `scripts/release.ps1` runs the full validation, documentation and installer sequence with the specified tools.

To publish, serve the contents of `site/` as static files, retaining `en/`, `search.json`, JavaScript and styles. If the canonical URL changes, update DESCRIPTION, both `_pkgdown.yml` files, `scripts/build-docs.R` and the `canonical` constant in `scripts/check-sites.py` before rebuilding. The manual documentation workflow creates an artifact; it does not publish automatically.

The delivery and its checksums make the result reviewable before deployment. It excludes local `.Renviron` and `.env` files and does not install globally or publish remotely.
''')}

examples={
'renviron': '''local({
  withr::local_envvar(c(RNV_DEMO = "parent", RNV_COPY = "parent-copy"))
  path <- tempfile()
  on.exit(unlink(path))
  writeLines(c("# invented configuration", "RNV_DEMO='one=two'",
               "RNV_COPY='${RNV_DEMO}'"), path)
  values <- renviron::renviron_read(.file = path)
  stopifnot(values$RNV_COPY == "one=two", Sys.getenv("RNV_DEMO") == "parent")
  renviron::renviron_add("RNV_DEMO", "updated", .file = path,
                        in_place = TRUE, confirm = FALSE)
  stopifnot(Sys.getenv("RNV_COPY") == "parent-copy")
  renviron::renviron_load(.file = path, .vars = "RNV_COPY")
  stopifnot(Sys.getenv("RNV_COPY") == "updated")
  print(renviron::renviron_list(.file = path))
  renviron::renviron_delete("RNV_DEMO", .file = path,
                           in_place = TRUE, confirm = FALSE)
  stopifnot(!renviron::renviron_exists("RNV_DEMO", .file = path))
})''',
'archivos': '''local({
  path <- tempfile()
  on.exit(unlink(path))
  values <- list(RNV_EQUALS = "a=b==", RNV_LITERAL = "${RNV_EXAMPLE}",
                 RNV_PATH = "C:\\\\folder\\\\", RNV_EMPTY = "")
  renviron::renviron_save(values, .file = path, confirm = FALSE)
  stopifnot(identical(renviron::renviron_read(.file = path), values))
  print(renviron::renviron_list(values))
})''',
'migracion': '''local({
  withr::local_envvar(c(RNV_MIGRATE = "session"))
  path <- tempfile()
  on.exit(unlink(path))
  writeLines("RNV_MIGRATE='file'", path)
  value <- renviron::renviron_get("RNV_MIGRATE", .file = path)
  stopifnot(value == "file", Sys.getenv("RNV_MIGRATE") == "session")
  renviron::renviron_load(.file = path)
  stopifnot(Sys.getenv("RNV_MIGRATE") == "file")
})''',
'deployment': '''stopifnot(packageVersion("renviron") >= "0.6.0")
renviron::renviron_list(list(RNV_INSTALL_CHECK = "invented"))'''
}

for key,(es_title,en_title,es,en) in guides.items():
    for lang,title,body in [('es',es_title,es),('en',en_title,en)]:
        base = root if lang=='es' else root/'pkgdown/i18n/en'
        yaml=f'''---
title: "{title}"
output: rmarkdown::html_vignette
vignette: >
  %\\VignetteIndexEntry{{{title}}}
  %\\VignetteEngine{{knitr::rmarkdown}}
  %\\VignetteEncoding{{UTF-8}}
---
'''
        write(base/'vignettes'/f'{key}.Rmd', yaml+'\n'+body.strip()+'\n\n```{r}\n'+examples[key]+'\n```')

for lang in ['es','en']:
    base=root if lang=='es' else root/'pkgdown/i18n/en'
    spanish=lang=='es'
    text='''# renviron

**0.6.0 — Archivos de entorno con consultas sin efectos sobre la sesión.**

Lea y consulte `.Renviron`, cargue solo las variables necesarias y edite una clave conservando el resto del archivo. El paquete interpreta la sintaxis con el lector nativo de R en un proceso aislado.

```r
library(renviron)
path <- tempfile()
renviron_save(list(RNV_EXAMPLE = "one=two"), .file = path, confirm = FALSE)
renviron_list(.file = path)
# RNV_EXAMPLE
# "*****"
unlink(path)
```

Instale el archivo local `renviron_0.6.0.zip` en Windows o `renviron_0.6.0.tar.gz` desde fuente, con las dependencias declaradas. Consulte la [guía de instalación](articles/deployment.html).

Las [guías de uso](articles/renviron.html), [ámbitos y sintaxis](articles/archivos.html) y [migración desde 0.5.1](articles/migracion.html) explican los contratos y cambios de comportamiento. La [referencia](reference/index.html) cubre todas las funciones.

La entrega local está preparada para publicación. Su existencia no confirma una versión publicada en repositorios remotos. Licencia MIT.
''' if spanish else '''# renviron

**0.6.0 — Environment files with queries that leave your session unchanged.**

Read and query `.Renviron`, load only the variables you need, and edit one key while preserving the rest of the file. The package interprets syntax with the native R reader in an isolated process.

```r
library(renviron)
path <- tempfile()
renviron_save(list(RNV_EXAMPLE = "one=two"), .file = path, confirm = FALSE)
renviron_list(.file = path)
# RNV_EXAMPLE
# "*****"
unlink(path)
```

Install the local `renviron_0.6.0.zip` on Windows or `renviron_0.6.0.tar.gz` from source, with the declared dependencies. See the [installation guide](articles/deployment.html).

The [usage](articles/renviron.html), [scopes and syntax](articles/archivos.html), and [migration from 0.5.1](articles/migracion.html) guides explain the contracts and behavior changes. The [reference](reference/index.html) covers every function.

The local delivery is prepared for publication. Its existence does not confirm a version published in remote repositories. MIT license.
'''
    write(base/'README.md',text)
    if spanish: write(base/'README.Rmd',text)
    changes='''# renviron 0.6.0

* Nueva lectura aislada con renviron_read() y consultas sin modificar la sesión.
* Lectura nativa con filtros, referencias, comillas, Unicode y valores con signos igual.
* Guardado literal compatible con R; edición por clave que conserva otras líneas.
* Confirmación antes de modificar la sesión y reemplazo mediante archivo temporal.
* Resolución de ámbitos en orden, ruta explícita y nombres personalizados.
* Validación de claves, valores y archivos con diagnósticos que omiten valores.
* Pruebas de integración, documentación bilingüe y guía de migración desde 0.5.1.
''' if spanish else '''# renviron 0.6.0

* New isolated renviron_read() and queries that do not change the session.
* Native reading with filters, references, quotes, Unicode and equals signs.
* R-compatible literal writing and single-key editing that preserves other lines.
* Confirmation before session changes and replacement through a temporary file.
* Ordered scope resolution, explicit paths and custom filenames.
* Key, value and file validation with value-free diagnostics.
* Integration tests, bilingual documentation and a migration guide from 0.5.1.
'''
    write(base/'NEWS.md',changes)
    write(base/'_pkgdown.yml',f'''url: https://adatar-do.github.io/renviron/{'en/' if not spanish else ''}
lang: {lang}
home:
  sidebar: false
template:
  bootstrap: 5
  bootswatch: flatly
navbar:
  structure:
    left: [intro, reference, articles, news]
    right: [search, github]
  components:
    intro:
      text: {'Inicio' if spanish else 'Home'}
      href: index.html
articles:
  - title: {'Guías' if spanish else 'Guides'}
    navbar: ~
    contents: [renviron, archivos, migracion, deployment]
''')
write(root/'R/renviron-package.R', '''#' Administración de archivos de entorno para R
#'
#' Lectura aislada, carga selectiva y edición por clave de archivos de entorno.
#' Consulte [renviron_read()] para lectura y [renviron_add()] para edición.
#' @keywords internal
"_PACKAGE"''')
print('Authored four paired executable guides, bilingual homes, changelog and site configuration')
