-- Signal and station node with accepting broadcasts

local signalName = "Create_Signal_4"
local stationName = "travel trough"
local sender = "computer_14"

-- Helper function: compare tables
local function tablesEqual(t1, t2)
    if type(t1) ~= type(t2) then return false end
    if type(t1) ~= "table" then return t1 == t2 end
    local keys1, keys2 = {}, {}
    for k in pairs(t1) do keys1[k] = true end
    for k in pairs(t2) do keys2[k] = true end
    for k in pairs(keys1) do if not keys2[k] then return false end end
    for k in pairs(keys2) do if not keys1[k] then return false end end
    for k, v1 in pairs(t1) do
        local v2 = t2[k]
        if not tablesEqual(v1, v2) then return false end
    end
    return true
end

-- Signal
local signal = peripheral.wrap(signalName)

-- Station
local station = peripheral.wrap("front")
local ok, err = pcall(station.setStationName, stationName, station)
if ok then
    print("Name set: " .. station.getStationName())
else
    print("Error: Can't set to " .. tostring(err))
end

local modem = peripheral.wrap("bottom")
rednet.open(peripheral.getName(modem))

local lastData = {signal = {}, station = {}}

local lastMessage = {sender="none"}
local lastSend = "None"

while true do
    -- REDNET CHECK (non-blocking, 0.7 Sec. Timeout)
    local id, message = rednet.receive(0.7)
    if message then
        if type(message) == "table" then
            if message.receiver == sender or message.receiver == "ALL" then
                lastMessage = message
                print("Receivec message: " .. tostring(lastMessage.sender), tostring(lastMessage.signal))
                -- and event for this computer occured
                if message.signal == "RED" then
                    signal.setForcedRed(true)
                else 
                    signal.setForcedRed(false)
                end
            end
        end
    end

    -- -- SIGNAL CHECK (periodic)
    local currentData = {
        sender = sender,
        signal = {
            name = peripheral.getName(signal),
            state = signal.getState(),
            signalType = signal.getSignalType()
        },
        station = {
            name = station.getStationName(),
            trainPresent = station.isTrainPresent(),
            trainImminent = station.isTrainImminent(),
            trainEnroute = station.isTrainEnroute(),
            assemblyMode = station.isInAssemblyMode(),
            trainName = station.isTrainPresent() and station.getTrainName() or "None"
        }
    }
    
    -- check for any changes
    local changed = false
    for category, data in pairs(currentData) do
        if not tablesEqual(lastData[category], data) then
            changed = true
            break
        end
    end
    
    if changed then
        rednet.broadcast(currentData)
        lastSend = tostring(lastData.signal.state)
        lastData = currentData

        -- Optional: Terminal-Status
        term.clear()
        term.setCursorPos(1,1)
        print("=== MONITOR ===")
        print("Signal State: " .. tostring(currentData.signal.state))
        print("Station: " .. currentData.station.name)
        print("Train: " .. tostring(currentData.station.trainPresent) .. " (" .. currentData.station.trainName .. ")")
        print("Rednet letzte Msg: " .. tostring(lastMessage.sender))
        print("Changes signal from: " .. lastSend)
    end
    sleep(0.1)
end
