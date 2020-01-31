function init()
    m.top.functionName = "run"
end function

function run()
    ' Execute the requested Discovery Event tracking method.
    discoEvents = discoveryEvents(m.top.appContext.config)
    discoEvents[m.top.runFunction.functionName](m.top.runFunction.args)

    m.top.control = "DONE"
    
end function