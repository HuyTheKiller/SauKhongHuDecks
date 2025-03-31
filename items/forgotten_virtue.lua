SMODS.Atlas({
    key = "forgotten_virtue",
    path = "ForgottenVirtue.png",
    px = 71,
    py = 95,
})

SMODS.Back({
    key = "forgotten_virgin",
    atlas = "forgotten_virtue",
    pos = { x = 0, y = 0 },
    omit = not config.DisableOverride,
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
    key = "forgotten_abstemious",
    atlas = "forgotten_virtue",
    pos = { x = 3, y = 0 },
    config = {hands = 3, discards = 4, b_side_lock = true, extra = {hand_discard_limit = 7}},
    omit = not config.DisableOverride,
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