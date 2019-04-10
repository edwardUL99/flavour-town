local settings = {}
local json = require("json")
local path = system.pathForFile("settings.json", system.DocumentsDirectory)

settings.default = {
  ["left"] = "a",
  ["right"] = "d",
  ["up"] = "w",
  ["down"] = "s",
  ["pause"] = "p",
  ["eat"] = "e",
  ["moveSpeed"] = 20,
  ["volume"] = 10, --1 is 10% volume, 10 is 100% volume
}

settings.custom = {
  ["left"] = "a",
  ["right"] = "d",
  ["up"] = "w",
  ["down"] = "s",
  ["pause"] = "p",
  ["eat"] = "e",
  ["moveSpeed"] = 20,
  ["volume"] = 10,
}

local function load()
  local file = io.open(path, "r")

  if file then
    local contents = file:read("*a")
    io.close(file)
    settings.custom = json.decode(contents)
  end

  for w, v in pairs(settings.custom) do
    print(w .. " " .. v)
  end
  return settings.custom
end

local function save()
  local file = io.open(path, "w")

  if file then
    file:write(json.encode(settings.custom))
    io.close(file)
  end
end

settings.load = load

settings.save = save

local function store(settingName, element)
  if settings.custom[settingName] then
    settings.custom[settingName] = element
  end
end

settings.store = store

return settings
