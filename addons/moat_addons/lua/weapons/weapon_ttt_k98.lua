AddCSLuaFile()
SWEP.HoldType = "ar2"

if CLIENT then
    SWEP.Slot = 2
    SWEP.Icon = "vgui/ttt/icon_scout"
    SWEP.IconLetter = "k"
end

SWEP.PrintName = "Karabiner 98k"
SWEP.Base = "weapon_tttbase"
SWEP.Spawnable = true
SWEP.Kind = WEAPON_HEAVY
SWEP.WeaponID = AMMO_RIFLE
SWEP.Primary.Delay = 1.5
SWEP.Primary.Recoil = 7
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "357"
SWEP.Primary.Damage = 50
SWEP.Primary.Cone = 0.000001
SWEP.Primary.ClipSize = 6
SWEP.Primary.ClipMax = 18 -- keep mirrored to ammo
SWEP.Primary.DefaultClip = 6
SWEP.HeadshotMultiplier = 5
SWEP.AutoSpawnable = false
SWEP.AmmoEnt = "item_ammo_357_ttt"
SWEP.UseHands = true
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 55
SWEP.ViewModel = "models/weapons/v_swep_kar.mdl" -- Weapon view model
SWEP.WorldModel = "models/weapons/w_swep_kar.mdl" -- Weapon world model
SWEP.Primary.Sound = Sound("Weapon_Kar.Single") -- script that calls the primary fire sound

SWEP.PrimaryAnim = {"cock01", "cock02", "cock03"}

SWEP.Secondary.Sound = Sound("Default.Zoom")
SWEP.IronSightsPos = Vector(1.8241, 0, 1.5131)
SWEP.IronSightsAng = Vector(0.4909, 0.2073, 0)
SWEP.IsZoomed = 0
SWEP.Scope = true
SWEP.DeploySpeed = 1.4
SWEP.ReloadSpeed = 1.4

SWEP.ReloadAnim = {
    DefaultReload = {
        Anim = "reload4",
        Time = 5.25,
        Act = ACT_VM_IDLE
    },
    DefaultReload4 = {
        Anim = "reload4",
        Time = 5.25,
        Act = ACT_VM_IDLE
    },
    DefaultReload3 = {
        Anim = "reload3",
        Time = 4.875,
        Act = ACT_VM_IDLE
    },
    DefaultReload2 = {
        Anim = "reload2",
        Time = 4.5,
        Act = ACT_VM_IDLE
    },
    DefaultReload1 = {
        Anim = "reload1",
        Time = 4.125,
        Act = ACT_VM_IDLE
    },
    ReloadEmpty1 = {
        Anim = "reload_empty1",
        Time = 3,
        Act = ACT_VM_IDLE
    },
    ReloadEmpty2 = {
        Anim = "reload_empty2",
        Time = 3.375,
        Act = ACT_VM_IDLE
    },
    ReloadEmpty3 = {
        Anim = "reload_empty3",
        Time = 3.75,
        Act = ACT_VM_IDLE
    },
    ReloadEmpty4 = {
        Anim = "reload_empty4",
        Time = 4.125,
        Act = ACT_VM_IDLE
    },
    ReloadEmpty = {
        Anim = "reload_empty",
        Time = 4.5,
        Act = ACT_VM_IDLE
    }
}

function SWEP:LastShot(self)
    -- self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    return true
end

function SWEP:ReloadAnimation(Clip, Ammo, CurrentTime)
    local Need = math.max(self:GetMaxClip1() - Clip, 0)
    if (Clip == 0 and Ammo > 4) then return "ReloadEmpty" end
    if (Clip == 0 and Ammo == 1) then return "ReloadEmpty1" end
    if (Clip == 0 and Ammo == 2) then return "ReloadEmpty2" end
    if (Clip == 0 and Ammo == 3) then return "ReloadEmpty3" end
    if (Clip == 0 and Ammo == 4) then return "ReloadEmpty4" end
    if (Need == 1 and Ammo >= 1) then return "DefaultReload1" end
    if (Need == 2 and Ammo >= 2) then return "DefaultReload2" end
    if (Need == 3 and Ammo >= 3) then return "DefaultReload3" end
    if (Need >= 4 and Ammo >= 4) then return "DefaultReload4" end
    if (Ammo == 1) then return "DefaultReload1" end
    if (Ammo == 2) then return "DefaultReload2" end
    if (Ammo == 3) then return "DefaultReload3" end
    if (Ammo == 4) then return "DefaultReload4" end

    return (Clip == 0) and "ReloadEmpty" or "DefaultReload"
end

function SWEP:SetZoom(state)
    if (not (IsValid(self.Owner) and self.Owner:IsPlayer())) then return end

    if (state) then
        self.Owner:SetFOV(20, .3)
    else
        self.Owner:SetFOV(0, .2)
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
            -- crosshair
            local gap = 80
            local length = scope_size
            surface.DrawLine(x - length, y, x - gap, y)
            surface.DrawLine(x + length, y, x + gap, y)
            surface.DrawLine(x, y - length, x, y - gap)
            surface.DrawLine(x, y + length, x, y + gap)
            gap = 10
            length = 50
            surface.DrawLine(x - length, y, x - gap, y)
            surface.DrawLine(x + length, y, x + gap, y)
            surface.DrawLine(x, y - length, x, y - gap)
            surface.DrawLine(x, y + length, x, y + gap)
            -- cover edges
            local sh = scope_size / 2
            local w = (x - sh) + 2
            surface.DrawRect(0, 0, w, scope_size)
            surface.DrawRect(x + sh - 2, 0, w, scope_size)
            -- cover gaps on top and bottom of screen
            surface.DrawLine(0, 0, scrW, 0)
            surface.DrawLine(0, scrH - 1, scrW, scrH - 1)
            surface.SetDrawColor(255, 0, 0, 255)
            surface.DrawRect(x - 1, y - 1, 2, 2)
            -- scope
            surface.SetTexture(scope)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRectRotated(x, y, scope_size, scope_size, 0)
        else
            return self.BaseClass.DrawHUD(self)
        end
    end

    function SWEP:AdjustMouseSensitivity()
        return (self:GetIronsights() and 0.2) or nil
    end
end