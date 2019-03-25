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
            -- bread
            x=1,
            y=87,
            width=73,
            height=60,

            sourceX = 38,
            sourceY = 29,
            sourceWidth = 155,
            sourceHeight = 114
        },
        {
            -- broccoli
            x=76,
            y=87,
            width=45,
            height=54,

            sourceX = 43,
            sourceY = 28,
            sourceWidth = 155,
            sourceHeight = 114
        },
        {
            -- burger
            x=1,
            y=1,
            width=91,
            height=84,

            sourceX = 33,
            sourceY = 13,
            sourceWidth = 155,
            sourceHeight = 114
        },
        {
            -- lettuce
            x=72,
            y=149,
            width=55,
            height=62,

            sourceX = 36,
            sourceY = 17,
            sourceWidth = 155,
            sourceHeight = 114
        },
        {
            -- tomato
            x=1,
            y=149,
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

    ["bread"] = 1,
    ["broccoli"] = 2,
    ["burger"] = 3,
    ["lettuce"] = 4,
    ["tomato"] = 5,
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
