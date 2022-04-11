local addonName, addon = ...
local Chars = {}
addon.Chars = Chars

function Chars:Position(haystack, len, needle, ndlLen, pos, wordSearch)
    if ndlLen > (len - pos + 1) then
        return nil
    end
    local match, j
    while pos <= len do
        if self:MatchStart(haystack, pos, needle, wordSearch) and
            self:MatchEnd(haystack, pos + ndlLen - 1, len, needle, ndlLen, wordSearch)
        then
            if ndlLen <= 2 then return pos end
            match = true
            j = pos + 1
            for i = 2, ndlLen - 1 do
                if haystack[j] ~= needle[i] then
                    match = false
                    break
                end
                j = j + 1
            end
            if match then return pos end
            match, j = nil, nil
            pos = pos + 1
        else
            pos = pos + 1
        end
    end
    return nil
end

function Chars:IsSpace(c)
    return self.spaceChars[c]
end

function Chars:MatchStart(haystack, start, ndl, wordSearch)
    if haystack[start] ~= ndl[1] then
        return false
    end
    if not wordSearch or start == 1 then
        return true
    end
    if haystack[start] == haystack[start - 1] then
        return false
    end
    if self.breakWordChar[haystack[start]] then
        return true
    end
    return self.breakWordChar[haystack[start - 1]]
end

function Chars:MatchEnd(haystack, pos, len, ndl, ndlLen, wordSearch)
    if haystack[pos] ~= ndl[ndlLen] then
        return false
    end
    if not wordSearch or pos == len then
        return true
    end
    if haystack[pos] == haystack[pos + 1] then
        return false
    end
    if self.breakWordChar[haystack[pos]] then
        return true
    end
    return self.breakWordChar[haystack[pos + 1]]
end

function Chars:ConvertToTable(chars)
    self.breakWordChar = {}
    local reader = string.reader(chars)
    while not reader:eof() do
        self.breakWordChar[reader:getNext()] = true
    end
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

Chars:ConvertToTable(
" \r!\"#$%&'()*+,-./" ..
    ":;<=>?@[\\]^_`" ..
    "{|}~" ..
    "" ..
    " ¡¢£¤¥¦§¨©ª«¬­®¯°±´µ¶·¸º»" ..
    "¿×÷" ..
    "፠" ..
    "           " ..
    "​" ..
    "  " ..
    " " ..
    " " ..
    "‐‒–—―‖‗‘’‚‛“”„‟•‣․‥…‧‰‱′″‴‵‶‷‸‹›※‼‽‾‿⁀⁁⁂⁃⁄⁅⁆" ..
    "⁇⁈⁉⁏⁐⁑⁒⁓⁔⁗" ..
    "₠₡₢₣₤₥₦₧₨₩₪₫" ..
    "€₭₮₯₰₱₲₳₴₵₶₷" ..
    "₸₹₺₻₼₽₾₿" ..
    "℃℉№℗℠℡™Ω℧℮℻⅀" ..
    "←↑→↓" ..
    "↰↱↲↳" ..
    "↴↵↶↷↸↹" ..
    "↺↻" ..
    "⇄⇅⇆⇇⇈⇉" ..
    "⇊⇋⇌" ..
    "⇚⇛⇜⇝⇞⇟" ..
    "⇠⇡⇢⇣⇤⇥" ..
    "⇦⇧⇨⇩⇪⇫" ..
    "⇬⇭⇮⇯⇰⇱" ..
    "⇲⇳" ..
    "⇽⇾⇿" ..
    "∓∕∖∗∘∙∧∨∴∵∶∷∼∽" ..
    "≤≥≪≫⋀⋁" ..
    "⋮⋯⋰⋱" ..
    "⌀⌃⌄⌐⌗〈〉⌵" ..
    "■□▲△▴▵" ..
    "▷▸▹▼▽▾▿" ..
    "◁◂◃◊" ..
    "♪" ..
    "✕✖❓❔❕❗❘❙❚" ..
    "❛❜❝❞❟❠" ..
    "❧" ..
    "❨❩❪❫❬❭❮❯❰❱" ..
    "❲❳❴❵➔➕➖➗" ..
    "⟦⟧⟨⟩⟪⟫⟬⟭⟮⟯" ..
    "⸘⸜⸝⸠⸡⸢⸣⸤⸥⸦⸧⸨⸩" ..
    "⸪⸫⸬⸭⸮ⸯ⸰⸱" ..
    "⸲⸳⸴⸵⸺" ..
    "⸻⸼⸽⸾⸿⹀" ..
    "⹁⹂⹃⹄⹌⹎" ..
    "　、。〃々〆〈〉《》「」『』【】〒〓" ..
    "〔〕〖〗〘〙〚〛〜〝〞〟〰〱〲〳〴〵〻〼〼〿" ..
    "゠・" ..
    "︰︱︲︳︴︵︶︷︸" ..
    "︹︺︻︼︽︾︿﹀" ..
    "﹁﹂﹃﹄" ..
    "﹅﹆" ..
    "﹇﹈" ..
    "﻿" ..
    "！＂＃＄％＆＇（）＊＋，－．／" ..
    "：；＜＝＞？＠［＼］＾＿｀｛｜｝～｟｠｡｢｣､" ..
    "￠￡￢￣￤￥￨￩￪￫￬￭￮"
)

--[[
https://wowwiki-archive.fandom.com/wiki/Localization
https://wowwiki-archive.fandom.com/wiki/ValidChatMessageCharacters
https://www.branah.com/

https://unicode-table.com/en/blocks/basic-latin/
Basic Latin 0000-007F
\r !"#$%&'()*+,-./
:;<=>?@[\\]^_`
{|}~

https://unicode-table.com/en/blocks/latin-1-supplement/
Latin-1 Supplement 0080-00FF

 ¡¢£¤¥¦§¨©ª«¬­®¯°±´µ¶·¸º»
¿×÷

https://unicode-table.com/en/blocks/ethiopic/
Ethiopic 1200-137F
፠

https://unicode-table.com/en/blocks/general-punctuation/
General Punctuation 2000-206F
           
​
  
 
 
‐‒–—―‖‗‘’‚‛“”„‟•‣․‥…‧‰‱′″‴‵‶‷‸‹›※‼‽‾‿⁀⁁⁂⁃⁄⁅⁆
⁇⁈⁉⁏⁐⁑⁒⁓⁔⁗

https://unicode-table.com/en/blocks/currency-symbols/
Currency Symbols 20A0-20CF
₠₡₢₣₤₥₦₧₨₩₪₫
€₭₮₯₰₱₲₳₴₵₶₷
₸₹₺₻₼₽₾₿

https://unicode-table.com/en/blocks/letterlike-symbols/
Letterlike Symbols 2100-214F
℃℉№℗℠℡™Ω℧℮℻⅀

https://unicode-table.com/en/blocks/arrows/
Arrows 2190-21FF
←↑→↓
↰↱↲↳
↴↵↶↷↸↹
↺↻
⇄⇅⇆⇇⇈⇉
⇊⇋⇌
⇚⇛⇜⇝⇞⇟
⇠⇡⇢⇣⇤⇥
⇦⇧⇨⇩⇪⇫
⇬⇭⇮⇯⇰⇱
⇲⇳
⇽⇾⇿

https://unicode-table.com/en/blocks/mathematical-operators/
Mathematical Operators 2200-22FF
∓∕∖∗∘∙∧∨∴∵∶∷∼∽
≤≥≪≫⋀⋁
⋮⋯⋰⋱

https://unicode-table.com/en/blocks/miscellaneous-technical/
Miscellaneous Technical 2300-23FF
⌀⌃⌄⌐⌗〈〉⌵

https://unicode-table.com/en/blocks/geometric-shapes/
Geometric Shapes 25A0-25FF
■□▲△▴▵
▷▸▹▼▽▾▿
◁◂◃◊

https://unicode-table.com/en/blocks/miscellaneous-symbols/
Miscellaneous Symbols 2600-26FF
♪

https://unicode-table.com/en/blocks/dingbats/
Dingbats 2700-27BF
✕✖❓❔❕❗❘❙❚
❛❜❝❞❟❠
❧
❨❩❪❫❬❭❮❯❰❱
❲❳❴❵➔➕➖➗

https://unicode-table.com/en/blocks/miscellaneous-mathematical-symbols-a/
Miscellaneous Mathematical Symbols-A 27C0-27EF
⟦⟧⟨⟩⟪⟫⟬⟭⟮⟯

https://unicode-table.com/en/blocks/supplemental-punctuation/
Supplemental Punctuation 2E00-2E7F
⸘⸜⸝⸠⸡⸢⸣⸤⸥⸦⸧⸨⸩
⸪⸫⸬⸭⸮ⸯ⸰⸱
⸲⸳⸴⸵⸺
⸻⸼⸽⸾⸿⹀
⹁⹂⹃⹄⹌⹎

https://unicode-table.com/en/blocks/cjk-symbols-and-punctuation/
CJK Symbols and Punctuation 3000-303F
　、。〃々〆〈〉《》「」『』【】〒〓
〔〕〖〗〘〙〚〛〜〝〞〟〰〱〲〳〴〵〻〼〼〿

https://unicode-table.com/en/blocks/katakana/
Katakana 30A0-30FF
゠・

https://unicode-table.com/en/blocks/cjk-compatibility-forms/
CJK Compatibility Forms FE30-FE4F
︰︱︲︳︴︵︶︷︸
︹︺︻︼︽︾︿﹀
﹁﹂﹃﹄
﹅﹆
﹇﹈

https://unicode-table.com/en/blocks/arabic-presentation-forms-b/
Arabic Presentation Forms-B
﻿

https://unicode-table.com/en/blocks/halfwidth-and-fullwidth-forms/
Halfwidth and Fullwidth Forms FF00-FFEF
！＂＃＄％＆＇（）＊＋，－．／
：；＜＝＞？＠［＼］＾＿｀｛｜｝～｟｠｡｢｣､
￠￡￢￣￤￥￨￩￪￫￬￭￮

]]--