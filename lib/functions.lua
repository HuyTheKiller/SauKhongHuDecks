local igo = Game.init_game_object
function Game:init_game_object()
	local ret = igo(self)
	ret.chaos_roll = "b_skh_lustyworm"
	ret.omnipotent_roll = "b_skh_patientworm"
	return ret
end

to_big = to_big or function(x)
	return x
end

function skh_get_rank_suffix(card) -- copy-pasted from Ortalab, renamed with mod id prefix for uniqueness
    local rank_suffix = (card.base.id - 2) % 13 + 2
    if rank_suffix < 11 then rank_suffix = tostring(rank_suffix)
    elseif rank_suffix == 11 then rank_suffix = 'Jack'
    elseif rank_suffix == 12 then rank_suffix = 'Queen'
    elseif rank_suffix == 13 then rank_suffix = 'King'
    elseif rank_suffix == 14 then rank_suffix = 'Ace'
    end
    return rank_suffix
end

function envious_roulette(card, odd_seed, odd_type, iteration) -- Gros Michel logic - copy-pasted and modified
	if pseudorandom(odd_seed) < G.GAME.probabilities.normal/odd_type then
		G.E_MANAGER:add_event(Event({
			func = function()
				-- play_sound('tarot1')
				card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_killed_ex')})
				card.T.r = -0.2
				card:juice_up(0.3, 0.4)
				card.states.drag.is = true
				card.children.center.pinch.x = true
				G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
					func = function()
							G.jokers:remove_card(card)
							card:remove()
							card = nil
						return true; end}))
				return true
			end
		}))
		iteration = iteration - 1
	end
end