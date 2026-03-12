Scheme library to make https requests. Built with (foreign c) and libcurl.

[Repository](https://git.sr.ht/~retropikzel/foreign-c-requests)

[Issue tracker](https://sr.ht/~retropikzel/foreign-c/trackers)

[Jenkins](https://jenkins.scheme.org/job/foreign_c/job/foreign-c-requests/)

## Caveats

- Not yet working on Mosh
- No cookie reading support yet

## Dependencies

Depends on libcurl, on Debian/Ubuntu:

    apt-get install libcurl4-openssl-dev

or
    apt-get install libcurl4-gnutls-dev


## Documentation



(**request** method url . option ...)

Method is [http method](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Methods)
as a symbol. For example 'GET or 'POST.

Url is the url you want to make request to.

Options are pairs passed in after other arguments, for example:

    (define url "https://snow-fort.org/s/gmail.com/nma.arvydas.silanskas/arvyy/mustache/1.0.2/arvyy-mustache-1.0.2.tgz")
    (request 'GET url '(download-path . "/tmp/arvyy-mustache-1.0.2.tgz"))

Options:

- download-path
    - Downloads the response of request to given path
    - If this is not given temporary file is used and deleted after
- headers
    - An association list of headers
- body
    - Request body as a string
    - Example: (define response
                       (request 'POST
                                "http://echo-http-requests.appspot.com/echo"
                                '(body . "Hello world")))



(**response-status-code** response)

Returns the HTTP status code of the response.



(**response-text** response)

Returns the content of the response as text.



(**response-bytes** response)

Returns the content of the response as bytes.



(**response-headers** response)

Returns the response headers as an association list.
Header names are downcased symbols.
