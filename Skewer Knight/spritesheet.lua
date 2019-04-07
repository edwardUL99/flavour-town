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
            x=0,
            y=0,
            width=200,
            height=200,

            sourceX = 100,
            sourceY = 100,
            sourceWidth = 400,
            sourceHeight = 400
        },
        {
            -- brocolli
            x=200,
            y=0,
            width=200,
            height=200,

            sourceX = 100,
            sourceY = 100,
            sourceWidth = 200,
            sourceHeight = 200
        },
        {
            -- carrot
            x=400,
            y=0,
            width=200,
            height=200,

            sourceX = 100,
            sourceY = 100,
            sourceWidth = 200,
            sourceHeight = 200
        },
        {
            -- cheese
            x=0,
            y=200,
            width=200,
            height=200,

            sourceX = 100,
            sourceY = 100,
            sourceWidth = 200,
            sourceHeight = 200
        },
        {
            -- sushi
            x=200,
            y=200,
            width=200,
            height=200,

            sourceX = 100,
            sourceY = 100,
            sourceWidth = 200,
            sourceHeight = 200
        },
        {
            -- tomato
            x=400,
            y=200,
            width=200,
            height=200,

            sourceX = 100,
            sourceY = 100,
            sourceWidth = 200,
            sourceHeight = 200
        },
    },

    sheetContentWidth = 600,
    sheetContentHeight = 400
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
