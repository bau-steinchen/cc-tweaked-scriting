-- Single output node: reagiert nur auf command = "dropoff"

local NODE_NAME = "computer_58"
local MODEM_SIDE = "bottom"
local DROPOFF_SIDE = "right"
local PULSE_DURATION = 1.0
local POLL_INTERVAL = 0.5

local modem = peripheral.wrap(MODEM_SIDE)
rednet.open(MODEM_SIDE)

local activePulseTimer = nil
local lastData = {
    sender = NODE_NAME,
    station = { trainPresent = false }
}
local currentData = lastData
local lastMessage = { sender = "none" }
local pollTimer = nil

local station = peripheral.wrap("top")

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
    print("=== DROPOFF NODE ===")
    print("Node: " .. NODE_NAME)
    print("Train Present: " .. tostring(currentData.station.trainPresent))
    print("Last sender: " .. tostring(lastMessage.sender))
    print("Last command: " .. tostring(lastMessage.command))
    print("Output active: " .. tostring(rs.getOutput(DROPOFF_SIDE)))
end

local function pulseDropoff()
    redstone.setAnalogOutput(DROPOFF_SIDE, 15)
    activePulseTimer = os.startTimer(PULSE_DURATION)
    redraw()
end

local function stopDropoff()
    redstone.setAnalogOutput(DROPOFF_SIDE, 0)
    activePulseTimer = nil
    redraw()
end

local function readStation()
    local currentData = {
        sender = NODE_NAME,
        station = {
            trainPresent = station.isTrainPresent()
        },
    }

    if not tablesEqual(lastData, currentData) then
        rednet.broadcast(currentData)
        lastData = currentData
        redraw(currentData)
    end
end

local function handleMessage(senderId, message, protocol)
    if type(message) ~= "table" then
        return
    end

    lastMessage = message

    print("Empfangen von ID: " .. tostring(senderId))
    dump(message)

    if message.receiver and message.receiver ~= NODE_NAME then
        return
    end

    if message.command == "dropoff" then
        if message.sleep ~= nil then
            sleep(message.sleep)
        end
        pulseDropoff()
        print("Command ausgeführt: dropoff")
    else
        print("Ignoriert, unknown command! ")
    end
end


redraw(lastData)
pollTimer = os.startTimer(0.1)
while true do
    local event, p1, p2, p3 = os.pullEvent()

    if event == "rednet_message" then
        local senderId, message, protocol = p1, p2, p3
        handleMessage(senderId, message, protocol)

    elseif event == "timer" then
        local timerId = p1

        if activePulseTimer and p1 == activePulseTimer then
            stopDropoff()
        elseif timerId == pollTimer then
            readStation()
            pollTimer = os.startTimer(POLL_INTERVAL)
        end
    end
end