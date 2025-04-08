SKHDecks = SMODS.current_mod
SKHDecks.load_table = {
	divine_entity = true,
	deadly_sin = true,
	heavenly_virtue = true,
	forgotten_sin = true,
	forgotten_virtue = true,
}
SKHDecks.optional_features = {
	post_trigger = true
}
SKHDecks.b_side_table = {}
SKHDecks.b_side_current = false

SKHDecks.multiplayer_loaded = false
if SMODS.Mods["Multiplayer"] and SMODS.Mods["Multiplayer"].can_load then
	SKHDecks.multiplayer_loaded = true
end

-- Load library files
local mod_path = "" .. SKHDecks.path
local files = NFS.getDirectoryItems(mod_path .. "lib")
for _, file in ipairs(files) do
	SMODS.load_file("lib/" .. file)()
end

-- Load items if enabled
for k, v in pairs(SKHDecks.load_table) do
    if v then SMODS.load_file('items/'..k..'.lua')() end
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