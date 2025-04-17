SMODS.Back({
	key = "forgotten_generous_mp",
	atlas = not config.AltTexture and "forgotten_virtue" or "forgotten_virtue_alt",
    pos = { x = 0, y = 1 },
	config = {dollars = -84},
	apply = function(self, back)
		G.GAME.bankrupt_at = -100
        G.GAME.banned_keys[#G.GAME.banned_keys+1] = {j_credit_card = true}
	end,
	loc_vars = function(self)
		return {vars = {-self.config.dollars-4}}
	end
})