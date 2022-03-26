local addonName, addon = ...
local Chars = {}
addon.Chars = Chars

function Chars:IsSpace(c)
    return self.spaceChars[c]
end

-- https://jkorpela.fi/chars/spaces.html
-- https://en.wikipedia.org/wiki/Newline#Unicode
Chars.spaceChars = {
    [" "] = true,
    ["\f"] = true,
    ["\n"] = true,
    ["\r"] = true,
    ["\t"] = true,
    ["\v"] = true,
    [""] = true,
    [" "] = true,
    [" "] = true,
    [" "] = true,
    [" "] = true,
    [" "] = true,
    [" "] = true,
    [" "] = true,
    [" "] = true,
    [" "] = true,
    [" "] = true,
    [" "] = true,
    [" "] = true,
    [" "] = true,
    [" "] = true,
    ["　"] = true,
}