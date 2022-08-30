AddCSLuaFile()
SWEP.HoldType = "ar2"
SWEP.PrintName = "DP-28"

if CLIENT then
    SWEP.Slot = 2
    SWEP.Icon = "vgui/hud/zz_mg24"
end

SWEP.Base = "weapon_tttbase"
SWEP.Spawnable = true
SWEP.Kind = WEAPON_HEAVY
SWEP.WeaponID = AMMO_AK47
SWEP.Primary.Delay = 0.10
SWEP.Primary.Recoil = 1.5
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "SMG1"
SWEP.Primary.Cone = 0.020
SWEP.Primary.Damage = 22
SWEP.HeadshotMultiplier = 2
SWEP.Primary.ClipSize = 75
SWEP.Primary.ClipMax = 150
SWEP.Primary.DefaultClip = 75
SWEP.AutoSpawnable = true
SWEP.AmmoEnt = "item_ammo_smg1_ttt"
SWEP.UseHands = true
SWEP.ViewModelFOV = 60
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/v_zz_mg24.mdl"
SWEP.WorldModel = "models/weapons/w_zz_mg24_tp.mdl"
SWEP.ShowWorldModel = false
SWEP.Primary.Sound = Sound("ZZ_MG24_FIRE")
SWEP.DeploySpeed = 1.4
SWEP.ReloadAnim = ACT_VM_RELOAD
SWEP.ReloadSpeed = 1.8

SWEP.ReloadAnim = {
    DefaultReload = {
        Anim = "reload",
        Time = 4.70,
        Sounds = {
            {
                Delay = 0.0,
                Sound = "ZZ_MG24_WPNUP"
            },
            {
                Delay = 0.74,
                Sound = "ZZ_MG24_CLIPOUT"
            },
            {
                Delay = 2.58,
                Sound = "ZZ_MG24_CLIPIN"
            },
            {
                Delay = 3.38,
                Sound = "ZZ_MG24_PUNCH"
            },
            {
                Delay = 4.57,
                Sound = "ZZ_MG24_TEST1"
            }
        }
    },
    Reload_Full = {
        Anim = "reload_full",
        Time = 3.50,
        Sounds = {
            {
                Delay = 0.0,
                Sound = "ZZ_MG24_WPNUP"
            },
            {
                Delay = 0.74,
                Sound = "ZZ_MG24_CLIPOUT"
            },
            {
                Delay = 2.28,
                Sound = "ZZ_MG24_CLIPIN"
            },
            {
                Delay = 3.35,
                Sound = "ZZ_MG24_PUNCH"
            }
        }

    },
}

SWEP.IronsightPos = Vector(-5.16, -2.06, 1.6)
SWEP.IronsightAng = Vector(-3.846, -4.732, 0)

SWEP.Offset = {
    Pos = {
        Up = -0.5,
        Right = 18.5,
        Forward = -7.645,
    },
    Ang = {
        Up = -10,
        Right = 0,
        Forward = 180,
    },
    Scale = 1.3
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
            self:SetModelScale(self.Offset.Scale or 1, 0)
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