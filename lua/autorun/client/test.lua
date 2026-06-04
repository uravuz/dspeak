require "dspeakui"

local gmodpipeOK, err = pcall(require, "gmodpipe")

if gmodpipeOK then
    statusUI("gmodpipe", true, "#dspeak.ui.ok")
else
    statusUI("gmodpipe", false, "#dspeak.ui.error")
    statusUI("discord", false, "#dspeak.ui.gmodpiperequired")
    print(err)
end

hook.Add("InitPostEntity", "CreateMyUI", function()
    drawUI()
end)

local serverResponded = false

net.Receive("dspeakHealth", function()
    serverResponded = true
    statusUI("server", true, "#dspeak.ui.ok")
end)

net.Start("dspeakHealth")
net.SendToServer()

timer.Create("serverHealthcheck", 5, 1, function()
    statusUI("server", false, "#dspeak.ui.noresponse")
end)

local lastPosition
local clients = {}

function registerClient(userId)
    net.Start("register")

    net.WriteString(userId)

    net.SendToServer()

end

net.Receive("updateClients", function()
    local clientsResponse = net.ReadTable()

    local newClients = {}

    for _, client in ipairs(clientsResponse) do
        if client.player == LocalPlayer() then
            continue
        end

        newClients.insert({
            player = client.player,
            discordId = client.discordId,
            lastPosition = client.player:GetPos()
        })
    end

    clients = newClients
end)

local pipe = Pipe.Connect("dspeak")
if not pipe then
    print("Failed to connect")
    return
end

local getIdRequest = {
    channel = "get-id"
}

Pipe.Write(pipe, util.TableToJSON(getIdRequest))

hook.Add("Think", "PipeResponse", function()
    local bytes = Pipe.Peek(pipe)
    if not bytes then
        print("Pipe error or disconnected")
        hook.Remove("Think", "PipeResponse")
        Pipe.Close(pipe)
        return
    end

    if bytes > 0 then
        local msg = Pipe.Read(pipe, 4096)
        if msg then
            local reply = util.JSONToTable(msg)
            if reply.channel == "user-id" then
                registerClient(reply.value)
            end
        end
    end
end)

function recalculateClient(client, playerPosition)
    local x = playerPosition.x - client.player:GetPos().x
    local z = playerPosition.x - client.player:GetPos().z

    local spatialRequest = {
        channel = "spatial-audio",
        userId = client.discordId,
        x = x,
        z = z
    }

    Pipe.Write(pipe, util.TableToJSON(spatialRequest))
end

function recalculateEveryone(playerPosition)
    for _, client in ipairs(clients) do
        recalculateClient(client, playerPosition)
    end
end

hook.Add("Think", "UpdateClientPositions", function()
    if lastPosition ~= LocalPlayer():GetPos() then
        recalculateEveryone(lastPosition)
        return
    end

    for _, client in ipairs(clients) do
        if client.lastPosition ~= client.player:GetPos() then
            recalculateClient(client, lastPosition)
        end
    end
end)
