''
' Returns an object containing registry utility functions.
''
function registry() as object
    this = {
        _defaultSection: "Default"

        ''
        ' Returns the value of `key` from the registry.
        '
        ' @param {string} key - Registry key.
        ' @param {string} [section] - Section name.
        ''
        read: function(key, section = m._defaultSection) as dynamic
            section = createObject("roRegistrySection", section)

            if section.exists(key)
                return section.read(key)
            else
                return invalid
            end if
        end function

        ''
        ' Writes `value` to the registry for `key`.
        '
        ' @param {string} key - Registry key.
        ' @param {string} value
        ' @param {string} [section] - Section name.
        ''
        write: function(key, value, section = m._defaultSection)
            section = createObject("roRegistrySection", section)
            section.write(key, value)
            section.flush()
        end function

        ''
        ' Deletes `key` from the registry.
        '
        ' @param {string} key - Registry key.
        ' @param {string} [section] - Section name.
        ''
        delete: function(key, section = m._defaultSection)
            section = createObject("roRegistrySection", section)
            section.delete(key)
            section.flush()
        end function

        ''
        ' Returns an roList containing one entry per registry key in this section.  Each entry is an roString containing the name of the key.
        '
        ' @param {string} [section] - Section name.
        ''
        getKeyList: function(section = m._defaultSection) as dynamic
            section = createObject("roRegistrySection", section)
            return section.getKeyList()
        end function

        ''
        ' For registry values of type object. Appends new values or creates a new object with
        ' passed in value if none exists already.
        '
        ' @param {string} key - registry key
        ' @param {object} value
        ' @param {string} section - section name
        ''
        appendValue: function(key, value, section = m._defaultSection) as void
            currentValue = m.read(key, section)

            if currentValue <> invalid and parseJson(currentValue) <> invalid
                objectValue = parseJson(currentValue)
                if objectValue.doesExist(key)
                    objectValue.addReplace(key, value.lookup(key))
                else
                    objectValue.append(value)
                end if
                m.write(key, formatJson(objectValue), section)
            else
                m.write(key, formatJson(value), section)
            end if
        end function

        ''
        ' Deletes a section from the registry.
        '
        ' @param {string} [section] - Section name.
        ''
        deleteSection: function(section = m._defaultSection) as dynamic
            registry = createObject("roRegistry")
            registry.delete(section)
            registry.flush()
        end function

        ''
        ' Resets/clears all sections from the registry
        '
        ''
        reset: function()
            sections = createObject("roRegistry").getSectionList()
            for each section in sections
                m.deleteSection(section)
            end for
        end function
    }

    return this
end function
