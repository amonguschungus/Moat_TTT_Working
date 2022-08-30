COMMAND.Name = "giveitem"
COMMAND.Flag = D3A.Config.Commands.GiveItem

COMMAND.Args = {{"string", "Name/SteamID"}, {"string", "Prefix"}, {"string", "Talent"}, {"string", "Talent"}, {"string", "Talent"}, {"string", "Talent"}}

COMMAND.Run = function(pl, args, supp)
    local rarities = {
        [0] = "Stock",
        [1] = "Worn",
        [2] = "Standard",
        [3] = "Superior",
        [4] = "High-End",
        [5] = "Ascended",
        [6] = "Cosmic",
        [7] = "Extinct",
        [8] = "Planetary"
    }
    local tals = {}
    local talnum = 0
    local talz = ""
    for i = 3, 6 do
        if args[i] ~= "" then
            table.insert(tals, args[i])
            talnum = talnum + 1
        end
    end
    if tals ~= {} then
        for k, v in ipairs(tals) do
            talz = talz .. " [[" .. tals[v] .. "]]"
        end
    end
    local ply = supp[1]:GetBySteamID()
    local id = ply:UserID()
    RunConsoleCommand("mga", "lua", "Player(" .. id .. "):m_DropInventoryItem([[".. args[2] .."]], [[weapon_ttt_te_m4a1]],nil,nil,nil,{" .. talz .. "})")
    D3A.Chat.Broadcast2(moat_cyan, D3A.Commands.Name(pl), moat_white, " has given ", moat_green, supp[1]:Name(), moat_white, " a " .. args[2]".")
end