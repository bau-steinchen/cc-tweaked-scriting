-- state_machine_rednet.lua
-- CC:Tweaked State Machine für Rednet-Broadcasts über ein wired modem

local sender = "controller"

local modem = peripheral.wrap("bottom")
if not rednet.isOpen(peripheral.getName(modem)) then
    rednet.open(peripheral.getName(modem))
end

local running = true
local stopped = false
local states = {"idle", "loco_arrived", "loco_parked", "pickup_full", "move_full", "entry", "output1","output2","output3","pickup1","pickup2","pickup3", "move_empty", "empty_parked", "call_loco", "loco_pickup"}

local current_state = "idle"

local ctx = {
    lastSender = nil,
    lastMessage = nil,
}
local newTrain = nil   -- Call new Train timer
local newTrainTimeout = 10
local activePulseTimer = nil
local messageHistory = {}
local historyCounter = 10

local function getStateIndex(current)
    for i, state in ipairs(states) do
        if state == current then
            return i-1
        end
    end
    return 0
end

local function draw()
    term.clear()
    term.setCursorPos(1, 1)
    print("              === SHUNTING PROCESS ===")
    print(" ____________________________________________________ ")
    print("|                                                    |")
    print("| State:    " .. string.format("%-40s", current_state) .. " |")
    print("|____________________________________________________|")
    print("|                                                    |")
    print("| Progress: " .. string.format("%-40s", (getStateIndex(current_state) .. "/" .. #states)) .. " |")
    print("|____________________________________________________|")
    term.setCursorPos(1, 15)
    print("Message Log:")
    for i, message in ipairs(messageHistory) do
        print(message)
    end
end

local function addMessage(text) 
    table.insert(messageHistory, tostring(text))
    if #messageHistory > historyCounter then
        table.remove(messageHistory, 1)
    end
end

local function OutputStation(receiver)
    print("Output Station Reached")
    sleep(1)
    rednet.broadcast({
        sender = sender,
        receiver = receiver, --> Couple
        command = "couple"
        
    })
    sleep(3)
    rednet.broadcast({
        sender = sender,
        receiver = receiver,
        command = "send"
        
    }) 
    addMessage("Broadcast send to " .. receiver)
end

local function handleCommand(msg)
    if type(msg) ~= "table" then
        return
    end

    -- Handle the state nessesary parts
    -- 
    -- 1. Idle
    if current_state == "idle" and msg.sender == "computer_58" then
        current_state = "loco_arrived"
        -- shunting startet reset new Train caller
        stopped = false
        -- decouple on computer 60
        sleep(1)
        rednet.broadcast({
            sender = sender,
            receiver = "computer_60",
            command = "couple"
            
        })
        sleep(2)
        rednet.broadcast({
            sender = sender,
            receiver = "computer_60",
            command = "dropoff"
            
        })
        
        addMessage("Broadcast send to computer 60")
        addMessage("New State: loco_arrived")
    end

    -- 2. locomotive arrived
    if current_state == "loco_arrived" and msg.sender == "computer_57" then
        current_state = "loco_parked"
        addMessage("locomotive parked starting shunting")

        rednet.broadcast({
            sender = sender,
            sleep = 2,
            receiver = "computer_71",
            command = "couple"
            
        })

    end

    -- 3. locomotive parked
    if current_state == "loco_parked" and msg.sender == "computer_61" then
        current_state = "pickup_full"
        -- locomotive stoped to pick up cargo
        sleep(1)
        rednet.broadcast({
            sender = sender,
            receiver = "computer_61",
            command = "couple"
            
        })
        addMessage("Broadcast send to computer 61")
        sleep(2)
        rednet.broadcast({
            sender = sender,
            receiver = "computer_61",
            command = "dropoff"
            
        })
        sleep(2)
    end

    -- 4. reverse point reached
    if current_state == "pickup_full" and msg.sender == "computer_56" then
        current_state = "move_full"
        print("Reverse Point reached sending back")
        sleep(1)
        rednet.broadcast({
            sender = sender,
            receiver = "computer_56",
            command = "couple"
            
        })
        addMessage("Broadcast send to computer 56")
    end
    
    -- 5. entry
    if current_state == "move_full" and msg.sender == "computer_77" then
        current_state = "entry"
        print("Entry Point Reached")
        -- sleep(1)
        -- rednet.broadcast({
        --     sender = sender,
        --     receiver = "computer_xx", --> Open gate 2
        --     command = "couple"
            
        -- })
        sleep(3)
        rednet.broadcast({
            sender = sender,
            receiver = "computer_77",
            command = "couple"
            
        }) 
        addMessage("Broadcast send to computer 77")
    end

    -- 6. output 2 reached
    if current_state == "entry" and msg.sender == "computer_63" then
        current_state = "output1"
        OutputStation("computer_63")
    end
    if current_state == "output1" and msg.sender == "computer_59" then
        rednet.broadcast({
            sender = sender,
            receiver = "computer_59",
            command = "send"
            
        }) 
        addMessage("Broadcast send to computer 59")
    end

    -- 7. output 3 reached
    if current_state == "output1" and msg.sender == "computer_64" then
        current_state = "output2"
        OutputStation("computer_64")
    end
    if current_state == "output2" and msg.sender == "computer_59" then
        rednet.broadcast({
            sender = sender,
            receiver = "computer_59",
            command = "send"
            
        }) 
        addMessage("Broadcast send to computer 59")
    end

    -- 8. output 4 reached
    if current_state == "output2" and msg.sender == "computer_65" then
        current_state = "output3"
        OutputStation("computer_65")
        sleep(1)
    end
    if current_state == "output3" and msg.sender == "computer_78" then --> Empty event need to be defined 
        current_state = "pickup3"
        rednet.broadcast({
            sender = sender,
            receiver = "computer_59",
            command = "send"
            
        }) 
        addMessage("Broadcast send to computer 59")
    end

    -- 9. output 4 reached
    if current_state == "pickup3" and msg.sender == "computer_65" then
        current_state = "pickup2"
        OutputStation("computer_65")
    end
    if current_state == "pickup2" and msg.sender == "computer_59" then
        rednet.broadcast({
            sender = sender,
            receiver = "computer_59",
            command = "send"
            
        }) 
        addMessage("Broadcast send to computer 59")
    end

    -- 10. output 3 reached
    if current_state == "pickup2" and msg.sender == "computer_64" then
        current_state = "pickup1"
        OutputStation("computer_64")
    end
    if current_state == "pickup1" and msg.sender == "computer_59" then
        rednet.broadcast({
            sender = sender,
            receiver = "computer_59",
            command = "send"
            
        }) 
        addMessage("Broadcast send to computer 59")
    end

    -- 11. output 2 reached
    if current_state == "pickup1" and msg.sender == "computer_63" then
        current_state = "move_empty"
        OutputStation("computer_63")
    end

    -- 12. reverse point reached
    if current_state == "move_empty" and msg.sender == "computer_56" then --> arrived turn 
        current_state = "empty_parked"
        sleep(1)
        rednet.broadcast({
            sender = sender,
            receiver = "computer_56",
            command = "send"
            
        })
    end

    -- 13. empty train parked
    if current_state == "empty_parked" and msg.sender == "computer_60" then --> empty waggons parked
        current_state = "call_loco"
        addMessage("Broadcast send to computer 61")
        sleep(2)
        rednet.broadcast({
            sender = sender,
            receiver = "computer_61",
            command = "couple"
            
        })
        sleep(2)
        rednet.broadcast({
            sender = sender,
            receiver = "computer_61",
            command = "dropoff"
            
        })
        addMessage("Broadcast send to computer 61")
    end

    -- 14. call loco when shunting loco parked
    if current_state == "call_loco" and msg.sender == "computer_71" then
        current_state = "loco_pickup"
        sleep(1)
        rednet.broadcast({
            sender = sender,
            sleep = 2,
            receiver = "computer_57",
            command = "couple"
            
        })
    end

    -- 15. locomotive back
    if current_state == "loco_pickup" and msg.sender == "computer_60" then
        sleep(1)
        -- couple on computer 60
        rednet.broadcast({
            sender = sender,
            receiver = "computer_60",
            command = "couple"
            
        })
        sleep(2)
        rednet.broadcast({
            sender = sender,
            receiver = "computer_60",
            command = "pickup"
            
        })
        rednet.broadcast({
            sender = sender,
            receiver = "computer_61",
            command = "pickup"
            
        })
        sleep(2)
        addMessage("Broadcast send to computer 60")
        addMessage("New State: idle")
        sleep(10)
        current_state = "idle"
        
        newTrain = os.startTimer(newTrainTimeout)
        addMessage("New call Timer: " .. newTrain)
    end
end

addMessage("Controller started.")
newTrain = os.startTimer(newTrainTimeout)

while running do
    local event, p1, p2, p3 = os.pullEvent()

    if event == "rednet_message" then
        local sender, message, protocol = p1, p2, p3
        ctx.lastSender = sender
        ctx.lastMessage = message
        handleCommand(message)
        draw()
    elseif event == "timer" then 
        --print("Timer Event: " .. p1)
        local timerId = p1
        if timerId == newTrain then
            addMessage("Timer newTrain with " .. tostring(stopped))
            if stopped ~= true and current_state == "idle" then
                redstone.setAnalogOutput("back", 15)
                newTrain = os.startTimer(newTrainTimeout)
                activePulseTimer = os.startTimer(1)
                addMessage("New Pulse Timer: " .. activePulseTimer .. " and new call Timer: " .. newTrain)
            else 
                stopped = false
                newTrain = nil
                addMessage("Stopped Value ist reset: " .. tostring(stopped))
            end

        elseif timerId == activePulseTimer then
            addMessage("pulse deactivated:" .. timerId)
            redstone.setAnalogOutput("back", 0)
            activePulseTimer = nil
        end
        draw()
    elseif event == "redstone" then
        if stopped ~= true then 
            -- stop newTrain timer
            addMessage("Signal get new train on the way")
            stopped = true
            draw()
        end
    end
end

print("Programm beendet.")