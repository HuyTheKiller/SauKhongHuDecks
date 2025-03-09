SMODS.Atlas({
	key = "saukhonghu_deck",
	path = "SauKhongHu.png",
	px = 71,
	py = 95,
})

SMODS.Back({
    key = "saukhonghu",
    atlas = "saukhonghu_deck",
    config = {hand_size = 1, extra = {ante_gain = 8}},
    apply = function(self, back)
		G.GAME.win_ante = G.GAME.win_ante + self.config.extra.ante_gain
        delay(0.4)
		G.E_MANAGER:add_event(Event({
			func = function()
				local mime = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_mime", "deck")
				mime:add_to_deck()
				G.jokers:emplace(mime)
				mime:start_materialize()

                local baron = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_baron", "deck")
				baron:add_to_deck()
				G.jokers:emplace(baron)
				baron:start_materialize()

				return true
			end,
		}))
	end,
    loc_vars = function(self)
        return {vars = {self.config.hand_size, 8 + self.config.extra.ante_gain}}
    end,
})

SMODS.Atlas({
	key = "sauhu_deck",
	path = "SauHu.png",
	px = 71,
	py = 95,
})

SMODS.Back({
    key = "sauhu",
    atlas = "sauhu_deck",
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_saukhonghu'},
    config = {discards = -1, hands = 1},
    apply = function(self, back)
        delay(0.4)
		G.E_MANAGER:add_event(Event({
			func = function()
				local oops = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_oops", "deck")
				oops:set_eternal(true)
				oops:add_to_deck()
				G.jokers:emplace(oops)
				oops:start_materialize()

                local obelisk = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_obelisk", "deck")
				obelisk:set_eternal(true)
				obelisk:set_edition({ negative = true }, true)
				obelisk:add_to_deck()
				G.jokers:emplace(obelisk)
				obelisk:start_materialize()

				return true
			end,
		}))
	end,
    loc_vars = function(self)
        return {vars = {self.config.discards, self.config.hands}}
    end,
})

SMODS.Atlas({
	key = "absolute_cinema_deck",
	path = "AbsoluteCinema.png",
	px = 71,
	py = 95,
})

SMODS.Back({
    key = "absolute_cinema",
    atlas = "absolute_cinema_deck",
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_sauhu'},
    config = {joker_slot = 1, hand_size = 2, extra = {ante_gain = 24}, vouchers = {"v_overstock_norm", "v_overstock_plus"}, ante_scaling = 2, remove_faces = true},
    calculate = function(self, back, context)
		if context.context == "final_scoring_step" then
			local tot = context.chips + context.mult
			context.chips = math.floor(tot / 2)
			context.mult = math.floor(tot / 2)
			update_hand_text({ delay = 0 }, { mult = context.mult, chips = context.chips })

			G.E_MANAGER:add_event(Event({
				func = function()
					local text = localize("k_balanced")
					play_sound("gong", 0.94, 0.3)
					play_sound("gong", 0.94 * 1.5, 0.2)
					play_sound("tarot1", 1.5)
					ease_colour(G.C.UI_CHIPS, { 0.8, 0.45, 0.85, 1 })
					ease_colour(G.C.UI_MULT, { 0.8, 0.45, 0.85, 1 })
					attention_text({
						scale = 1.4,
						text = text,
						hold = 2,
						align = "cm",
						offset = { x = 0, y = -2.7 },
						major = G.play,
					})
					G.E_MANAGER:add_event(Event({
						trigger = "after",
						blockable = false,
						blocking = false,
						delay = 4.3,
						func = function()
							ease_colour(G.C.UI_CHIPS, G.C.BLUE, 2)
							ease_colour(G.C.UI_MULT, G.C.RED, 2)
							return true
						end,
					}))
					G.E_MANAGER:add_event(Event({
						trigger = "after",
						blockable = false,
						blocking = false,
						no_delete = true,
						delay = 6.3,
						func = function()
							G.C.UI_CHIPS[1], G.C.UI_CHIPS[2], G.C.UI_CHIPS[3], G.C.UI_CHIPS[4] =
								G.C.BLUE[1], G.C.BLUE[2], G.C.BLUE[3], G.C.BLUE[4]
							G.C.UI_MULT[1], G.C.UI_MULT[2], G.C.UI_MULT[3], G.C.UI_MULT[4] =
								G.C.RED[1], G.C.RED[2], G.C.RED[3], G.C.RED[4]
							return true
						end,
					}))
					return true
				end,
			}))
			delay(0.6)
			return context.chips, context.mult
		end
	end,
	apply = function(self, back)
        G.GAME.win_ante = G.GAME.win_ante + self.config.extra.ante_gain
		delay(0.4)
		G.E_MANAGER:add_event(Event({
			func = function()
				local mime = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_mime", "deck")
				mime:set_eternal(true)
				mime:add_to_deck()
				G.jokers:emplace(mime)
				mime:start_materialize()

                local baron = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_baron", "deck")
				baron:set_eternal(true)
				baron:add_to_deck()
				G.jokers:emplace(baron)
				baron:start_materialize()

				local invis = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_invisible", "deck")
				invis:add_to_deck()
				G.jokers:emplace(invis)
				invis:start_materialize()

				return true
			end,
		}))
	end,
    loc_vars = function(self)
        return {vars = {self.config.joker_slot, self.config.hand_size, 8 + self.config.extra.ante_gain}}
    end,
})

SMODS.Atlas({
	key = "plot_hole_deck",
	path = "PlotHole.png",
	px = 71,
	py = 95,
})

SMODS.Back({
	key = "plot_hole",
	atlas = "plot_hole_deck",
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_sauhu'},
	config = {hands = -3, discards = 1, extra = {ante_loss = 12}, vouchers = {"v_magic_trick"}, randomize_rank_suit = true},
	calculate = function(self, back, context)
		if context.before then
			for c = #G.playing_cards, 1, -1 do
				G.playing_cards[c]:set_ability(G.P_CENTERS["m_glass"])
			end
		end
	end,
	apply = function(self, back)
		ease_ante(-self.config.extra.ante_loss)
        G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
        G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante - self.config.extra.ante_loss
		delay(0.4)
		G.E_MANAGER:add_event(Event({
			func = function()
				local oops = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_oops", "deck")
				oops:set_eternal(true)
				oops:set_edition({ negative = true }, true)
				oops:add_to_deck()
				G.jokers:emplace(oops)
				oops:start_materialize()

				local oops2 = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_oops", "deck")
				oops2:set_eternal(true)
				oops2:set_edition({ negative = true }, true)
				oops2:add_to_deck()
				G.jokers:emplace(oops2)
				oops2:start_materialize()

				return true
			end,
		}))
		G.E_MANAGER:add_event(Event({
			func = function()
				for c = #G.playing_cards, 1, -1 do
					G.playing_cards[c]:set_ability(G.P_CENTERS["m_glass"])
				end
				return true
			end,
		}))
	end,
	loc_vars = function(self)
        return {vars = {self.config.hands, self.config.discards, 1 - self.config.extra.ante_loss}}
    end,
})

SMODS.Atlas({
	key = "modicon",
	path = "icon.png",
	px = 32,
	py = 32
})

SMODS.current_mod.description_loc_vars = function()
	return { background_colour = G.C.CLEAR, text_colour = G.C.WHITE, scale = 1.2 }
end