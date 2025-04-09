SMODS.Atlas({
    key = "deadly_sin",
    path = "DeadlySin.png",
    px = 71,
    py = 95,
})

SMODS.Back({
	key = "lustyworm",
	atlas = "deadly_sin",
    pos = { x = 0, y = 0 },
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

SMODS.Back({
	key = "greedyworm",
	atlas = "deadly_sin",
    pos = { x = 1, y = 0 },
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_lustyworm'},
	config = {extra = {money = 8}},
	calculate = function(self, back, context)
		if context.setting_blind then
			for i = 1, #G.jokers.cards do
				G.jokers.cards[i]:set_rental(true)
				if G.jokers.cards[i].edition then
					G.jokers.cards[i]:set_edition(nil)
					delay(0.1)
					ease_dollars(self.config.extra.money)
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
						ease_dollars(self.config.extra.money)
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
					add_tag(Tag('tag_investment'))
					play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
					play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
					return true
				end)
			}))
		end
	end,
	apply = function(self, back)
		G.E_MANAGER:add_event(Event({
			func = (function()
				add_tag(Tag('tag_investment'))
				play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
				play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
				add_tag(Tag('tag_investment'))
				play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
				play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
				return true
			end)
		}))
	end,
	loc_vars = function(self)
        return {vars = {self.config.extra.money}}
    end,
})

SMODS.Back({
	key = "gluttonyworm",
	atlas = "deadly_sin",
    pos = { x = 2, y = 0 },
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_lustyworm'},
	config = {vouchers = {"v_magic_trick"}, extra = {odds = 6}},
	calculate = function(self, back, context)
		if context.context == "eval" and G.GAME.last_blind and G.GAME.last_blind.boss then
			G.E_MANAGER:add_event(Event({
				func = function()
					for k, v in pairs(G.playing_cards) do
						if pseudorandom('gluttony_deck_chomp') < G.GAME.probabilities.normal/self.config.extra.odds then
							play_sound("skh_chomp", 0.7, 0.3)
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

SMODS.Back({
	key = "slothfulworm",
	atlas = "deadly_sin",
    pos = { x = 0, y = 1 },
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

SMODS.Back({
	key = "wrathfulworm",
	atlas = "deadly_sin",
    pos = { x = 2, y = 1 },
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_greedyworm'},
	config = {extra = {hands = 3, xchipmult = 2, odds = 6, smash = false}},
	calculate = function(self, back, context)
		if context.setting_blind then
			G.E_MANAGER:add_event(Event({func = function()
				ease_discard(-G.GAME.current_round.discards_left, nil, true)
				ease_hands_played(self.config.extra.hands)
				return true end }))
		end
		if context.before then
			self.config.extra.smash = false
			if pseudorandom("wrathful_smash") < G.GAME.probabilities.normal/self.config.extra.odds then
				self.config.extra.smash = true
			end
		end
		if context.destroy_card and context.cardarea == G.play then
			return {
				remove = self.config.extra.smash and true or false
			}
		end
		if context.context == "final_scoring_step" and self.config.extra.smash then
			context.chips = context.chips * self.config.extra.xchipmult
			context.mult = context.mult * self.config.extra.xchipmult
			update_hand_text({ delay = 0 }, { mult = context.mult, chips = context.chips })

			G.E_MANAGER:add_event(Event({
				func = function()
					local text = localize("k_smash_ex")
					play_sound("multhit2", 1, 1)
					play_sound("xchips", 1, 1)
					play_sound("skh_smash", 0.7, 0.5)
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
		return {vars = {self.config.extra.hands, self.config.extra.xchipmult}}
	end
})

SMODS.Back({
	key = "enviousworm",
	atlas = "deadly_sin",
    pos = { x = 3, y = 0 },
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_gluttonyworm'},
	config = {extra = {odds_common = nil,    odds_uncommon = 150,
					   odds_rare = 100,      odds_cry_epic = 80,
					   odds_legendary = 60,  odds_cry_exotic = 40,
					   odds_cry_candy = 100, odds_cry_cursed = nil}},
	calculate = function(self, back, context)
		if context.end_of_round then
			local killed = false
			local has_common = false
			for i = 1, #G.jokers.cards do
				local temp = G.jokers.cards[i]
				if temp.config.center.rarity == 1 then
					has_common = true
				end
				if temp.config.center.rarity == 2 then
					killed = envious_roulette(temp, "envious_uncommon", self.config.extra.odds_uncommon, i)
				elseif temp.config.center.rarity == 3 then
					killed = envious_roulette(temp, "envious_rare", self.config.extra.odds_rare, i) or killed
				elseif temp.config.center.rarity == 4 then
					killed = envious_roulette(temp, "envious_legendary", self.config.extra.odds_legendary, i) or killed
				end
				if Cryptid then -- I'm just unreasonably adding Cryptid compat, bruh
					if temp.config.center.rarity == 'cry_epic' then
						killed = envious_roulette(temp, "envious_cry_epic", self.config.extra.odds_cry_epic, i) or killed
					elseif temp.config.center.rarity == 'cry_exotic' then
						killed = envious_roulette(temp, "envious_cry_exotic", self.config.extra.odds_cry_exotic, i) or killed
					elseif temp.config.center.rarity == 'cry_candy' then
						killed = envious_roulette(temp, "envious_cry_candy", self.config.extra.odds_cry_candy, i) or killed
					end
				end
			end
			if killed and has_common then
				play_sound("skh_envious_laugh", 1, 1)
			end
		end
	end,
})

SMODS.Back({
	key = "pridefulworm",
	atlas = "deadly_sin",
    pos = { x = 1, y = 1 },
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_gluttonyworm'},
	calculate = function(self, back, context)
		if context.setting_blind then
			for i = 1, #G.jokers.cards do
				local temp = G.jokers.cards[i]
				if temp.config.center.rarity == 1 or temp.config.center.rarity == 2 then
					G.E_MANAGER:add_event(Event({
						func = function()
							play_sound('tarot1')
							card_eval_status_text(temp, 'extra', nil, nil, nil, {message = localize('k_weak_ex')})
							temp.T.r = -0.2
							temp:juice_up(0.3, 0.4)
							temp.states.drag.is = true
							temp.children.center.pinch.x = true
							G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
								func = function()
										G.jokers:remove_card(temp)
										temp:remove()
										temp = nil
									return true; end}))
							return true
						end
					}))
					i = i - 1
				end
			end
		end
		if context.destroy_card and context.cardarea == G.play then
			if not context.destroying_card.debuff then
				local temp = context.destroying_card
				if not SMODS.has_no_rank(temp) and temp:get_id() < 13 then
					return {
						message = localize("k_weak_ex"),
						remove = true
					}
				end
			end
		end
	end,
	apply = function(self, back)
		G.E_MANAGER:add_event(Event({
			func = function()
				for k, v in pairs(G.playing_cards) do
                    if v:get_id() < 13 then
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
	end
})

SMODS.Back({
	key = "wormychaos",
	atlas = "deadly_sin",
    pos = { x = 3, y = 1 },
	unlocked = false,
	config = {extra = {
		in_game = false,
		current_deck_config = {
			triggered = nil,
			greedy_money = 8,
			gluttony_odds = 6,
			slothful_odds = 30,
			slothful_ante_loss = 1,
			wrathful_hands = 3,
			wrathful_xchipmult = 2,
			wrathful_odds = 6,
			odds_common = nil, odds_uncommon = 150, odds_rare = 100, odds_cry_epic = 80,
			odds_legendary = 60, odds_cry_exotic = 40, odds_cry_candy = 100, odds_cry_cursed = nil,
		}
	}},
	calculate = function(self, back, context)
		if G.GAME.facing_blind or not self.config.extra.in_game then self.config.extra.in_game = true end
		if context.before then self.config.extra.current_deck_config.triggered = false end
		if context.ending_shop then
			self.config.extra.in_game = true
			local decks = {"b_skh_lustyworm", "b_skh_greedyworm", "b_skh_gluttonyworm",
			"b_skh_slothfulworm", "b_skh_wrathfulworm", "b_skh_enviousworm", "b_skh_pridefulworm"}
			local new_decks = {}
			for k, v in ipairs(decks) do
				if v ~= G.GAME.chaos_roll then new_decks[#new_decks+1] = v end
			end
			G.GAME.chaos_roll = pseudorandom_element(new_decks, pseudoseed('chaos_roll'))
			play_sound("skh_new_chaos_roll", 1, 1)
		end
		if G.GAME.chaos_roll == "b_skh_lustyworm" then
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
							end
						end
						break
					end
				end
				if #suits == 2 then
					local new_jack = copy_card(context.full_hand[1], nil, nil, G.playing_card)
					assert(SMODS.change_base(new_jack, pseudorandom_element(suits, pseudoseed("chaos_lusty_deck_reproduce")), "Jack"))
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
		elseif G.GAME.chaos_roll == "b_skh_greedyworm" then
			if context.setting_blind then
				for i = 1, #G.jokers.cards do
					G.jokers.cards[i]:set_rental(true)
					if G.jokers.cards[i].edition then
						G.jokers.cards[i]:set_edition(nil)
						delay(0.1)
						ease_dollars(self.config.extra.current_deck_config.greedy_money)
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
							ease_dollars(self.config.extra.current_deck_config.greedy_money)
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
			if context.context == "eval" then
				G.E_MANAGER:add_event(Event({
					func = (function()
						add_tag(Tag('tag_investment'))
						play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
						play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
						return true
					end)
				}))
			end
		elseif G.GAME.chaos_roll == "b_skh_gluttonyworm" then
			if context.context == "eval" then
				G.E_MANAGER:add_event(Event({
					func = function()
						for k, v in pairs(G.playing_cards) do
							if pseudorandom('chaos_gluttony_deck_chomp') < G.GAME.probabilities.normal/self.config.extra.current_deck_config.gluttony_odds then
								play_sound("skh_chomp", 0.7, 0.3)
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
			end
		elseif G.GAME.chaos_roll == "b_skh_slothfulworm" then
			if context.end_of_round then
				if pseudorandom("chaos_slothful_backstep") < G.GAME.probabilities.normal/self.config.extra.current_deck_config.slothful_odds then
					ease_ante(-self.config.extra.current_deck_config.slothful_ante_loss)
					G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
					G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante - self.config.extra.current_deck_config.slothful_ante_loss
				end
			end
		elseif G.GAME.chaos_roll == "b_skh_wrathfulworm" then
			if context.setting_blind then
				G.E_MANAGER:add_event(Event({func = function()
					ease_discard(-G.GAME.current_round.discards_left, nil, true)
					ease_hands_played(self.config.extra.current_deck_config.wrathful_hands)
					return true end }))
			end
			if context.before then
				if pseudorandom("chaos_wrathful_smash") < G.GAME.probabilities.normal/self.config.extra.current_deck_config.wrathful_odds then
					self.config.extra.triggered = true
				end
			end
			if context.destroy_card and context.cardarea == G.play then
				return {
					remove = self.config.extra.triggered and true or false
				}
			end
			if context.context == "final_scoring_step" and self.config.extra.triggered then
				context.chips = context.chips * self.config.extra.current_deck_config.wrathful_xchipmult
				context.mult = context.mult * self.config.extra.current_deck_config.wrathful_xchipmult
				update_hand_text({ delay = 0 }, { mult = context.mult, chips = context.chips })

				G.E_MANAGER:add_event(Event({
					func = function()
						local text = localize("k_smash_ex")
						play_sound("multhit2", 1, 1)
						play_sound("xchips", 1, 1)
						play_sound("skh_smash", 0.7, 0.5)
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
		elseif G.GAME.chaos_roll == "b_skh_enviousworm" then
			if context.end_of_round then
				local killed = false
				local has_common = false
				for i = 1, #G.jokers.cards do
					local temp = G.jokers.cards[i]
					if temp.config.center.rarity == 1 then
						has_common = true
					end
					if temp.config.center.rarity == 2 then
						killed = envious_roulette(temp, "chaos_envious_uncommon", self.config.extra.current_deck_config.odds_uncommon, i)
					elseif temp.config.center.rarity == 3 then
						killed = envious_roulette(temp, "chaos_envious_rare", self.config.extra.current_deck_config.odds_rare, i) or killed
					elseif temp.config.center.rarity == 4 then
						killed = envious_roulette(temp, "chaos_envious_legendary", self.config.extra.current_deck_config.odds_legendary, i) or killed
					end
					if Cryptid then -- I'm just unreasonably adding Cryptid compat, bruh
						if temp.config.center.rarity == 'cry_epic' then
							killed = envious_roulette(temp, "chaos_envious_cry_epic", self.config.extra.current_deck_config.odds_cry_epic, i) or killed
						elseif temp.config.center.rarity == 'cry_exotic' then
							killed = envious_roulette(temp, "chaos_envious_cry_exotic", self.config.extra.current_deck_config.odds_cry_exotic, i) or killed
						elseif temp.config.center.rarity == 'cry_candy' then
							killed = envious_roulette(temp, "chaos_envious_cry_candy", self.config.extra.current_deck_config.odds_cry_candy, i) or killed
						end
					end
				end
				if killed and has_common then
					play_sound("skh_envious_laugh", 1, 1)
				end
			end
		elseif G.GAME.chaos_roll == "b_skh_pridefulworm" then
			if context.destroy_card and context.cardarea == G.play then
				if not context.destroying_card.debuff then
					local temp = context.destroying_card
					if not SMODS.has_no_rank(temp) and temp:get_id() < 13 then
						return {
							message = localize("k_weak_ex"),
							remove = true
						}
					end
				end
			end
			if context.context == "final_scoring_step" then
				G.E_MANAGER:add_event(Event({
					func = function()
						local prideful_debuff_targets = {}
						for i = 1, #G.jokers.cards do
							local temp = G.jokers.cards[i]
							if (temp.config.center.rarity == 1 or temp.config.center.rarity == 2) and not temp.debuff then
								prideful_debuff_targets[#prideful_debuff_targets+1] = temp
							end
						end
						local joker_to_debuff = #prideful_debuff_targets > 0 and pseudorandom_element(prideful_debuff_targets, pseudoseed("chaos_prideful_debuff"))
						if joker_to_debuff then
							joker_to_debuff:set_debuff(true)
							joker_to_debuff:juice_up()
							G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.06*G.SETTINGS.GAMESPEED, blockable = false, blocking = false, func = function()
								play_sound('tarot2', 0.76, 0.4);return true end}))
							play_sound('tarot2', 1, 0.4)
						end
						return true
					end
				}))
			end
			if context.context == "eval" then
				for i = 1, #G.jokers.cards do
					local temp = G.jokers.cards[i]
					if temp.debuff then
						temp:set_debuff(false)
					end
				end
			end
		end
	end,
	apply = function(self, back)
		self.config.extra.in_game = true
	end,
	loc_vars = function(self)
		if self.config.extra.in_game then
			return {
				vars = {G.localization.descriptions.Back[G.GAME.chaos_roll].name},
				key = "b_skh_wormychaos"
			}
		else
			return {key = "b_skh_wormychaos_collection"}
		end
	end,
	collection_loc_vars = function(self)
		return {key = "b_skh_wormychaos_collection"}
	end,
	locked_loc_vars = function(self)
		return {key = "b_skh_wormychaos_collection"}
	end,
	check_for_unlock = function(self, args)
		local decks = {"b_skh_lustyworm", "b_skh_greedyworm", "b_skh_gluttonyworm",
			"b_skh_slothfulworm", "b_skh_wrathfulworm", "b_skh_enviousworm", "b_skh_pridefulworm"}
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