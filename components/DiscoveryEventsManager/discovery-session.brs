' Utility object for storing session info
' 
' Session info includes: 
'   - sessionId
'   - createdAt timestamp
'   - lastActive timestamp (when last event was sent)
function discoverySession() as object
    return {
        SESSION_TIMEOUT: 1800, ' 30 mins in secs

        ' Gets the active session. If no active session, create one
        getActiveSession: function() as object
            if m._shouldCreateSession()
                sessionId = m._generateId()
                timestamp = timeHelper().getRFC3339Timestamp()
                m.createSession(sessionId, timestamp)
            end if

            return {
                sessionId: m._getSessionId(),
                createdAt: m._getCreatedAt(),
                lastActive: m._getLastActive()
            }
        end function

        ' Calculate and return the sessionTimer in milliseconds
        ' Only works if active session exists
        getSessionTimer: function(timestamp = invalid) as float
            sessionTimer = 0

            createdAt = m._getCreatedAt()
            if createdAt <> invalid
                currentDt = createObject("roDateTime")

                if timestamp <> invalid and type(timestamp) = "String"
                    timestampRegexString = "\d{4}-\d{2}-\d{2}T\d{2}\:\d{2}\:\d{2}\.\d{2,}Z"
                    ' should capture "2019-12-17T19:36:26.72Z" or "2019-12-17T19:36:26.7230Z"

                    timestampRegex = createObject("roRegex", timestampRegexString, "")

                    match = timestampRegex.isMatch(timestamp)
                    if match then currentDt.fromISO8601String(timestamp)
                end if

                createdAtDt = createObject("roDateTime")
                createdAtDt.fromISO8601String(createdAt)

                currentMilliseconds = (currentDt.asSeconds() * 1000) + currentDt.getMilliseconds()
                createdAtMilliseconds = (createdAtDt.asSeconds() * 1000) + createdAtDt.getMilliseconds()

                sessionTimer = currentMilliseconds - createdAtMilliseconds
            end if

            return sessionTimer
        end function

        createSession: function(id as string, timestamp as string) as void
            registry().write(m._sessionIdKey, id, m._registrySection)
            registry().write(m._createdAtKey, timestamp, m._registrySection)
            registry().write(m._lastActiveKey, timestamp, m._registrySection)
        end function

        updateLastActive: function(timestamp as string) as void
            registry().write(m._lastActiveKey, timestamp, m._registrySection)
        end function

        ' Note: no used at the moment but might need it for cleanup in the future
        delete: function() as void
            registry().deleteSection(m._registrySection)
        end function

        ' -----------------------------------
        ' Private
        ' -----------------------------------
        _sessionIdKey: "sessionId",
        _createdAtKey: "createdAt",
        _lastActiveKey: "lastActiveTime",
        _registrySection: "discovery-session",

        _generateId: function() as string
            di = createObject("roDeviceInfo")
            return di.getRandomUUID()
        end function

        _shouldCreateSession: function() as boolean
            sessionId = m._getSessionId()
            lastActive = m._getLastActive()

            if sessionId = invalid then return true

            ' check if time since last activity is past timeout limit
            if lastActive <> invalid
                currentDt = createObject("roDateTime")

                lastActiveDt = createObject("roDateTime")
                lastActiveDt.fromISO8601String(lastActive)

                if (currentDt.asSeconds() - lastActiveDt.asSeconds()) > m.SESSION_TIMEOUT then return true
            end if

            return false
        end function

        _getSessionId: function() as object
            return registry().read(m._sessionIdKey, m._registrySection)
        end function

        _getCreatedAt: function() as object
            return registry().read(m._createdAtKey, m._registrySection)
        end function

        _getLastActive: function() as object
            return registry().read(m._lastActiveKey, m._registrySection)
        end function
    }
end function