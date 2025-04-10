SMODS.Atlas({
    key = "forgotten_virtue",
    path = "ForgottenVirtue.png",
    px = 71,
    py = 95,
})

SMODS.Atlas({
    key = "forgotten_virtue_alt",
    path = "ForgottenVirtueAlt.png",
    px = 71,
    py = 95,
})

SMODS.Back({
    key = "forgotten_virgin",
    atlas = not config.AltTexture and "forgotten_virtue" or "forgotten_virtue_alt",
    pos = { x = 0, y = 0 },
    omit = not config.DisableOverride or SKHDecks.mod_list.multiplayer,
    unlocked = false,
    unlock_condition = {type = 'win_deck', deck = 'b_skh_virginworm'},
    config = {b_side_lock = true},
    calculate = function(self, back, context)
        if context.before then
            local rule_is_broken = false
            for _, v1 in ipairs(context.scoring_hand) do
                if v1:get_id() == 13 then
                    for _, v2 in ipairs(context.scoring_hand) do
                        if v2:get_id() == 11 then
                            rule_is_broken = true
                            break
                        end
                    end
                    break
                end
            end
            if rule_is_broken then
                game_over()
            end
        end
    end
})

SKHDecks.add_skh_b_side("b_skh_virginworm", "b_skh_forgotten_virgin")

SMODS.Back({
	key = "forgotten_humble",
	atlas = not config.AltTexture and "forgotten_virtue" or "forgotten_virtue_alt",
    pos = { x = 1, y = 0 },
	config = {b_side_lock = true},
    omit = not config.DisableOverride or SKHDecks.mod_list.multiplayer,
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_humbleworm'},
})

SKHDecks.add_skh_b_side("b_skh_humbleworm", "b_skh_forgotten_humble")

SMODS.Back({
    key = "forgotten_diligent",
    atlas = not config.AltTexture and "forgotten_virtue" or "forgotten_virtue_alt",
    pos = { x = 2, y = 0 },
    config = {joker_slot = 1, b_side_lock = true},
    omit = not config.DisableOverride or SKHDecks.mod_list.multiplayer,
    unlocked = false,
    unlock_condition = {type = 'win_deck', deck = 'b_skh_diligentworm'},
    apply = function(self, back)
        delay(0.4)
		G.E_MANAGER:add_event(Event({
			func = function()
				local joker = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_joker", "deck")
				joker:add_to_deck()
				G.jokers:emplace(joker)
				joker:start_materialize()

				return true
			end,
		}))
    end,
    loc_vars = function(self)
        return {vars = {self.config.joker_slot}}
    end
})

SKHDecks.add_skh_b_side("b_skh_diligentworm", "b_skh_forgotten_diligent")

SMODS.Back({
    key = "forgotten_abstemious",
    atlas = not config.AltTexture and "forgotten_virtue" or "forgotten_virtue_alt",
    pos = { x = 3, y = 0 },
    config = {hands = 3, discards = 4, b_side_lock = true, extra = {hand_discard_limit = 7}},
    omit = not config.DisableOverride or SKHDecks.mod_list.multiplayer,
    unlocked = false,
    unlock_condition = {type = 'win_deck', deck = 'b_skh_abstemiousworm'},
    calculate = function(self, back, context)
        if context.pre_discard then
            if G.GAME.hand_discard_used >= self.config.extra.hand_discard_limit then
                game_over()
            end
            G.GAME.hand_discard_used = G.GAME.hand_discard_used + 1
        end
        if context.before then
            if G.GAME.hand_discard_used >= self.config.extra.hand_discard_limit then
                game_over()
            end
            G.GAME.hand_discard_used = G.GAME.hand_discard_used + 1
        end
        if context.end_of_round and not context.repetition then
            G.GAME.hand_discard_used = 0
        end
    end,
    apply = function(self, back)
        if G.GAME.stake >= 5 then G.GAME.starting_params.discards = G.GAME.starting_params.discards + 1 end
    end,
    loc_vars = function(self)
        return {vars = {self.config.extra.hand_discard_limit}}
    end
})

SKHDecks.add_skh_b_side("b_skh_abstemiousworm", "b_skh_forgotten_abstemious")

SMODS.Back({
	key = "forgotten_kind",
	atlas = not config.AltTexture and "forgotten_virtue" or "forgotten_virtue_alt",
    pos = { x = 1, y = 1 },
	config = {b_side_lock = true, extra = {retriggers = 2}},
    omit = not config.DisableOverride or SKHDecks.mod_list.multiplayer,
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_kindworm'},
	calculate = function(self, back, context)
		if context.setting_blind then
            if G.GAME.number_of_jokers == #G.jokers.cards then
                G.GAME.debuff_roll = true
            end
        end
        if context.before then
            G.GAME.number_of_jokers = #G.jokers.cards
            if G.jokers.cards[1] and not G.GAME.selected_debuff_target then game_over() end
        end
        if context.retrigger_joker_check and not context.retrigger_joker and G.GAME.selected_debuff_target then
			if context.other_card == G.GAME.selected_debuff_target then
				return {
					message = localize("k_again_ex"),
					repetitions = self.config.extra.retriggers,
					card = G.GAME.selected_debuff_target,
				}
			else
				return nil, true
			end
		end
        if context.context == "final_scoring_step" and G.GAME.selected_debuff_target then
            G.E_MANAGER:add_event(Event({
                func = function()
                    G.GAME.selected_debuff_target:set_debuff(true)
                    G.GAME.selected_debuff_target:juice_up()
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.06*G.SETTINGS.GAMESPEED, blockable = false, blocking = false, func = function()
                        play_sound('tarot2', 0.76, 0.4);return true end}))
                    play_sound('tarot2', 1, 0.4)
                    G.GAME.debuff_roll = true
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
            G.GAME.selected_debuff_target = nil
        end
	end,
    loc_vars = function(self)
        return {vars = {self.config.extra.retriggers}}
    end
})

SKHDecks.add_skh_b_side("b_skh_kindworm", "b_skh_forgotten_kind")

SMODS.Back({
	key = "forgotten_generous",
	atlas = not config.AltTexture and "forgotten_virtue" or "forgotten_virtue_alt",
    pos = { x = 0, y = 1 },
	config = {dollars = -84, b_side_lock = true},
    omit = not config.DisableOverride or SKHDecks.mod_list.multiplayer,
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_generousworm'},
	apply = function(self, back)
		G.GAME.bankrupt_at = -100
        G.GAME.banned_keys[#G.GAME.banned_keys+1] = {j_credit_card = true}
	end,
	loc_vars = function(self)
		return {vars = {-self.config.dollars-4}}
	end
})

SKHDecks.add_skh_b_side("b_skh_generousworm", "b_skh_forgotten_generous")

SMODS.Back({
    key = "forgotten_patient",
    atlas = not config.AltTexture and "forgotten_virtue" or "forgotten_virtue_alt",
    pos = { x = 2, y = 1 },
    config = {b_side_lock = true, ante_scaling = 4},
    omit = not config.DisableOverride or SKHDecks.mod_list.multiplayer,
    unlocked = false,
    unlock_condition = {type = 'win_deck', deck = 'b_skh_patientworm'},
    calculate = function(self, back, context)
        if context.setting_blind then
            local choices = { "Small", "Big", "Boss" }
            for _, c in pairs(choices) do
                if G.GAME.round_resets.blind_states[c] == "Current" then
                    G.GAME.chicot_count = find_joker("Chicot")
                    G.GAME.chicot_coeffi = G.P_BLINDS[G.GAME.round_resets.blind_choices[c]].name == "Violet Vessel" and 3
                                        or G.P_BLINDS[G.GAME.round_resets.blind_choices[c]].name == "The Wall" and 2
                                        or 1
                    G.GAME.blind.chips = get_blind_amount(G.GAME.round_resets.blind_ante)
                                        * G.GAME.starting_params.ante_scaling
                                        * G.GAME.patient_scaling_table[c]
                end
            end
        end
        if context.context == "eval" then
            G.GAME.chicot_count = {}
            G.GAME.chicot_coeffi = 1
        end
    end,
    apply = function(self, back)
        G.GAME.banned_keys[#G.GAME.banned_keys+1] = {v_hieroglyph = true}
        G.GAME.banned_keys[#G.GAME.banned_keys+1] = {v_petroglyph = true}
    end,
    loc_vars = function(self)
        return {vars = {self.config.ante_scaling}}
    end
})

SKHDecks.add_skh_b_side("b_skh_patientworm", "b_skh_forgotten_patient")