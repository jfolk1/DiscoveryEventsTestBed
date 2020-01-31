function utils() as object
    this = {
        getApplicationVersion: function() as dynamic
            return createObject("roAppInfo").getVersion()
        end function

        getApplicationBuildNumber: function() as dynamic
            return createObject("roAppInfo").getValue("build_version")
        end function

        getDeviceId: function() as dynamic
            return createObject("roDeviceInfo").GetChannelClientId()
        end function
    }

    return this
end function
