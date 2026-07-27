function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

function allToUpper(str)
    return (string.upper(str))
end