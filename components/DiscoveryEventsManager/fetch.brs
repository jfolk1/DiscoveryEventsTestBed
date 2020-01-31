''
' Performs an HTTP request to `url`.
'
' @param {string} url - Request URL.
' @param {object} [options]
' @param {string} [options.method] - Request method.
' @param {object} [options.headers] - Request headers.
' @param {object} [options.data] - Request data.
' @param {integer} [options.timeout] - Request timeout.
' @param {integer} [options.maxRetries] - Maximum number of retries in case of failures.
' @param {integer} [options.initialRetryDelay] - Initial time to wait between retries.
' @param {integer} [options.maxRetryDelay] - Maximum time to wait between retries.
'
' @returns {dynamic} - response object or invalid on failure
' @returns {boolean} response.ok - Represents success or failure.
' @returns {integer} response.status - Response status code.
' @returns {string} response.statusText - Response status description.
' @returns {object} response.headers - Response headers.
' @returns {object} response.body - Response body as JSON.
''
function fetch(url as string, options = {}) as dynamic
    defaultOptions = {
        method: "GET",
        timeout: 60000,
        maxRetries: 5,
        initialRetryDelay: 1000,
        maxRetryDelay: 5000,
        headers: {
            "Accept": "application/json",
            "Content-Type": "application/json"
        },
        data: {}
    }

    options = extend(defaultOptions, options)

    ''
    ' Requests the URL.
    ''
    m.request = function(url, options) as dynamic
        log().debug("Fetch: "+ url)
        http = createObject("roUrlTransfer")
        http.setMessagePort(createObject("roMessagePort"))

        ' Pipes in URLs cause Roku's version of curl to return an error, so we need to manually escape them.
        ' Note that there are a few API URLs that use pipes.
        url = url.replace("|", http.escape("|"))
        http.setUrl(url)

        http.setHeaders(options.headers)
        http.enableEncodings(true)                              ' Accept gzipped payloads
        http.setCertificatesFile("common:/certs/ca-bundle.crt") ' HTTPS!
        http.retainBodyOnError(true)                            ' Return the body of the response even if the HTTP status code indicates that an error

        if options.method = "GET"
            wasRequestSent = http.asyncGetToString()
        else if options.method = "POST" or options.method = "PUT" or options.method = "DELETE"
            if options.headers["Content-Type"] = "application/json"
                body = formatJson(options.data)
            else if options.headers["Content-Type"] = "application/x-www-form-urlencoded"
                body = createQueryString(options.data)
            end if

            ' For QA to debug
            log().debug("Body: " + body)

            http.setRequest(options.method)
            wasRequestSent = http.asyncPostFromString(body)
        end if

        if wasRequestSent
            event = wait(options.timeout, http.getPort())
            if type(event) = "roUrlEvent"
                response = {
                    ok: 200 <= event.getResponseCode() and event.getResponseCode() < 300,
                    status: event.getResponseCode(),
                    statusText: event.getFailureReason(),
                    headers: event.getResponseHeaders(),
                    body: {
                        text: event.getString(),
                        json: invalid
                    }
                }

                ' Response error.
                if response.status < 0 then
                    log().error("HTTP request error:" + response.statusText)
                    http.asyncCancel()
                    return invalid
                end if

                'In some cases Content-Type may be "application/json; charset=utf-8" (or other?)
                'so we try to define exactly "application/json"
                isContentTypeJson = Instr(1, response.headers["Content-Type"], "application/json") <> 0
                if isContentTypeJson and event.getString() <> ""
                    response.body.json = parseJson(event.getString())
                end if

                return response
            else if event = invalid
                ' Request timed out.
                http.asyncCancel()

                return invalid
            end if
        end if
    end function

    ''
    ' Requests the URL and retries on timeouts and 5xx status codes.
    ''
    m.requestWithRetry = function(url, options, numRetries = 0)
        response  = m.request(url, options)
        log().debug(response)
        
        shouldRetry = false
        if response = invalid
            shouldRetry = true
            log().info("Network request timed out.")
        else if response.status >= 500
            shouldRetry = true
            log().info("Network request received " + response.status.toStr())
        end if

        if shouldRetry and numRetries < options.maxRetries
            numRetries = numRetries + 1
            delay = math().min(2 ^ numRetries * options.initialRetryDelay, options.maxRetryDelay)

            log().info("Retrying network request in " + (delay / 1000).toStr() + " seconds.")

            sleep(delay)
            return m.requestWithRetry(url, options, numRetries)
        else
            return response
        end if
    end function

    return m.requestWithRetry(url, options)
end function
