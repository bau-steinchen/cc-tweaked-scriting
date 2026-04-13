-- state_machine_rednet.lua
-- CC:Tweaked State Machine für Rednet-Broadcasts über ein wired modem

local sender = "controller"

local modem = peripheral.wrap("bottom")
if not rednet.isOpen(peripheral.getName(modem)) then
    rednet.open(peripheral.getName(modem))
end

local running = true
local states = {"idle, stop1, loco_arrived, loco_parked, loco_pickup"}

local current_state = "idle"

local ctx = {
    lastSender = nil,
    lastMessage = nil,
}


local function handleCommand(msg)
    if type(msg) ~= "table" then
        return
    end

    print("New Message arrived: " .. msg.sender)

    -- Handle the state nessesary parts

    -- 1. Idle
    if current_state == "idle" and msg.sender == "computer_58" then
        current_state = "stop1"
        -- decouple on computer 60
        rednet.broadcast({
            sender = sender,
            sleep = 2,
            receiver = "computer_60",
            command = "couple"
            
        })
        print("Broadcast send to computer 60")
    elseif current_state == "stop1" and msg.sender == "computer_60" then 
        -- loco decoupled and sending
        current_state = "loco_arrived"
        sleep(2)

        -- send only loco to park
        rednet.broadcast({
            sender = sender,
            sleep = 2,
            receiver = "computer_58",
            command = "dropoff"
            
        })
        print("Broadcast send to computer 58")
        print("New State: loco_arrived")
    end

    -- 2. locomotive arrived
    if current_state == "loco_arrived" and msg.sender == "computer_57" then
        current_state = "loco_parked"
        print("locomotive parked starting shunting")
    end

    -- 3. locomotive parked

    -- 4. shunting loco arrived

    -- 5. reverse point reached

    -- 6. output 2 reached

    -- 7. output 3 reached

    -- 8. output 4 reached

    -- 9. shunting loco parked

    -- 10. output 4 reached

    -- 11. output 3 reached

    -- 12. output 2 reached

    -- 13. reverse point reached

    -- 14. empty train parked

    -- 15. locomotive back

end


local function handleRednetEvent(sender, message)
    -- Nur gewünschtes Protokoll akzeptieren
    -- if protocol ~= PROTOCOL then
    --     return
    -- end

    -- Nur Broadcast-artige Steuerung verarbeiten:
    -- Rednet-Broadcast kommt ebenfalls als rednet_message an.
    -- Wir unterscheiden hier logisch über den Nachrichteninhalt.
    ctx.lastSender = sender
    ctx.lastMessage = message

    --pushMessage(sender, message, protocol)
    handleCommand(message)
end


print("Controller started.")

while running do
    local event, p1, p2, p3 = os.pullEvent()

    if event == "rednet_message" then
        local sender, message, protocol = p1, p2, p3
        handleRednetEvent(sender, message)
    end
end

print("Programm beendet.")