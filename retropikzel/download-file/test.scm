(test-begin "download-file")

(define tmpfile "/tmp/download-file-test-file.json")
(when (file-exists? tmpfile) (delete-file tmpfile))
(download-file "https://microsoftedge.github.io/Demos/json-dummy-data/64KB.json"
               tmpfile)
(test-assert (file-exists? tmpfile))

(download-file "https://microsoftedge.github.io/Demos/json-dummy-data/64KB.json")
(test-assert (file-exists? "64KB.json"))

(test-end "download-file")

