''
' Returns an object containing logging utility functions.
''
function log()
    this = {
        ''
        ' Logs a debug message.
        ''
        debug: function(msg as dynamic)
            m._log("debug", msg)
        end function

        ''
        ' Logs an info message.
        ''
        info: function(msg as dynamic)
            m._log("info", msg)
        end function

        ''
        ' Logs a warning message.
        ''
        warn: function(msg as dynamic)
            m._log("warn", msg)
        end function

        ''
        ' Logs an error message.
        ''
        error: function(msg as dynamic)
            m._log("error", msg)
        end function


        ' ----------------------------------------------------------------------
        ' Private
        ' ----------------------------------------------------------------------

        _levels: {
            "debug": 0
            "info": 1
            "warn": 2
            "error": 3
        }

        _log: function(flag as string, msg as dynamic)
            level = "debug"

            if m._levels[flag] >= m._levels[level]
                msg = toString(msg)
                if msg.len() > 1000 then
                    print "> [" + flag + "]" tab(10) mid(msg, 0, 1000) + " ..." + chr(10)
                else
                    print "> [" + flag + "]" tab(10) msg + chr(10)
                end if
            end if
        end function
    }

    return this
end function
