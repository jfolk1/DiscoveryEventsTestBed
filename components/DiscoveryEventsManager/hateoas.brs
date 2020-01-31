''
' Returns a relationship link from a set of HATEOAS links.
''
function getHateoasLink(rel as string, links as object) as dynamic
    for each link in links
        if rel = link.rel
            return link
        end if
    end for

    return invalid
end function

''
' Returns HTTP request methods
''
function httpRequestMethods() as object
    return {
        POST: "post",
        PUT: "put",
        GET: "get"
    }
end function

''
' Create request object from given hateoasLink and parameters.
''
function createRequest(hateoasLink as object, parameters = {} as object)
    requestUrl = expandUriTemplate(hateoasLink.href, parameters)

    urlParts = requestUrl.tokenize("?")
    queryStringParameters = createObjectFromQueryString(urlParts[1])
    unusedParameters = {}
    for each parameter in parameters
        if queryStringParameters[parameter] = invalid then unusedParameters[parameter] = parameters[parameter]
    end for

    hasUnusedParameters = unusedParameters.count() > 0
    requestBody = ""
    requestMethods = httpRequestMethods()
    if hasUnusedParameters and (hateoasLink.method <> invalid and (hateoasLink.method = requestMethods.POST or hateoasLink.method = requestMethods.PUT))
        ' Add unused parameters to the request body.
        requestBody = createQueryString(unusedParameters)
    else if hasUnusedParameters
        ' Add unused parameters to the query string.
        requestUrl = urlParts[0] + "?" + createQueryString(queryStringParameters) + "&" + createQueryString(unusedParameters)
    end if

    request = {
        url: requestUrl,
        method: iif(hateoasLink.method <> invalid, hateoasLink.method, requestMethods.GET)
        headers: {
            "Accept": "application/json",
            "Content-Type": iif(hateoasLink.contentType <> invalid, hateoasLink.contentType, "application/json"),
        },
        body: requestBody
    }

    return request
end function

' Parses links from an API response.
'
' @param {string} linksStr - Value from the "Link" response header.
''
function parseLinks(linksStr as string)
    links = {}
    for each linkStr in linksStr.tokenize(",")
        linkParts = linkStr.tokenize(";")

        url = linkParts[0]
        url = createobject("roRegex", "<|>", "").replaceAll(url, "")

        rel = linkParts[1]
        rel = createObject("roRegex", "rel=" + chr(34) + "(.*)" + chr(34), "").match(rel)[1]

        links[rel] = iif(url.len() > 0, url, invalid)
    end for

    return links
end function
