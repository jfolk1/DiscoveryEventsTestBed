'*************************************************************
'** Hello World example 
'** Copyright (c) 2015 Roku, Inc.  All rights reserved.
'** Use of the Roku Platform is subject to the Roku SDK Licence Agreement:
'** https://docs.roku.com/doc/developersdk/en-us
'*************************************************************

sub Main()
  print "in showChannelSGScreen"
  'Indicate this is a Roku SceneGraph application'
  screen = CreateObject("roSGScreen")
  m.port = CreateObject("roMessagePort")
  screen.setMessagePort(m.port)

  'Create a scene and load /components/helloworld.xml'
  scene = screen.CreateScene("HelloWorld")
  screen.show()

  m.global = screen.getGlobalNode()
  m.global.observeField("event", "onGlobalEventHandler")


  m.discoveryEventsManager = createObject("roSGNode", "DiscoveryEventsManager")
  ' m.discoveryEventsManager.appContext = m.top.appContext

  while(true)
    msg = wait(0, m.port)
    msgType = type(msg)
    if msgType = "roSGScreenEvent"
      if msg.isScreenClosed() then return
    end if
  end while
end sub


function onGlobalEventHandler() as void
  print "fired event"
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
    if m.global.event.type = m.constants.DISCOVERY_EVENTS.TYPE
        event = m.global.event.data
        onDiscoveryEventHandler(event)
    end if

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
    ' Let the Discovery Event Manager know that we've received an event
    m.discoveryEventsManager.event = event
end function
