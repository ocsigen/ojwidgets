opam pin ojwidgets .
opam pin ojquery https://github.com/ocsigen/ojquery.git#jenkins
opam install --deps-only ojwidgets
opam install --verbose ojwidgets
opam remove --verbose ojwidgets
