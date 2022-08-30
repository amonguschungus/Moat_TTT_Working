AddCSLuaFile()
SWEP.HoldType = "smg"
SWEP.PrintName = "Honey Badger"

if CLIENT then
    SWEP.Slot = 2
    SWEP.Icon = "vgui/ttt/icon_g11"
    SWEP.IconLetter = "w"
end

SWEP.Base = "weapon_tttbase"
SWEP.Spawnable = true
SWEP.Kind = WEAPON_HEAVY
SWEP.WeaponID = AMMO_HBADGER
SWEP.ENUM = 12
SWEP.Primary.Delay = 0.075
SWEP.Primary.Recoil = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "SMG1"
SWEP.Primary.Cone = 0.04
SWEP.Primary.Damage = 20
SWEP.Primary.ClipSize = 30
SWEP.Primary.ClipMax = 120
SWEP.Primary.DefaultClip = 30
SWEP.HeadshotMultiplier = 2
SWEP.AutoSpawnable = true
SWEP.AmmoEnt = "item_ammo_smg1_ttt"
SWEP.Scope = true
SWEP.UseHands = true
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 75
SWEP.ViewModel = "models/v_models/v_hbg.mdl" --Viewmodel path
SWEP.WorldModel = "models/w_models/weapons/w_hbg.mdl" -- Weapon world model path
SWEP.Primary.Sound = Sound("weapons/hbg/gunfire/hbg-1.wav") -- This is the sound of the weapon, when you shoot.
SWEP.IronSightsPos = Vector(-2.8, 0, 0.4)
SWEP.IronSightsAng = Vector(0, 0, 0)
SWEP.DeploySpeed = 1.4
SWEP.ReloadSpeed = .9

SWEP.ReloadAnim = {
    DefaultReload = {
        Anim = "reload",
        Time = 1.5,
    },
    ReloadEmpty = {
        Anim = "reload",
        Time = 2,
    },
}

SWEP.Offset = {
    Pos = {
        Up = -1.5,
        Right = 1,
        Forward = 3
    },
    Ang = {
        Up = -1,
        Right = 0,
        Forward = 180
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
                pos, ang = pl:GetBonePosition(handBone)
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