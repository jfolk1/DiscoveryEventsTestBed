''
' Constants that can be used throughout the app
'
''
function constants() as object
    m = {
        ' Used for capping the number of items requested when fetching.  This is based on the
        ' device model and performance
        EMBED_LIMIT: {
            LOW_END_MODEL: 5,
            HIGH_END_MODEL: 8
        },

        DISCOVERY_EVENTS: {
            TYPE: "DiscoveryEvent",
            
            PLAYBACK: {
                TYPE: "playback",
                ACTIONS: {
                    PLAYBACK_REQUEST: "playbackRequest",
                    STREAM_INITIATE: "streamInitiate",
                    START: "start",
                    PROGRESS: "progress",
                    PAUSE_START: "pauseStart",
                    PAUSE_STOP: "pauseStop",
                    SEEK_START: "seekStart",
                    SEEK_STOP: "seekStop",
                    BUFFER_START: "bufferStart",
                    BUFFER_STOP: "bufferStop",
                    RESUME: "resume",
                    COMPLETE: "complete",
                    STOP: "stop",
                    STREAM_COMPLETE: "streamComplete"
                }
            },
            AD: {
                TYPE: "ad",
                PROGRESS_FREQUENCY: 1000, ' in milliseconds
                ACTIONS: {
                    START: "start",
                    PROGRESS: "progress",
                    PAUSE_START: "pauseStart",
                    PAUSE_STOP: "pauseStop",
                    BUFFER_START: "bufferStart",
                    BUFFER_STOP: "bufferStop",
                    RESUME: "resume",
                    SKIP: "skip", ' not used at the moment, but if we ever use skippable ads
                    COMPLETE: "complete",
                    STOP: "stop"
                }
            },
            AUTHENTICATION: {
                TYPE: "authentication",
                ACTIONS: {
                    LOGIN: "login",
                    LOGOUT: "logout",
                    FORCED_LOGOUT: "forcedLogout"
                }
            },
            SESSION: {
                TYPE: "session"
                ACTIONS: {
                    FIRSTSTART: "firststart", ' leaving for legacy purposes. installed apps look for this value in registry
                    START: "start",
                    STOP: "stop"
                },
                START_TYPES: {
                    FIRST: "first",
                    COLD: "cold",
                    RESUME: "resume"
                }
            },
            CHAPTER: {
                TYPE: "chapter",
                ACTIONS: {
                    START: "start",
                    COMPLETE: "complete"
                }
            },
            AD_BREAK: {
                TYPE: "adBreak",
                ACTIONS: {
                    START: "start",
                    COMPLETE: "complete"
                }
            },
            USER_PROFILE: {
                TYPE: "userProfile",
                ACTIONS: {
                    ON: "on",
                    OFF: "off"
                },
                CATEGORIES: {
                    WATCHLIST: "watchlist",
                    FAVORITES: "favorites"
                }
            },
            BROWSE: {
                TYPE: "browse",
                ACTIONS: { VIEW: "view" }
            },
            INTERACTION: {
                TYPE: "interaction",
                ACTIONS: {
                    CLICK: "click",
                    IMPRESSION: "impression",
                    SCROLL: "scroll"
                }
            }
        }
    }

    return m
end function