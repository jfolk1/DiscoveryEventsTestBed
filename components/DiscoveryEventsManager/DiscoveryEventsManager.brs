''
' Initialize Component
''
function init()
    m.previousPlaybackProgressTime = 0 ' datetime as seconds for last playback.progress event
    m.previousAdProgressTime = 0 ' datetime as seconds for last ad.progress event
    m.eventBatchQueue = []
    m.MAX_EVENT_BATCH_QUEUE = 100

    m.eventBatchQueueTimer = invalid

    ' Get a reference to the app config
    m.config = invalid

    ' Create and keep a reference to the constants instance
    m.constants = constants()

    ' Task Queue Manager
    m.taskQueueManager = createObject("roSGNode", "TaskQueueManager")

    ' Listen for player events
    m.top.observeField("event", "onEventHandler")
end function

''
' Executed whenever the app context changes
''
function onAppContextChanged()
    ' Get a reference to the app config
    m.config = m.top.appContext.config

    ' Sets up a timer that will take care of firing queued events at the specified interval
    m.eventBatchQueueTimer = createObject("roSGNode", "Timer")
    m.eventBatchQueueTimer.duration = m.config.discoveryEvents.batchFrequencyInMs / 1000
    m.eventBatchQueueTimer.repeat = "true"
    m.eventBatchQueueTimer.observeField("fire", "onBatchQueueInterval")
    m.eventBatchQueueTimer.control = "start"
end function

''
' Handles events
''
function onEventHandler() as void
    event = m.top.event

    ' Nothing to do here
    if event = invalid then return

    deviceInfo = createObject("roDeviceInfo")
    event.uuid = deviceInfo.GetRandomUUID()
    eventTypesForBatchQueue = [m.constants.DISCOVERY_EVENTS.AD.TYPE, m.constants.DISCOVERY_EVENTS.AUTHENTICATION.TYPE,
        m.constants.DISCOVERY_EVENTS.SESSION.TYPE, m.constants.DISCOVERY_EVENTS.CHAPTER.TYPE, m.constants.DISCOVERY_EVENTS.AD_BREAK.TYPE,
        m.constants.DISCOVERY_EVENTS.USER_PROFILE.TYPE, m.constants.DISCOVERY_EVENTS.BROWSE.TYPE, m.constants.DISCOVERY_EVENTS.INTERACTION.TYPE]

    session = discoverySession().getActiveSession()
    event.sessionId = session.sessionId
    if event.timestamp = invalid then event.timestamp = timeHelper().getRFC3339Timestamp()
    event.sessionTimer = discoverySession().getSessionTimer(event.timestamp)

    discoverySession().updateLastActive(event.timestamp)

    log().info("onEventHandler() session id: " + event.sessionId)

    if event.type = m.constants.DISCOVERY_EVENTS.PLAYBACK.TYPE
        onVideoPlaybackEventHandler(event)
    else if event.type = m.constants.DISCOVERY_EVENTS.AD.TYPE
        onAdEventHandler(event)
    else if arrayContains(eventTypesForBatchQueue, event.type)
        addEventToBatchQueue(event)
    end if
end function

''
' Handles video playback events
'
' @param {object} event - playback object
''
function onVideoPlaybackEventHandler(event as Object)
    if event.payload.action = constants().DISCOVERY_EVENTS.PLAYBACK.ACTIONS.PROGRESS
        onPlaybackProgress(event)
    else
        addEventToBatchQueue(event)
    end if
end function

''
' Handles ad events
'
' @param {object} event - ad object
''
function onAdEventHandler(event as Object)
    if event.payload.action = constants().DISCOVERY_EVENTS.AD.ACTIONS.PROGRESS
        onAdProgress(event)
    else
        addEventToBatchQueue(event)
    end if
end function

''
' Media play progress event handler
'
' @param {object} event - media object
''
function onPlaybackProgress(event)
    eventDt = createObject("roDateTime")
    eventDt.fromISO8601String(event.timestamp)
    eventDtAsSeconds = eventDt.asSeconds()

    playbackProgressFrequencyInSeconds = m.config.discoveryEvents.playbackProgressFrequencyInMs / 1000
    shouldNotifyPlaybackProgress = abs(eventDtAsSeconds - m.previousPlaybackProgressTime) >= playbackProgressFrequencyInSeconds

    ' Send playback.progress if time since last playback.progress event reaches progress frequency
    if shouldNotifyPlaybackProgress
        addEventToBatchQueue(event)
        m.previousPlaybackProgressTime = eventDtAsSeconds
    end if
end function

function onAdProgress(event)
    eventDt = createObject("roDateTime")
    eventDt.fromISO8601String(event.timestamp)
    eventDtAsSeconds = eventDt.asSeconds()

    adProgressFrequencyInSeconds = m.constants.DISCOVERY_EVENTS.AD.PROGRESS_FREQUENCY / 1000
    shouldNotifyAdProgress = abs(eventDtAsSeconds - m.previousAdProgressTime) >= adProgressFrequencyInSeconds

    ' Send ad.progress if time since last ad.progress event reaches progress frequency
    if shouldNotifyAdProgress
        addEventToBatchQueue(event)
        m.previousAdProgressTime = eventDtAsSeconds
    end if
end function

''
' Fires events accumulated in the queue at the specified interval
''
function onBatchQueueInterval()
    ' Process whatever is in the event queue when the interval has been reached
    processEventBatchQueue()
end function

''
' Adds the event to the queue and fires the events if the criteria has been met
''
function addEventToBatchQueue(event)
    m.eventBatchQueue.push(event)
    if isPendingBatchQueueProcess() then processEventBatchQueue()
end function

' Checks if the queue max event cap has been reached
function isPendingBatchQueueProcess() as Boolean
    return m.eventBatchQueue.count() >= m.MAX_EVENT_BATCH_QUEUE
end function

' Processes Discovery events
function processEventBatchQueue() as void
    ' Don't do anything if empty
    if m.eventBatchQueue.count() = 0 then return

    ' Process the event batch
    trackDiscoveryEvent({events: m.eventBatchQueue})

    ' Reset the event batch queue array
    m.eventBatchQueue = []
end function

''
' Tracks Discovery events
'
' @param {object} events - Event batch queue.
''
function trackDiscoveryEvent(events as object) as void
    m.taskQueueManager.appContext = m.top.appContext
    m.taskQueueManager.task = {
        taskNodeName: "DiscoveryEventsTask"
        functionName: "trackEvent",
        args: events
    }
end function
