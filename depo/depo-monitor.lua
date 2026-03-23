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
    checkpoint  = { row = 2, textX = 22, leftX = 9,  rightX = 31, name = "Depo" },
    depo1       = { row = 3, textX = 22, leftX = 9,  rightX = 31, name = "Depo" },
    depo2       = { row = 4, textX = 22, leftX = 9,  rightX = 31, name = "Depo" },
    depo3       = { row = 5, textX = 22, leftX = 9,  rightX = 31, name = "Depo" },
    depo4       = { row = 6, textX = 22, leftX = 9,  rightX = 31, name = "Depo" },
    depo5       = { row = 7, textX = 22, leftX = 9,  rightX = 31, name = "Depo" },
    depo6       = { row = 8, textX = 22, leftX = 9,  rightX = 31, name = "Depo" },
    depo7       = { row = 9, textX = 22, leftX = 9,  rightX = 31, name = "Depo" },
    depo8       = { row = 10, textX = 22, leftX = 9,  rightX = 31, name = "Depo" },
    depo9       = { row = 11, textX = 22, leftX = 9,  rightX = 31, name = "Depo" },
    depo10      = { row = 12, textX = 22, leftX = 9,  rightX = 31, name = "Depo" },
    depo11      = { row = 13, textX = 22, leftX = 9,  rightX = 31, name = "Depo" },
    -- Signals
    entry1      = { row = 21, textX = 6,  name = "computer_51", text=" ", type="signal"},
    entry2      = { row = 16, textX = 9,  name = "computer_46", text=" ", type="signal"},
    entry3      = { row = 19, textX = 16, name = "computer_47", text=" ", type="signal"},
    entry4      = { row = 17, textX = 14, leftX = 29, rightX = 11, name = "Signal"},
    entry5      = { row = 9, textX = 14, leftX = 29, rightX = 11, name = "Signal"},
    entry6      = { row = 9, textX = 14, leftX = 29, rightX = 11, name = "Signal"},
    entry7      = { row = 9, textX = 14, leftX = 29, rightX = 11, name = "Signal"},
    entry8      = { row = 9, textX = 14, leftX = 29, rightX = 11, name = "Signal"},
    entry9      = { row = 9, textX = 14, leftX = 29, rightX = 11, name = "Signal"},
    entry10     = { row = 9, textX = 14, leftX = 29, rightX = 11, name = "Signal"},
    entry11     = { row = 9, textX = 14, leftX = 29, rightX = 11, name = "Signal"},
    entry12     = { row = 9, textX = 14, leftX = 29, rightX = 11, name = "Signal"},
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
                print(textutils.serialize(node.name))
                local color = colors.green
                if message.signal.state == "RED" then
                    color = colors.red
                end
                drawNode(node, color)
            end
        end
    end
end