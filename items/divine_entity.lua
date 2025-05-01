SMODS.Back({
    key = "saukhonghu",
    atlas = "divine_entity",
    pos = { x = 0, y = 0 },
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

SMODS.Back({
    key = "sauhu",
    atlas = "divine_entity",
    pos = { x = 1, y = 0 },
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

SMODS.Back({
	key = "tsaunami",
	atlas = "divine_entity",
    pos = { x = 0, y = 1 },
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
})

SMODS.Back({
    key = "absolute_cinema",
    atlas = "divine_entity",
    pos = { x = 2, y = 0 },
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_sauhu'},
    config = {joker_slot = 2, hand_size = 8, extra = {win_ante_gain = 24}, vouchers = {"v_overstock_norm", "v_overstock_plus"}, ante_scaling = 2, remove_faces = true},
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

SMODS.Back({
	key = "plot_hole",
	atlas = "divine_entity",
    pos = { x = 3, y = 0 },
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

SMODS.Back({
	key = "sauphanim",
	atlas = "divine_entity",
    pos = { x = 1, y = 1 },
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_tsaunami'},
	config = {extra = {money = 1}, vouchers = {"v_tarot_merchant"}, ante_scaling = 2, no_interest = true},
	calculate = function(self, back, context)
		if context.individual and context.cardarea == G.play then
			if context.other_card.ability.set == 'Enhanced' and not context.other_card.debuff then
				local temp = context.other_card
				G.E_MANAGER:add_event(Event({trigger = 'after', func = function()
					temp:set_ability(G.P_CENTERS.c_base)
					return true
				end}))
				return { dollars = self.config.extra.money }
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
        return {vars = {self.config.extra.money}}
    end,
})

SMODS.Back({
	key = "weeormhole",
	atlas = "divine_entity",
    pos = { x = 2, y = 1 },
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
						sound = "skh_wee",
						colour = G.C.BLACK,
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

SMODS.Back({
	key = "hallucinatingworm_collection",
	atlas = "divine_entity",
	pos = { x = 3, y = 1 },
	unlocked = false,
	config = {extra = {in_game = false}},
	calculate = function(self, back, context)
		if G.GAME.facing_blind or not self.config.extra.in_game then self.config.extra.in_game = true end
		if G.GAME.random_choice == 1 then
			if context.context == "eval" and G.GAME.last_blind and G.GAME.last_blind.boss then
				if G.jokers.cards[1] then
					local target = pseudorandom(pseudoseed("hallucinating_joker"), 1, #G.jokers.cards)
					if G.jokers.cards[target] then
						_card = create_card("Joker", G.jokers, nil, nil, nil, nil, nil, "hallucinating_joker_gen")
						G.jokers.cards[target]:remove_from_deck()
						_card:add_to_deck()
						_card:start_materialize()
						G.jokers.cards[target] = _card
						_card:set_card_area(G.jokers)
						G.jokers:set_ranks()
						G.jokers:align_cards()
					end
				end
			end
		elseif G.GAME.random_choice == 2 then
			if context.individual and context.cardarea == G.play then
				if not context.other_card.debuff then
					local suits = {}
					local temp = context.other_card
					for _, v in pairs(SMODS.Suits) do
						suits[#suits+1] = tostring(v.key)
					end
					G.E_MANAGER:add_event(Event({
						func = function()
							temp.base.id = SMODS.has_no_rank(temp) and temp.base.id or pseudorandom("hallucinating_rank", 2, 14)
							local rank_suffix = skh_get_rank_suffix(temp)
							assert(SMODS.change_base(temp, pseudorandom_element(suits, pseudoseed("hallucinating_suit")), rank_suffix))

							return true
						end
					}))
					return {
						chips = pseudorandom("hallucinating_chip", -25, 40),
						mult = pseudorandom("hallucinating_mult", -10, 15),
						card = context.other_card
					}
				end
			end
		end
	end,
	apply = function(self, back)
		G.GAME.random_choice = pseudorandom("hallucinating_random", 1, 2)
		self.config.extra.in_game = true
	end,
	loc_vars = function(self)
		if self.config.extra.in_game then
			return {
				key = "b_skh_hallucinatingworm" .. tostring(G.GAME.random_choice)
			}
		else
			return {key = "b_skh_hallucinatingworm_collection"}
		end
	end,
	collection_loc_vars = function(self)
		return {key = "b_skh_hallucinatingworm_collection"}
	end,
	locked_loc_vars = function(self)
		return {key = "b_skh_hallucinatingworm_collection"}
	end,
	check_for_unlock = function(self, args)
		local decks = {"b_skh_saukhonghu", "b_skh_sauhu", "b_skh_tsaunami",
			"b_skh_absolute_cinema", "b_skh_plot_hole", "b_skh_sauphanim", "b_skh_weeormhole"}
		local temp = true
		for k, v in ipairs(decks) do
			local deck_info = G.PROFILES[G.SETTINGS.profile]
			and G.PROFILES[G.SETTINGS.profile].deck_usage
			and G.PROFILES[G.SETTINGS.profile].deck_usage[v]
			if not deck_info then temp = false
			elseif next(deck_info.wins) == nil then temp = false end
		end
		self.unlocked = temp
		if self.unlocked then return true end
	end
})

if CardSleeves then

	SMODS.Atlas({
		key = "sleeves",
		path = "Sleeves.png",
		px = 73,
		py = 95,
	})

	CardSleeves.Sleeve({
		key = "tsaunami",
		name = "Tsaunami Sleeve",
		atlas = 'sleeves',
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
			if self.get_current_deck_key() == "b_skh_tsaunami" then
				delay(0.4)
				G.E_MANAGER:add_event(Event({
					func = function()
						local splash = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_splash", "deck")
						splash:set_edition({ negative = true }, true)
						splash:add_to_deck()
						G.jokers:emplace(splash)
						splash:start_materialize()

						local splash2 = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_splash", "deck")
						splash2:set_edition({ negative = true }, true)
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

	CardSleeves.Sleeve({
		key = "weeormhole",
		name = "Weeormhole Sleeve",
		atlas = 'sleeves',
		pos = { x = 1, y = 0 },
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
								sound = "skh_wee",
								colour = G.C.BLACK,
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

SMODS.Joker:take_ownership('splash',
	{
		discovered = true,
		in_pool = function(self, args)
			local ret_table = {
				allow_duplicates = G.GAME.selected_back.effect.center.key == "b_skh_tsaunami"
			}
			if CardSleeves then
				ret_table.allow_duplicates = G.GAME.selected_back.effect.center.key == "b_skh_tsaunami"
				or G.GAME.selected_sleeve == "sleeve_skh_tsaunami"
			end
			return true, ret_table
		end,
	},
	true
)