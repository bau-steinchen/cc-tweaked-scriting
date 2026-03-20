-- Create Train Station Monitor (CC:Tweaked)
local station = nil
local sides = {"left", "right", "front", "back", "up", "down"}

-- Finde die Train Station Peripheral
for _, side in ipairs(sides) do
    local per = peripheral.wrap(side)
    if per and per.getStationName then
        station = per
        print("Train Station gefunden auf " .. side)
        break
    end
end

if not station then
    error("Keine Train Station gefunden!")
end

while true do
    local ok, err = pcall(function()
        -- Alle verfügbaren Infos auslesen
        local name = station.getStationName()
        local trainPresent = station.isTrainPresent()
        local trainImminent = station.isTrainImminent()
        local trainEnroute = station.isTrainEnroute()
        local assemblyMode = station.isInAssemblyMode()
        local trainName = trainPresent and station.getTrainName() or "Keine"

        -- Auf Monitor anzeigen (clear & print)
        term.clear()
        term.setCursorPos(1,1)
        print("=== Train Station Monitor ===")
        print("Name: " .. (name or "Unbekannt"))
        print("Zug da: " .. tostring(trainPresent))
        print("Zug nah: " .. tostring(trainImminent))
        print("Zug unterwegs: " .. tostring(trainEnroute))
        print("Assembly Mode: " .. tostring(assemblyMode))
        print("Aktueller Zug: " .. trainName)
    end)
    
    if not ok then
        print("Fehler: " .. tostring(err))
    end
    
    sleep(2)  -- 2 Sekunden warten
end
