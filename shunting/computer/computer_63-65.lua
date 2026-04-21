-- Coupler Node mit Redstone-Station-Inputs + command-Steuerung

local NODE_NAME = "computer_63"
local MODEM_SIDE = "bottom"

-- Outputs
local COUPLE_SIDE = "back"
local SEND_SIDE = "front"

-- Inputs
local STATION = "left"
local STATION_SHORT = "right"

local OUTPUT_PULSE_DURATION = 1.0
local POLL_INTERVAL = 0.5

local modem = peripheral.wrap(MODEM_SIDE)
if not modem then
    error("Kein Modem an " .. MODEM_SIDE)
end

rednet.open(MODEM_SIDE)

local lastData = {
    sender = NODE_NAME,
    station = { trainPresent = false },
    station_short = { trainPresent = false }
}

local lastMessage = { sender = "none" }
local pollTimer = nil

local activePulseTimers = {}

local function tablesEqual(t1, t2)
    if type(t1) ~= type(t2) then return false end
    if type(t1) ~= "table" then return t1 == t2 end

    local seen = {}
    for k, v in pairs(t1) do
        seen[k] = true
        if not tablesEqual(v, t2[k]) then
            return false
        end
    end

    for k in pairs(t2) do
        if not seen[k] then
            return false
        end
    end

    return true
end

local function dump(value, indent, seen)
    indent = indent or ""
    seen = seen or {}

    if type(value) ~= "table" then
        print(indent .. tostring(value))
        return
    end

    if seen[value] then
        print(indent .. "<cycle>")
        return
    end
    seen[value] = true

    print(indent .. "{")
    for k, v in pairs(value) do
        io.write(indent .. "  [" .. tostring(k) .. "] = ")
        if type(v) == "table" then
            print()
            dump(v, indent .. "  ", seen)
        else
            print(tostring(v))
        end
    end
    print(indent .. "}")
end

local function redraw(currentData)
    term.clear()
    term.setCursorPos(1, 1)
    print("=== COUPLER NODE ===")
    print("Node: " .. NODE_NAME)
    print("Pickup in  (" .. STATION .. "): " .. tostring(currentData.station.trainPresent))
    print("Dropoff in (" .. STATION_SHORT .. "): " .. tostring(currentData.station_short.trainPresent))
    print("Last msg sender: " .. tostring(lastMessage.sender))
    print("Last command: " .. tostring(lastMessage.command))
end

local function pulseSide(side, duration)
    redstone.setAnalogOutput(side, 15)
    local timerId = os.startTimer(duration or OUTPUT_PULSE_DURATION)
    activePulseTimers[timerId] = side
end

local function readRedstoneStations()
    local currentData = {
        sender = NODE_NAME,
        station = {
            trainPresent = rs.getInput(STATION)
        },
        station_short = {
            trainPresent = rs.getInput(STATION_SHORT)
        }
    }

    if not tablesEqual(lastData, currentData) then
        rednet.broadcast(currentData)
        lastData = currentData
        redraw(currentData)
    end
end

local function handleCommand(message)
    local command = message.command

    if command == "couple" then
        
        pulseSide(COUPLE_SIDE, OUTPUT_PULSE_DURATION)
        print("Command ausgeführt: couple")

    elseif command == "send" then
        pulseSide(SEND_SIDE, OUTPUT_PULSE_DURATION)
        print("Command ausgeführt: send")
    else
        print("Unbekannter command: " .. tostring(command))
    end
end

local function handleMessage(senderId, message, protocol)
    if type(message) ~= "table" then
        return
    end

    if message.receiver and message.receiver ~= NODE_NAME then
        return
    end
    
    lastMessage = message
    print("Empfangen von ID: " .. tostring(senderId))
    dump(message)

    if message.command then
        handleCommand(message)
    end
end

pollTimer = os.startTimer(0.1)
redraw(lastData)

while true do
    local event, p1, p2, p3 = os.pullEvent()

    if event == "rednet_message" then
        local senderId, message, protocol = p1, p2, p3
        handleMessage(senderId, message, protocol)
        redraw(lastData)

    elseif event == "timer" then
        local timerId = p1

        if timerId == pollTimer then
            readRedstoneStations()
            pollTimer = os.startTimer(POLL_INTERVAL)

        elseif activePulseTimers[timerId] then
            local side = activePulseTimers[timerId]
            redstone.setAnalogOutput(side, 0)
            activePulseTimers[timerId] = nil
        end
        redraw(lastData)

    elseif event == "redstone" then
        readRedstoneStations()
        redraw(lastData)
    end
end