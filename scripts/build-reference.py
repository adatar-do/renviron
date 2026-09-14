from pathlib import Path
import json
root=Path(__file__).resolve().parents[2]
source=json.loads((root/'artifacts/renviron-release/reference.json').read_text(encoding='utf-8'))
def arr(x): return x if isinstance(x,list) else [x]
def field(n,s): return '\\'+n+'{'+s+'}\n'
def esc(s): return s.replace('\\','\\\\').replace('%','\\%')

entries={
'renviron_read': ('Read variables without changing the session',
 'Parse an environment file using the native R reader in an isolated process. References are resolved in file order using the inherited session environment. No startup profiles are executed and no parent variables are changed.',
 'A named list, invisibly. Missing and empty files return list(). Invalid assignments stop with a line number and no value in the diagnostic.'),
'renviron_load': ('Load variables into the current session',
 'Read and validate the entire file before changing the session. Set only the selected keys; leave other session variables unchanged.',
 'The named list of loaded values, invisibly.'),
'renviron_get': ('Retrieve one variable value',
 'Query only the file or supplied list. Does not load variables or fall back to unrelated values from the current session.',
 'A character value, including an empty string; NULL if the key is absent.'),
'renviron_exists': ('Check whether a variable is declared',
 'Check key presence, including a declared empty value, without modifying the session.', 'TRUE or FALSE.'),
'renviron_list': ('List names with masked values',
 'Return only names and a constant mask without loading session variables. The mask reveals neither value contents nor length. It is not encryption.',
 'A named character vector containing ***** for each variable, or character() if there are no variables.'),
'renviron_add': ('Add or update one variable',
 'Update only the selected session key. When persistence is requested, write first. Cancellation or a write failure leaves the session unchanged.',
 'The modified named list, invisibly, or the original list if cancelled.'),
'renviron_delete': ('Delete one session variable and optionally its file assignment',
 'Remove only the selected key. Editing, line preservation and cancellation follow renviron_add().',
 'The remaining named list, invisibly, or the original list if cancelled.'),
'renviron_save': ('Save a complete set of variables',
 'Replace the entire file with R-compatible literal values after validating all input. Prepare a temporary file in the same directory and replace the destination, retaining existing file permissions. Does not change the current session.',
 'The saved path, invisibly, or NULL if cancelled.'),
'renviron_unset_all': ('Unset selected keys declared in a file',
 'Read without loading and unset only the resulting keys in the current session. Does not modify the file or unrelated environment variables.',
 'NULL, invisibly.'),
'renviron_path': ('Resolve the configuration file path',
 'Search scopes in the supplied order without merging files or changing the active project. Project scope defaults to the current working directory.',
 'An absolute path. If no file exists, return the first candidate path so a file can be created.'),
'scoped_path_r': ('Construct a path in a single scope',
 'Compatibility helper for one scope. Use renviron_path() to search multiple scopes. Does not activate or change a project.',
 'An absolute path.'),
'renviron-package': ('Environment file management for R',
 'Isolated reading, selective loading and single-key editing of environment files. Start with renviron_read() and renviron_add().', ''),
'%>%': ('Pipe operator', 'Pipe operator re-exported from magrittr.', '')}

params={
'scope':'Scopes to search in order: user and project. The default order is user, then project. scoped_path_r() accepts a single scope and defaults to user.',
'.file':'A filename relative to the selected scope, or an explicit absolute path.',
'.vars':'Keys to return or load; NULL selects all. References are resolved against the full file before filtering.',
'verbosity':'0 suppresses the missing-file message; 1 shows it.',
'...':'Arguments for renviron_path() in writers, or renviron_read() in queries/unset_all. Path functions reject unknown arguments. In scoped_path_r(), these are path components.',
'project':'Project directory, default getwd(). No project-root autodetection is performed.',
'user':'User directory, default the R home directory. Supplying it explicitly disables the R_ENVIRON_USER override in renviron_path().',
'envvar':'Optional environment variable that overrides the user-scoped path.',
'key':'One portable environment variable name.',
'value':'One character value, without NA or line breaks. Empty strings are allowed.',
'.renviron':'A named list or named character vector. NULL reads the selected file. When supplied to a persistent editor, the modified list replaces the whole file.',
'.Renviron':'A named list or named character vector of scalar character values without NA or line breaks. list() creates an empty file.',
'in_place':'Also save the file. The default is FALSE. Add/delete still modify the selected session key.',
'confirm':'Request interactive confirmation before writing. Scripts must explicitly pass FALSE. Cancellation leaves the file and session unchanged.'}

native='''Reading supports quotes, equals signs, UTF-8, full-line comments and native R variable references with defaults. The optional export prefix is accepted as an extension. Bare KEY= is ignored; quoted empty values retain a declared key and an empty string in the returned list. Windows may represent empty process variables as unset. An unquoted expansion producing an empty value may be ignored by R and preserve an inherited value. A trailing hash belongs to the value. Reads start a separate R process with --vanilla and a 60-second timeout; reuse a returned list when querying many keys. Values are resolved, not raw file expressions.'''
editing='''Without a supplied list, persistent add/delete edits only the selected key, removes its duplicate assignments, and retains other comments, blank lines and expressions. Line endings are normalized to LF and UTF-8. With a supplied list, the modified list replaces the whole document. Other dependent session variables are not recalculated. The returned list retains pre-edit resolved values except for the edited key; read again for recalculated file values.'''
writing='''Input values are literal, including dollar-brace expressions. Names must be portable identifiers. NUL bytes, invalid UTF-8, multiline values and encoded lines over 99900 bytes are rejected. The destination directory must exist and symbolic links are not accepted as write targets. New files use mode 0600 where supported; inherited Windows ACLs also apply. Existing permissions are retained. Snapshot checks detect intervening changes but do not provide a lock between concurrent writers. Coordinate one writer per file.'''
paths='''An absolute .file takes precedence. Otherwise the first existing file in scope order is selected; no files are merged. If none exists, the first candidate is returned. R_ENVIRON_USER only redirects the default .Renviron in user scope when user is omitted. Custom filenames are not redirected. Use scope = c("project", "user") to prefer project files. Project scope means getwd() or the supplied project directory.'''

out=root/'renviron/pkgdown/i18n/en/man';out.mkdir(parents=True,exist_ok=True)
for filename,d in source['docs'].items():
    aliases=arr(d.get('alias',[]));name=next((n for n in aliases if n in source['api']),d['name'])
    title,description,value=entries[name]
    text=field('name',esc(d['name']))+''.join(field('alias',esc(n)) for n in aliases)+field('title',title)
    if 'usage' in d: text+=field('usage',d['usage'])
    if name in source['api']:
        names=arr(source['api'][name]['parameters'])
        text+=field('arguments','\n'+''.join('\\item{'+n+'}{'+params[n]+'}\n' for n in names))
    if value:text+=field('value',value)
    text+=field('description',description)
    details=[]
    if name in ('renviron_read','renviron_load','renviron_get','renviron_exists','renviron_list','renviron_unset_all'):details.append(native)
    if name in ('renviron_add','renviron_delete'):details.append(editing)
    if name in ('renviron_add','renviron_delete','renviron_save'):details.append(writing)
    if name in ('renviron_path','scoped_path_r'):details.append(paths)
    if details:text+=field('details','\n\n'.join(details))
    if 'examples' in d:text+=field('examples',d['examples'])
    (out/filename).write_text(text,encoding='utf-8')
print(f'Generated complete English help for {len(source["api"])} functions and package/pipe topics')
