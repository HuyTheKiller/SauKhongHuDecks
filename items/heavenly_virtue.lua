SMODS.Atlas({
    key = "heavenly_virtue",
    path = "HeavenlyVirtue.png",
    px = 71,
    py = 95,
})

SMODS.Back({
	key = "virginworm",
	atlas = "heavenly_virtue",
    pos = { x = 0, y = 0 },
	config = {extra = {hand_this_round = localize("k_none"), hand_lock = false}},
	calculate = function(self, back, context)
		if context.before then
			if not self.config.extra.hand_lock then
				self.config.extra.hand_this_round = localize(context.scoring_name, "poker_hands")
				self.config.extra.hand_lock = true
			else
				if self.config.extra.hand_this_round ~= localize(context.scoring_name, "poker_hands") then
					for k, v in ipairs(context.scoring_hand) do
						if not v.debuff then
							v:set_debuff(true)
						end
					end
				end
			end
		end
		if context.end_of_round then
			self.config.extra.hand_this_round = localize("k_none")
			self.config.extra.hand_lock = false
		end
		if context.context == "eval" and G.GAME.last_blind and G.GAME.last_blind.boss then
			for c = #G.playing_cards, 1, -1 do
				if G.playing_cards[c].debuff then
					G.playing_cards[c]:set_debuff(false)
				end
			end
		end
	end,
	apply = function(self, back)
        self.config.extra.hand_this_round = localize("k_none")
		self.config.extra.hand_lock = false
		delay(0.4)
		G.E_MANAGER:add_event(Event({
			func = function()
				local card_sharp = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_card_sharp", "deck")
				card_sharp:add_to_deck()
				G.jokers:emplace(card_sharp)
				card_sharp:start_materialize()

				return true
			end,
		}))
	end,
	loc_vars = function(self)
		return {vars = {self.config.extra.hand_this_round}}
	end
})

SMODS.Back({
	key = "humbleworm",
	atlas = "heavenly_virtue",
    pos = { x = 1, y = 0 },
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_virginworm'},
	config = {extra = {percent = 0.5, anti_humble = nil}},
	calculate = function(self, back, context)
		if context.before then
			self.config.extra.anti_humble = next(context.poker_hands['Straight'])
										or next(context.poker_hands['Flush'])
										or next(context.poker_hands['Full House'])
										or next(context.poker_hands['Four of a Kind'])
		end
		if context.context == "final_scoring_step" then
			if self.config.extra.anti_humble then
				context.chips = math.max(math.floor(context.chips*self.config.extra.percent + 0.5), 0)
				context.mult = math.max(math.floor(context.mult*self.config.extra.percent + 0.5), 1)
			else
				context.chips = context.chips*(1+self.config.extra.percent)
				context.mult = context.mult*(1+self.config.extra.percent)
			end
			update_hand_text({ delay = 0 }, { mult = context.mult, chips = context.chips })

			G.E_MANAGER:add_event(Event({
				func = function()
					local text = self.config.extra.anti_humble and localize("k_not_humbled_ex") or localize("k_humbled_ex")
					play_sound("multhit2", 1, 1)
					play_sound("xchips", 1, 1)
					attention_text({
						scale = 1.4,
						text = text,
						hold = 2,
						align = "cm",
						offset = { x = 0, y = -2.7 },
						major = G.play,
					})
					return true
				end,
			}))
			delay(0.6)
			return context.chips, context.mult
		end
	end,
	loc_vars = function(self)
		return {vars = {self.config.extra.percent, 1+self.config.extra.percent}}
	end
})

SMODS.Back({
	key = "diligentworm",
	atlas = "heavenly_virtue",
    pos = { x = 2, y = 0 },
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_virginworm'},
	config = {extra = {Xmult = 0.5, Xmult_final = 3}},
	calculate = function(self, back, context)
		if context.context == "final_scoring_step" then
			if G.GAME.current_round.hands_left == 0 then
				context.mult = context.mult*self.config.extra.Xmult_final
			else
				context.mult = math.max(math.floor(context.mult*self.config.extra.Xmult + 0.5), 1)
			end
			update_hand_text({ delay = 0 }, { mult = context.mult, chips = context.chips })

			G.E_MANAGER:add_event(Event({
				func = function()
					local text = G.GAME.current_round.hands_left == 0 and localize("k_complete_ex") or localize("k_not_enough_ex")
					play_sound("multhit2", 1, 1)
					attention_text({
						scale = 1.4,
						text = text,
						hold = 2,
						align = "cm",
						offset = { x = 0, y = -2.7 },
						major = G.play,
					})
					return true
				end,
			}))
			delay(0.6)
			return context.chips, context.mult
		end
	end,
	loc_vars = function(self)
		return {vars = {self.config.extra.Xmult_final, self.config.extra.Xmult}}
	end
})

SMODS.Back({
	key = "abstemiousworm",
	atlas = "heavenly_virtue",
    pos = { x = 3, y = 0 },
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_humbleworm'},
	config = {joker_slot = -1, consumable_slot = -1},
	apply = function(self, back)
		local first_suit = pseudorandom_element({'Spades','Hearts','Clubs','Diamonds'}, pseudoseed('abstemious_remove1'))
		local seconds_suits = {}
		for k, v in ipairs({'Spades','Hearts','Clubs','Diamonds'}) do
			if v ~= first_suit then seconds_suits[#seconds_suits+1] = v end
		end
		local second_suit = pseudorandom_element(seconds_suits, pseudoseed('abstemious_remove2'))
		G.E_MANAGER:add_event(Event({
			func = function()
				for k, v in pairs(G.playing_cards) do
                    if v.base.suit == first_suit or v.base.suit == second_suit then
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
				G.GAME.starting_deck_size = #G.playing_cards
                return true
			end
		}))
	end,
	loc_vars = function(self)
		return {vars = {self.config.joker_slot, self.config.consumable_slot}}
	end
})

SMODS.Back({
	key = "kindworm",
	atlas = "heavenly_virtue",
    pos = { x = 1, y = 1 },
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_humbleworm'},
	config = {extra = {deck_mult = 2}},
	apply = function(self, back)
		G.E_MANAGER:add_event(Event({
            func = function()
				for d = 2, self.config.extra.deck_mult do
					for i = 1, #G.playing_cards do
						local card = G.playing_cards[i]
						local _card = copy_card(card, nil, nil, G.playing_card)
						_card:add_to_deck()
						table.insert(G.playing_cards, _card)
						G.deck:emplace(_card)
					end
				end
				G.GAME.starting_deck_size = #G.playing_cards
                return true
            end
        }))
	end,
	loc_vars = function(self)
		return {vars = {self.config.extra.deck_mult}}
	end
})

SMODS.Back({
	key = "generousworm",
	atlas = "heavenly_virtue",
    pos = { x = 0, y = 1 },
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_diligentworm'},
	config = {extra = {debt_Xmult = 3, megadebt_Xmult = 5, current_dollars = 0, super_generous = nil}},
	calculate = function(self, back, context)
		if context.before then
			self.config.extra.super_generous = false
			self.config.extra.current_dollars = G.GAME.dollars
			if self.config.extra.current_dollars <= -20 then
				self.config.extra.super_generous = true
			end
		end
		if context.context == "final_scoring_step" then
			if self.config.extra.current_dollars <= -15 then
				if self.config.extra.super_generous then
					context.mult = context.mult*self.config.extra.megadebt_Xmult
				else
					context.mult = context.mult*self.config.extra.debt_Xmult
				end

				update_hand_text({ delay = 0 }, { mult = context.mult, chips = context.chips })

				G.E_MANAGER:add_event(Event({
					func = function()
						local text = self.config.extra.super_generous and localize("k_super_generous_ex") or localize("k_generous_ex")
						play_sound("multhit2", 1, 1)
						attention_text({
							scale = 1.4,
							text = text,
							hold = 2,
							align = "cm",
							offset = { x = 0, y = -2.7 },
							major = G.play,
						})
						return true
					end,
				}))
			end
			delay(0.6)
			return context.chips, context.mult
		end
	end,
	apply = function(self, back)
		delay(0.4)
		G.E_MANAGER:add_event(Event({
			func = function()
				local credit_card = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_credit_card", "deck")
				credit_card:add_to_deck()
				G.jokers:emplace(credit_card)
				credit_card:start_materialize()

				return true
			end,
		}))
	end,
	loc_vars = function(self)
		return {vars = {self.config.extra.debt_Xmult, self.config.extra.megadebt_Xmult}}
	end
})

SMODS.Back({
	key = "patientworm",
	atlas = "heavenly_virtue",
    pos = { x = 2, y = 1 },
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_diligentworm'},
	config = {extra = {xchipmult = 3, odds = 1, calm = false, in_game = false}},
	calculate = function(self, back, context)
		if G.GAME.facing_blind or not self.config.extra.in_game then self.config.extra.in_game = true
		else self.config.extra.odds = math.max(1, 3*#G.jokers.cards) end
		if context.before then
			self.config.extra.calm = false
			if pseudorandom("patient_calm") < G.GAME.probabilities.normal/self.config.extra.odds then
				self.config.extra.calm = true
			end
		end
		if context.context == "final_scoring_step" and self.config.extra.calm then
			context.chips = context.chips * self.config.extra.xchipmult
			context.mult = context.mult * self.config.extra.xchipmult
			update_hand_text({ delay = 0 }, { mult = context.mult, chips = context.chips })

			G.E_MANAGER:add_event(Event({
				func = function()
					local text = localize("k_calm_ex")
					play_sound("multhit2", 1, 1)
					play_sound("xchips", 1, 1)
					attention_text({
						scale = 1.4,
						text = text,
						hold = 2,
						align = "cm",
						offset = { x = 0, y = -2.7 },
						major = G.play,
					})
					return true
				end,
			}))
			delay(0.6)
			return context.chips, context.mult
		end
	end,
	apply = function(self, back)
		self.config.extra.in_game = true
	end,
	loc_vars = function(self)
		if self.config.extra.in_game then
			return {vars = {G.GAME.probabilities.normal, self.config.extra.odds, self.config.extra.xchipmult}}
		else
			return {
				vars = {G.GAME.probabilities.normal, self.config.extra.xchipmult},
				key = "b_skh_patientworm_collection"
			}
		end
	end,
	collection_loc_vars = function(self)
		return {
			vars = {G.GAME.probabilities.normal, self.config.extra.xchipmult},
			key = "b_skh_patientworm_collection"
		}
	end
})

SMODS.Back({
	key = "omnipotentworm",
	atlas = "heavenly_virtue",
	pos = { x = 3, y = 1 },
	unlocked = false,
	config = {extra = {
		current_deck = "b_skh_patientworm",
		in_game = false,
		current_deck_config = {
			triggered = nil,
			virgin_hand_this_round = localize("k_none"),
			virgin_hand_lock = false,
			virgin_Xmult = 2,
			humble_percent = 0.5,
			diligent_Xmult = 0.5,
			diligent_Xmult_final = 3,
			abstemious_Xmult = 1,
			abstemious_bonus = 0.25,
			generous_debt_Xmult = 3,
			generous_megadebt_Xmult = 5,
			generous_current_dollars = 0,
			generous_super_generous = nil,
			patient_xchipmult = 3,
			patient_odds = 1,
		}
	}},
	calculate = function(self, back, context)
		if G.GAME.facing_blind or not self.config.extra.in_game then self.config.extra.in_game = true end
		if context.before then self.config.extra.current_deck_config.triggered = false end
		if context.end_of_round then
			self.config.extra.current_deck_config.virgin_hand_this_round = localize("k_none")
			self.config.extra.current_deck_config.virgin_hand_lock = false
		end
		if context.reroll_shop then
			self.config.extra.in_game = true
			local decks = {"b_skh_virginworm", "b_skh_humbleworm", "b_skh_diligentworm",
			"b_skh_abstemiousworm", "b_skh_kindworm", "b_skh_generousworm", "b_skh_patientworm"}
			local new_decks = {}
			for k, v in ipairs(decks) do
				if v ~= self.config.extra.current_deck then new_decks[#new_decks+1] = v end
			end
			self.config.extra.current_deck = pseudorandom_element(new_decks, pseudoseed('omnipotent_roll'))
			play_sound("skh_new_omnipotent_roll", 1, 1)
		end
		if self.config.extra.current_deck == "b_skh_virginworm" then
			if context.before then
				if not self.config.extra.current_deck_config.virgin_hand_lock then
					self.config.extra.current_deck_config.virgin_hand_this_round = localize(context.scoring_name, "poker_hands")
					self.config.extra.current_deck_config.virgin_hand_lock = true
				else
					if self.config.extra.current_deck_config.virgin_hand_this_round ~= localize(context.scoring_name, "poker_hands") then
						for k, v in ipairs(context.scoring_hand) do
							if not v.debuff then
								v:set_debuff(true)
							end
						end
					else self.config.extra.current_deck_config.triggered = true
					end
				end
			end
			if context.context == "final_scoring_step" and self.config.extra.current_deck_config.triggered then
				context.mult = context.mult*self.config.extra.current_deck_config.virgin_Xmult
				update_hand_text({ delay = 0 }, { mult = context.mult, chips = context.chips })

				G.E_MANAGER:add_event(Event({
					func = function()
						local text = localize("k_virgin_ex")
						play_sound("multhit2", 1, 1)
						attention_text({
							scale = 1.4,
							text = text,
							hold = 2,
							align = "cm",
							offset = { x = 0, y = -2.7 },
							major = G.play,
						})
						return true
					end,
				}))
				delay(0.6)
				return context.chips, context.mult
			end
			if context.end_of_round then
				for c = #G.playing_cards, 1, -1 do
					if G.playing_cards[c].debuff then
						G.playing_cards[c]:set_debuff(false)
					end
				end
			end
		elseif self.config.extra.current_deck == "b_skh_humbleworm" then
			if context.before then
				self.config.extra.current_deck_config.triggered = next(context.poker_hands['Straight'])
																or next(context.poker_hands['Flush'])
																or next(context.poker_hands['Full House'])
																or next(context.poker_hands['Four of a Kind'])
			end
			if context.context == "final_scoring_step" then
				if self.config.extra.current_deck_config.triggered then
					context.chips = math.max(math.floor(context.chips*self.config.extra.current_deck_config.humble_percent + 0.5), 0)
					context.mult = math.max(math.floor(context.mult*self.config.extra.current_deck_config.humble_percent + 0.5), 1)
				else
					context.chips = context.chips*(1+self.config.extra.current_deck_config.humble_percent)
					context.mult = context.mult*(1+self.config.extra.current_deck_config.humble_percent)
				end
				update_hand_text({ delay = 0 }, { mult = context.mult, chips = context.chips })

				G.E_MANAGER:add_event(Event({
					func = function()
						local text = self.config.extra.current_deck_config.triggered and localize("k_not_humbled_ex") or localize("k_humbled_ex")
						play_sound("multhit2", 1, 1)
						play_sound("xchips", 1, 1)
						attention_text({
							scale = 1.4,
							text = text,
							hold = 2,
							align = "cm",
							offset = { x = 0, y = -2.7 },
							major = G.play,
						})
						return true
					end,
				}))
				delay(0.6)
				return context.chips, context.mult
			end
		elseif self.config.extra.current_deck == "b_skh_diligentworm" then
			if context.context == "final_scoring_step" then
				if G.GAME.current_round.hands_left == 0 then
					context.mult = context.mult*self.config.extra.current_deck_config.diligent_Xmult_final
				else
					context.mult = math.max(math.floor(context.mult*self.config.extra.current_deck_config.diligent_Xmult + 0.5), 1)
				end
				update_hand_text({ delay = 0 }, { mult = context.mult, chips = context.chips })

				G.E_MANAGER:add_event(Event({
					func = function()
						local text = G.GAME.current_round.hands_left == 0 and localize("k_complete_ex") or localize("k_not_enough_ex")
						play_sound("multhit2", 1, 1)
						attention_text({
							scale = 1.4,
							text = text,
							hold = 2,
							align = "cm",
							offset = { x = 0, y = -2.7 },
							major = G.play,
						})
						return true
					end,
				}))
				delay(0.6)
				return context.chips, context.mult
			end
		elseif self.config.extra.current_deck == "b_skh_abstemiousworm" then
			if context.before then
				for i = 1, #context.full_hand do
					if i > 3 then
						local temp = context.full_hand[i]
						temp:set_debuff(true)
						self.config.extra.current_deck_config.abstemious_Xmult =
						  self.config.extra.current_deck_config.abstemious_Xmult
						+ self.config.extra.current_deck_config.abstemious_bonus
					end
				end
			end
			if context.context == "final_scoring_step" and self.config.extra.current_deck_config.abstemious_Xmult > 1 then
				context.mult = context.mult*self.config.extra.current_deck_config.abstemious_Xmult
				update_hand_text({ delay = 0 }, { mult = context.mult, chips = context.chips })

				G.E_MANAGER:add_event(Event({
					func = function()
						local text = localize("k_diet_ex")
						play_sound("multhit2", 1, 1)
						attention_text({
							scale = 1.4,
							text = text,
							hold = 2,
							align = "cm",
							offset = { x = 0, y = -2.7 },
							major = G.play,
						})
						return true
					end,
				}))
				delay(0.6)
				return context.chips, context.mult
			end
			if context.end_of_round then
				self.config.extra.current_deck_config.abstemious_Xmult = 1
				for c = #G.playing_cards, 1, -1 do
					if G.playing_cards[c].debuff then
						G.playing_cards[c]:set_debuff(false)
					end
				end
			end
		elseif self.config.extra.current_deck == "b_skh_kindworm" then
		elseif self.config.extra.current_deck == "b_skh_generousworm" then
			if context.before then
				self.config.extra.current_deck_config.generous_super_generous = false
				self.config.extra.current_deck_config.generous_current_dollars = G.GAME.dollars
				if self.config.extra.current_deck_config.generous_current_dollars <= 0 then
					self.config.extra.super_generous = true
				end
			end
			if context.context == "final_scoring_step" then
				if self.config.extra.current_deck_config.generous_current_dollars <= 5 then
					if self.config.extra.current_deck_config.generous_super_generous then
						context.mult = context.mult*self.config.extra.current_deck_config.generous_megadebt_Xmult
					else
						context.mult = context.mult*self.config.extra.current_deck_config.generous_debt_Xmult
					end

					update_hand_text({ delay = 0 }, { mult = context.mult, chips = context.chips })

					G.E_MANAGER:add_event(Event({
						func = function()
							local text = self.config.extra.current_deck_config.generous_super_generous
								and localize("k_super_generous_ex") or localize("k_generous_ex")
							play_sound("multhit2", 1, 1)
							attention_text({
								scale = 1.4,
								text = text,
								hold = 2,
								align = "cm",
								offset = { x = 0, y = -2.7 },
								major = G.play,
							})
							return true
						end,
					}))
				end
				delay(0.6)
				return context.chips, context.mult
			end
		elseif self.config.extra.current_deck == "b_skh_patientworm" then
			if G.GAME.facing_blind then
				self.config.extra.odds = math.max(1, 3*#G.jokers.cards)
			end
			if context.before then
				if pseudorandom("omnipotent_patient_calm") < G.GAME.probabilities.normal/self.config.extra.current_deck_config.patient_odds then
					self.config.extra.current_deck_config.triggered = true
				end
			end
			if context.context == "final_scoring_step" and self.config.extra.current_deck_config.triggered then
				context.chips = context.chips * self.config.extra.current_deck_config.patient_xchipmult
				context.mult = context.mult * self.config.extra.current_deck_config.patient_xchipmult
				update_hand_text({ delay = 0 }, { mult = context.mult, chips = context.chips })

				G.E_MANAGER:add_event(Event({
					func = function()
						local text = localize("k_calm_ex")
						play_sound("multhit2", 1, 1)
						play_sound("xchips", 1, 1)
						attention_text({
							scale = 1.4,
							text = text,
							hold = 2,
							align = "cm",
							offset = { x = 0, y = -2.7 },
							major = G.play,
						})
						return true
					end,
				}))
				delay(0.6)
				return context.chips, context.mult
			end
		end
	end,
	apply = function(self, back)
		self.config.extra.in_game = true
		self.config.extra.current_deck = "b_skh_patientworm"
		self.config.extra.current_deck_config.virgin_hand_this_round = localize("k_none")
		self.config.extra.current_deck_config.virgin_hand_lock = false
	end,
	loc_vars = function(self)
		if self.config.extra.in_game then
			return {
				vars = {G.localization.descriptions.Back[self.config.extra.current_deck].name},
				key = "b_skh_omnipotentworm"
			}
		else
			return {key = "b_skh_omnipotentworm_collection"}
		end
	end,
	collection_loc_vars = function(self)
		return {key = "b_skh_omnipotentworm_collection"}
	end,
	locked_loc_vars = function(self)
		return {key = "b_skh_omnipotentworm_collection"}
	end,
	check_for_unlock = function(self, args)
		local decks = {"b_skh_virginworm", "b_skh_humbleworm", "b_skh_diligentworm",
			"b_skh_abstemiousworm", "b_skh_kindworm", "b_skh_generousworm", "b_skh_patientworm"}
		local temp = true
		for k, v in ipairs(decks) do
			local deck_info = G.PROFILES[G.SETTINGS.profile]
			and G.PROFILES[G.SETTINGS.profile].deck_usage
			and G.PROFILES[G.SETTINGS.profile].deck_usage[v]
			if deck_info then temp = temp and deck_info.wins > 0
			else temp = false end
		end
		self.unlocked = temp
		if self.unlocked then return true end
	end
})