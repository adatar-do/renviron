# renviron

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
