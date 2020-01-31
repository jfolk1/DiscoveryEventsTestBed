''
' Inline/ternary conditional
''
function iif(condition as boolean, t as dynamic, f as dynamic)
    if condition
        return t
    else
        return f
    end if
end function

''
' Convert any type to a string.
''
function toString(x as dynamic) as dynamic
    if type(x) = "<uninitialized>" then return "uninitialized"
    if x = invalid then return "invalid"
    if hasInterface(x, "ifBoolean") then return iif(x, "true", "false")
    if hasInterface(x, "ifInt") then return stri(x).trim()
    if hasInterface(x, "ifFloat") or type(x) = "roFloat" then return str(x).trim()
    if hasInterface(x, "ifString") then return x
    if type(x) = "roAssociativeArray" then return formatJson(x)
    if hasInterface(x, "ifSGNodeDict") then return x.subType()

    return ""
end function

''
' Returns if |x| has the interface |interface|.
''
function hasInterface(x as dynamic, interface as string) as boolean
    return getInterface(x, interface) <> invalid
end function
