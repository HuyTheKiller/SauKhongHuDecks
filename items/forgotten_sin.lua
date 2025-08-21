SMODS.Back({
    key = "forgotten_lusty",
    atlas = not config.AltTexture and "forgotten_sin" or "forgotten_sin_alt",
    pos = { x = 0, y = 0 },
    omit = not config.DisableOverride and not SKHDecks.mod_list.multiplayer,
    unlocked = false,
    unlock_condition = {type = 'win_deck', deck = 'b_skh_lustyworm'},
    config = {b_side_lock = true},
    calculate = function(self, back, context)
        if context.before then
            local face_count = 0
            for i = 1, #context.full_hand do
                local temp = context.full_hand[i]
                if temp:is_face() then
                    face_count = face_count + 1
                end
            end
            if face_count > 1 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local ranks = {}
                        for k, rank in pairs(SMODS.Ranks) do
                            if not rank.face then ranks[#ranks + 1] = k end
                        end
                        local new_cards = {}
                        for i=2, face_count do
                            G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                            local new_card = copy_card(context.full_hand[i], nil, nil, G.playing_card)
                            SMODS.change_base(new_card, nil, pseudorandom_element(ranks, pseudoseed('b_lusty_debaunched')))
                            playing_card_randomise(new_card)
                            table.insert(new_cards, new_card)
                        end
                        for i, new_card in ipairs(new_cards) do
                            new_card:add_to_deck()
                            G.deck.config.card_limit = G.deck.config.card_limit + 1
                            table.insert(G.playing_cards, new_card)
                            G.deck:emplace(new_card)
                            context.full_hand[i+1]:juice_up()
                            new_card:juice_up()
                        end
                        playing_card_joker_effects(new_cards)
                        G.deck:shuffle('b_lusty_shuffle')
                        local text = localize("k_debaunched_ex")
                        play_sound("skh_debaunched", 1, 1)
                        attention_text({
                            scale = 1.4,
                            text = text,
                            hold = 2,
                            align = "cm",
                            offset = { x = 0, y = -2.7 },
                            major = G.play,
                        })
                        return true
                    end
                }))
            end
        end
    end
})

SKHDecks.add_skh_b_side("b_skh_lustyworm", "b_skh_forgotten_lusty")

SMODS.Back({
    key = "forgotten_greedy",
    atlas = not config.AltTexture and "forgotten_sin" or "forgotten_sin_alt",
    pos = { x = 1, y = 0 },
    omit = not config.DisableOverride and not SKHDecks.mod_list.multiplayer,
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_greedyworm'},
    config = {dollars = 96, b_side_lock = true, extra = {money_common = 6, money_uncommon = 4, money_rare = 2, money_loss = 1, money_loss_per_ante = 0}},
    calculate = function(self, back, context)
        if context.before then
            for i = 1, #G.play.cards do
                G.E_MANAGER:add_event(Event({func = function() G.play.cards[i]:juice_up(); return true end }))
                ease_dollars(-self.config.extra.money_loss)
                delay(0.15)
            end
        end
        if context.skh_press then
            ease_dollars(-self.config.extra.money_loss)
        end
        if context.post_trigger then
            local temp = context.other_card
            if temp.config.center.rarity == 1 then
                return {
                    dollars = self.config.extra.money_common,
                    card = context.other_context.blueprint_card or context.other_card,
                }
            elseif temp.config.center.rarity == 2 then
                return {
                    dollars = self.config.extra.money_uncommon,
                    card = context.other_context.blueprint_card or context.other_card,
                }
            elseif temp.config.center.rarity == 3 then
                return {
                    dollars = self.config.extra.money_rare,
                    card = context.other_context.blueprint_card or context.other_card,
                }
            end
		end
        if context.context == "eval" and G.GAME.last_blind and G.GAME.last_blind.boss then
            self.config.extra.money_loss_per_ante = math.floor(to_number(G.GAME.dollars)/4)
            ease_dollars(-self.config.extra.money_loss_per_ante)
        end
    end,
    apply = function(self, back)
        G.GAME.modifiers.discard_cost = self.config.extra.money_loss
    end,
    loc_vars = function(self)
        return {vars = {4+self.config.dollars, self.config.extra.money_loss}}
    end
})

SKHDecks.add_skh_b_side("b_skh_greedyworm", "b_skh_forgotten_greedy")

SMODS.Back({
    key = "forgotten_gluttony",
    atlas = not config.AltTexture and "forgotten_sin" or "forgotten_sin_alt",
    pos = { x = 2, y = 0 },
    omit = not config.DisableOverride and not SKHDecks.mod_list.multiplayer,
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_gluttonyworm'},
    config = {b_side_lock = true},
    calculate = function(self, back, context)
        if context.destroy_card and context.cardarea == G.play then
            G.GAME.cards_destroyed = G.GAME.cards_destroyed + 1
            return {
                message = localize('k_chomp_ex'),
                sound = "skh_chomp",
                colour = G.C.YELLOW,
                remove = true
            }
        end
        if context.context == "eval" and G.GAME.cards_destroyed > 0 then
            play_sound("skh_vomit", 1, 1)
            for _ = 1, math.max(1, math.floor(G.GAME.cards_destroyed/4)) do
                local new_card = create_playing_card(nil, G.deck)
                new_card:add_to_deck()
                playing_card_randomise(new_card)
                playing_card_joker_effects({new_card})
            end
            G.GAME.cards_destroyed = 0
        end
    end
})

SKHDecks.add_skh_b_side("b_skh_gluttonyworm", "b_skh_forgotten_gluttony")

SMODS.Back({
	key = "forgotten_slothful",
	atlas = not config.AltTexture and "forgotten_sin" or "forgotten_sin_alt",
    pos = { x = 0, y = 1 },
    omit = not config.DisableOverride and not SKHDecks.mod_list.multiplayer,
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_slothfulworm'},
	config = {joker_slot = -3, consumable_slot = -1, hands = -1, discards = -2,
				extra = {odds1 = 4, odds2 = 4, odds3 = 4, ante_loss = 1}, b_side_lock = true},
	calculate = function(self, back, context)
		if context.end_of_round and not context.repetition and not context.individual then
            local has_dropped = false
			if SMODS.pseudorandom_probability(back, 'b_slothful_backstep1', 1, self.config.extra.odds1, 'b_slothful_deck1') then
                has_dropped = true
				ease_ante(-self.config.extra.ante_loss)
				G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
				G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante - self.config.extra.ante_loss
			end
			if SMODS.pseudorandom_probability(back, 'b_slothful_backstep2', 1, self.config.extra.odds2, 'b_slothful_deck2') then
				has_dropped = true
                ease_ante(-self.config.extra.ante_loss)
				G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
				G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante - self.config.extra.ante_loss
			end
            if SMODS.pseudorandom_probability(back, 'b_slothful_backstep3', 1, self.config.extra.odds3, 'b_slothful_deck3') then
				has_dropped = true
                ease_ante(-self.config.extra.ante_loss)
				G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
				G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante - self.config.extra.ante_loss
			end
            if has_dropped then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local text = localize("k_zzz")
                        play_sound("skh_sleeping", 1, 1)
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
		end
	end,
	apply = function(self, back)
		local random_ante = pseudorandom('forgotten_slothful_random_ante', -3, 2)
        G.GAME.win_ante = G.GAME.win_ante + random_ante
	end
})

SKHDecks.add_skh_b_side("b_skh_slothfulworm", "b_skh_forgotten_slothful")

SMODS.Back({
	key = "forgotten_wrathful",
	atlas = not config.AltTexture and "forgotten_sin" or "forgotten_sin_alt",
    pos = { x = 2, y = 1 },
    omit = not config.DisableOverride and not SKHDecks.mod_list.multiplayer,
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_wrathfulworm'},
	config = {b_side_lock = true, extra = {hands = 3, xchipmult = 2, odds = 6, odds_flip = 2, smash = false}},
	calculate = function(self, back, context)
		if context.setting_blind then
			G.E_MANAGER:add_event(Event({func = function()
				ease_discard(-G.GAME.current_round.discards_left, nil, true)
				ease_hands_played(self.config.extra.hands)
				return true end }))
            if SMODS.pseudorandom_probability(back, 'b_wrathful_flip', 1, self.config.extra.odds_flip, 'b_wrathful_deck2') and #G.jokers.cards > 0 then
                G.jokers:unhighlight_all()
                for k, v in ipairs(G.jokers.cards) do
                    v:flip()
                end
                if #G.jokers.cards > 1 then
                    G.E_MANAGER:add_event(Event({ trigger = 'after', delay = 0.2, func = function() 
                        G.E_MANAGER:add_event(Event({ func = function() G.jokers:shuffle('b_wrathful_shuffle'); play_sound('cardSlide1', 0.85);return true end })) 
                        delay(0.15)
                        G.E_MANAGER:add_event(Event({ func = function() G.jokers:shuffle('b_wrathful_shuffle'); play_sound('cardSlide1', 1.15);return true end })) 
                        delay(0.15)
                        G.E_MANAGER:add_event(Event({ func = function() G.jokers:shuffle('b_wrathful_shuffle'); play_sound('cardSlide1', 1);return true end })) 
                        delay(0.5)
                    return true end }))
                end
            end
		end
		if context.before then
			self.config.extra.smash = false
			if SMODS.pseudorandom_probability(back, 'b_wrathful_smash', 1, self.config.extra.odds, 'b_wrathful_deck1') then
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
        if context.context == "eval" then
            for k, v in ipairs(G.jokers.cards) do
                if v.facing == 'back' then v:flip() end
            end
        end
	end,
	loc_vars = function(self)
		return {vars = {SMODS.get_probability_vars(G.GAME.selected_back, 1, self.config.extra.odds_flip, "b_wrathful_deck2")}}
	end
})

SKHDecks.add_skh_b_side("b_skh_wrathfulworm", "b_skh_forgotten_wrathful")

SMODS.Back({
	key = "forgotten_envious",
	atlas = not config.AltTexture and "forgotten_sin" or "forgotten_sin_alt",
    pos = { x = 3, y = 0 },
    omit = not config.DisableOverride and not SKHDecks.mod_list.multiplayer,
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_enviousworm'},
	config = {b_side_lock = true, extra = {
        odds_common = nil,       odds_uncommon = 20,
        odds_rare = 15,         odds_cry_epic = 12,
        odds_legendary = 10,     odds_cry_exotic = 8,
        odds_cry_candy = 15,    odds_cry_cursed = nil,
        odds_playing_card = 8}},
	calculate = function(self, back, context)
		if context.end_of_round and not context.repetition and not context.individual then
			local killed = false
			local has_common = false
			for i = 1, #G.jokers.cards do
				local temp = G.jokers.cards[i]
				if temp.config.center.rarity == 1 then
					has_common = true
                elseif temp.config.center.rarity == 2 then
					killed = envious_roulette(temp, "b_envious_uncommon", self.config.extra.odds_uncommon, i, back) or killed
				elseif temp.config.center.rarity == 3 then
					killed = envious_roulette(temp, "b_envious_rare", self.config.extra.odds_rare, i, back) or killed
				elseif temp.config.center.rarity == 4 then
					killed = envious_roulette(temp, "b_envious_legendary", self.config.extra.odds_legendary, i, back) or killed
				end
				if Cryptid then
					if temp.config.center.rarity == 'cry_epic' then
						killed = envious_roulette(temp, "b_envious_cry_epic", self.config.extra.odds_cry_epic, i, back) or killed
					elseif temp.config.center.rarity == 'cry_exotic' then
						killed = envious_roulette(temp, "b_envious_cry_exotic", self.config.extra.odds_cry_exotic, i, back) or killed
					elseif temp.config.center.rarity == 'cry_candy' then
						killed = envious_roulette(temp, "b_envious_cry_candy", self.config.extra.odds_cry_candy, i, back) or killed
					end
				end
			end
			if killed and has_common then
				play_sound("skh_envious_laugh", 1, 1)
			end
		end
        if context.context == "eval" then
            for c = 1, #G.playing_cards do
				local temp = G.playing_cards[c]
				if not temp.debuff then
					if temp.edition then
						envious_roulette(temp, "b_envious_edition", self.config.extra.odds_playing_card, c, back)
					end
					if temp.seal then
						envious_roulette(temp, "b_envious_seal", self.config.extra.odds_playing_card, c, back)
					end
					if temp.ability.set == "Enhanced" then
						envious_roulette(temp, "b_envious_enhancement", self.config.extra.odds_playing_card, c, back)
					end
				end
			end
        end
	end,
})

SKHDecks.add_skh_b_side("b_skh_enviousworm", "b_skh_forgotten_envious")

SMODS.Back({
	key = "forgotten_prideful",
	atlas = not config.AltTexture and "forgotten_sin" or "forgotten_sin_alt",
    pos = { x = 1, y = 1 },
    omit = not config.DisableOverride and not SKHDecks.mod_list.multiplayer,
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_pridefulworm'},
    config = {joker_slot = -4, b_side_lock = true},
	calculate = function(self, back, context)
		if context.setting_blind then
			local has_rare_or_above = false
            for i = 1, #G.jokers.cards do
				local temp = G.jokers.cards[i]
				if temp.config.center.rarity ~= 1 and temp.config.center.rarity ~= 2 then
                    has_rare_or_above = true
                else
					G.E_MANAGER:add_event(Event({
						func = function()
							temp:set_edition({ negative = true }, true)
                            temp:set_rental(true)
							return true
						end
					}))
				end
			end
            if has_rare_or_above then
                for i = 1, #G.jokers.cards do
                    local temp = G.jokers.cards[i]
                    if temp.config.center.rarity == 1 or temp.config.center.rarity == 2 then
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                temp:set_rental(false)
                                return true
                            end
                        }))
                    end
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
		G.GAME.banned_keys[#G.GAME.banned_keys+1] = {v_antimatter = true}
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

SKHDecks.add_skh_b_side("b_skh_pridefulworm", "b_skh_forgotten_prideful")