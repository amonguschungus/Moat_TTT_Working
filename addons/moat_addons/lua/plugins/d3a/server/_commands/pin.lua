COMMAND.Name = "Pin"
COMMAND.Flag = D3A.Config.Commands.Pin
COMMAND.AdminMode = false

COMMAND.Args = {{"string", "Daily"}}

COMMAND.Run = function(pl, args, supp)
	local dailies = 1
    if dailies == nil then
        D3A.Chat.SendToPlayer2(pl, moat_cyan, "Sorry, your inventory hasn't loaded yet!")
    else
        for k, v in ipairs(dailies) do 
            D3A.Chat.SendToPlayer2(pl, moat_cyan, v)
        end
    end
end