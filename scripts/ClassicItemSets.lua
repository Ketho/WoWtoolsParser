local parser = require "wowtoolsparser"

-- https://github.com/Gethe/wow-ui-source/blob/classic/FrameXML/Constants.lua#L311
local INVSLOT_AMMO = 0
local INVSLOT_HEAD = 1
local INVSLOT_NECK = 2
local INVSLOT_SHOULDER = 3
local INVSLOT_BODY = 4
local INVSLOT_CHEST = 5
local INVSLOT_WAIST = 6
local INVSLOT_LEGS = 7
local INVSLOT_FEET = 8
local INVSLOT_WRIST = 9
local INVSLOT_HAND = 10
local INVSLOT_FINGER1 = 11
local INVSLOT_FINGER2 = 12
local INVSLOT_TRINKET1 = 13
local INVSLOT_TRINKET2 = 14
local INVSLOT_BACK = 15
local INVSLOT_MAINHAND = 16
local INVSLOT_OFFHAND = 17
local INVSLOT_RANGED = 18
local INVSLOT_TABARD = 19

-- https://wow.gamepedia.com/Enum_Item.InventoryType
-- https://wow.gamepedia.com/InventorySlotName
-- https://wow.gamepedia.com/API_C_Transmog.GetSlotForInventoryType
local InventoryTypeToSlot = {
	--[0] = INVSLOT_AMMO, -- IndexNonEquipType
	[1] = INVSLOT_HEAD, -- IndexHeadType
	--[2] = INVSLOT_NECK, -- IndexNeckType
	[3] = INVSLOT_SHOULDER, -- IndexShoulderType
	[4] = INVSLOT_BODY, -- IndexBodyType
	[5] = INVSLOT_CHEST, -- IndexChestType
	[6] = INVSLOT_WAIST, -- IndexWaistType
	[7] = INVSLOT_LEGS, -- IndexLegsType
	[8] = INVSLOT_FEET, -- IndexFeetType
	[9] = INVSLOT_WRIST, -- IndexWristType
	[10] = INVSLOT_HAND, -- IndexHandType
	--[11] = INVSLOT_FINGER1, -- IndexFingerType
	--[12] = INVSLOT_TRINKET1, -- IndexTrinketType
	[13] = INVSLOT_MAINHAND, -- IndexWeaponType, 16
	[14] = INVSLOT_OFFHAND, -- IndexShieldType, 17
	[15] = INVSLOT_MAINHAND, -- IndexRangedType, 16
	[16] = INVSLOT_BACK, -- IndexCloakType, 15
	[17] = INVSLOT_MAINHAND, -- Index2HweaponType, 16
	--[18] = IndexBagType, -- IndexBagType
	[19] = INVSLOT_TABARD, -- IndexTabardType, 19
	[20] = INVSLOT_CHEST, -- IndexRobeType, 5
	[21] = INVSLOT_MAINHAND, -- IndexWeaponmainhandType, 16
	[22] = INVSLOT_OFFHAND, -- IndexWeaponoffhandType, 17 (fixed)
	[23] = INVSLOT_OFFHAND, -- IndexHoldableType, 17
	--[24] = IndexAmmoType, -- IndexAmmoType
	--[25] = IndexThrownType, -- IndexThrownType
	[26] = INVSLOT_MAINHAND, -- IndexRangedrightType, 16
	--[27] = IndexQuiverType, -- IndexQuiverType
	--[28] = IndexRelicType, -- IndexRelicType
}

local function SortTableKey(tbl)
	local sorted = {}
	for key in pairs(tbl) do
		table.insert(sorted, key)
	end
	table.sort(sorted)
	return sorted
end

local function ClassicItemSets(BUILD)
	local item_inventoryType = parser.ReadCSV("item", {build=BUILD, header=true})
	local set_names, set_itemIDs = parser.ReadCSV("itemset", {build=BUILD, header=true})
	print("IMorphSets = {")

	for _, setID in pairs(SortTableKey(set_names)) do
		print(string.format("\t[%d] = {", setID))
		print(string.format('\t\tname = "%s",', set_names[setID]))
		local sortedSet = {}
		for _, itemID in pairs(set_itemIDs[setID]) do
			table.insert(sortedSet, {
				itemID = itemID,
				inventoryType = item_inventoryType[itemID],
				slot = InventoryTypeToSlot[item_inventoryType[itemID]] or 0,
			})
		end
		table.sort(sortedSet, function(a, b)
			return a.slot < b.slot
		end)
		for _, v in pairs(sortedSet) do
			if v.slot > 0 then -- neck, finger, trinket cant be morphed
				print(string.format("\t\t[%d] = %d, -- %d", v.slot, v.itemID, v.inventoryType))
			end
		end
		print("\t},")
	end
	print("}")
end

-- https://gist.github.com/Ketho/2eb100d509e68bf3f49ffa10b3b7d9f4
ClassicItemSets("1.13.2")
