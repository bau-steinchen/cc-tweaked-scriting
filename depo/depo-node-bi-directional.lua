-- Signal and station node with accepting broadcasts

local signalName = "Create_Signal_5"
local stationName = "Depo"
local sender = "computer_13"
local track_index = 1


local MODEM_SIDE = "bottom"
local DROPOFF_SIDE = "front"
local PULSE_DURATION = 1.0
local POLL_INTERVAL = 0.5
local activePulseTimer = nil
local pollTimer = nil

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
local station = peripheral.wrap(DROPOFF_SIDE)
local ok, err = pcall(station.setStationName, stationName, station)
if ok then
    print("Name set: " .. station.getStationName())
else
    print("Error: Can't set to " .. tostring(err))
end

local modem = peripheral.wrap("bottom")
rednet.open(peripheral.getName(modem))

local lastData = {signal = {}, station = {}}
local currentData = {signal = {}, station = {name="None", trainPresent = false}}

local lastMessage = {sender="none"}
local lastSend = "None"

local function draw()
    -- Optional: Terminal-Status
    term.clear()
    term.setCursorPos(1,1)
    print("=== MONITOR ===")
    print("Signal State: " .. tostring(currentData.signal.state) or "")
    print("Station: " .. currentData.station.name or "")
    print("Train: " .. tostring(currentData.station.trainPresent) or "" .. " (" .. currentData.station.trainName or "" .. ")")
    print("Rednet letzte Msg: " .. tostring(lastMessage.sender))
    print("Changes signal from: " .. lastSend)
end

local function pulseDropoff()
    redstone.setAnalogOutput(DROPOFF_SIDE, 15)
    activePulseTimer = os.startTimer(PULSE_DURATION)
end

local function stopDropoff()
    redstone.setAnalogOutput(DROPOFF_SIDE, 0)
    activePulseTimer = nil
end

local function readStation()
    local success, trainPresent = pcall(function()
        return station.isTrainPresent()
    end)
    
    -- -- SIGNAL CHECK (periodic)
    currentData = {
        sender = sender,
        track_index = track_index,
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
    end
end

local function handleMessage(message)
    if type(message) ~= "table" then return end

    if message.receiver == sender or message.receiver == "ALL" then
        lastMessage = message
        print("Receive message: " .. tostring(lastMessage.sender), tostring(lastMessage.signal))
        -- and event for this computer occured
        if message.signal == "RED" then
            signal.setForcedRed(true)
        else 
            signal.setForcedRed(false)
        end
    end

    if message.track_index and message.track_index ~= track_index then return end
    -- message has current track index sending train
    pulseDropoff()

end

readStation()
draw()
pollTimer = os.startTimer(POLL_INTERVAL)
stopDropoff()

while true do
    local event, p1, p2, p3 = os.pullEvent()

    if event == "rednet_message" then
        local sender, message, protocol = p1, p2, p3
        handleMessage(message)
        draw()
    elseif event == "timer" then 
        local timerId = p1

        if activePulseTimer and timerId == activePulseTimer then
            stopDropoff()

        elseif pollTimer and timerId == pollTimer then
            readStation()
            pollTimer = os.startTimer(POLL_INTERVAL)
        end
        draw()
    end
end
