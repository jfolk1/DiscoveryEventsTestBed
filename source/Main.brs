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

  m.global = screen.getGlobalNode()
  m.global.addFields({
    event:{}
  })

  print m.global



  m.port = CreateObject("roMessagePort")
  screen.setMessagePort(m.port)

  'Create a scene and load /components/helloworld.xml'
  scene = screen.CreateScene("HelloWorld")
  screen.show()




  ' m.discoveryEventsManager.appContext = m.top.appContext


  payload = {}
  while(true)
    sendDiscoveryEvent(payload)

    ' 'msg = wait(0, m.port)
    ' 'msgType = type(msg)
    ' 'if msgType = "roSGScreenEvent"
    ' '  if msg.isScreenClosed() then return
    ' 'end if
  end while
end sub




function sendDiscoveryEvent(payload as dynamic) as void

    ' Nothing to do here
    if payload = invalid then return

  ' 'print "sendDiscoveryEvent"

    m.global.event = {
        type: constants().DISCOVERY_EVENTS.TYPE,
        timestamp: timeHelper().getRFC3339Timestamp(),
        data: payload
    }
end function
