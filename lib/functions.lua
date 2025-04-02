-- Inject global variable for Wormy Chaos and Omnipotent Worm
local igo = Game.init_game_object
function Game:init_game_object()
	local ret = igo(self)
	ret.chaos_roll = "b_skh_lustyworm"
	ret.omnipotent_roll = "b_skh_patientworm"
	ret.hand_discard_used = 0
	return ret
end

-- Talisman compat
to_big = to_big or function(x)
	return x
end

-- copy-pasted from Ortalab, renamed with mod id prefix for uniqueness
function skh_get_rank_suffix(card)
    local rank_suffix = (card.base.id - 2) % 13 + 2
    if rank_suffix < 11 then rank_suffix = tostring(rank_suffix)
    elseif rank_suffix == 11 then rank_suffix = 'Jack'
    elseif rank_suffix == 12 then rank_suffix = 'Queen'
    elseif rank_suffix == 13 then rank_suffix = 'King'
    elseif rank_suffix == 14 then rank_suffix = 'Ace'
    end
    return rank_suffix
end

-- also copy-pasted from Ortalab, with some tweaks to not guarantee enhancement
function playing_card_randomise(card)
    local modifier = 8
    local edition = poll_edition('random_edition', modifier, true, false)
    local enhance = SMODS.poll_enhancement({key = 'random_enhance'})
    local seal = SMODS.poll_seal({key = 'random_seal'})
    card:set_edition(edition, true, true)
    card:set_ability(G.P_CENTERS[enhance or "c_base"])
    card:set_seal(seal, true, true)
end

-- Gros Michel logic - copy-pasted and modified
function envious_roulette(card, odd_seed, odd_type, iteration)
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
		return true
	else return false end
end

-- A separate game_over() function to use instead of calling end_round() to trigger game over
function game_over()
	G.STATE = G.STATES.GAME_OVER
	if not G.GAME.won and not G.GAME.seeded and not G.GAME.challenge then 
		G.PROFILES[G.SETTINGS.profile].high_scores.current_streak.amt = 0
	end
	G:save_settings()
	G.FILE_HANDLER.force = true
	G.STATE_COMPLETE = false
end

-- Forgotten Slothful shenanigan
local rb = reset_blinds
function reset_blinds()
    rb()
    if G.GAME.round_resets.ante == G.GAME.win_ante and G.GAME.selected_back.effect.center.key == "b_skh_forgotten_slothful" then
        G.GAME.round_resets.blind_states.Small = 'Hide'
        G.GAME.round_resets.blind_states.Big = 'Hide'
        G.GAME.round_resets.blind_states.Boss = 'Upcoming'
        G.GAME.blind_on_deck = 'Boss'
        G.GAME.round_resets.blind_choices.Boss = get_new_boss()
        G.GAME.round_resets.boss_rerolled = false
    end
end

-- Cool, config tab
config = SKHDecks.config

SKHDecks.config_tab = function()
    return {n = G.UIT.ROOT, config = {r = 0.1, align = "cm", padding = 0.1, colour = G.C.BLACK, minw = 8, minh = 4}, nodes = {
        {n=G.UIT.R, config = {align = 'cm'}, nodes={
			create_toggle({label = localize('SKH_disable_override'), ref_table = config, ref_value = 'DisableOverride', info = localize('SKH_disable_override_desc'), active_colour = SKHDecks.badge_text_colour, right = true}),
		}},
    }}
end

-- Tattered Decks style for SKH Forgotten Decks
SKHDecks.add_skh_b_side = function(deck_id, b_side_id)
	SKHDecks.b_side_table[deck_id] = b_side_id
	SKHDecks.b_side_table[b_side_id] = deck_id
end

if Galdur then
	function skh_custom_deck_select_page_deck()
		local page = deck_select_page_deck()
		local button_area = page.nodes[1].nodes[2].nodes[1].nodes[1]

		local switch_button = {n = G.UIT.R, config={align = "cm", padding = 0.05}, nodes = {
			{n=G.UIT.R, config = {maxw = 2.5, minw = 2.5, minh = 0.2, r = 0.1, hover = true, ref_value = 1, button = "flip_skh_b_sides", colour = SKHDecks.badge_colour, align = "cm", emboss = 0.1}, nodes = {
				{n=G.UIT.T, config={text = localize("b_forgotten"), scale = 0.4, colour = G.C.GREY}}
			}}
		}}
		table.insert(button_area.nodes, 1, switch_button)
		if SKHDecks.b_side_current then
			G.E_MANAGER:add_event(Event({
				trigger = "immediate",
				blockable = false,
				func = function()
					G.FUNCS.apply_skh_b_sides()
					return true
				end
			}))
		end
		return page
	end

	for _, args in ipairs(Galdur.pages_to_add) do
		if args.name == "gald_select_deck" and not config.DisableOverride then
			args.definition = skh_custom_deck_select_page_deck
		end
	end

	local original_deck_page = G.FUNCS.change_deck_page
	G.FUNCS.change_deck_page = function(args)
		original_deck_page(args)

		if SKHDecks.b_side_current then
			if SKHDecks.b_side_current then
				G.E_MANAGER:add_event(Event({
					trigger = "immediate",
					blockable = false,
					func = function()
						G.FUNCS.apply_skh_b_sides()
						return true
					end
				}))
			end
		end
	end
else
	-- G.FUNCS.apply_skh_b_sides = function()
	-- 	G.UIDEF.run_setup_option('New Run')
	-- end
end

G.FUNCS.apply_skh_b_sides = function()
	if Galdur and Galdur.config.use then
		for _, deck_area in ipairs(Galdur.run_setup.deck_select_areas) do
			if #deck_area.cards ~= 0 then
				local card = deck_area.cards[1]
				if SKHDecks.b_side_table[card.config.center.key] ~= nil then
					local center = G.P_CENTERS[SKHDecks.b_side_table[card.config.center.key]]
					local cards_to_remove = {}
					for _, card in ipairs(deck_area.cards) do
						table.insert(cards_to_remove, card)
					end
					G.E_MANAGER:add_event(Event({trigger = "immediate", blockable = false, func = function() 
						for _, cards in ipairs(cards_to_remove) do
							cards:remove()
						end
						return true
					end }))
					for i = 1, Galdur.config.reduce and 1 or 10 do
						G.E_MANAGER:add_event(Event({trigger = "after", blockable = false, func = function()
							local new_card = Card(deck_area.T.x, deck_area.T.y, G.CARD_W, G.CARD_H, center, center, {galdur_back = Back(center), deck_select = 1})
							new_card.deck_select_position = true
							new_card.sprite_facing = "back"
							new_card.facing = "back"
							new_card.children.back = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS[center.atlas or "centers"], center.pos)
							new_card.children.back.states.hover = card.states.hover
							new_card.children.back.states.click = card.states.click
							new_card.children.back.states.drag = card.states.drag
							new_card.children.back.states.collide.can = false
							new_card.children.back:set_role({major = new_card, role_type = "Glued", draw_major = new_card})
							deck_area:emplace(new_card)
							if Galdur.config.reduce or i == 10 then
								new_card.sticker = get_deck_win_sticker(center)
							end
							return true
						end}))
					end
				end
			end
		end
	else
		-- G.FUNCS.exit_overlay_menu()
		-- G.FUNCS.setup_run({config = {id = 'flip_skh_b_sides'}})
	end
end

G.FUNCS.flip_skh_b_sides = function(e)
	stop_use()
	play_sound("gong", 0.5,1.0)
	play_sound("whoosh",0.5,1.0)
	play_sound("crumple1",0.5,1.0)

	G.E_MANAGER:add_event(Event({
		trigger = 'immediate',
		func = function()
			SKHDecks.b_side_current = not SKHDecks.b_side_current
			if G.OVERLAY_MENU then
				G.OVERLAY_MENU:set_role({xy_bond = 'Weak'})
			end
			return true
		end
	}))

	G.E_MANAGER:add_event(Event({
		trigger = "immediate",
		func = function()
			G.FUNCS.apply_skh_b_sides()
			return true
		end
	}))
end