function system() as object
    m = {
        ''
        ' Roku low end models based on the following list
        ' https://en.wikipedia.org/wiki/Roku
        ' Criteria: Anything that has a 600 MHz processor (or slower) and contains 256 MB of RAM or less
        ''
        rokuLowEndModels: {
            ' First generation models
            ROKU_DVP: "N1000",
            ROKU_SD: "N1050",
            ROKU_HD_1: "N1100",
            ROKU_HD_XR: "n1101",
            ROKU_HD_2: "2000C",
            ROKU_XD: "2050X",
            ROKU_XDS: "2100X",

            ' second generation models
            ROKU_LT_1: "2400X",
            ROKU_LT_2: "2450X",
            ROKU_HD_3: "2500X",
            ROKU_2_HD: "3000X",
            ROKU_2_XD: "3050X",
            ROKU_2_XS: "3100X",
            ROKU_STREAMING_STICK_MHL_1: "3400X",
            ROKU_STREAMING_STICK_MHL_2: "3420X",

            ' third generation models
            ROKU_LT_3: "2700X",
            ROKU_1_SE: "2710X",
            ROKU_2: "2720X"
        },

        ''
        ' Get the display resolution
        ''
        getDisplaySize: function() as dynamic
            return createObject("roDeviceInfo").getDisplaySize()
        end function

        ''
        ' Returns the application version from the manifest
        ''
        getApplicationVersion: function() as dynamic
            appInfo = createObject("roAppInfo")
            return appInfo.getVersion()
        end function

        ''
        ' Returns the application id from the manifest
        '
        ''
        getApplicationId: function() as dynamic
            appInfo = createObject("roAppInfo")
            return appInfo.GetId()
        end function

        ''
        ' Returns a unique id for this roku device
        ''
        getDeviceId: function() as dynamic
            di = CreateObject("roDeviceInfo")
            return di.getChannelClientId()
        end function

        ' ''
        ' Returns the connection type
        ' ''
        getConnectionType: function() as Dynamic
            di = CreateObject("roDeviceInfo")
            return di.getConnectionType()
        end function

        ''
        ' Returns a random UUID
        ''
        getRandomUUID: function() as Dynamic
            di = createObject("roDeviceInfo")
            return di.getRandomUUID()
        end function

        ''
        ' Returns the model display name
        ''
        getModelDisplayName: function() as Dynamic
            di = createObject("roDeviceInfo")
            return di.getModelDisplayName()
        end function

        ''
        ' Returns the device model
        ''
        getModel: function() as Dynamic
            di = createObject("roDeviceInfo")
            return di.getModel()
        end function

        ''
        ' Gets the device's advertising ID
        '
        ' @returns {dynamic} - advertising ID or invalid
        ''
        getAdvertisingId: function() as dynamic
            deviceInfo = createObject("roDeviceInfo")
            return deviceInfo.GetRIDA()
        end function

        ''
        ' Returns device model
        '
        ''
        getDeviceModel: function() as dynamic
            deviceInfo = createObject("roDeviceInfo")
            return deviceInfo.getModel()
        end function

        ''
        ' Detects if the current device if a Roku low end model
        '
        ' @return {boolean} - true if it's a low end device, false if it's not
        ''
        isDeviceLowEndModel: function() as boolean
            deviceInfo = createObject("roDeviceInfo")
            model = deviceInfo.getModel()

            found = false
            for each model in m.rokuLowEndModels
                if lcase(deviceInfo.getModel()) = lcase(m.rokuLowEndModels[model])
                    found = true
                    exit for
                end if
            end for

            return found
        end function

        ''
        ' Returns the different parts that encompass the Roku OS version: major, minor and build
        '
        ' @return {string} [object.major] - major part of the version
        ' @return {string} [object.minor] - minor part of the version
        ' @return {string} [object.build] - build part of the version
        ''
        getFirmwareVersion: function() as object
            deviceInfo = createObject("roDeviceInfo")
            fwVersion = deviceInfo.getVersion()

            return {
                major: mid(fwVersion, 3, 1)
                minor: mid(fwVersion, 5, 2)
                build: mid(fwVersion, 8, 5)
            }
        end function

        ''
        ' Returns if the user has disabled ad tracking at the system level
        '
        ' @return {boolean} true if the user has disabled ad tracking, false otherwise
        ''
        isAdTrackingLimited: function() as object
            deviceInfo = createObject("roDeviceInfo")
            return deviceInfo.isRIDADisabled()
        end function
    }

    return m
end function