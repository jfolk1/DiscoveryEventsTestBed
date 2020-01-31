''
' Constructs an access token.
'
' @param {object} config
' @param {string} config.access_token - Access token value.
' @param {string} config.token_type - Type of token.
' @param {integer} [config.expires_at] - When the access token expires.
' @param {integer} [config.expires_in] - Seconds when the token expires.
' @param {string} [config.refresh_token] - Refresh token value.
'
''
function createAccessToken(config as object) as object
    this = {
        getToken: function()
            return m._token
        end function

        getType: function()
            return m._type
        end function

        isExpired: function()
            return m.getExpiresAt() and m.getExpiresAt() <= createObject("roDateTime").asSeconds()
        end function

        getExpiresAt: function()
            return m._expiresAt
        end function

        getRefreshToken: function()
            return m._refreshToken
        end function

        ''
        ' Serialize into a JSON string.
        ' The result can be parsed and passed to `createAccessToken()` to create a new access token object.
        ''
        toJson: function()
            tokenObject = {
                access_token: m.getToken(),
                token_type: m.getType(),
                expires_at: m.getExpiresAt(),
            }

            if m.getRefreshToken() <> invalid
                tokenObject.refresh_token = m.getRefreshToken().getToken()
            else
                tokenObject.refresh_token = invalid
            end if

            return formatJson(tokenObject)
        end function


        ' ---------------------------------------------------------------------
        ' Private
        ' ---------------------------------------------------------------------

        _token: config.access_token
        _type: config.token_type
        _expiresAt: invalid
        _refreshToken: invalid
    }

    if config.expires_at <> invalid
        this._expiresAt = config.expires_at
    end if

    if config.expires_in <> invalid
        this._expiresAt = createObject("roDateTime").asSeconds() + config.expires_in
    end if

    if config.refresh_token <> invalid
        this._refreshToken = createAccessToken({
            access_token: config.refresh_token,
            type: "refresh_token"
        })
    end if

    return this
end function
