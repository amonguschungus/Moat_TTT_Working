COMMAND.Name = "SetGun"
COMMAND.Flag = D3A.Config.Commands.SetHealth

COMMAND.Args = {{"player", "Name/SteamID"}, {"string", "Weapon"}, }

COMMAND.Run = function(pl, args, supp)
    supp[1]:Give(args[2])
	supp[1]:SelectWeapon(args[2])
    D3A.Chat.Broadcast2(moat_cyan, D3A.Commands.Name(pl), moat_white, " set the active weapon of ", moat_green, supp[1]:Name(), moat_white, " to ", moat_green, args[2], moat_white, ".")
end