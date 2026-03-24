local modem = peripheral.wrap("bottom")
rednet.open(peripheral.getName(modem))

local mon = peripheral.wrap("monitor_0")
mon.setTextScale(1)
mon.setBackgroundColor(colors.black)
mon.clear()

-------------------------------------------------
-- Konfiguration
-------------------------------------------------

local Nodes = {
    Checkpoint  = { row = 13, textX = 38,  name = "computer_14", text="Checkpoint", type="Station", signal="Create_Signal_4", offset= 12},
    depo1       = { row = 12, textX = 45,  name = "computer_13", text="Depo",       type="Station", signal="Create_Signal_5", offset= 6},
    depo2       = { row = 11, textX = 45,  name = "computer_12", text="Depo",       type="Station", signal="Create_Signal_6", offset= 6},
    depo3       = { row = 10, textX = 45,  name = "computer_11", text="Depo",       type="Station", signal="Create_Signal_7", offset= 6},
    depo4       = { row = 9 , textX = 45,  name = "computer_10", text="Depo",       type="Station", signal="Create_Signal_8", offset= 6},
    depo5       = { row = 8 , textX = 45,  name = "computer_9" , text="Depo",       type="Station", signal="Create_Signal_9", offset= 6},
    depo6       = { row = 7 , textX = 45,  name = "computer_8" , text="Depo",       type="Station", signal="Create_Signal_10", offset= 6},
    depo7       = { row = 6 , textX = 45,  name = "computer_7" , text="Depo",       type="Station", signal="Create_Signal_11", offset= 6},
    depo8       = { row = 5 , textX = 45,  name = "computer_6" , text="Depo",       type="Station", signal="Create_Signal_12", offset= 6},
    depo9       = { row = 4 , textX = 45,  name = "computer_5" , text="Depo",       type="Station", signal="Create_Signal_13", offset= 6},
    depo10      = { row = 3 , textX = 45,  name = "computer_4" , text="Depo",       type="Station", signal="Create_Signal_14", offset= 6},
    depo11      = { row = 2 , textX = 45,  name = "computer_3" , text="Depo",       type="Station", signal="Create_Signal_15", offset= 6},
    -- Signals
    entry1      = { row = 21, textX = 6,   name = "computer_51", text=" ", type="signal", signal="Create_Signal_18"},
    entry2      = { row = 16, textX = 10,  name = "computer_46", text=" ", type="signal", signal="top"},
    entry3      = { row = 19, textX = 16,  name = "computer_47", text=" ", type="signal", signal="Create_Signal_3"},
    entry4      = { row = 13, textX = 15,  name = "computer_20", text=" ", type="signal", signal="top"},
    entry5      = { row = 12, textX = 15,  name = "computer_21", text=" ", type="signal", signal="top"},
    entry6      = { row = 11, textX = 15,  name = "computer_22", text=" ", type="signal", signal="top"},
    entry7      = { row = 10, textX = 15,  name = "computer_23", text=" ", type="signal", signal="top"},
    entry8      = { row = 9 , textX = 15,  name = "computer_24", text=" ", type="signal", signal="top"},
    entry9      = { row = 8 , textX = 15,  name = "computer_25", text=" ", type="signal", signal="top"},
    entry10     = { row = 7 , textX = 15,  name = "computer_26", text=" ", type="signal", signal="top"},
    entry11     = { row = 6 , textX = 15,  name = "computer_27", text=" ", type="signal", signal="top"},
    entry12     = { row = 5 , textX = 15,  name = "computer_28", text=" ", type="signal", signal="top"},
    entry13     = { row = 4 , textX = 15,  name = "computer_29", text=" ", type="signal", signal="top"},
    entry14     = { row = 3 , textX = 15,  name = "computer_30", text=" ", type="signal", signal="top"},
    entry15     = { row = 2 , textX = 15,  name = "computer_31", text=" ", type="signal", signal="top"},
    entry16     = { row = 16, textX = 59,  name = "computer_17", text=" ", type="signal", signal="top"},
    entry17     = { row = 17, textX = 64,  name = "computer_18", text=" ", type="signal", signal="top"},
    entry18     = { row = 19, textX = 56,  name = "computer_19", text=" ", type="signal", signal="Create_Signal_17"},
    entry19     = { row = 17, textX = 54,  name = "computer_52", text=" ", type="signal", signal="top"},
    entry20     = { row = 19, textX = 63,  name = "computer_53", text=" ", type="signal", signal="Create_Signal_19"},
    entry21     = { row = 2 , textX = 14,  name = "computer_55", text=" ", type="signal", signal="top"},
}

-------------------------------------------------
-- Zeichnen
-------------------------------------------------

local function drawPlan()
    mon.setTextColor(colors.white)

    mon.setCursorPos(1,2) 
    mon.write("           __[ ]____________________________<Depo>[ ]___________[ ]___ <---> Base     ")
    mon.setCursorPos(1,3)
    mon.write("          /__[ ]____________________________<Depo>[ ]____\\_/    ")
    mon.setCursorPos(1,4)
    mon.write("         |/__[ ]____________________________<Depo>[ ]____\\|   ")
    mon.setCursorPos(1,5)
    mon.write("         |/__[ ]____________________________<Depo>[ ]____\\|   ")
    mon.setCursorPos(1,6)
    mon.write("         |/__[ ]____________________________<Depo>[ ]____\\|   ")
    mon.setCursorPos(1,7)
    mon.write("         |/__[ ]____________________________<Depo>[ ]____\\|   ")
    mon.setCursorPos(1,8)
    mon.write("         |/__[ ]____________________________<Depo>[ ]____\\|   ")
    mon.setCursorPos(1,9)
    mon.write("         |/__[ ]____________________________<Depo>[ ]____\\|   ")
    mon.setCursorPos(1,10)
    mon.write("         |/__[ ]____________________________<Depo>[ ]____\\|   ")
    mon.setCursorPos(1,11)
    mon.write("         |/__[ ]____________________________<Depo>[ ]____\\|   ")
    mon.setCursorPos(1,12)
    mon.write("         |/__[ ]____________________________<Depo>[ ]____\\|   ")
    mon.setCursorPos(1,13)
    mon.write("         |/__[ ]______________________<Checkpoint>[ ]____\\|   ")
    mon.setCursorPos(1,14)
    mon.write("         |                                                | ")
    mon.setCursorPos(1,15)
    mon.write("         |                                                | ")
    mon.setCursorPos(1,16)
    mon.write("        [ ]                                              [ ]  ")
    mon.setCursorPos(1,17)
    mon.write("         |                                  _________[ ]__|___[ ]_____  ")
    mon.setCursorPos(1,18)
    mon.write("         |                                 /              |              <---> Base                        ")
    mon.setCursorPos(1,19)
    mon.write(" ________|\\___[ ]_________________________/       ___[ ]___\\__[ ]_____  ")
    mon.setCursorPos(1,20)
    mon.write("         |                                       /          ")
    mon.setCursorPos(1,21)
    mon.write(" ___[ ]_/_______________________________________/       ")
    mon.setCursorPos(1,22)
    mon.write(" <---> South     ")

end

local function drawNode(node, color)
    mon.setCursorPos(node.textX, node.row)
    if node.type == "signal" then
        mon.setBackgroundColor(color)
        mon.write(node.text)
        mon.setBackgroundColor(colors.black)
    else -- type == station
        mon.setTextColor(color)
        mon.write(node.text)
        mon.setTextColor(colors.white)
        mon.setCursorPos(node.textX + node.offset, node.row)
        mon.setBackgroundColor(color)
        mon.write(" ")
        mon.setBackgroundColor(colors.black)
    end

end

local function findNodeBySender(sender)
    for _, node in pairs(Nodes) do
        if node.name == sender then
            return node
        end
    end
    return nil
end

-------------------------------------------------
-- Startanzeige
-------------------------------------------------

drawPlan()

-------------------------------------------------
-- Hauptloop
-------------------------------------------------

while true do
    local id, message, protocol = rednet.receive(nil, 0.7)
    

    if message then
        -- print("Message: \n" .. textutils.serialize(message))
        -- print(type(message))
        local node = findNodeBySender(message.sender)

        if type(message) == "table" then

            if node then
                -- print(textutils.serialize(node.name))
                local color = colors.green
                if message.signal.state == "RED" then
                    color = colors.red
                end
                drawNode(node, color)
            end
        end
    end
end