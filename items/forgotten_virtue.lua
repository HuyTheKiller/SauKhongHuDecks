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
    omit = true,
    unlocked = false,
    unlock_condition = {type = 'win_deck', deck = 'b_skh_virginworm'},
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
                G.STATE = G.STATES.GAME_OVER
                G.STATE_COMPLETE = false
            end
        end
    end
})

SKHDecks.add_skh_b_side("b_skh_virginworm", "b_skh_forgotten_virgin")

SMODS.Back({
    key = "forgotten_abstemious",
    atlas = "forgotten_virtue",
    pos = { x = 3, y = 0 },
    config = {hands = 3, discards = 4, extra = {hand_discard_limit = 7}},
    omit = true,
    unlocked = false,
    unlock_condition = {type = 'win_deck', deck = 'b_skh_abstemiousworm'},
    calculate = function(self, back, context)
        if context.pre_discard and context.cardarea == G.play then
            G.GAME.hand_discard_used = G.GAME.hand_discard_used + 1
            print(G.GAME.hand_discard_used)
            if G.GAME.hand_discard_used >= self.config.extra.hand_discard_limit then
                ease_hands_played(-G.GAME.current_round.hands_left, true)
            end
        end
        if context.before then
            G.GAME.hand_discard_used = G.GAME.hand_discard_used + 1
            print(G.GAME.hand_discard_used)
        end
        if context.after then
            if G.GAME.hand_discard_used >= self.config.extra.hand_discard_limit then
                ease_hands_played(-G.GAME.current_round.hands_left, true)
            end
        end
        if context.end_of_round and not context.repetition then
            G.GAME.hand_discard_used = 0
        end
    end,
    loc_vars = function(self)
        return {vars = {self.config.hands, self.config.discards}}
    end
})

SKHDecks.add_skh_b_side("b_skh_abstemiousworm", "b_skh_forgotten_abstemious")