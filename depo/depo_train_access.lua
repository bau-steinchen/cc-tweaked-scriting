-- Single output node: reagiert nur auf command = "dropoff"

local NODE_NAME = "computer_80"
local MODEM_SIDE = "bottom"

local modem = peripheral.wrap(MODEM_SIDE)
rednet.open(MODEM_SIDE)


local trains = ["None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None"]

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
        return false -- no trains available 
    end

    -- select random entry from available items
    local index = available[math.random(#available)]

    -- receiver = index in array and track num
    rednet.broadcast({
        sender = sender,
        track_index = index,
        command = "send"
    })
end



local function handleMessage(message)
    if type(message) ~= "table" then return end
    
    if message.station then
        if message.station.isTrainPresent then
            trains[message.track_index] = message.station.trainName or "No Name"
        else 
            -- remove train from list when it leaves
            trains[message.track_index] = "None"
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
        -- Notify from controller to send next train
        sendNewTrain()
        redraw()
    end
end