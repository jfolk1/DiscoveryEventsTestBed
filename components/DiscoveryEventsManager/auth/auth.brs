''
' Returns an object containing auth utility functions.
'
' @parameter {object} appConfig - Application config.
''
function auth(appConfig as object) as object
    this = {
        ''
        ' Returns if the device is activated.
        '
        ' @returns {boolean}
        ''
        isActivated: function() as boolean
            ' If we have an auth token...
            return m._getAuthToken() <> invalid
        end function

        ''
        ' Returns if the auth session is expired.
        '
        ' @returns {boolean}
        ''
        isSessionExpired: function()
            expiresAt = registry().read("expiresAt", m._sessionRegistrySection)
            if expiresAt = invalid then return false

            return parseJson(expiresAt) <= createObject("roDateTime").asSeconds()
        end function

        ''
        ' Returns either an authenticated or anonymous access token.
        '
        ' @param {boolean} [force] - Whether to force a fetch of an access token.
        ' @returns {object}
        ''
        getAccessToken: function(force = false) as object
            if m.isActivated()
                authToken = m._getAuthToken(force)
                if authToken <> invalid then return authToken
            end if

            ' Return an anon token if the device isn't activated or if we couldn't get an auth token.
            return m._getAnonToken(force)
        end function

        ''
        ' Returns the affiliate associated with this session.
        '
        ' @return {dynamic} Affiliate object or invalid.
        ''
        getAffiliate: function() as dynamic
            affiliate = invalid
            affiliateJson = registry().read("affiliate", m._sessionRegistrySection)

            if affiliateJson <> invalid
                affiliate = createAffiliate(m._appConfig)
                affiliate.fromJsonData(parseJson(affiliateJson))
            end if

            return affiliate
        end function

        ''
        ' Returns the unique device ID used for SSO.
        '
        ' @returns {string}
        ''
        getSsoId: function() as string
            ssoId = registry().read("ssoId", m._registrySection)

            if ssoId = invalid
                ssoTimeId = registry().read("ssoTimeId", m._registrySection)
                if ssoTimeId = invalid
                    date = createObject("roDateTime")
                    ssoTimeId = date.asSeconds().toStr()
                    registry().write("ssoTimeId", ssoTimeId, m._registrySection)
                end if

                ssoId = createObject("roDeviceInfo").getChannelClientId() + ssoTimeId

                hmac = createObject("roHMAC")
                idKey = createObject("roByteArray")
                idKey.fromAsciiString(m._ssoIdKey)
                if hmac.setup("sha1", idKey) = 0
                    message = CreateObject("roByteArray")
                    message.fromAsciiString("ROKU" + createObject("roDeviceInfo").getChannelClientId() + ssoTimeId)
                    result = hmac.process(message)
                    ssoId = result.toHexString()
                end if

                registry().write("ssoId", ssoId, m._registrySection)
                log().debug("Created and saved SSOID to registry")
            end if

            return ssoId
        end function

        ''
        ' Returns the UUID associated with this session.
        '
        ' @returns {dynamic} UUID string or invalid.
        ''
        getUUID: function() as dynamic
            return registry().read("uuid", m._sessionRegistrySection)
        end function

        ''
        ' Returns a hashed UUID associated with this session.
        '
        ' @returns {dynamic} hashedUUID string or invalid.
        ''
        getHashedUUID: function() as dynamic
            return registry().read("hashedUUID", m._sessionRegistrySection)
        end function

        ''
        ' Returns the apiUUID(userId) associated with this session.
        '
        ' @returns {dynamic} apiUUID string or invalid.
        ''
        getApiUUID: function() as dynamic
            ' Previous version does not store apiUUID so if it is invalid update AuthToken where apiUUID will be stored
            if registry().read("apiUUID", m._sessionRegistrySection) = invalid
                m._getAuthToken(true)
            end if
            return registry().read("apiUUID", m._sessionRegistrySection)
        end function

        ''
        ' Returns the HBA status associated with this session.
        '
        ' @returns {dynamic} hbaStatus string or invalid.
        ''
        getHBAStatus: function() as dynamic
            return registry().read("hbaStatus", m._sessionRegistrySection)
        end function

        ' ---------------------------------------------------------------------
        ' Device activation
        ' ---------------------------------------------------------------------

        ''
        ' Fetches an activation code and other activation info from the Entitlements API.
        '
        ' @returns {object} activationInfo
        '          {string} activationInfo.userCode - Activation code to display to the user.
        '          {integer} activationInfo.expiresIn - Time (in seconds) before the activation code expires.
        '          {string} activationInfo.activationUrl - URL where the user should enter the activation code.
        ''
        fetchActivationInfo: function() as dynamic
            url = getHateoasLink("get_auth_code_v1", m._appConfig.apiLinks).href
            response = fetch(url, {
                method: "POST",
                data: {
                    "client_id": m._appConfig.clientId,
                    "device_id": m.getSsoId(),
                    "grant_type": "adobe_sso"
                },
                headers: m._authHeaders
            })

            if response <> invalid and response.ok
                responseJsonData = response.body.json

                return {
                    userCode: responseJsonData.user_code,
                    expiresIn: responseJsonData.expires_in
                    activationUrl: responseJsonData.activation_url,
                }
            else
                log().error("Failed to get activation info.")
                return invalid
            end if
        end function

        ''
        ' Checks SSO endpoint to see if the user has an active session.
        '
        ' Only really to be used on app startup.
        '
        ' @returns {boolean} True if user is logged in to any channel with a participating mvpd, false if not.
        ''
        checkSsoAuthentication: function() as boolean
            return m.fetchAuthToken("roku_sso") <> invalid
        end function

        ''
        ' Attempts to fetch an auth token from the Entitlements API, as part of the device activation flow.
        '
        ' @returns {dynamic} authToken or invalid - Auth token on success, invalid on failure.
        ''
        fetchAuthToken: function(grantType = "adobe_sso" as string)
            url = getHateoasLink("get_auth_token_v1", m._appConfig.apiLinks).href

            response = fetch(url, {
                method: "POST",
                data: {
                    "client_id": m._appConfig.clientId,
                    "device_id": m.getSsoId(),
                    "grant_type": grantType,
                    "networks.code": m._appConfig.networkCode
                },
                headers: m._authHeaders
            })

            if response <> invalid and response.ok
                responseData = response.body.json

                ' `expires_in` is returned as a string, convert to an integer
                responseData.expires_in = strtoi(responseData.expires_in)
                authToken = createAccessToken(responseData)

                affiliateUriTemplate = getHateoasLink("affiliate_by_id", m._appConfig.apiLinks).href
                affiliateUrl = expandUriTemplate(affiliateUriTemplate, { authClientId: responseData.auth_client_id, platform: m._appConfig.platform })
                affiliate = createAffiliate(m._appConfig, { url: affiliateUrl }).fetch()

                ' If the affiliate doesn't provide a session expiration, then use the default one
                sessionTtl = responseData.auth_session
                if sessionTtl = invalid then sessionTtl = m._defaultSessionTtl
                expiresAt = createObject("roDateTime").asSeconds() + sessionTtl

                registry().write("expiresAt", formatJson(expiresAt), m._sessionRegistrySection)

                ' HBA Status
                hbaStatus = iif(responseData.hba_status <> invalid, responseData.hba_status, "unknown")

                ' Persist the auth token, UUID, and affiliate.
                registry().write("authToken", authToken.toJson(), m._sessionRegistrySection)
                registry().write("uuid", responseData.uuid, m._sessionRegistrySection)
                registry().write("hashedUUID", responseData.hashed_uuid, m._sessionRegistrySection)
                registry().write("apiUUID", responseData.api_uuid, m._sessionRegistrySection)
                registry().write("affiliate", affiliate.toJson(), m._sessionRegistrySection)
                registry().write("hbaStatus", hbaStatus, m._sessionRegistrySection)

                ' Enable the affiliate bumper.  Some affiliates require a "bumper" to be played in place
                ' of a preroll ad for the first video watched after login.
                userSettings().setAffiliateBumperEnabled(true)

                return authToken
            else
                return invalid
            end if
        end function

        ''
        ' Deactivates the device.
        ''
        deactivate: function()
            authToken = m._getAuthToken()
            if authToken <> invalid and authToken.getRefreshToken() <> invalid
                ' Let the entitlements API know that we've logged out for the current affiliate.
                url = getHateoasLink("deauthorize_token_v1", m._appConfig.apiLinks).href

                response = fetch(url, {
                    method: "POST",
                    data: {
                        "refresh_token": authToken.getRefreshToken().getToken(),
                        "client_id": m._appConfig.clientId,
                        "grant_type": "adobe_sso"
                    },
                    headers: m._authHeaders
                })
            end if

            ' Remove the session registry section.
            registry().deleteSection(m._sessionRegistrySection)
        end function


        ' ---------------------------------------------------------------------
        ' Private
        ' ---------------------------------------------------------------------

        _appConfig: appConfig,
        _registrySection: "Auth",
        _sessionRegistrySection: "AuthSession",
        _defaultSessionTtl: 31536000, ' 365 d * 24 h * 60 m * 60 s
        _ssoIdKey: "1cdstg25", ' Special key from Adobe to generate the unique device id passed into every request
        ' Headers that must be passed to every request that Entitlements forwards to Adobe (grant_type of adobe_sso or roku_sso)
        ' x-roku-reserved-roku-connect-token must have the empty string value because Roku OS will inject the channel token
        _authHeaders: {
            "Content-Type": "application/x-www-form-urlencoded",
            "x-roku-reserved-roku-connect-token": ""
        },

        ''
        ' Returns a saved token or fetches a new one.
        '
        ' @param {boolean} [force] - Whether to force a fetch of a new token.
        ' @returns {object} anonToken
        ''
        _getAnonToken: function(force) as object
            anonTokenJson = registry().read("anonToken", m._registrySection)

            if anonTokenJson <> invalid
                anonToken = createAccessToken(parseJson(anonTokenJson))
                if not anonToken.isExpired() and not force then return anonToken
            end if

            return m._fetchAnonToken()
        end function

        ''
        ' Fetches an anonymous token.
        '
        ' @returns {object} anonToken
        ''
        _fetchAnonToken: function() as object
            url = getHateoasLink("get_anonymous_token_v1", m._appConfig.apiLinks).href
            response = fetch(url, {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                data: {
                    "client_id": m._appConfig.clientId,
                    "grant_type": "client_credentials"
                }
            })

            if response <> invalid and response.ok
                tokenData = response.body.json
                ' `expires_in` is returned as a string, convert to an integer
                tokenData.expires_in = strtoi(tokenData.expires_in)
                anonToken = createAccessToken(tokenData)

                ' Persist the anon token.
                registry().write("anonToken", anonToken.toJson(), m._registrySection)

                return anonToken
            else
                ' Return an invalid access token.
                return createAccessToken({ access_token: "" })
            end if
        end function

        ''
        ' Returns an authenticated access token.
        '
        ' @param {boolean} [force] - Whether to force a fetch of a new token.
        ' @returns {dynamic} authToken or invalid.
        ''
        _getAuthToken: function(force = false) as dynamic
            authTokenJson = registry().read("authToken", m._sessionRegistrySection)
            if authTokenJson = invalid then return invalid

            authToken = createAccessToken(parseJson(authTokenJson))

            if not authToken.isExpired() and not force
                return authToken
            else
                ' If we can't exchange the refresh token for an new auth token, this will return invalid.
                return m._refreshAuthToken(authToken.getRefreshToken())
            end if
        end function

        ''
        ' Exchanges a refresh token for a new auth token.
        '
        ' @param {object} refreshToken
        ' @param {dynamic} authToken or invalid
        ''
        _refreshAuthToken: function(refreshToken as object) as dynamic
            url = getHateoasLink("refresh_token_v1", m._appConfig.apiLinks).href
            response = fetch(url, {
                method: "POST",
                data: {
                    "client_id": m._appConfig.clientId,
                    "device_id": m.getSsoId(),
                    "grant_type": "refresh_token",
                    "networks.code": m._appConfig.networkCode,
                    "refresh_token": refreshToken.getToken()
                },
                headers: m._authHeaders
            })

            ' Get access to the global scope.
            screen = createObject("roSGScreen")
            m.global = screen.getGlobalNode()

            if response <> invalid and response.status = 200
                tokenData = response.body.json
                ' `expires_in` is returned as a string, convert to an integer
                tokenData.expires_in = strtoi(tokenData.expires_in)
                authToken = createAccessToken(tokenData)

                ' Persist the auth token.
                registry().write("authToken", authToken.toJson(), m._sessionRegistrySection)
                ' Previous version does not store apiUUID so persist the apiUUID too
                registry().write("apiUUID", tokenData.api_uuid, m._sessionRegistrySection)

                return authToken
            else if response <> invalid and response.status >= 500
                errorMessage = "The server cannot process the request. Please try again later." + chr(10) + "Error code: " + response.status.toStr()
                log().error(errorMessage)

                ' This will display the error message in the SG thread
                if m.global.isSceneGraphActive
                    ' Propagate the event to the global scope
                    m.global.setField("event", {
                        type: "temporaryRefreshTokenError",
                        data: {
                            message: errorMessage
                        }
                    })
                else
                    ' This will display the error message in the Main thread
                    showErrorScreen("Error", errorMessage)
                end if
            else
                ' Expired refresh token
                log().error("Failed to exchange refresh token.")

                ' We need to track this specific type of event in GA. See ApplicationScene
                if response <> invalid and response.status = 410
                    googleAnalytics(m._appConfig, m.getUUID()).trackEvent({
                        category: "authentication-events",
                        action: "mso-410",
                        label: m.getAffiliate().name
                    })

                    if m.global.isSceneGraphActive
                        ' Send "forcedLogout" event
                        m.global.setField("event", {
                            type: constants().DISCOVERY_EVENTS.TYPE,
                            data: discoveryEventsHelper().getDiscoveryAuthenticationEvent(constants().DISCOVERY_EVENTS.AUTHENTICATION.ACTIONS.FORCED_LOGOUT, m.getAffiliate().id)
                        })
                    end if
                end if

                ' Deactivate the device if we fail to get a new auth token.
                registry().deleteSection(m._sessionRegistrySection)
                return invalid
            end if
        end function
    }

    return this
end function