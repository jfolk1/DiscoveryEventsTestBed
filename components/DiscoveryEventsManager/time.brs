function timeHelper() as object
    this = {

        ''
        ' Returns a unix timestamp in seconds
        '
        ''
        getTimeStamp: function() as Dynamic
            return CreateObject("roDateTime").asSeconds()
        end function

        ''
        ' Returns a unix timestamp in milliseconds
        '
        ''
        getTimeStampInMillisecs: function() as Dynamic
            timestamp& = CreateObject("roDateTime").asSeconds()
            return timestamp& * 1000
        end function

        ''
        ' Convert a unix time in seconds to an ISO 8601 representation 
        ' of the date/time value, e.g. "2018-01-24T12:07:16Z"
        '
        ''
        timeToISOString: function(seconds as Integer) as String
            time = CreateObject("roDateTime")
            time.FromSeconds(seconds)
            return time.toISOString()
        end function

        ''
        ' Return an ISO 8601 representation of the date/time value
        '
        ''
        getTimeStampISOString: function() as Dynamic
            return CreateObject("roDateTime").toISOString()
        end function

        ''
        ' Return the date/time value in RFC 3339 format
        '
        ' RFC 3339 example: 2017-09-18T01:33:39.402805942Z
        ''
        getRFC3339Timestamp: function() as string
            datetime = createObject("roDateTime")
            isoTimestamp = datetime.toISOString()

            ' regex for finding seconds
            regex = createObject("roRegex", "(\d{2}Z)", "")
            if regex.isMatch(isoTimestamp)
                secondsString = datetime.getSeconds().toStr()
                if len(secondsString) = 1 then secondsString = "0" + secondsString

                rfcMilliseconds = datetime.getMilliseconds().toStr()
                if len(rfcMilliseconds) = 1
                    rfcMilliseconds = "00" + rfcMilliseconds
                else if len(rfcMilliseconds) = 2
                    rfcMilliseconds = "0" + rfcMilliseconds
                end if

                rfcSeconds = secondsString + "." + rfcMilliseconds + "Z"
                rfcTimestamp = regex.replace(isoTimestamp, rfcSeconds)

                return rfcTimestamp
            end if

            ' Return ISO 8601 by default if no match
            return isoTimestamp
        end function

        ' Returns the timezone offset from UTC time in minutes
        getTimezoneOffset: function() as float
            ' Calculate manually instead of using getTimeZoneOffset() from ifDateTime
            ' getTimeZoneOffset() returns offset as absolute value even if the offset should be negative. i.e. EST returns 240 instead of -240
            utcDt = createObject("roDateTime")

            localDt = createObject("roDateTime")
            localDt.toLocalTime()

            return cint((localDt.asSeconds() - utcDt.asSeconds()) / 60)
        end function
    }

    return this
end function
