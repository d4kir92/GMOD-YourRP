
SWEP.Author = "D4KiR"
SWEP.Contact = "youtube.com/c/D4KiR"
SWEP.Purpose = "This item can unlock/lock the door that you owned"
SWEP.Instructions = "Left Click - Unlock door\nRight Click - Lock door"

//The category that you SWep will be shown in, in the Spawn (Q) Menu
//(This can be anything, GMod will create the categories for you)
SWEP.Category = "YourRP"

//The name of the SWep, as appears in the weapons tab in the spawn menu(Q Menu)
SWEP.PrintName = "Key"

//Sets the position of the weapon in the switching menu
//(appears when you use the scroll wheel or keys 1-6 by default)
SWEP.Slot = 1
SWEP.SlotPos = 1

//Sets drawing the ammuntion levels for this weapon
SWEP.DrawAmmo = false

//Sets the drawing of the crosshair when this weapon is deployed
SWEP.DrawCrosshair = false

SWEP.Spawnable = true -- Whether regular players can see it
SWEP.AdminSpawnable = true -- Whether Admins/Super Admins can see it

SWEP.ViewModel = "models/weapons/c_arms.mdl" -- This is the model used for clients to see in first person.
SWEP.WorldModel = "" -- This is the model shown to all other clients and in third-person.

//This determins how big each clip/magazine for the gun is. You can
//set it to -1 to disable the ammo system, meaning primary ammo will
//not be displayed and will not be affected.
SWEP.Primary.ClipSize = -1

//This sets the number of rounds in the clip when you first get the gun. Again it can be set to -1.
SWEP.Primary.DefaultClip = -1

//Obvious. Determines whether the primary fire is automatic. This should be true/false
SWEP.Primary.Automatic = false

//Sets the ammunition type the gun uses, see below for a list of types.
SWEP.Primary.Ammo = "none"
SWEP.Secondary.Ammo = "none"

function SWEP:Reload()

end

function SWEP:Think()

end

SWEP.numbers = {}
function SWEP:AddKeyNr( nr )
  table.insert( self.numbers, nr )
end

//Throw an office chair on primary attack
function SWEP:PrimaryAttack()
	//Call the throw attack function, with the office chair model
  for k, v in pairs( self.numbers ) do
    unlockDoor( self.Owner:GetEyeTrace().Entity, v )
  end
end

//Throw a wooden chair on secondary attack
function SWEP:SecondaryAttack()

	//Call the throw attack function, this time with the wooden chair model
  for k, v in pairs( self.numbers ) do
    lockDoor( self.Owner:GetEyeTrace().Entity, v )
  end
end
