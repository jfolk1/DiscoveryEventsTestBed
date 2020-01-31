function discoveryEventsHelper() as object
    m = {
        ''
        ' Collects and authentication object to be used as a payload for Discovery events
        '
        ' @return {object} event - an object representation of the login event
        ''
        getDiscoveryAuthenticationEvent: function(action as string, affiliateId) as Object
            data = {}
            data.setModeCaseSensitive()
            data["affiliateId"] = affiliateId
            data["action"] = action

            event = {
                type: constants().DISCOVERY_EVENTS.AUTHENTICATION.TYPE,
                payload: data
            }

            return event
        end function

        ''
        ' Collects a session object to be used as a payload for Discovery events
        '
        ' @return {object} event - an object representation of the session event
        ''
        getDiscoverySessionEvent: function(data as object) as object
            payload = {}
            payload.setModeCaseSensitive()
            payload["action"] = data.action

            if data.startType <> invalid then payload["startType"] = data.startType
            if data.appLoadTime <> invalid then payload["appLoadTime"] = data.appLoadTime

            event = {
                type: constants().DISCOVERY_EVENTS.SESSION.TYPE,
                payload: payload
            }

            return event
        end function
    }

    return m
end function