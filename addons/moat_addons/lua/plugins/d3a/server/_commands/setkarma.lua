COMMAND.Name = "SetKarma"
COMMAND.Flag = D3A.Config.Commands.SetHealth

COMMAND.Args = {{"player" or "boolean", "Name/SteamID" or "Everyone"}, {"number", "Karma"}, }

COMMAND.Run = function(pl, args, supp)
    if supp[1] == NULL then
        for k, v in ipairs(player.GetAll()) do
            v:SetBaseKarma(args[2])
            v:SetLiveKarma(args[2])
            D3A.Chat.Broadcast2(moat_cyan, D3A.Commands.Name(pl), moat_white, " set the karma of ", moat_green, "all players", moat_white, " to ", moat_green, args[2], moat_white, ".")
        end
    else 
        supp[1]:SetBaseKarma(args[2])
        supp[1]:SetLiveKarma(args[2])
        D3A.Chat.Broadcast2(moat_cyan, D3A.Commands.Name(pl), moat_white, " set the karma of ", moat_green, supp[1]:Name(), moat_white, " to ", moat_green, args[2], moat_white, ".")
    end
	
	
end