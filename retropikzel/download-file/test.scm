(test-begin "download-file")

(define tmpfile "/tmp/download-file-test-file.json")
(when (file-exists? tmpfile) (delete-file tmpfile))
(download-file "https://microsoftedge.github.io/Demos/json-dummy-data/64KB.json"
               tmpfile)
(test-assert (file-exists? tmpfile))

(test-end "download-file")

