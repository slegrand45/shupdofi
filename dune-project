(lang dune 3.7)

(name shupdofi)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Stéphane Legrand <slegrand45@gmail.com>")

(maintainers "Stéphane Legrand <slegrand45@gmail.com>")

(license AGPL)

(documentation https://url/to/documentation)

(implicit_transitive_deps false)

(package
 (name shupdofi)
 (synopsis "SHare UPload DOwnload FIles")
 (description "A web application to upload/download files with user rights management")
 (depends ocaml dune yojson tiny_httpd ojs)
 (tags
  (topics "to describe" your project)))
