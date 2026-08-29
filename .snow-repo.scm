(repository
  (package
    (git
      (hash "a417c9aec13dd81474373dc71cf50431c7dbbf4f")
      (url "https://codeberg.org/retropikzel/foreign-c-libraries.git"))
    (authors "Retropikzel")
    (version "1.1.6")
    (library
      (name
        (retropikzel system))
      (path "retropikzel/system.sld")
      (foreign-depends)
      (depends
        (scheme base)
        (scheme write)
        (scheme process-context)
        (foreign c)))
    (manual "retropikzel/system/README.md")
    (description "Execute a shell command.")
    (test "retropikzel/system/test.scm")
    (test-depends
      (scheme base)
      (scheme write)
      (scheme file)
      (retropikzel system)
      (retropikzel tap)
      (srfi 64))
    (updated "2026-08-29T16:47:57+00:00")))
