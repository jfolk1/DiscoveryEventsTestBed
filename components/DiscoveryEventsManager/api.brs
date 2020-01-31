''
' Returns an object containing API utility functions.
'
' @parameter {object} appConfig - Application config.
''
function api(appConfig as object) as object
    this = {
        ''
        ' Performs a GET request to the API.
        '
        ' @param {string} url - Request URL.
        ' @param {boolean} [isRetry] - Represents that the request is being retried.
        '
        ' @returns {dynamic} - response object or invalid on failure
        '
        get: function(url, isRetry = false) as dynamic
            return m._request(url, {}, {}, isRetry)
        end function

        ''
        ' Performs a POST request to the API.
        '
        ' @param {string} url - Request URL.
        ' @param {object} [data] - Request data.
        ' @param {boolean} [isRetry] - Represents that the request is being retried.
        '
        ' @returns {dynamic} - response object or invalid on failure
        '
        post: function(url, data = {}, options = {}, isRetry = false)
            options.httpMethod = "POST"
            return m._request(url, data, options, isRetry)
        end function

        ''
        ' Performs a PUT request to the API.
        '
        ' @param {string} url - Request URL.
        ' @param {object} [data] - Request data.
        ' @param {boolean} [isRetry] - Represents that the request is being retried.
        '
        ' @returns {dynamic} - response object or invalid on failure
        '
        put: function(url, data = {}, options = {}, isRetry = false)
            options.httpMethod = "PUT"
            return m._request(url, data, options, isRetry)
        end function

        ''
        ' Performs a DELETE request to the API.
        '
        ' @param {string} url - Request URL.
        ' @param {object} [data] - Request data.
        ' @param {boolean} [isRetry] - Represents that the request is being retried.
        '
        ' @returns {dynamic} - response object or invalid on failure
        '
        delete: function(url, data = {}, options = {}, isRetry = false)
            options.httpMethod = "DELETE"
            return m._request(url, data, options, isRetry)
        end function

        ' ---------------------------------------------------------------------
        ' Private
        ' ---------------------------------------------------------------------

        ''
        ' Performs a request to the API.
        '
        ' @param {string} url - Request URL.
        ' @param {object} [data] - Request data.
        ' @param {object} [options] - Request options.
        ' @param {boolean} [isRetry] - Represents that the request is being retried.
        ' @param {string} [httpMethod] - http method.
        '
        ' @returns {dynamic} - response object or invalid on failure
        '
        _request: function(url, data = {}, options = {}, isRetry = false) as dynamic
            if options.httpMethod = invalid
                options.httpMethod = "GET"
            end if

            contentType = "application/json"

            if options.httpMethod = "POST"
                contentType = "application/x-www-form-urlencoded"
            end if

            if options.headers <> invalid and options.headers["Content-Type"] <> invalid
                contentType = options.headers["Content-Type"]
            end if

            response = fetch(url, {
                method: options.httpMethod,
                data: data,
                headers: {
                    "Authorization": "Bearer " + auth(m._appConfig).getAccessToken(isRetry).getToken(),
                    "Content-Type": contentType
                }
            })

            if response = invalid
                return invalid
            end if

            if response.ok
                return response
            else if response.status = 401 and not isRetry
                return m._request(url, data, options, true)
            end if
        end function

        _appConfig: appConfig
    }

    return this
end function
