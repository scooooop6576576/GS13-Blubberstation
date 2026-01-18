/datum/martial_art/krav_maga
	name = "Krav Maga"
	id = MARTIALART_KRAVMAGA
	VAR_PRIVATE/datum/action/neck_chop/neckchop
	VAR_PRIVATE/datum/action/leg_sweep/legsweep
	VAR_PRIVATE/datum/action/lung_punch/lungpunch

/datum/martial_art/krav_maga/New()
	. = ..()
	neckchop = new(src)
	legsweep = new(src)
	lungpunch = new(src)

/datum/martial_art/krav_maga/Destroy()
	neckchop = null
	legsweep = null
	lungpunch = null
	return ..()

/datum/action/neck_chop
	name = "Neck Chop"
	desc = "Injures the neck, stopping the victim from speaking for a while."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "neckchop"
	check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_HANDS_BLOCKED|AB_CHECK_CONSCIOUS

/datum/action/neck_chop/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	var/datum/martial_art/source = target
	if (source.streak == "neck_chop")
		owner.visible_message(span_danger("[owner] assumes a neutral stance."), "<b><i>Your next attack is cleared.</i></b>")
		owner.balloon_alert(owner, "cleared")
		source.streak = ""
	else
		owner.visible_message(span_danger("[owner] assumes the Neck Chop stance!"), "<b><i>Your next attack will be a Neck Chop.</i></b>")
		owner.balloon_alert(owner, "neck chop")
		source.streak = "neck_chop"

/datum/action/leg_sweep
	name = "Leg Sweep"
	desc = "Trips the victim, knocking them down for a brief moment."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "legsweep"
	check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_HANDS_BLOCKED|AB_CHECK_CONSCIOUS

/datum/action/leg_sweep/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	var/datum/martial_art/source = target
	if (source.streak == "leg_sweep")
		owner.visible_message(span_danger("[owner] assumes a neutral stance."), "<b><i>Your next attack is cleared.</i></b>")
		owner.balloon_alert(owner, "cleared")
		source.streak = ""
	else
		owner.visible_message(span_danger("[owner] assumes the Low Sweep stance!"), "<b><i>Your next attack will be a Low Sweep.</i></b>")
		owner.balloon_alert(owner, "low sweep")
		source.streak = "low_sweep"

/datum/action/lung_punch//referred to internally as 'quick choke'
	name = "Lung Punch"
	desc = "Delivers a strong punch just above the victim's abdomen, constraining the lungs. The victim will be unable to breathe for a short time."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "lungpunch"
	check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_HANDS_BLOCKED|AB_CHECK_CONSCIOUS

/datum/action/lung_punch/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	var/datum/martial_art/source = target
	if (source.streak == "quick_choke")
		owner.visible_message(span_danger("[owner] assumes a neutral stance."), "<b><i>Your next attack is cleared.</i></b>")
		owner.balloon_alert(owner, "cleared")
		source.streak = ""
	else
		owner.visible_message(span_danger("[owner] assumes the Lung Punch stance!"), "<b><i>Your next attack will be a Lung Punch.</i></b>")
		owner.balloon_alert(owner, "lung punch")
		source.streak = "quick_choke"//internal name for lung punch

/datum/martial_art/krav_maga/activate_style(mob/living/new_holder)
	. = ..()
	to_chat(new_holder, span_userdanger("You know the arts of [name]!"))
	to_chat(new_holder, span_danger("Place your cursor over a move at the top of the screen to see what it does."))
	neckchop.Grant(new_holder)
	legsweep.Grant(new_holder)
	lungpunch.Grant(new_holder)

/datum/martial_art/krav_maga/deactivate_style(mob/living/remove_from)
	to_chat(remove_from, span_userdanger("You suddenly forget the arts of [name]..."))
	neckchop?.Remove(remove_from)
	legsweep?.Remove(remove_from)
	lungpunch?.Remove(remove_from)
	return ..()

/datum/martial_art/krav_maga/proc/check_streak(mob/living/attacker, mob/living/defender)
	switch(streak)
		if("neck_chop")
			streak = ""
			neck_chop(attacker, defender)
			return TRUE
		if("leg_sweep")
			streak = ""
			leg_sweep(attacker, defender)
			return TRUE
		if("quick_choke")//is actually lung punch
			streak = ""
			quick_choke(attacker, defender)
			return TRUE
	return FALSE

/datum/martial_art/krav_maga/proc/leg_sweep(mob/living/attacker, mob/living/defender)
	if(defender.stat != CONSCIOUS || defender.IsParalyzed())
		return MARTIAL_ATTACK_INVALID
	if(HAS_TRAIT(attacker, TRAIT_PACIFISM))
		return MARTIAL_ATTACK_INVALID // Does 5 damage, so we can't let pacifists leg sweep.
	defender.visible_message(
		span_warning("[attacker] leg sweeps [defender]!"),
		span_userdanger("Your legs are sweeped by [attacker]!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
		null,
		attacker,
	)
	to_chat(attacker, span_danger("You leg sweep [defender]!"))
	playsound(attacker, 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	defender.apply_damage(5, BRUTE, BODY_ZONE_CHEST)
	defender.Knockdown(6 SECONDS)
	log_combat(attacker, defender, "leg sweeped")
	return MARTIAL_ATTACK_SUCCESS

/datum/martial_art/krav_maga/proc/quick_choke(mob/living/attacker, mob/living/defender)//is actually lung punch
	attacker.do_attack_animation(defender)
	defender.visible_message(
		span_warning("[attacker] pounds [defender] on the chest!"),
		span_userdanger("Your chest is slammed by [attacker]! You can't breathe!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
		COMBAT_MESSAGE_RANGE,
		attacker,
	)
	to_chat(attacker, span_danger("You pound [defender] on the chest!"))
	playsound(attacker, 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
	if(defender.losebreath <= 10)
		defender.losebreath = clamp(defender.losebreath + 5, 0, 10)
	defender.adjust_oxy_loss(10)
	log_combat(attacker, defender, "quickchoked")
	return MARTIAL_ATTACK_SUCCESS

/datum/martial_art/krav_maga/proc/neck_chop(mob/living/attacker, mob/living/defender)
	if(HAS_TRAIT(attacker, TRAIT_PACIFISM))
		return MARTIAL_ATTACK_INVALID // Does 10 damage, so we can't let pacifists neck chop.
	attacker.do_attack_animation(defender)
	defender.visible_message(
		span_warning("[attacker] karate chops [defender]'s neck!"),
		span_userdanger("Your neck is karate chopped by [attacker], rendering you unable to speak!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
		COMBAT_MESSAGE_RANGE,
		attacker,
	)
	to_chat(attacker, span_danger("You karate chop [defender]'s neck, rendering [defender.p_them()] unable to speak!"))
	playsound(attacker, 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
	defender.apply_damage(10, attacker.get_attack_type(), BODY_ZONE_HEAD)
	defender.adjust_silence_up_to(20 SECONDS, 20 SECONDS)
	log_combat(attacker, defender, "neck chopped")
	return MARTIAL_ATTACK_SUCCESS

/datum/martial_art/krav_maga/harm_act(mob/living/attacker, mob/living/defender)
	var/picked_hit_type = pick("punch", "kick")
	var/bonus_damage = 0
	if(defender.body_position == LYING_DOWN)
		bonus_damage += 5
		picked_hit_type = "stomp"

	if(defender.check_block(attacker, 10 + bonus_damage, "[attacker]'s [picked_hit_type]", UNARMED_ATTACK))
		return MARTIAL_ATTACK_FAIL
	if(check_streak(attacker, defender))
		return MARTIAL_ATTACK_SUCCESS

	log_combat(attacker, defender, "[picked_hit_type]ed")
	var/obj/item/bodypart/affecting = defender.get_bodypart(defender.get_random_valid_zone(attacker.zone_selected))
	defender.apply_damage(10 + bonus_damage, attacker.get_attack_type(), affecting)
	if(picked_hit_type == "kick" || picked_hit_type == "stomp")
		attacker.do_attack_animation(defender, ATTACK_EFFECT_KICK)
		playsound(defender, 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	else
		attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
		playsound(defender, 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
	defender.visible_message(
		span_danger("[attacker] [picked_hit_type]s [defender]!"),
		span_userdanger("You're [picked_hit_type]ed by [attacker]!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
		COMBAT_MESSAGE_RANGE,
		attacker,
	)
	to_chat(attacker, span_danger("You [picked_hit_type] [defender]!"))
	log_combat(attacker, defender, "[picked_hit_type] with [name]")
	return MARTIAL_ATTACK_SUCCESS

/datum/martial_art/krav_maga/disarm_act(mob/living/attacker, mob/living/defender)
	if(defender.check_block(attacker, 0, attacker.name, UNARMED_ATTACK))
		return MARTIAL_ATTACK_FAIL
	if(check_streak(attacker, defender))
		return MARTIAL_ATTACK_SUCCESS
	var/obj/item/stuff_in_hand = defender.get_active_held_item()
	if(prob(60) && stuff_in_hand && defender.temporarilyRemoveItemFromInventory(stuff_in_hand))
		attacker.put_in_hands(stuff_in_hand)
		defender.visible_message(
			span_danger("[attacker] disarms [defender]!"),
			span_userdanger("You're disarmed by [attacker]!"),
			span_hear("You hear aggressive shuffling!"),
			COMBAT_MESSAGE_RANGE,
			attacker,
		)
		to_chat(attacker, span_danger("You disarm [defender]!"))
		playsound(defender, 'sound/items/weapons/thudswoosh.ogg', 50, TRUE, -1)
		log_combat(attacker, defender, "disarmed (Krav Maga)", addition = "(disarmed of [stuff_in_hand])")
	return MARTIAL_ATTACK_INVALID // normal shove

//Krav Maga Gloves

/obj/item/clothing/gloves/krav_maga
	abstract_type = /obj/item/clothing/gloves/krav_maga
	clothing_traits = list(TRAIT_FAST_CUFFING)

/obj/item/clothing/gloves/krav_maga/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/martial_art_giver, /datum/martial_art/krav_maga)

/datum/atom_skin/kaza_ruk
	abstract_type = /datum/atom_skin/kaza_ruk
	reset_missing = FALSE
	/// Color (/matrix) applied with the skin. If null, no color is applied.
	var/reskin_color

/datum/atom_skin/kaza_ruk/apply(atom/apply_to)
	. = ..()
	if(reskin_color)
		apply_to.add_atom_colour(color_matrix_filter(reskin_color), FIXED_COLOUR_PRIORITY)

/datum/atom_skin/kaza_ruk/clear_skin(atom/clear_from)
	. = ..()
	if(reskin_color)
		clear_from.remove_atom_colour(FIXED_COLOUR_PRIORITY, reskin_color)

/datum/atom_skin/kaza_ruk/get_preview_icon(atom/for_atom)
	var/image/generated = ..()
	if(reskin_color)
		generated.add_filter("preview_filter", 1, color_matrix_filter(reskin_color))
	return generated

/datum/atom_skin/kaza_ruk/red
	preview_name = "Red"

/datum/atom_skin/kaza_ruk/blue
	preview_name = "Blue"
	reskin_color = list(0.33, 0.33, 0.33, 0, 0, 0, 0, 0, 1)

/obj/item/clothing/gloves/kaza_ruk/sec//more obviously named, given to sec
	name = "kaza ruk gloves"
	desc = "These gloves seem to guide you through a non-lizardperson friendly variant of the Tiziran martial art, Kaza Ruk. \
		You're not entirely sure how they do that. Probably nanites."
	icon_state = "fightgloves"
	greyscale_colors = "#c41e0d"
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE

/obj/item/clothing/gloves/kaza_ruk/sec/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/kaza_ruk, infinite = TRUE)

/obj/item/clothing/gloves/kaza_ruk/combatglovesplus
	name = "combat gloves plus"
	desc = "These tactical gloves are fireproof and electrically insulated, and through the use of nanochip technology will teach you the martial art of krav maga."
	icon_state = "black"
	greyscale_colors = "#2f2e31"
	siemens_coefficient = 0
	strip_delay = 8 SECONDS
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor_type = /datum/armor/krav_maga_combatglovesplus

/datum/armor/krav_maga_combatglovesplus
	bio = 90
	fire = 80
	acid = 50
