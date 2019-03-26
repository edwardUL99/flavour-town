--
-- created with TexturePacker - https://www.codeandweb.com/texturepacker
--
-- $TexturePacker:SmartUpdate:1dc8820a44ab470e88489a9fe836f7bf:74a32c161e96ccd7bb0d2379b259613d:c46243f411ca86fe596665ab352bd775$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- bacon
            x=235,
            y=709,
            width=122,
            height=272,

            sourceX = 49,
            sourceY = 39,
            sourceWidth = 200,
            sourceHeight = 350
        },
        {
            -- brocolli
            x=1,
            y=385,
            width=252,
            height=262,

            sourceX = 19,
            sourceY = 19,
            sourceWidth = 290,
            sourceHeight = 300
        },
        {
            -- carrot
            x=1,
            y=883,
            width=222,
            height=172,

            sourceX = 9,
            sourceY = 19,
            sourceWidth = 270,
            sourceHeight = 200
        },
        {
            -- cheese
            x=2,
            y=1,
            width=502,
            height=382,

            sourceX = 48,
            sourceY = 8,
            sourceWidth = 550,
            sourceHeight = 390
        },
        {
            -- sushi
            x=255,
            y=385,
            width=192,
            height=322,

            sourceX = 39,
            sourceY = 19,
            sourceWidth = 270,
            sourceHeight = 360
        },
        {
            -- tomato
            x=1,
            y=649,
            width=232,
            height=232,

            sourceX = 9,
            sourceY = 19,
            sourceWidth = 260,
            sourceHeight = 290
        },
    },

    sheetContentWidth = 504,
    sheetContentHeight = 1056
}

SheetInfo.frameIndex =
{

    ["bacon"] = 1,
    ["broccoli"] = 2,
    ["carrot"] = 3,
    ["cheese"] = 4,
    ["sushi"] = 5,
    ["tomato"] = 6,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

function SheetInfo:getWidth(name)
  return self.sheet.frames[self.frameIndex[name]].width
end

function SheetInfo:getHeight(name)
  return self.sheet.frames[self.frameIndex[name]].height
end

return SheetInfo
