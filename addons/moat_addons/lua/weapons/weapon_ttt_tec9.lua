AddCSLuaFile()
SWEP.HoldType = "pistol"

if CLIENT then
    SWEP.Slot = 1
    SWEP.Icon = "vgui/tfa_csgo_tec9"
    SWEP.IconLetter = "t"
end

SWEP.PrintName = "TEC-9"
SWEP.Kind = WEAPON_PISTOL
SWEP.WeaponID = AMMO_GLOCK
SWEP.Base = "weapon_tttbase"
SWEP.Primary.Recoil = 1
SWEP.Primary.Damage = 22
SWEP.Primary.Delay = 0.08
SWEP.Primary.Cone = 0.05
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = 24
SWEP.Primary.ClipMax = 120
SWEP.Primary.DefaultClip = 24
SWEP.Primary.Ammo = "Pistol"
SWEP.AutoSpawnable = false
SWEP.AmmoEnt = "item_ammo_pistol_ttt"
SWEP.UseHands = true -- should the hands be displayed
SWEP.ViewModelFlip = false -- should the weapon be hold with the left or the right hand
SWEP.ViewModelFOV = 68
SWEP.ViewModel = "models/weapons/tfa_csgo/tec9/c_tec9.mdl"
SWEP.WorldModel = "models/weapons/tfa_csgo/tec9/w_tec9.mdl"
SWEP.Primary.Sound = Sound("TFA_CSGO_TEC9.1")
SWEP.IronSightsPos = Vector(3.3, 0, 0)
SWEP.IronSightsAng = Vector(0, -4, 0)
SWEP.HeadshotMultiplier = 2
SWEP.DeploySpeed = 1
SWEP.ReloadSpeed = 1

SWEP.ReloadAnim = {
    DefaultReload = {
        Anim = "reload",
        Time = 1.66667,
    },
    ReloadEmpty = {
        Anim = "reload_empty",
        Time = 2.33333,
    }
}