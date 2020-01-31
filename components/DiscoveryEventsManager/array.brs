''
' Returns the results of applying iteratee to each element.
''
function map(arr as object, iteratee as function) as object
    results = []
    for each e in arr
        results.push(iteratee(e))
    end for

    return results
end function

''
' Inserts a value in an array at the specified index.
''
function arrayInsert(array as object, index as integer, value as dynamic) as Object
    temp = []
    for i = 0 to index - 1
        temp.push(array[i])
    end for
    
    temp.push(value)
    
    max = array.count() - 1
    for i = index to max
        temp.push(array[i])
    end for

    return temp
end function

''
' Checks if given array contains given item.
''
function arrayContains(array as object, item as object) as boolean
    for each arrayItem in array
        if arrayItem = item
            return true
        end if
    end for
    return false
end function