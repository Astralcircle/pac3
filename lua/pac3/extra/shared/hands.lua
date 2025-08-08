local SWEP = {Primary = {}, Secondary = {}}
SWEP.PrintName = "Hands"
SWEP.Instructions = "Right-Click to toggle crosshair"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.SlotPos = 1
SWEP.Slot = 1

SWEP.Spawnable = true
SWEP.Weight = 1

SWEP.HoldType = "normal"
SWEP.ViewModel = "models/weapons/c_arms.mdl"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:DrawWorldModel() end
function SWEP:DrawWorldModelTranslucent() end
function SWEP:PrimaryAttack() end
function SWEP:Reload() return end

function SWEP:Initialize()
	self:SetHoldType("normal")
end

function SWEP:DrawWeaponSelection(x, y, width, tall, alpha)
	draw.SimpleText("C", "creditslogo", x + width / 2, y, Color(255, 220, 0, alpha), TEXT_ALIGN_CENTER)
	self:PrintWeaponInfo(x + width + 20, y + tall * 0.95, alpha)
end

function SWEP:SecondaryAttack()
	if SERVER or not IsFirstTimePredicted() then return end
	self.DrawCrosshair = not self.DrawCrosshair
end

function SWEP:OnDrop()
	if SERVER then
		self:Remove()
	end
end

weapons.Register(SWEP, "none")
