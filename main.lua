SKHDecks = SMODS.current_mod
SKHDecks.load_table = {
	divine_entity = true,
	deadly_sin = true,
	heavenly_virtue = true,
}

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