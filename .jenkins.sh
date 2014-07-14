
opam pin add --no-action ojwidgets .
opam pin add --no-action ojquery https://github.com/ocsigen/ojquery.git#master
opam install --deps-only ojwidgets
opam install --verbose ojwidgets

do_build_doc () {
  make wikidoc
  cp -Rf _build/ojwidgets-api.wikidocdir/*.wiki ${API_DIR}
  cp -Rf doc/manual-wiki/*.wiki ${MANUAL_SRC_DIR}/
}

do_remove () {
  opam remove --verbose ojwidgets
}
