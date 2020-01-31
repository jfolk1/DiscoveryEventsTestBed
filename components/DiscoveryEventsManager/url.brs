''
' Appends query string parameters to the URL.
''
function appendQueryStringParameters(url as string, parameters as object) as string
    if parameters.count()
        url = url + iif(url.instr("?") = -1, "?", "&") + createQueryString(parameters)
    end if

    return url
end function

''
' Creates a query string.
''
function createQueryString(parameters as object) as string
    transport = createObject("roUrlTransfer")

    queryString = ""
    for each key in parameters
        value = iif(parameters[key] <> invalid, parameters[key], "")

        queryString = queryString + transport.escape(key)
        queryString = queryString + "="
        queryString = queryString + transport.escape(toString(value))
        queryString = queryString + "&"
    end for

    return left(queryString, len(queryString) - 1)
end function

''
' Creates object from given query string
''
function createObjectFromQueryString(query as string) as object
    position = instr(0, query, "?")
    if position = -1 or position = len(query) - 1 then return {}
    obj = {}
    fields = mid(query, position + 1, query.len() - position).tokenize("&")
    for each field in fields
        fieldKeyValue = field.tokenize("=")
        obj[fieldKeyValue[0]] = fieldKeyValue[1]
    end for
    return obj
end function

''
' Expands a URI template into a URI
'
' NOTE: This is a hack to expand the simple URI templates that we use in the
'       API responses, and does not conform to RFC6570 (https://tools.ietf.org/html/rfc6570).
''
function expandUriTemplate(uriTemplate as string, vars as object) as string
    uri = uriTemplate

    templateVariableRegex = createObject("roRegex", "{[?&]?(\w+)}", "")
    ' Optional URI template variables contain ? or & within the variable string.
    optionalVariableRegex = createObject("roRegex", "\?|&", "")

    while templateVariableRegex.isMatch(uri)
        match = templateVariableRegex.match(uri)
        completeMatch = match[0]
        templateVariable = match[1]

        isVariableOptional = optionalVariableRegex.isMatch(completeMatch)

        replacement = invalid
        if vars[templateVariable] = invalid
             replacement = ""
        else if not isVariableOptional
            ' {val} => value
            replacement = toString(vars[templateVariable]).encodeURIComponent()
        else
            ' {?val} => ?val=value
            ' {&val} => &val=value
            expansionChar = optionalVariableRegex.match(completeMatch)[0]
            replacement = expansionChar + templateVariable + "=" + toString(vars[templateVariable]).encodeURIComponent()
        end if

        uri = uri.replace(completeMatch, replacement)
    end while

    return uri
end function
