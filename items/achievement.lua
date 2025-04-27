SMODS.Achievement({
    key = "i_dont_need_those",
    -- reset_on_startup = true,
    hidden_name = false,
    hidden_text = true,
    unlock_condition = function(self, args)
        if args.type == "modify_jokers" then
            if G.GAME and G.GAME.selected_back.effect.center.key == "b_skh_saukhonghu" then
                local has_earned = true

                if G.jokers then
                    for i = 1, #G.jokers.cards do
                        if G.jokers.cards[i].config.center.key == "j_mime" or G.jokers.cards[i].config.center.key == "j_baron" then
                            has_earned = false
                            break
                        end
                    end
                end

                if has_earned then return true end
            end
        end
    end
})

SMODS.Achievement({
    key = "the_harem",
    -- reset_on_startup = true,
    hidden_name = false,
    hidden_text = true,
    unlock_condition = function(self, args)
        if args.type == "harem_of_a_kind" then
            return true
        end
    end
})

SMODS.Achievement({
    key = "absolute_saunema",
    -- reset_on_startup = true,
    hidden_name = false,
    hidden_text = true,
    unlock_condition = function(self, args)
        if args.type == "win" then
            if G.GAME and G.GAME.selected_back.effect.center.key == "b_skh_absolute_cinema" then
                return true
            end
        end
    end
})

SMODS.Achievement({
    key = "you_broke_the_rules",
    -- reset_on_startup = true,
    hidden_name = false,
    hidden_text = true,
    unlock_condition = function(self, args)
        if args.type == "forgotten_virtue_game_over" then
            return true
        end
    end
})

SMODS.Achievement({
    key = "smart_kid",
    -- reset_on_startup = true,
    hidden_name = false,
    hidden_text = true,
    unlock_condition = function(self, args)
        if args.type == "round_win" then
            if G.GAME and G.GAME.selected_back.effect.center.key == "b_skh_diligentworm"
            and G.GAME.non_final_hand_streak and G.GAME.non_final_hand_streak >= 2 then
                return true
            end
        end
    end
})