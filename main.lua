SKHDecks = SMODS.current_mod
SKHDecks.load_table = {
	divine_entity = true,
	deadly_sin = true,
	heavenly_virtue = true,
	forgotten_sin = true,
	forgotten_virtue = true,
}
SKHDecks.optional_features = {
	retrigger_joker = true,
	post_trigger = true
}
SKHDecks.b_side_table = {}
SKHDecks.b_side_current = false

-- Danger zone
SKHDecks.debug = false

SKHDecks.mod_list = {
	multiplayer = false,
	-- malverk = false,
}
if (SMODS.Mods["Multiplayer"] or {}).can_load
or (SMODS.Mods["NanoMultiplayer"] or {}).can_load then
	SKHDecks.mod_list.multiplayer = true
end
-- if (SMODS.Mods["malverk"] or {}).can_load then
-- 	SKHDecks.mod_list.malverk = true
-- end

-- Load library files
local mod_path = "" .. SKHDecks.path
local files = NFS.getDirectoryItems(mod_path .. "lib")
for _, file in ipairs(files) do
	SMODS.load_file("lib/" .. file)()
	sendInfoMessage("The library file " .. file .. " has been loaded!", "SKHDecks")
end

-- Load items if enabled
for k, v in pairs(SKHDecks.load_table) do
    if v then
		SMODS.load_file('items/'..k..'.lua')()
		sendInfoMessage("The item file " .. k .. ".lua has been loaded!", "SKHDecks")
	end
end

-- Use Malverk's AltTexture and disable built-in one if detected
-- if SKHDecks.mod_list.malverk then
-- 	sendInfoMessage("Malverk mod detected! \"Alternative Texture\" feature has been disabled.", "SKHDecks")
-- end
-- It turns out Malverk doesn't support modded decks lmao

-- Send a warning if Multiplayer is also installed
if SKHDecks.mod_list.multiplayer then
	sendWarnMessage("Multiplayer mod detected! This prevents several decks from appearing. While there is a way to select those decks, doing so is NOT RECOMMENDED.", "SKHDecks")
end

SMODS.Atlas({
	key = "modicon",
	path = "icon.png",
	px = 32,
	py = 32
})

SKHDecks.description_loc_vars = function()
	return { background_colour = G.C.CLEAR, text_colour = G.C.WHITE, scale = 1.2 }
end