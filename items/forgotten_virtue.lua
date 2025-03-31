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