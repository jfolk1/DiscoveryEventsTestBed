
sub init()

  m.discoveryEventsManager = createObject("roSGNode", "DiscoveryEventsManager")
  print m.discoveryEventsManager

  print m.global
 m.global.ObserveField("event", "onGlobalEventHandler")
print "hello world"

  m.top.setFocus(true)
  m.myLabel = m.top.findNode("myLabel")
  
  'Set the font size
  m.myLabel.font.size=92

  'Set the color to light blue
  m.myLabel.color="0x72D7EEFF"

  '**
  '** The full list of editable attributes can be located at:
  '** http://sdkdocs.roku.com/display/sdkdoc/Label#Label-Fields
  '**
end sub

function onGlobalEventHandler(msg as object) as void
  event = msg.getData()

  ' 'print event
  ' 'print "onGlobalEventHandler"

    '  Refresh token error events'
    'if m.global.event.type = "temporaryRefreshTokenError"
    '    ' Remove the loading screen
    '    showLoading(false)
    '    onMessageHandler({message: m.global.event.data.message}, m.DIALOG_TYPE_MESSAGE, function()
    '        ' Exit the app!
    '        m.top.exit = true
    '    end function)
    'end if

    '' RMF events
    'if m.global.event.type = "RokuMarketingFramework"
    '    onRokuMarketingFrameworkHandler(m.global.event)
    'end if

    ' Discovery Events
    ' 'if m.global.event.type = m.constants.DISCOVERY_EVENTS.TYPE
    ' '    event = m.global.event.data
        onDiscoveryEventHandler(event)
    ' 'end if

    '' Send Interaction Event for Impression
    'if m.global.event.type = "RowItemImpression"
    '    screen = m.screenStack.peek()

    '    ' Get payload for impression event and call onDiscoveryEventHandler() directly
    '    ' Race condition occurs with multiple impression events sent simultaneously
    '    ' m.global.event changes too quickly to track impressions
    '    impressionEvent = screen.callFunc("getImpressionEvent", m.global.event.data)
    '    onDiscoveryEventHandler(impressionEvent)
    'end if

    'if m.global.event.type = "ActivationSuccess"
    '    'Migration starts
    '    migrateContinueWatching()
    '    migrateWatchLaterItems()
    '    migrateFavoriteItems()
    'end if
end function

function onDiscoveryEventHandler(event)
  print "onDiscoveryEventHandler"
    ' Let the Discovery Event Manager know that we've received an event
    m.discoveryEventsManager.event = event
end function
