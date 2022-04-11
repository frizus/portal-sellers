local addonName, addon = ...
local Message = addon.Message
local DB, Table = addon.param, addon.Table

function Message:MarkChanged(what, id)
    if not DB.trackerWindowOpened then
        if what == "delete" then
            if self.changed and self.changed["addIds"] and self.changed["addIds"][id] then
                self.changed["addIds"][id] = nil
                if Table:Empty(self.changed["addIds"]) then
                    self.changed["add"] = nil
                    self.changed["addIds"] = nil
                end
            end
            return
        end
        if what ~= "add" then
            return
        end
    end

    if not self.changed then
        self.changed = {}
    end
    if not self.changed[what] then self.changed[what] = true end
    if id then
        local ids = what .. "Ids"
        if not self.changed[ids] then
            self.changed[ids] = {}
        end
        self.changed[ids][id] = true
    end
end

function Message:DeleteChanged(id)
    if not self.changed then return end
    if self.changed["addIds"] and self.changed["addIds"][id] then self.changed["addIds"][id] = nil end
    if self.changed["updateIds"] and self.changed["updateIds"][id] then self.changed["updateIds"][id] = nil end
end