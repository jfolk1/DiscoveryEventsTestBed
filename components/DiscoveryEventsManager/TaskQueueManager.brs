''
' Initialize Component
''
function init()
    ' Keep track if there's a current task running
    m.isTaskRunning = false
    
    ' Array of pending tasks
    m.taskQueue = []

    ' Add a listener for tasks to be fired
    m.top.observeField("task", "onNewTaskHandler")
end function

''
' Called when a new task request is received
''
function onNewTaskHandler()
    task = m.top.task
    if task <> invalid then 
        m.taskQueue.push(task)
    end if

    if not m.isTaskRunning
        runTask()
    end if
end function

''
' Runs a task from the task queue
''
function runTask() as void
    if m.taskQueue.count() > 0
        task = m.taskQueue.shift()

        ' if the current task cannot be processed, request the next task in the queue
        if task = invalid or task.taskNodeName = invalid
            runTask()
        end if
        
        ' Lock the task queue until the current operation has been completed
        m.isTaskRunning = true

        ' Create a new task and run it
        m.taskNode = createObject("roSGNode", task.taskNodeName)
        m.taskNode.observeField("control", "onControlUpdate")
        m.taskNode.appContext = m.top.appContext
        m.taskNode.runFunction = task
        m.taskNode.control = "RUN"
    end if
end function

''
' Task control callback
''
function onControlUpdate()
    if m.taskNode.control = "stop"
        ' Remove observers and set the current task to invalid before creating a new one
        m.taskNode.unobserveField("control")
        m.taskNode = invalid
        m.isTaskRunning = false

        ' We are done with the current task, get the next one
        runTask()
    end if
end function