opam pin add --no-action ojwidgets .
opam pin add --no-action ojquery https://github.com/ocsigen/ojquery.git#master
opam install --deps-only ojwidgets
opam install --verbose ojwidgets
opam remove --verbose ojwidgets
