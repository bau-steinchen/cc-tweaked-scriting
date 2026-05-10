-- Single output node: reagiert nur auf command = "dropoff"

local NODE_NAME = "computer_56"
local MODEM_SIDE = "bottom"
local DROPOFF_SIDE = "right"
local PULSE_DURATION = 1.0
local POLL_INTERVAL = 0.5

local modem = peripheral.wrap(MODEM_SIDE)
rednet.open(MODEM_SIDE)

local activePulseTimer = nil
local pollTimer = nil
local lastData = { sender = NODE_NAME, station = { trainPresent = false } }
local lastMessage = { sender = "none" }

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

local function redraw(currentData)
    term.clear()
    term.setCursorPos(1, 1)
    print("=== RETURN NODE ===")
    print("Node: " .. NODE_NAME)
    print("Train Present: " .. tostring(currentData.station.trainPresent))
    print("Last sender: " .. tostring(lastMessage.sender))
    print("Last command: " .. tostring(lastMessage.command))
    print("Output active: " .. tostring(rs.getOutput(DROPOFF_SIDE)))
end

local function pulseDropoff()
    print("power on")
    redstone.setAnalogOutput(DROPOFF_SIDE, 15)
    activePulseTimer = os.startTimer(PULSE_DURATION)
end

local function stopDropoff()
    print("power off")
    redstone.setAnalogOutput(DROPOFF_SIDE, 0)
    activePulseTimer = nil
end

local function readStation()
    local success, trainPresent = pcall(function()
        return station.isTrainPresent()
        -- return redstone.getInput("back")
    end)
        
    local currentData = {
        sender = NODE_NAME,
        station = { trainPresent = success and trainPresent or false }
        -- station = { trainPresent = redstone.getInput("back")}
    }

    if not tablesEqual(lastData, currentData) then
        rednet.broadcast(currentData)
        lastData = currentData
        redraw(currentData)
    end
end

local function handleMessage(senderId, message, protocol)
    if type(message) ~= "table" then return end

    if message.receiver and message.receiver ~= NODE_NAME then return end

    lastMessage = message
    if message.command == "couple" then 
        sleep(1)
        pulseDropoff()
    end
    
end

readStation()
redraw(lastData)
pollTimer = os.startTimer(POLL_INTERVAL)

while true do
    local event, p1, p2, p3 = os.pullEvent()

    if event == "rednet_message" then
        local senderId, message, protocol = p1, p2, p3
        handleMessage(senderId, message, protocol)
        redraw(lastData)

    elseif event == "timer" then
        local timerId = p1

        if activePulseTimer and timerId == activePulseTimer then
            stopDropoff()

        elseif pollTimer and timerId == pollTimer then
            readStation()
            pollTimer = os.startTimer(POLL_INTERVAL)
        end
        redraw(lastData)
    end
end