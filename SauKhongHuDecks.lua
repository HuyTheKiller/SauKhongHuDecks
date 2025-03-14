SMODS.Atlas({
	key = "saukhonghu_deck",
	path = "SauKhongHu.png",
	px = 71,
	py = 95,
})

SMODS.Back({
    key = "saukhonghu",
    atlas = "saukhonghu_deck",
    config = {hand_size = 1, extra = {win_ante_gain = 8}},
    apply = function(self, back)
		G.GAME.win_ante = G.GAME.win_ante + self.config.extra.win_ante_gain
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
        return {vars = {self.config.hand_size, 8 + self.config.extra.win_ante_gain}}
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
    config = {joker_slot = 1, hand_size = 2, extra = {win_ante_gain = 24}, vouchers = {"v_overstock_norm", "v_overstock_plus"}, ante_scaling = 2, remove_faces = true},
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
        G.GAME.win_ante = G.GAME.win_ante + self.config.extra.win_ante_gain
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
        return {vars = {self.config.joker_slot, self.config.hand_size, 8 + self.config.extra.win_ante_gain}}
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
	key = "tsaunami_deck",
	path = "Tsaunami.png",
	px = 71,
	py = 95,
})

SMODS.Back({
	key = "tsaunami",
	atlas = "tsaunami_deck",
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_saukhonghu'},
	calculate = function(self, back, context)
		if context.repetition and context.cardarea == G.play then
			local splash_retrig = find_joker('Splash')
			return {
				message = localize("k_again_ex"),
				repetitions = #splash_retrig,
				card = card,
			}
		end
	end,
	apply = function(self, back)
		SMODS.Joker:take_ownership('splash',
			{
				discovered = true,
				in_pool = function(self, args)
					return true, {allow_duplicates = true}
				end,
			},
			true
		)
	end
})

SMODS.Atlas({
	key = "sauphanim_deck",
	path = "Sauphanim.png",
	px = 71,
	py = 95,
})

SMODS.Back({
	key = "sauphanim",
	atlas = "sauphanim_deck",
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_tsaunami'},
	config = {extra = {dollars = 1}, vouchers = {"v_tarot_merchant"}, ante_scaling = 2, no_interest = true},
	calculate = function(self, back, context)
		if context.individual and context.cardarea == G.play then
			if context.other_card.ability.set == 'Enhanced' and not context.other_card.debuff then
				local temp = context.other_card
				G.E_MANAGER:add_event(Event({trigger = 'after', func = function()
					temp:set_ability(G.P_CENTERS.c_base)
					return true
				end}))
				return { dollars = self.config.extra.dollars }
			end
		end
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
		G.GAME.bosses_used["bl_psychic"] = 2 -- Prevent Psychic from giving you a jumpscare at Ante 1
		G.E_MANAGER:add_event(Event({
			func = function()
				for k, v in pairs(G.playing_cards) do
                    v.to_remove = true
                end
                local i = 1
                while i <= #G.playing_cards do
                    if G.playing_cards[i].to_remove then
                        G.playing_cards[i]:remove()
                    else
                        i = i + 1
                    end
                end
				G.GAME.starting_deck_size = #G.playing_cards
                return true
			end
		}))
		delay(0.4)
		G.E_MANAGER:add_event(Event({
			func = function()
				local marble = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_marble", "deck")
				marble:set_perishable(true)
				marble:add_to_deck()
				G.jokers:emplace(marble)
				marble:start_materialize()

				return true
			end,
		}))
	end,
	loc_vars = function(self)
        return {vars = {self.config.extra.dollars}}
    end,
})

SMODS.Atlas({
	key = "weeormhole_deck",
	path = "Weeormhole.png",
	px = 71,
	py = 95,
})

SMODS.Back({
	key = "weeormhole",
	atlas = "weeormhole_deck",
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_tsaunami'},
	calculate = function(self, back, context)
		if context.individual and context.cardarea == G.play then
			if not context.other_card.debuff then
				local temp = context.other_card
				if SMODS.has_no_rank(temp) or temp:get_id() > 2 then
					G.E_MANAGER:add_event(Event({
						func = function()
							temp.base.id = SMODS.has_no_rank(temp) and temp.base.id or math.max(2, temp.base.id - 1)
							local rank_suffix = skh_get_rank_suffix(temp)
							assert(SMODS.change_base(temp, nil, rank_suffix))

							return true
						end
					}))
				end
			end
		end
		if context.destroy_card and context.cardarea == G.play then
			if not context.destroying_card.debuff then
				local temp = context.destroying_card
				if not SMODS.has_no_rank(temp) and temp:get_id() <= 2 then
					return {
						message = localize("k_wee_ex"),
						remove = true
					}
				end
			end
		end
	end,
	apply = function(self, back)
		delay(0.4)
		G.E_MANAGER:add_event(Event({
			func = function()
				local wee = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_wee", "deck")
				wee:add_to_deck()
				G.jokers:emplace(wee)
				wee:start_materialize()

				return true
			end,
		}))
	end,
})

if CardSleeves then

	SMODS.Atlas({
		key = "tsaunami_sleeve",
		path = "TsaunamiSleeve.png",
		px = 71,
		py = 95,
	})

	CardSleeves.Sleeve({
		key = "tsaunami",
		name = "Tsaunami Sleeve",
		atlas = 'tsaunami_sleeve',
		pos = { x = 0, y = 0 },
		unlocked = false,
		unlock_condition = { deck = "b_skh_tsaunami", stake = "stake_blue" },
		calculate = function(self, sleeve, context)
			if self.get_current_deck_key() ~= "b_skh_tsaunami" then
				if context.repetition and context.cardarea == G.play then
					local splash_retrig = find_joker('Splash')
					return {
						message = localize("k_again_ex"),
						repetitions = #splash_retrig,
						card = card,
					}
				end
			end
		end,
		apply = function(self, sleeve)
			if self.get_current_deck_key() ~= "b_skh_tsaunami" then
				SMODS.Joker:take_ownership('splash',
					{
						discovered = true,
						in_pool = function(self, args)
							return true, {allow_duplicates = true}
						end,
					},
					true
				)
			else
				delay(0.4)
				G.E_MANAGER:add_event(Event({
					func = function()
						local splash = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_splash", "deck")
						splash:add_to_deck()
						G.jokers:emplace(splash)
						splash:start_materialize()

						local splash2 = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_splash", "deck")
						splash2:add_to_deck()
						G.jokers:emplace(splash2)
						splash2:start_materialize()

						return true
					end,
				}))
			end
		end,
		loc_vars = function(self)
			local key = self.key
			if self.get_current_deck_key() == "b_skh_tsaunami" then
				key = key .. "_alt"
			else
				key = self.key
			end
			return { key = key }
		end,
	})

	SMODS.Atlas({
		key = "weeormhole_sleeve",
		path = "WeeormholeSleeve.png",
		px = 71,
		py = 95,
	})

	CardSleeves.Sleeve({
		key = "weeormhole",
		name = "Weeormhole Sleeve",
		atlas = 'weeormhole_sleeve',
		pos = { x = 0, y = 0 },
		config = {},
		unlocked = false,
		unlock_condition = { deck = "b_skh_weeormhole", stake = "stake_black" },
		calculate = function(self, sleeve, context)
			if self.get_current_deck_key() ~= "b_skh_weeormhole" then
				if context.individual and context.cardarea == G.play then
					if not context.other_card.debuff then
						local temp = context.other_card
						if SMODS.has_no_rank(temp) or temp:get_id() > 2 then
							G.E_MANAGER:add_event(Event({
								func = function()
									temp.base.id = SMODS.has_no_rank(temp) and temp.base.id or math.max(2, temp.base.id - 1)
									local rank_suffix = skh_get_rank_suffix(temp)
									assert(SMODS.change_base(temp, nil, rank_suffix))

									return true
								end
							}))
						end
					end
				end
				if context.destroy_card and context.cardarea == G.play then
					if not context.destroying_card.debuff then
						local temp = context.destroying_card
						if not SMODS.has_no_rank(temp) and temp:get_id() <= 2 then
							return {
								message = localize("k_wee_ex"),
								remove = true
							}
						end
					end
				end
			end
		end,
		apply = function(self, sleeve)
			if self.get_current_deck_key() == "b_skh_weeormhole" then
				G.E_MANAGER:add_event(Event({
					func = function()
						for _, card in ipairs(G.playing_cards) do
							assert(SMODS.change_base(card, nil, self.config.only_one_rank))
						end

						return true
					end
				}))
			else
				delay(0.4)
				G.E_MANAGER:add_event(Event({
					func = function()
						local wee = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_wee", "deck")
						wee:add_to_deck()
						G.jokers:emplace(wee)
						wee:start_materialize()

						return true
					end,
				}))
			end
		end,
		loc_vars = function(self)
			local key = self.key
			if self.get_current_deck_key() == "b_skh_weeormhole" then
				key = key .. "_alt"
				self.config = {only_one_rank = '2'}
			else
				key = self.key
			end
			return { key = key }
		end,
	})
end

--------------------------------- ^^^^^^^^^^^^^^^^^^^^^^^^^ ---------------------------------
---------------------------------  7 divine entity decks    ---------------------------------
---------------------------------------------------------------------------------------------
--------------------------------- 7 deadly sin decks (WIP)  ---------------------------------
--------------------------------- vvvvvvvvvvvvvvvvvvvvvvvvv ---------------------------------

SMODS.Atlas({
	key = "lustyworm_deck",
	path = "SinLusty.png",
	px = 71,
	py = 95,
})

SMODS.Back({
	key = "lustyworm",
	atlas = "lustyworm_deck",
	calculate = function(self, back, context)
		if context.before then
			local suits = {}
			for i = 1, #context.full_hand do
				local temp = context.full_hand[i]
				if temp:get_id() == 13 then
					suits[#suits+1] = temp.base.suit
					for j = 1, #context.full_hand do
						local temp2 = context.full_hand[j]
						if temp2:get_id() == 12 then
							suits[#suits+1] = temp2.base.suit
							break
						end -- ooh, a rare case of using break end
					end
					break
				end -- this is to optimize performance in some way by limiting iterations whenever possible
			end
			if #suits == 2 then
				local new_jack = copy_card(context.full_hand[1], nil, nil, G.playing_card)
				assert(SMODS.change_base(new_jack, pseudorandom_element(suits, pseudoseed("lusty_deck_reproduce")), "Jack"))
				new_jack:add_to_deck()
				G.deck.config.card_limit = G.deck.config.card_limit + 1
				table.insert(G.playing_cards, new_jack)
				G.hand:emplace(new_jack)
				new_jack.states.visible = nil
				G.E_MANAGER:add_event(Event({
					func = function()
						new_jack:start_materialize()
						return true
					end
				}))
				return {
					message = localize('k_reproduced_ex'),
					colour = G.C.RED,
				}
			end
		end
	end
})

SMODS.Atlas({
	key = "greedyworm_deck",
	path = "SinGreedy.png",
	px = 71,
	py = 95,
})

SMODS.Back({
	key = "greedyworm",
	atlas = "greedyworm_deck",
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_lustyworm'},
	config = {extra = {dollars = 8}},
	calculate = function(self, back, context)
		if context.setting_blind then
			for i = 1, #G.jokers.cards do
				G.jokers.cards[i]:set_rental(true)
				if G.jokers.cards[i].edition then
					G.jokers.cards[i]:set_edition(nil)
					delay(0.1)
					ease_dollars(self.config.extra.dollars)
				end
			end
			for c = #G.playing_cards, 1, -1 do
				local temp = G.playing_cards[c]
				if not temp.debuff then
					if temp.edition then
						G.E_MANAGER:add_event(Event({trigger = 'after', func = function()
							temp:set_edition(nil)
							return true
						end}))
						delay(0.1)
						ease_dollars(self.config.extra.dollars)
					end
					if temp.seal then
						G.E_MANAGER:add_event(Event({trigger = 'after', func = function()
							temp:set_seal("Gold")
							return true
						end}))
					end
					if temp.ability.set == "Enhanced" then
						G.E_MANAGER:add_event(Event({trigger = 'after', func = function()
							temp:set_ability(G.P_CENTERS["m_gold"])
							return true
						end}))
					end
				end
			end
		end
		if context.context == "eval" and G.GAME.last_blind and G.GAME.last_blind.boss then
			G.E_MANAGER:add_event(Event({
				func = (function()
					add_tag(Tag('tag_investment'))
					play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
					play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
					return true
				end)
			}))
		end
	end,
	loc_vars = function(self)
        return {vars = {self.config.extra.dollars}}
    end,
})

SMODS.Atlas({
	key = "gluttonyworm_deck",
	path = "SinGluttony.png",
	px = 71,
	py = 95,
})

SMODS.Back({
	key = "gluttonyworm",
	atlas = "gluttonyworm_deck",
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_lustyworm'},
	config = {vouchers = {"v_magic_trick"}, extra = {odds = 6}},
	calculate = function(self, back, context)
		if context.context == "eval" and G.GAME.last_blind and G.GAME.last_blind.boss then
			G.E_MANAGER:add_event(Event({
				func = function()
					for k, v in pairs(G.playing_cards) do
						if pseudorandom('gluttony_deck_chomp') < G.GAME.probabilities.normal/self.config.extra.odds then
							card_eval_status_text(v, 'extra', nil, nil, nil, {message = localize('k_chomp_ex')})
							v.to_remove = true
						end
					end
					local i = 1
					while i <= #G.playing_cards do
						if G.playing_cards[i].to_remove then
							G.playing_cards[i]:remove()
						else
							i = i + 1
						end
					end
					return true
				end
			}))
			-- return {
			-- 	message = localize('k_chomp_ex'),
			-- 	colour = G.C.YELLOW,
			-- }
		end
	end,
	loc_vars = function(self)
		return {vars = {G.GAME.probabilities.normal, self.config.extra.odds}}
	end
})

SMODS.Atlas({
	key = "enviousworm_deck",
	path = "SinEnvious.png",
	px = 71,
	py = 95,
})

SMODS.Back({
	key = "enviousworm",
	atlas = "enviousworm_deck",
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_gluttonyworm'},
	config = {extra = {odds_common = nil,    odds_uncommon = 150,
					   odds_rare = 100,      odds_cry_epic = 80, -- envious_roulette is too janky
					   odds_legendary = 60,  odds_cry_exotic = 40, -- so I have to manually increase the odds
					   odds_cry_candy = 100, odds_cry_cursed = nil}}, -- to an absurd amount
	calculate = function(self, back, context)
		if context.end_of_round then
			-- local i = 1
			for i = 1, #G.jokers.cards do
				local temp = G.jokers.cards[i]
				if temp.config.center.rarity == 2 then
					envious_roulette(temp, "envious_uncommon", self.config.extra.odds_uncommon, i)
				elseif temp.config.center.rarity == 3 then
					envious_roulette(temp, "envious_rare", self.config.extra.odds_rare, i)
				elseif temp.config.center.rarity == 4 then
					envious_roulette(temp, "envious_legendary", self.config.extra.odds_legendary, i)
				end
				if Cryptid then -- I'm just unreasonably adding Cryptid compat, bruh
					if temp.config.center.rarity == 'cry_epic' then
						envious_roulette(temp, "envious_cry_epic", self.config.extra.odds_cry_epic, i)
					elseif temp.config.center.rarity == 'cry_exotic' then
						envious_roulette(temp, "envious_cry_exotic", self.config.extra.odds_cry_exotic, i)
					elseif temp.config.center.rarity == 'cry_candy' then
						envious_roulette(temp, "envious_cry_candy", self.config.extra.odds_cry_candy, i)
					end
				end
			end
		end
	end,
})

SMODS.Atlas({
	key = "slothfulworm_deck",
	path = "SinSlothful.png",
	px = 71,
	py = 95,
})

SMODS.Back({
	key = "slothfulworm",
	atlas = "slothfulworm_deck",
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_greedyworm'},
	config = {joker_slot = -3, consumable_slot = -1, hands = -1, discards = -2,
				extra = {odds = 30, ante_loss = 1, win_ante_loss = 1}},
	calculate = function(self, back, context)
		if context.end_of_round then
			if pseudorandom("slothful_backstep") < G.GAME.probabilities.normal/self.config.extra.odds then
				ease_ante(-self.config.extra.ante_loss)
				G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
				G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante - self.config.extra.ante_loss
			end
		end
	end,
	apply = function(self, back)
		G.GAME.win_ante = G.GAME.win_ante - self.config.extra.win_ante_loss
	end,
	loc_vars = function(self)
		return {vars = {self.config.joker_slot, self.config.consumable_slot, self.config.hands,
						self.config.discards, 8 - self.config.extra.win_ante_loss}}
	end,
})

----------------------------------------------------------------------------------

SMODS.Atlas({
	key = "modicon",
	path = "icon.png",
	px = 32,
	py = 32
})

SMODS.current_mod.description_loc_vars = function()
	return { background_colour = G.C.CLEAR, text_colour = G.C.WHITE, scale = 1.2 }
end

function skh_get_rank_suffix(card) -- copy-pasted from Ortalab, renamed with mod id prefix for uniqueness
    local rank_suffix = (card.base.id - 2) % 13 + 2
    if rank_suffix < 11 then rank_suffix = tostring(rank_suffix)
    elseif rank_suffix == 11 then rank_suffix = 'Jack'
    elseif rank_suffix == 12 then rank_suffix = 'Queen'
    elseif rank_suffix == 13 then rank_suffix = 'King'
    elseif rank_suffix == 14 then rank_suffix = 'Ace'
    end
    return rank_suffix
end

function envious_roulette(card, odd_seed, odd_type, iteration) -- Gros Michel logic - copy-pasted and modified
	if pseudorandom(odd_seed) < G.GAME.probabilities.normal/odd_type then
		G.E_MANAGER:add_event(Event({
			func = function()
				-- play_sound('tarot1')
				card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_killed_ex')})
				card.T.r = -0.2
				card:juice_up(0.3, 0.4)
				card.states.drag.is = true
				card.children.center.pinch.x = true
				G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
					func = function()
							G.jokers:remove_card(card)
							card:remove()
							card = nil
						return true; end}))
				return true
			end
		}))
		iteration = iteration - 1
	end
end