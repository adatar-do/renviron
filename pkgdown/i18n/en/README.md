# renviron

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
