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
}
if (SMODS.Mods["Multiplayer"] or {}).can_load
or (SMODS.Mods["NanoMultiplayer"] or {}).can_load then
	SKHDecks.mod_list.multiplayer = true
end

-- Load library files
local mod_path = "" .. SKHDecks.path
local files = NFS.getDirectoryItems(mod_path .. "lib")
for _, file in ipairs(files) do
	SMODS.load_file("lib/" .. file)()
	sendInfoMessage("The library file " .. file .. " has been loaded!", "SKHDecks")
end

-- Notify and block several files if Multiplayer is also installed
if SKHDecks.mod_list.multiplayer then
	sendInfoMessage("Multiplayer mod detected!", "SKHDecks")
	SKHDecks.load_table.divine_entity = false
	SKHDecks.load_table.forgotten_virtue = false
	for k, v in pairs(SKHDecks.load_table) do
		if not v then
			sendInfoMessage("Blocking item file " .. k .. ".lua ...", "SKHDecks")
		end
	end
end

-- Load items if enabled
for k, v in pairs(SKHDecks.load_table) do
    if v then
		SMODS.load_file('items/'..k..'.lua')()
		sendInfoMessage("The item file " .. k .. ".lua has been loaded!", "SKHDecks")
	end
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