--Copyright (C) 2017 Arno Zura ( https://www.gnu.org/licenses/gpl.txt )

AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName		= lang.moneyprinter
ENT.Author			= "D4KiR"
ENT.Contact			= "-"
ENT.Purpose			= "Prints money"
ENT.Information = "Money printer by yrp"
ENT.Instructions	= "Press E on printer"

ENT.Category = "YourRP Moneyprinters"

ENT.Editable = false
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT