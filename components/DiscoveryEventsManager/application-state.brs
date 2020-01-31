''
' Application state checker
''
function applicationState()

    m = {
        ''
        ' Returns if the application was previously launched or not.
        '
        ' @returns {boolean} - whether the application was previously launched
        ''
        isFirstLaunch: function() as boolean
            firstStartInRegistry = registry().read(constants().DISCOVERY_EVENTS.SESSION.ACTIONS.FIRSTSTART, m._registrySection)
            return firstStartInRegistry = invalid
        end function

        ''
        ' Records the first launch of the app
        ''
        recordFirstLaunch: function() as void
            registry().write(constants().DISCOVERY_EVENTS.SESSION.ACTIONS.FIRSTSTART, "true", m._registrySection)
        end function

        ' ----------------------------------------------------------------------
        ' Private
        ' ----------------------------------------------------------------------
        _registrySection: "application-state"
    }

    return m
end function