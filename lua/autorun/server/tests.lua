local clients = {}

util.AddNetworkString("register")
util.AddNetworkString("updateClients")

net.Receive("register", function(_, player)
    local discordId = net.ReadString()
    
    print("new client registered:", player, discordId)

    table.insert(clients, { player = player, discordId = discordId })

    net.Start("updateClients")
    net.WriteTable(clients)
    net.Broadcast()
end)