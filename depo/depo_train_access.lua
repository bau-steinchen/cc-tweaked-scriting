-- train node to find all available trains
local NODE_NAME = "computer_80"
local MODEM_SIDE = "top"
local NOTIFY_OUTPUT = "bottom"

local activePulseTimer = nil
local PULSE_DURATION = 1.0

local modem = peripheral.wrap(MODEM_SIDE)
rednet.open(MODEM_SIDE)

local lastmsg = ""
redstonemsg = ""
local trains = {"None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None"}

local function redraw()
    term.clear()
    term.setCursorPos(1, 1)
    print("=== TRAIN ACCESS NODE ===")
    print("Node: " .. NODE_NAME)
    print("Trains in Depo Present: ")
    print("Depo  1: - " .. trains[1])
    print("Depo  2: - " .. trains[2])
    print("Depo  3: - " .. trains[3])
    print("Depo  4: - " .. trains[4])
    print("Depo  5: - " .. trains[5])
    print("Depo  6: - " .. trains[6])
    print("Depo  7: - " .. trains[7])
    print("Depo  8: - " .. trains[8])
    print("Depo  9: - " .. trains[9])
    print("Depo 10: - " .. trains[10])
    print("Depo 11: - " .. trains[11])
    print("Last Message: " .. lastmsg)
    print(redstonemsg)
end

local function sendNewTrain()
    -- see which elemements not "None"
    local available = {}

    for i, v in ipairs(trains) do
        if v ~= "None" then
            table.insert(available, i)
        end
    end

    if #available == 0 then
        lastmsg = "No Train available doing nothing"
        return false -- no trains available 
    end

    -- select random entry from available items
    local index = available[math.random(#available)]

    -- receiver = index in array and track num
    rednet.broadcast({
        sender = sender,
        track_index = index,
        command = "SEND"
    })
    lastmsg = "New Train from Track " .. index

    -- sending redstone notify that new train is send 
    redstone.setAnalogOutput(NOTIFY_OUTPUT, 15)
    activePulseTimer = os.startTimer(PULSE_DURATION)
end

local function stopPulse()
    redstone.setAnalogOutput(NOTIFY_OUTPUT, 0)
    activePulseTimer = nil
end

local function handleMessage(message)
    if type(message) ~= "table" then return end

    if not message.track_index then return end
    --lastmsg = "New Message from Track: " .. message.track_index

    if message.station then
        if message.station.trainPresent then
            trains[message.track_index] = message.station.trainName or "No Name"
            lastmsg = "New train at track: " .. message.track_index .. tostring(message.station.trainPresent)
        else 
            -- remove train from list when it leaves
            trains[message.track_index] = "None"
            --lastmsg = "Train left at track: " .. message.track_index .. tostring(message.station.trainPresent)
        end
    end
end

redraw()

while true do
    local event, p1, p2, p3 = os.pullEvent()

    if event == "rednet_message" then
        -- depo update event
        local senderId, message, protocol = p1, p2, p3
        handleMessage(message)
        redraw()

    elseif event == "redstone" then
        if redstone.getInput("right") then -- high redstone pulse
            -- Notify from controller to send next train
            redstonemsg = "Redstone signal get - sending new train"
            sendNewTrain()
            redraw()
        end
    elseif event == "timer" then
        if activePulseTimer and p1 == activePulseTimer then
            stopPulse()
            redraw()
        end
    end
end