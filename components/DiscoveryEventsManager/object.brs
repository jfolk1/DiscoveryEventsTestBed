''
' Copy all of the properties in `source` to the `destination` object.
''
function extend(destination as object, source as object) as object
    for each key in source
        destination[key] = source[key]
    end for

    return destination
end function

''
' Checks for the validity of an object embedded into a parent
'
' @param {object} parent - root object used for lookups
' @param {string} keyPath - string path to be checked if it exist within the parent object
'
' @returns {dynamic} - the nested object if it exists or invalid otherwise
''
function getPropertyForKeyPath(parent as Object, keyPath as String) as Dynamic
    if parent = invalid or keyPath = invalid then return invalid

    ' Set the parent as the current object in the hierarchy
    currentObject = parent

    ' Split the keyPath into an array of keys
    keys = keyPath.split(".")

    for i = 0 to keys.count() - 1
        if currentObject[keys[i]] = invalid
            return invalid
        else
            currentObject = currentObject[keys[i]]
        end if
    end for

    return currentObject
end function
