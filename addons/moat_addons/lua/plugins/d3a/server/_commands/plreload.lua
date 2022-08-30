COMMAND.Name = "plreload"
COMMAND.Flag = D3A.Config.Commands.SetHealth

COMMAND.Args = {{"player", "Name/SteamID"}}

COMMAND.Run = function(pl, args, supp)
    local sh = supp[1]:GetActiveWeapon()
    if sh.Primary.Ammo ~= "none" then
        sh:SetClip1(sh:Clip1() / 2)
        sh:Reload()
        supp[1]:GiveAmmo((sh:GetMaxClip1() / 2), sh:GetPrimaryAmmoType())
        D3A.Chat.Broadcast2(moat_cyan, D3A.Commands.Name(pl), moat_white, " has forced ", moat_green, supp[1]:Name(), moat_white, " to reload their weapon: " .. sh:GetPrintName() .. "!")
    else
        D3A.Chat.SendToPlayer2(pl, moat_red, "Cannot force player to reload their " .. sh:GetPrintName() .. "!")
    end
end