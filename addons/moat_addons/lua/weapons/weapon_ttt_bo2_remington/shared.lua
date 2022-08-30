if SERVER then
    AddCSLuaFile()
else
    SWEP.Slot = 1
end

SWEP.HoldType = "revolver"
SWEP.PrintName = "Remington"
--- Default GMod values ---
SWEP.Base = "weapon_tttbase"
DEFINE_BASECLASS("weapon_tttbase")
SWEP.Purpose = "Shoot with style."
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.Kind = WEAPON_PISTOL
SWEP.AmmoEnt = "item_ammo_revolver_ttt"
SWEP.Primary.Ammo = "AlyxGun"
SWEP.Primary.Delay = 0.6
SWEP.Primary.Recoil = 1
SWEP.Primary.Cone = 0.01
SWEP.Primary.Damage = 60
SWEP.HeadshotMultiplier = 5
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = 7
SWEP.Primary.DefaultClip = 7
SWEP.Primary.Sound = Sound("Weapon_BO2_RNMA.fire") -- This is the sound of the weapon, when you shoot.
SWEP.AutoSpawnable = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
--- Model settings ---
SWEP.HoldType = "revolver"
SWEP.UseHands = true
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 80
SWEP.ViewModel = "models/weapons/bo2/c_bo2_nma.mdl" --Viewmodel path
SWEP.WorldModel = "models/weapons/bo2/w_bo2_nma.mdl" -- Weapon world model path
SWEP.DeploySpeed = 1.4
SWEP.ReloadSpeed = 1.25

SWEP.ReloadAnim = {
    DefaultReload = {
        Anim = "reload",
        Time = 2.22222,
    }
}

SWEP.Offset = {
    Pos = {
        Up = -3.5,
        Right = 1,
        Forward = 4
    },
    Ang = {
        Up = 90,
        Right = -2,
        Forward = 190
    },
    Scale = 1
}

--Procedural world model anim
function SWEP:Initialize()
    if (self.SetHoldType) then
        self:SetHoldType(self.HoldType or "pistol")
    end

    return self.BaseClass.Initialize(self)
end

function SWEP:ViewPunch()
    if (not IsValid(self:GetOwner()) or not self:GetOwner().ViewPunch) then return end
    self:GetOwner():ViewPunch(Angle(util.SharedRandom(self:GetClass(), -0.2, -0.1, 1) * self.Primary.Recoil, util.SharedRandom(self:GetClass(), -0.1, 0.1, 2) * self.Primary.Recoil, 0))
end

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