AddCSLuaFile()

if CLIENT then
    SWEP.Slot = 2
    SWEP.Icon = "vgui/ttt/icon_mp5"
    SWEP.IconLetter = "x"
end

SWEP.PrintName = "PPSH-41"
SWEP.Base = "weapon_tttbase"
SWEP.HoldType = "ar2"
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.Delay = 0.07
SWEP.Primary.Recoil = 1.2
SWEP.Primary.Cone = 0.03
SWEP.Primary.Damage = 14
SWEP.Primary.Automatic = true
SWEP.Primary.ClipSize = 50
SWEP.Primary.ClipMax = 150
SWEP.Primary.DefaultClip = 50
SWEP.Primary.Range = 800
SWEP.Primary.FalloffRange = 1600
SWEP.Primary.Sound = Sound("weapon_bo3_ppsh.fire") -- This is the sound of the weapon, when you shoot.
SWEP.UseHands = true
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 65
SWEP.ViewModel = "models/weapons/bo3/c_bo3_ppsh.mdl" --Viewmodel path
SWEP.WorldModel = "models/weapons/bo3/w_bo3_ppsh.mdl" -- Weapon world model path
SWEP.IronSightsPos =  Vector(-0.16,-6.20,-1.20)
SWEP.IronSightsAng = Vector(0,0,0)
SWEP.Kind = WEAPON_HEAVY
SWEP.AutoSpawnable = true
SWEP.AmmoEnt = "item_ammo_pistol_ttt"
SWEP.AllowDrop = true
SWEP.IsSilent = false
SWEP.NoSights = false
SWEP.DeploySpeed = 1
SWEP.ReloadSpeed = 1

SWEP.ReloadAnim = {
    DefaultReload = {
        Anim = "reload",
        Time = 2,
    },
    ReloadEmpty = {
        Anim = "reload",
        Time = 4,
    },
}

SWEP.Offset = {
    Pos = {
        Up = -0.5,
        Right = 1.1,
        Forward = 5.5
    },
    Ang = {
        Up = 90,
        Right = 0,
        Forward = 200
    },
    Scale = 1
}

function SWEP:DrawWorldModel()
    local hand, offset, rotate
    local pl = self:GetOwner()

    if IsValid(pl) and pl.SetupBones then
        pl:SetupBones()
        pl:InvalidateBoneCache()
        self:InvalidateBoneCache()
    end

    if IsValid(pl) then
        local boneIndex = pl:LookupBone("ValveBiped.Bip01_R_Hand")

        if boneIndex then
            local pos, ang

            local mat = pl:GetBoneMatrix(boneIndex)
            if mat then
                pos, ang = mat:GetTranslation(), mat:GetAngles()
            else
                pos, ang = pl:GetBonePosition( handBone )
            end

            pos = pos + ang:Forward() * self.Offset.Pos.Forward + ang:Right() * self.Offset.Pos.Right + ang:Up() * self.Offset.Pos.Up
            ang:RotateAroundAxis(ang:Up(), self.Offset.Ang.Up)
            ang:RotateAroundAxis(ang:Right(), self.Offset.Ang.Right)
            ang:RotateAroundAxis(ang:Forward(), self.Offset.Ang.Forward)
            self:SetRenderOrigin(pos)
            self:SetRenderAngles(ang)
            self:DrawModel()
        end
    else
        self:SetRenderOrigin(nil)
        self:SetRenderAngles(nil)
        self:DrawModel()
    end
end