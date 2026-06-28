local station = peripheral.wrap("top")

if not station then
  error("Keine Station am top-Side gefunden.")
end

local function pulse(side, seconds)
  redstone.setOutput(side, true)
  sleep(seconds)
  redstone.setOutput(side, false)
end

local wasPresent = false

redstone.setOutput("back", false)
redstone.setOutput("top", false)

while true do
  local ok, isPresent = pcall(function()
    return station.isTrainPresent()
  end)

  if not ok then
    print("Fehler beim Lesen der Station.")
    sleep(5)
  else
    if isPresent and not wasPresent then
        term.clear()
        print("Empty Train arrived.")

        pulse("back", 1)
        sleep(25)
        pulse("back", 1)
        sleep(5)
        pulse("top", 1)

        print("Full Train was send again.")
    end

    wasPresent = isPresent
    sleep(5)
  end
end