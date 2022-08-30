-- todo replace relay
moat.cfg.webhook = "http://208.103.169.40:5059/"
moat.cfg.oldwebhook = "http://107.191.51.43:3000/"

moat.cfg.discord = {
    primarywebhook = "https://discord.com/api/webhooks/986308854277087294/BnxcGqduKWAVELCSrOnXE5gOzrYpPl3DLfDVs7lrW9h_U73rK8-YXJ-5p6iRWKIyoG4D"
}

discord.AddChannels {
	["ttt-tv"] = "https://discord.com/api/webhooks/986308854277087294/BnxcGqduKWAVELCSrOnXE5gOzrYpPl3DLfDVs7lrW9h_U73rK8-YXJ-5p6iRWKIyoG4D",
	["general"] = "https://discord.com/api/webhooks/986308854277087294/BnxcGqduKWAVELCSrOnXE5gOzrYpPl3DLfDVs7lrW9h_U73rK8-YXJ-5p6iRWKIyoG4D",
	["ttt-bot"] = "https://discord.com/api/webhooks/986308854277087294/BnxcGqduKWAVELCSrOnXE5gOzrYpPl3DLfDVs7lrW9h_U73rK8-YXJ-5p6iRWKIyoG4D",
	["tradinglounge"] = "https://discord.com/api/webhooks/986308854277087294/BnxcGqduKWAVELCSrOnXE5gOzrYpPl3DLfDVs7lrW9h_U73rK8-YXJ-5p6iRWKIyoG4D",
	["ttt-challenges"] = "https://discord.com/api/webhooks/986308854277087294/BnxcGqduKWAVELCSrOnXE5gOzrYpPl3DLfDVs7lrW9h_U73rK8-YXJ-5p6iRWKIyoG4D",
	["ttt-logs"] = "https://discord.com/api/webhooks/986308854277087294/BnxcGqduKWAVELCSrOnXE5gOzrYpPl3DLfDVs7lrW9h_U73rK8-YXJ-5p6iRWKIyoG4D",
    ["staff-logs"] = "https://discord.com/api/webhooks/986308854277087294/BnxcGqduKWAVELCSrOnXE5gOzrYpPl3DLfDVs7lrW9h_U73rK8-YXJ-5p6iRWKIyoG4D",
    ["boss-logs"] = "https://discord.com/api/webhooks/986308854277087294/BnxcGqduKWAVELCSrOnXE5gOzrYpPl3DLfDVs7lrW9h_U73rK8-YXJ-5p6iRWKIyoG4D",
    ["error-logs"] = "https://discord.com/api/webhooks/986308854277087294/BnxcGqduKWAVELCSrOnXE5gOzrYpPl3DLfDVs7lrW9h_U73rK8-YXJ-5p6iRWKIyoG4D",
    ["testing"] = "https://discord.com/api/webhooks/986308854277087294/BnxcGqduKWAVELCSrOnXE5gOzrYpPl3DLfDVs7lrW9h_U73rK8-YXJ-5p6iRWKIyoG4D",
    ["dev-logs"] = "https://discord.com/api/webhooks/986308854277087294/BnxcGqduKWAVELCSrOnXE5gOzrYpPl3DLfDVs7lrW9h_U73rK8-YXJ-5p6iRWKIyoG4D",
    ["old-staff"] = "https://discord.com/api/webhooks/986308854277087294/BnxcGqduKWAVELCSrOnXE5gOzrYpPl3DLfDVs7lrW9h_U73rK8-YXJ-5p6iRWKIyoG4D",
	["mga-logs"] = "https://discord.com/api/webhooks/986308854277087294/BnxcGqduKWAVELCSrOnXE5gOzrYpPl3DLfDVs7lrW9h_U73rK8-YXJ-5p6iRWKIyoG4D",
	["toxic-logs"] = "https://discord.com/api/webhooks/986308854277087294/BnxcGqduKWAVELCSrOnXE5gOzrYpPl3DLfDVs7lrW9h_U73rK8-YXJ-5p6iRWKIyoG4D",
    ["error-logs-sv"] = "https://discord.com/api/webhooks/986308854277087294/BnxcGqduKWAVELCSrOnXE5gOzrYpPl3DLfDVs7lrW9h_U73rK8-YXJ-5p6iRWKIyoG4D",
    ["server-list"] = "https://discord.com/api/webhooks/986308854277087294/BnxcGqduKWAVELCSrOnXE5gOzrYpPl3DLfDVs7lrW9h_U73rK8-YXJ-5p6iRWKIyoG4D",
    ["enhanced-boss-logs"] = "https://discord.com/api/webhooks/986308854277087294/BnxcGqduKWAVELCSrOnXE5gOzrYpPl3DLfDVs7lrW9h_U73rK8-YXJ-5p6iRWKIyoG4D",
}

discord.AddUsers("ttt-tv", {"Moat TTT Announcements", "Lottery Announcements"}, true)
discord.AddUsers("general", {"Moat TTT Announcement", "Lottery Announcement"}, true)
discord.AddUsers("enhanced-boss-logs", {"AntiCheat - Lua"}, true)
discord.AddUsers("ttt-bot", {"Event", "Drop"})
discord.AddUsers("tradinglounge", {"Events", "Drops"})
discord.AddUsers("ttt-challenges", {"Contracts", "Bounties", "Lottery"})
discord.AddUsers("ttt-logs", {"Lottery Win", "Gamble Win"}, true)
discord.AddUsers("staff-logs", {"Anti Cheat", "Past Offences", "Gamble Chat", "Gamble", "Server", "TTS"})
discord.AddUsers("boss-logs", {"Snap", "Skid", "Gamble Log", "Trade", "Bad Map", "ASN Check"})
discord.AddUsers("mga-logs", {"MGA Log"}, true)
discord.AddUsers("dev-logs", {"Developer"})
discord.AddUsers("toxic-logs", {"Toxic TTT Loggers"})
discord.AddUsers("error-logs", {"Client Error Reports"}, true)
discord.AddUsers("error-logs-sv", {"Server Error Reports"}, true)
discord.AddUsers("server-list", {"Servers"})

slack.AddChannels {
	["mod-log"] = 'https://hooks.slack.com/services/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'
}

slack.AddUsers("mod-log", {"MGA Log"}, true)

function post_discord_server_list()
    Server.IsDev = false
    for k,v in pairs(Servers.Roster) do
        timer.Simple(0.5 * k,function()
            discord.Embed("Servers",{
                author = {
                    name = "★▶Moat ".. v.Name .. " ★ Official Inventory ★ Chill ★ Fun",
                    icon_url = "https://ttt.dev/60433443430256164487.jpg"
                },
                description = "Join: " .. v.ConnectURL,
            })
            if k == #Servers.Roster then
                Server.IsDev = true
            end
        end)
    end
end