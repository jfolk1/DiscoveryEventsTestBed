''
' Discovery Events utility class.
'
' @parameter {object} config - Application config.
''

function discoveryEvents(config as object) as object
    m = {
        ''
        ' Tracks Discovery Events
        '
        ' @param {object} args - an object containing an array of events objects
        ''
        trackEvent: function(args = {}) as dynamic
            eventCollection = []
            deviceInfo = createObject("roDeviceInfo")
            for each event in args.events
                ' Create the event payload with case sensitive attributes
                payload = {}
                payload.setModeCaseSensitive()
                payload = event.payload
                payload["clientAttributes"] = m._getClientAttributes()
                payload["productAttributes"] = m._getProductAttributes()
                payload.uuid = deviceInfo.getRandomUUID()

                ' Add the event to the event collection array
                eventCollection.push({
                    type: event.type,
                    version: "v2",
                    sessionId: event.sessionId,
                    sessionTimer: event.sessionTimer,
                    uuid: event.uuid,
                    timestamp: event.timestamp,
                    timeOffset: timeHelper().getTimezoneOffset(),
                    payload: payload
                })
            end for

            ' No events in collection, don't do anything
            if eventCollection.count() = 0 then return invalid

            ' *****************************************************
            ' TODO - From Keith Whitney:
            ' This seems like functionality that we should move elsewhere, in a generic way, so that it can be reused. It could do the following:
            ' 1. Given a HATEOAS link name and URI template parameters, get the HATEOAS link, and expand the URI template with the given parameters.
            ' 2. Based on the method and content type, it can send a request to the APIs.
            ' Let's see if the Eos team is doing something similar. We can make this even more generic (API requests vs. raw requests to any endpoint), and it would be a great pattern to follow.
            eventHateoasLink = getHateoasLink("events", m._config.apiLinks) ' Get the event object from the hateoas links
            eventsUriTemplate = eventHateoasLink.href ' Get the hateoas Events template
            method = lcase(eventHateoasLink.method) ' HTTP method
            contentType = eventHateoasLink.type ' Header content type
            eventsUrl = expandUriTemplate(eventsUriTemplate, {}) ' Get the final URL for posting events

            ' Accept POST and GET request methods
            if method = m._httpRequestMethods.POST or method = m._httpRequestMethods.GET
                ' Send the events with the specified request method to the Events API
                response = api(m._config)[method](eventsUrl, eventCollection, {
                    headers: { "Content-Type": contentType }
                })
            end if
            ' *****************************************************
        end function

        ' ---------------------------------------------------------------------
        ' Private
        ' ---------------------------------------------------------------------
        _config: config,

        _httpRequestMethods: {
            POST: "post",
            GET: "get"
        }

        ''
        ' Returns an object representing client attributes
        '
        ' @returns {object} - client attributes
        ''
        _getClientAttributes: function() as Object
            deviceInfo = createObject("roDeviceInfo")

            ' Let's construct the operating system version
            firmwareVersion = system().getFirmwareVersion()
            osVersion = firmwareVersion.major + "." + firmwareVersion.minor + " build " + firmwareVersion.build

            ' Creates a clientAttributes object that will be included in every event payload
            clientAttributes = {}
            clientAttributes.setModeCaseSensitive()
            clientAttributes["type"] = "settop"
            clientAttributes["id"] = utils().getDeviceId()
            clientAttributes["advertisingId"] = iif(system().isAdTrackingLimited(), invalid, system().getAdvertisingId())
            clientAttributes["limitAdTracking"] = system().isAdTrackingLimited()
            clientAttributes["browser"] = {
                name: "null",
                version: "null",
            }
            clientAttributes["device"] = {
                brand: m._config.platform,
                manufacturer: m._config.platform,
                model: deviceInfo.getModelDisplayName(),
                version: deviceInfo.getModel()
            }
            clientAttributes["os"] = {
                name: m._config.platform,
                version: osVersion
            }

           return clientAttributes
        end function

        ''
        ' Returns an object representing product attributes
        '
        ' @returns {object} - product attributes
        ''
        _getProductAttributes: function() as Object
            ' Creates a productAttributes object that will be included in every event payload
            productAttributes = {}
            productAttributes.setModeCaseSensitive()
            productAttributes["name"] = lcase(m._config.networkCode)
            productAttributes["version"] = utils().getApplicationVersion()
            productAttributes["buildNumber"] = utils().getApplicationBuildNumber()

           return productAttributes
        end function
    }

    return m
end function
