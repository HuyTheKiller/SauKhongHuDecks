SMODS.Back({
	key = "forgotten_hallucinating_collection",
	atlas = "forgotten_entity",
	pos = { x = 3, y = 1 },
    omit = not config.DisableOverride,
	unlocked = false,
    unlock_condition = {type = 'win_deck', deck = 'b_skh_hallucinatingworm_collection'},
	config = {b_side_lock = true, extra = {in_game = false}},
	calculate = function(self, back, context)
		if G.GAME.facing_blind or not self.config.extra.in_game then self.config.extra.in_game = true end
		if G.GAME.random_choice == 1 then
			if context.setting_blind then
				G.jokers:unhighlight_all()
                if #G.jokers.cards > 1 then
                    G.E_MANAGER:add_event(Event({ trigger = 'after', delay = 0.2, func = function() 
                        G.E_MANAGER:add_event(Event({ func = function() G.jokers:shuffle('b_hallucinating_shuffle'); play_sound('cardSlide1', 0.85);return true end })) 
                        delay(0.15)
                        G.E_MANAGER:add_event(Event({ func = function() G.jokers:shuffle('b_hallucinating_shuffle'); play_sound('cardSlide1', 1.15);return true end })) 
                        delay(0.15)
                        G.E_MANAGER:add_event(Event({ func = function() G.jokers:shuffle('b_hallucinating_shuffle'); play_sound('cardSlide1', 1);return true end })) 
                        delay(0.5)
                    return true end }))
                end
            end
            if context.skh_press and G.GAME.facing_blind then
                for k, v in ipairs(G.jokers.cards) do
                    if v.facing ~= 'back' then v:flip() end
                end
                G.GAME.click_count = G.GAME.click_count + 1
                if G.GAME.click_count > G.GAME.click_threshold then
                    G.GAME.click_count = 0
                    G.GAME.click_threshold = pseudorandom("b_hallucinating_new_click_threshold", 25, 40)
                    if pseudorandom("b_hallucinating_joker_choice")<0.8 then
                        if #G.jokers.cards > 1 then
                            G.E_MANAGER:add_event(Event({ trigger = 'after', delay = 0.2, func = function() 
                                G.E_MANAGER:add_event(Event({ func = function() G.jokers:shuffle('b_hallucinating_shuffle'); play_sound('cardSlide1', 0.85);return true end })) 
                                delay(0.15)
                                G.E_MANAGER:add_event(Event({ func = function() G.jokers:shuffle('b_hallucinating_shuffle'); play_sound('cardSlide1', 1.15);return true end })) 
                                delay(0.15)
                                G.E_MANAGER:add_event(Event({ func = function() G.jokers:shuffle('b_hallucinating_shuffle'); play_sound('cardSlide1', 1);return true end })) 
                                delay(0.5)
                            return true end }))
                        end
                    else
                        if G.jokers.cards[1] then
                            local target = pseudorandom(pseudoseed("b_hallucinating_joker"), 1, #G.jokers.cards)
                            if G.jokers.cards[target] then
                                _card = create_card("Joker", G.jokers, nil, nil, nil, nil, nil, "b_hallucinating_joker_gen")
                                _card.children.back.sprite_pos = G.jokers.cards[target].children.back.sprite_pos
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
                end
            end
            if context.context == "eval" then
                G.GAME.click_count = 0
                for k, v in ipairs(G.jokers.cards) do
                    if v.facing == 'back' then v:flip() end
                end
            end
		elseif G.GAME.random_choice == 2 then
            if context.skh_press and G.GAME.facing_blind then
                G.GAME.click_count = G.GAME.click_count + 1
                if G.GAME.click_count <= G.GAME.click_threshold then
                    if G.GAME.click_count % 7 == 0 then
                        if #G.hand.highlighted > 0 then
                            for i = 1, #G.hand.highlighted do
                                local suits = {}
                                local temp = G.hand.highlighted[i]
                                for _, v in pairs(SMODS.Suits) do
                                    suits[#suits+1] = tostring(v.key)
                                end
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        temp.base.id = SMODS.has_no_rank(temp) and temp.base.id or pseudorandom("b_hallucinating_rank", 2, 14)
                                        local rank_suffix = skh_get_rank_suffix(temp)
                                        assert(SMODS.change_base(temp, pseudorandom_element(suits, pseudoseed("b_hallucinating_suit")), rank_suffix))

                                        return true
                                    end
                                }))
                            end
                        end
                    end
                elseif G.GAME.click_count > G.GAME.click_threshold then
                    G.GAME.click_count = 0
                    G.GAME.click_threshold = pseudorandom("b_hallucinating_new_click_threshold", 25, 40)
                    for i = 1, #G.hand.cards do
                        local suits = {}
                        local temp = G.hand.cards[i]
                        for _, v in pairs(SMODS.Suits) do
                            suits[#suits+1] = tostring(v.key)
                        end
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                temp.base.id = SMODS.has_no_rank(temp) and temp.base.id or pseudorandom("b_hallucinating_rank_hand", 2, 14)
                                local rank_suffix = skh_get_rank_suffix(temp)
                                assert(SMODS.change_base(temp, pseudorandom_element(suits, pseudoseed("b_hallucinating_suit_hand")), rank_suffix))

                                return true
                            end
                        }))
                    end
                end
            end
            if context.context == "eval" then
                G.GAME.click_count = 0
            end
			if context.individual and context.cardarea == G.play then
				if not context.other_card.debuff then
					return {
						chips = pseudorandom("b_hallucinating_chip", -25, 40),
						mult = pseudorandom("b_hallucinating_mult", -10, 15),
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
				key = "b_skh_forgotten_hallucinating" .. tostring(G.GAME.random_choice)
			}
		else
			return {key = "b_skh_forgotten_hallucinating_collection"}
		end
	end,
	collection_loc_vars = function(self)
		return {key = "b_skh_forgotten_hallucinating_collection"}
	end,
	locked_loc_vars = function(self)
		return {key = "b_skh_forgotten_hallucinating_collection"}
	end,
})

SKHDecks.add_skh_b_side("b_skh_hallucinatingworm_collection", "b_skh_forgotten_hallucinating_collection")