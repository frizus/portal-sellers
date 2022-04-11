local addonName, addon = ...
local Table = {}
addon.Table = Table

function Table:Get(table, key)
    if type(key) ~= "table" then
        return table[key]
    end

    local length = #key
    if length == 2 then
        if type(table[key[1]]) == "table" then
            return table[key[1]][key[2]]
        end
    elseif length == 1 then
        return table[key[1]]
    end
end

function Table:Set(table, key, value)
    if type(key) ~= "table" then
        table[key] = value
    end

    local length = #key
    if length == 2 then
        if table[key[1]] == nil then
            table[key[1]] = {}
        end
        table[key[1]][key[2]] = value
    elseif length == 1 then
        table[key[1]] = value
    end
end

function Table:Length(table)
    local length = 0
    for _ in pairs(table) do
        length = length + 1
    end
    return length
end

function Table:NotEmpty(table)
    for _ in pairs(table) do
        return true
    end
end

function Table:Empty(table)
    for _ in pairs(table) do
        return
    end
    return true
end

function Table:GetSortedKeys(tbl, field, asc)
    local keys = {}
    for key in pairs(tbl) do table.insert(keys, key) end

    if asc ~= false then
        table.sort(keys, function(a, b)
            return tbl[a][field] < tbl[b][field]
        end)
    else
        table.sort(keys, function(a, b)
            return tbl[a][field] > tbl[b][field]
        end)
    end

    return keys
end