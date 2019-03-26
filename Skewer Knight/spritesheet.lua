--
-- created with TexturePacker - https://www.codeandweb.com/texturepacker
--
-- $TexturePacker:SmartUpdate:81ee5f465e40320d943fe47d8e487f8b:0389c017d81de7ef748b1cb1094e5e49:c46243f411ca86fe596665ab352bd775$
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
            -- sushi
            x=56,
            y=27,
            width=200,
            height=200,

            sourceX = 38,
            sourceY = 29,
            sourceWidth = 155,
            sourceHeight = 114,
        },
        {
            -- tomato
            x=174,
            y=317,
            width=45,
            height=54,

            sourceX = 43,
            sourceY = 28,
            sourceWidth = 155,
            sourceHeight = 114
        },
        {
            -- carrot
            x=212,
            y=573,
            width=91,
            height=84,

            sourceX = 33,
            sourceY = 13,
            sourceWidth = 155,
            sourceHeight = 114
        },
        {
            --cheese
            x=148,
            y=801,
            width=55,
            height=62,

            sourceX = 36,
            sourceY = 17,
            sourceWidth = 155,
            sourceHeight = 114
        },
        {
            -- bacon
            x=431,
            y=45,
            width=69,
            height=70,

            sourceX = 36,
            sourceY = 7,
            sourceWidth = 155,
            sourceHeight = 114
        },
    },

    sheetContentWidth = 128,
    sheetContentHeight = 220
}

SheetInfo.frameIndex =
{

    ["sushi"] = 1,
    ["tomato"] = 2,
    ["carrot"] = 3,
    ["cheese"] = 4,
    ["bacon"] = 5,
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
