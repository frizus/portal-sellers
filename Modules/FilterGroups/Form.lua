local addonName, addon = ...
local FilterGroupForm = {}
addon.FilterGroupForm = FilterGroupForm

function FilterGroupForm:CreateTag(filterGroup)
    local tag = ""
    if filterGroup["classes"] then
        tag = filterGroup["classes"]
    end
    tag = tag .. "--"
    if filterGroup["wordGroupsString"] then
        tag = tag .. filterGroup["wordGroupsString"]
    end
    return tag
end