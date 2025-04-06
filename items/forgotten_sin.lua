SMODS.Atlas({
    key = "forgotten_sin",
    path = "ForgottenSin.png",
    px = 71,
    py = 95,
})

SMODS.Back({
    key = "forgotten_lusty",
    atlas = "forgotten_sin",
    pos = { x = 0, y = 0 },
    omit = not config.DisableOverride,
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
                            SMODS.change_base(new_card, nil, pseudorandom_element(ranks, pseudoseed('forgotten_lusty_debaunched')))
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
                        G.deck:shuffle('forgotten_lusty_shuffle')
                        return true
                    end
                }))
                return {
					message = localize('k_debaunched_ex'),
					colour = G.C.RED,
				}
            end
        end
    end
})

SKHDecks.add_skh_b_side("b_skh_lustyworm", "b_skh_forgotten_lusty")

SMODS.Back({
    key = "forgotten_greedy",
    atlas = "forgotten_sin",
    pos = { x = 1, y = 0 },
    omit = not config.DisableOverride,
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
    atlas = "forgotten_sin",
    pos = { x = 2, y = 0 },
    omit = not config.DisableOverride,
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
	atlas = "forgotten_sin",
    pos = { x = 0, y = 1 },
    omit = not config.DisableOverride,
	unlocked = false,
	unlock_condition = {type = 'win_deck', deck = 'b_skh_slothfulworm'},
	config = {joker_slot = -3, consumable_slot = -1, hands = -1, discards = -2,
				extra = {odds = 30, ante_loss = 1}, b_side_lock = true},
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
		local random_ante = pseudorandom('forgotten_slothful_random_ante', -3, 2)
        G.GAME.win_ante = G.GAME.win_ante + random_ante
	end
})

SKHDecks.add_skh_b_side("b_skh_slothfulworm", "b_skh_forgotten_slothful")

SMODS.Back({
	key = "forgotten_prideful",
	atlas = "forgotten_sin",
    pos = { x = 1, y = 1 },
    omit = not config.DisableOverride,
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