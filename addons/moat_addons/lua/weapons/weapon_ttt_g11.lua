AddCSLuaFile()
SWEP.HoldType = "ar2"
SWEP.PrintName = "G11"

if CLIENT then
    SWEP.Slot = 2
    SWEP.Icon = "vgui/ttt/icon_g11"
    SWEP.IconLetter = "w"
end

SWEP.Base = "weapon_tttbase"
SWEP.Spawnable = true
SWEP.Kind = WEAPON_HEAVY
SWEP.WeaponID = AMMO_G11
SWEP.ENUM = 12
SWEP.Primary.Delay = 0.089
SWEP.Primary.Recoil = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "SMG1"
SWEP.Primary.Cone = 0.01
SWEP.Primary.Damage = 16
SWEP.Primary.ClipSize = 35
SWEP.Primary.ClipMax = 125
SWEP.Primary.DefaultClip = 35
SWEP.AutoSpawnable = true
SWEP.AmmoEnt = "item_ammo_smg1_ttt"
SWEP.Scope = true
SWEP.UseHands = true
SWEP.ViewModelFlip = true
SWEP.ViewModelFOV = 75
SWEP.ViewModel = "models/weapons/v_rif_g11.mdl"
SWEP.WorldModel = "models/weapons/w_snip_g11.mdl"
SWEP.Primary.Sound = Sound("weapons/hk_g11/galil-1.wav")
SWEP.Secondary.Sound = Sound("Default.Zoom")
SWEP.ShowWorldModel = false
SWEP.IronSightsPos = Vector(6, -22, -2)
SWEP.IronSightsAng = Vector(2.6, 1.37, 3.5)
SWEP.DeploySpeed = 1.4
SWEP.ReloadAnim = ACT_VM_RELOAD
SWEP.ReloadSpeed = 1.4

SWEP.ReloadAnim = {
    DefaultReload = {
        Anim = "reload",
        Time = 2.5,
    },
    ReloadEmpty = {
        Anim = "reload",
        Time = 3.5,
    }
}

SWEP.Offset = {
    Pos = {
        Up = -1.1,
        Right = 1.0,
        Forward = -3.0,
    },
    Ang = {
        Up = 0,
        Right = 0,
        Forward = 180,
    }
}

function SWEP:SetZoom(state)
    if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
        if state then
            self:GetOwner():SetFOV(45, 0.3)
        else
            self:GetOwner():SetFOV(0, 0.2)
        end
    end
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

if CLIENT then
    local scope = surface.GetTextureID("sprites/scope")

    function SWEP:DrawHUD()
        if self:GetIronsights() then
            surface.SetDrawColor(0, 0, 0, 255)
            local scrW = ScrW()
            local scrH = ScrH()
            local x = scrW / 2.0
            local y = scrH / 2.0
            local scope_size = scrH
            -- Crosshair
            local gap = 80
            local length = scope_size
            surface.DrawLine(x - length, y, x - gap, y)
            surface.DrawLine(x + length, y, x + gap, y)
            surface.DrawLine(x, y - length, x, y - gap)
            surface.DrawLine(x, y + length, x, y + gap)
            gap = 0
            length = 50
            surface.DrawLine(x - length, y, x - gap, y)
            surface.DrawLine(x + length, y, x + gap, y)
            surface.DrawLine(x, y - length, x, y - gap)
            surface.DrawLine(x, y + length, x, y + gap)
            -- Cover edges
            local sh = scope_size / 2
            local w = (x - sh) + 2
            surface.DrawRect(0, 0, w, scope_size)
            surface.DrawRect(x + sh - 2, 0, w, scope_size)
            -- Cover gaps on top and bottom of screen
            surface.DrawLine(0, 0, scrW, 0)
            surface.DrawLine(0, scrH - 1, scrW, scrH - 1)
            surface.SetDrawColor(255, 0, 0, 255)
            surface.DrawLine(x, y, x + 1, y + 1)
            -- Scope
            surface.SetTexture(scope)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRectRotated(x, y, scope_size, scope_size, 0)
        else
            return self.BaseClass.DrawHUD(self)
        end
    end

    function SWEP:AdjustMouseSensitivity()
        return (self:GetIronsights() and 0.5) or nil
    end
end