config = SKHDecks.config

-- Inject global variable for various decks
local igo = Game.init_game_object
function Game:init_game_object()
	local ret = igo(self)
	ret.chaos_roll = "b_skh_lustyworm" -- Womry Chaos
	ret.omnipotent_roll = "b_skh_patientworm" -- Omnipotent Worm
	ret.hand_discard_used = 0 -- Forgotten Abstemious
	ret.cards_destroyed = 0 -- Forgotten Gluttony
	ret.selected_debuff_target = nil -- Forgotten Kind
	ret.debuff_roll = false -- Forgotten Kind
	ret.number_of_jokers = 0 -- Forgotten Kind
	ret.chicot_count = {} -- Forgotten Patient
	ret.chicot_coeffi = 1 -- Forgotten Patient
	ret.random_choice = 1 -- Hallucinating Worm
	ret.click_count = 0 -- Forgotten Hallucinating
	ret.click_threshold = 25 -- Forgotten Hallucinating
	ret.current_round.rule_broken_amount = 0 -- Number of times a deck rule is broken in Multiplayer in one specific round
	return ret
end

-- Talisman compat
to_big = to_big or function(x)
	return x
end
to_number = to_number or function(x)
	return x
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
	check_for_unlock({type = "forgotten_virtue_game_over"})
	G.RESET_BLIND_STATES = true
	G.RESET_JIGGLES = true
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

-- Forgotten Diligent's debuff-first-joker mechanic
local cardarea_update_ref = CardArea.update
function CardArea:update(dt)
	cardarea_update_ref(self, dt)
	if G.GAME.selected_back then
		if G.GAME.selected_back.effect.center.key == "b_skh_forgotten_diligent" then
			if self == G.jokers and G.jokers.cards[1] then
				for i = 1, #G.jokers.cards do
					if i == 1 and not G.jokers.cards[i].debuff then
						G.jokers.cards[i]:set_debuff(true)
					end
					if i > 1 and G.jokers.cards[i].debuff then
						G.jokers.cards[i]:set_debuff(false)
					end
				end
			end
		elseif G.GAME.selected_back.effect.center.key == "b_skh_forgotten_kind" then
			if G.GAME.number_of_jokers ~= #G.jokers.cards and G.GAME.facing_blind then
				G.GAME.debuff_roll = true
				G.GAME.number_of_jokers = #G.jokers.cards
			end
			if self == G.jokers and G.jokers.cards[1] and G.GAME.debuff_roll then
				G.GAME.number_of_jokers = #G.jokers.cards
				local debuff_targets = {}
				for i = 1, #G.jokers.cards do
					local temp = G.jokers.cards[i]
					if not temp.debuff then
						debuff_targets[#debuff_targets+1] = temp
					end
				end
				G.GAME.selected_debuff_target = #debuff_targets > 0 and pseudorandom_element(debuff_targets, pseudoseed("b_kind_debuff")) or nil
				G.GAME.debuff_roll = false
			end
		end
	end
end

-- Add on-click context (copy-pasted from Cryptid)
local lcpref = Controller.L_cursor_press
function Controller:L_cursor_press(x, y)
	lcpref(self, x, y)
	if G and G.jokers and G.jokers.cards and not G.SETTINGS.paused then
		SMODS.calculate_context({ skh_press = true })
	end
end

-- Hopefully fix triggering game_over() in Forgotten Patient resulting in a crash on leaving game over screen
local set_joker_loss_ref = set_joker_loss
function set_joker_loss()
	if G and G.jokers and G.jokers.cards and G.jokers.cards[1] then
		set_joker_loss_ref()
	end
end

upd = Game.update
function Game:update(dt)
	upd(self, dt)
	-- Many stuff here are copy-pasted from Cryptid ;P
	-- Decrease blind size for Forgotten Patient
	local choices = { "Small", "Big", "Boss" }
	G.GAME.patient_scaling_table = G.GAME.patient_scaling_table or {}
	for _, c in pairs(choices) do
		if
			G.GAME
			and G.GAME.round_resets
			and G.GAME.round_resets.blind_choices
			and G.GAME.round_resets.blind_choices[c]
			and G.GAME.selected_back
			and G.GAME.selected_back.effect.center.key == "b_skh_forgotten_patient"
			and G.STATE ~= G.STATES.GAME_OVER
		then
			if
				G.GAME.round_resets.blind_states[c] ~= "Current"
				and G.GAME.round_resets.blind_states[c] ~= "Defeated"
			then
				G.GAME.patient_scaling_table[c] = (G.GAME.patient_scaling_table[c] or G.P_BLINDS[G.GAME.round_resets.blind_choices[c]].mult)
				* (config.NerfBSidePatient and 1.0139594 or 1.0233738)^(-dt*(SKHDecks.debug and 10 or 1)) -- ~(50 or 30)*log(2, 2*G.GAME.starting_params.ante_scaling) seconds per Ante
				if G.blind_select_opts then
					local blind_UI = G.blind_select_opts[string.lower(c)].definition.nodes[1].nodes[1].nodes[1].nodes[1]
					local chip_text_node = blind_UI.nodes[1].nodes[3].nodes[1].nodes[2].nodes[2].nodes[3]
					if chip_text_node then
						chip_text_node.config.text = number_format(
							get_blind_amount(G.GAME.round_resets.blind_ante)
							* G.GAME.starting_params.ante_scaling
							* G.GAME.patient_scaling_table[c]
						)
						chip_text_node.config.scale = score_number_scale(
							0.9,
							get_blind_amount(G.GAME.round_resets.blind_ante)
							* G.GAME.starting_params.ante_scaling
							* G.GAME.patient_scaling_table[c]
						)
					end
					G.blind_select_opts[string.lower(c)]:recalculate()
				end
			elseif
				G.GAME.round_resets.blind_states[c] ~= "Defeated"
				and to_big(G.GAME.chips) < to_big(G.GAME.blind.chips)
			then
				G.GAME.blind.chips = G.GAME.blind.chips
					* (config.NerfBSidePatient and 1.0139594 or 1.0233738)^(-dt*(SKHDecks.debug and 10 or 1)) -- ~(50 or 30)*log(2, 2*G.GAME.starting_params.ante_scaling) seconds per Ante
				G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
				if
					G.GAME.blind.chips < get_blind_amount(G.GAME.round_resets.blind_ante)*G.P_BLINDS[G.GAME.round_resets.blind_choices[c]].mult/(2*G.GAME.chicot_coeffi^#G.GAME.chicot_count)
				then
					game_over()
				end
			end
			if
				G.GAME.round_resets.blind_states[c] == "Current"
				and to_big(G.GAME.chips) >= to_big(G.GAME.blind.chips)
				and G.STATE == G.STATES.SELECTING_HAND
			then
				-- G.GAME.chips = G.GAME.blind.chips
				G.STATE = G.STATES.HAND_PLAYED
				G.STATE_COMPLETE = true
				end_round()
			end
		end
	end
	if -- Money-exceeds-0 triggers game over in Forgotten Generous
		G.GAME
		and G.GAME.selected_back
		and G.GAME.selected_back.effect.center.key == "b_skh_forgotten_generous"
		and G.STATE ~= G.STATES.GAME_OVER
	then
		if G.GAME.dollars > to_big(0) then game_over() end
	end
	if -- Money-exceeds-0 triggers live loss (Multiplayer) or game over (Singleplayer) in reworked Forgotten Generous
		G.GAME
		and G.GAME.selected_back
		and G.GAME.selected_back.effect.center.key == "b_skh_forgotten_generous_mp"
		and G.STATE ~= G.STATES.GAME_OVER
	then
		if G.GAME.dollars > to_big(0) then
			if MP.LOBBY.code then
				if not MP.is_pvp_boss() then
				G.GAME.current_round.rule_broken_amount = 1
				end
			else game_over() end
		elseif G.GAME.dollars <= to_big(0) or MP.is_pvp_boss() then
			G.GAME.current_round.rule_broken_amount = 0
		end
	end
end

-- Forgotten Humble: Mult/chips cannot exceed x/y
mod_mult_ref = mod_mult
function mod_mult(_mult)
	_mult = mod_mult_ref(_mult)
	if G.GAME.selected_back.effect.center.key == "b_skh_forgotten_humble" then
		_mult = math.min(_mult, 30*math.max(G.GAME.round_resets.ante, 1))
	end
	if G.GAME.selected_back.effect.center.key == "b_skh_hallucinatingworm_collection"
	or G.GAME.selected_back.effect.center.key == "b_skh_forgotten_hallucinating_collection" then
		_mult = math.max(_mult, 1) -- floor the mult at 1
	end
	return _mult
end

mod_chips_ref = mod_chips
function mod_chips(_chips)
	_chips = mod_chips_ref(_chips)
	if G.GAME.selected_back.effect.center.key == "b_skh_forgotten_humble" then
		_chips = math.min(_chips, 75*math.max(G.GAME.round_resets.ante, 1))
	end
	if G.GAME.selected_back.effect.center.key == "b_skh_hallucinatingworm_collection"
	or G.GAME.selected_back.effect.center.key == "b_skh_forgotten_hallucinating_collection" then
		_chips = math.max(_chips, 0) -- floor the chips at 0
	end
	return _chips
end

-- Trigger live loss at end of round equal to number of times a rule has been broken in that round
if SKHDecks.mod_list.multiplayer then
	local update_new_round_ref = Game.update_new_round
	function Game:update_new_round(dt)
		if MP.LOBBY.code and not G.STATE_COMPLETE then
			if G.GAME.current_round.rule_broken_amount > 0 then
				for _ = 1, G.GAME.current_round.rule_broken_amount do
					MP.ACTIONS.fail_round(G.GAME.current_round.hands_played)
				end
				G.GAME.current_round.rule_broken_amount = 0
			end
		end
		update_new_round_ref(self, dt)
	end
end
-- Cool, config tab
SKHDecks.config_tab = function()
    return {n = G.UIT.ROOT, config = {r = 0.1, align = "cm", padding = 0.1, colour = G.C.BLACK, minw = 8, minh = 6}, nodes = {
        {n=G.UIT.R, config = {align = 'cm'}, nodes={
			create_toggle({label = localize('SKH_disable_override'), ref_table = config, ref_value = 'DisableOverride', info = localize('SKH_disable_override_desc'), active_colour = SKHDecks.badge_text_colour, right = true}),
		}},
		{n=G.UIT.R, config = {align = 'cm'}, nodes={
			create_toggle({label = localize('SKH_alt_texture'), ref_table = config, ref_value = 'AltTexture', info = localize('SKH_alt_texture_desc'), active_colour = SKHDecks.badge_text_colour, right = true}),
		}},
		{n=G.UIT.R, config = {align = 'cm'}, nodes={
			create_toggle({label = localize('SKH_nerf_b_side_patient'), ref_table = config, ref_value = 'NerfBSidePatient', info = localize('SKH_nerf_b_side_patient_desc'), active_colour = SKHDecks.badge_text_colour, right = true}),
		}},
		{n=G.UIT.R, config = {align = 'cm'}, nodes={
			create_toggle({label = localize('SKH_insane_hallu'), ref_table = config, ref_value = 'InsaneHallu', info = localize('SKH_insane_hallu_desc'), active_colour = SKHDecks.badge_text_colour, right = true}),
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
		if args.name == "gald_select_deck" and not config.DisableOverride and not SKHDecks.mod_list.multiplayer then
			args.definition = skh_custom_deck_select_page_deck
		end
	end

	local populate_deck_card_areas_ref = populate_deck_card_areas
	function populate_deck_card_areas(page)
		populate_deck_card_areas_ref(page)

		if SKHDecks.b_side_current or config.DisableOverride then
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
else
	-- G.FUNCS.apply_skh_b_sides = function()
	-- 	G.UIDEF.run_setup_option('New Run')
	-- end
end

-- Helper function for G.FUNCS.apply_skh_b_sides
function table_contains(t, x)
    found = false
    for _, v in pairs(t) do
        if v == x then
            found = true
			break
        end
    end
    return found
end

local forgotten_table = {
	"b_skh_forgotten_lusty", "b_skh_forgotten_greedy", "b_skh_forgotten_gluttony", "b_skh_forgotten_slothful", "b_skh_forgotten_wrathful", "b_skh_forgotten_envious", "b_skh_forgotten_prideful",
	"b_skh_forgotten_virgin", "b_skh_forgotten_humble", "b_skh_forgotten_diligent", "b_skh_forgotten_abstemious", "b_skh_forgotten_kind", "b_skh_forgotten_generous", "b_skh_forgotten_patient",
}

G.FUNCS.apply_skh_b_sides = function()
	if Galdur and Galdur.config.use then
		if not config.DisableOverride then
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
								new_card.children.back = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS[center.unlocked and center.atlas or center.config.b_side_lock and "skh_forgotten_locked" or "centers"], center.unlocked and center.pos or center.config.b_side_lock and {x = 0, y = 0} or {x = 4, y = 0})
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
			for _, deck_area in ipairs(Galdur.run_setup.deck_select_areas) do
				if #deck_area.cards ~= 0 then
					local card = deck_area.cards[1]
					if table_contains(forgotten_table, card.config.center.key) then
						local center = G.P_CENTERS[card.config.center.key]
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
								new_card.children.back = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS[center.unlocked and center.atlas or center.config.b_side_lock and "skh_forgotten_locked" or "centers"], center.unlocked and center.pos or center.config.b_side_lock and {x = 0, y = 0} or {x = 4, y = 0})
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