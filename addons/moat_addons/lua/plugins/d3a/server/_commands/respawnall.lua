COMMAND.Name = "Respawnall"

COMMAND.Flag = D3A.Config.Commands.Return
COMMAND.AdminMode = true
COMMAND.CheckRankWeight = true

COMMAND.Args = {}

COMMAND.Run = function(pl, args, supp)
    for k, ply in pairs(player.GetAll()) do
        if !ply:Alive() then
          ply:SpawnForRound()
        end
    end
    D3A.Chat.Broadcast2(pl, moat_cyan, plname, moat_white, " has respawned all dead players.")
end