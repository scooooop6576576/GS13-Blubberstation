//BLUEBERRY CHEM - USED TO ONLY CHANGES PLAYER'S COLOR AND NOTHING MORE. BUT NOW IT MAKES YOU BIG

/// Volume used for all blueberry noises
#define BLUEBERRY_INFLATION_VOLUME 45

#define BURST_IMMEDIATELY "Burst immediately"
#define DELAY_BURST "Delay bursting"
#define DELAY_BURST_MODIFIER 0.1

#define BLUEBERRY_SPILL_BELLY "<span class='warning'>You feel a wetness spread on your belly as juice leaks out of your belly button!</span>"
#define BLUEBERRY_SPILL_PENIS "<span class='warning'>You feel your cock tingle as it leaks out juice!</span>"
#define BLUEBERRY_SPILL_VAGINA "<span class='warning'>You feel your pussy tingle as it leaks out juice!</span>"
#define BLUEBERRY_SPILL_BREASTS "<span class='warning'>You feel your breasts tighten, as juice leaks out of your nipples!</span>"
#define BLUEBERRY_SPILL_GENERIC "<span class='warning'>You feel your body tighten as you start leaking juice!</span>"

#define BLUEBERRY_SPLASH_BELLY "<span class='warning'>You feel pressure and wetness spread on your belly as juice splutters out of your belly button!</span>"
#define BLUEBERRY_SPLASH_PENIS "<span class='warning'>You feel your cock twitch as waves of juice surge out!</span>"
#define BLUEBERRY_SPLASH_VAGINA "<span class='warning'>You feel your pussy twitch as waves of juice surge out!</span>"
#define BLUEBERRY_SPLASH_BREASTS "<span class='warning'>The pressure in your breasts becomes too much, as you feel juice start to spray out of your nipples!</span>"
#define BLUEBERRY_SPLASH_GENERIC "<span class='warning'>The pressure in your body just becomes to much, as juice starts to spill out of you!</span>"
#define BLUEBERRY_SPLASH_AMOUNT_PERCENTAGE 2
#define BLUEBERRY_SPLASH_AMOUNT_MAX 100

GLOBAL_LIST_INIT(blueberry_growing, list(
	'modular_gs/sound/voice/gurgle1.ogg', 'modular_gs/sound/voice/gurgle2.ogg', 'modular_gs/sound/voice/gurgle3.ogg'
))
GLOBAL_LIST_INIT(blueberry_growing_nearing_limit, list(
	'modular_gs/sound/effects/inflation/creaking/Creak1.ogg', 'modular_gs/sound/effects/inflation/creaking/Creak2.ogg', 'modular_gs/sound/effects/inflation/creaking/Creak3.ogg', 'modular_gs/sound/effects/inflation/creaking/Creak4.ogg'
))
GLOBAL_LIST_INIT(blueberry_burst, list(
	'modular_gs/sound/effects/inflation/pop/inflation_wet_crescendo.ogg'
))
#define BLUEBBERY_BURST_SOUND 'modular_gs/sound/effects/inflation/pop/burst_wet.ogg'

GLOBAL_LIST_INIT(blueberry_growing_flavour, list(
	"<span class='danger'>Oof... Your belly groans as you feel the juice slosh inside you!</span>",
	"<span class='danger'>You feel like a juice filled balloon!</span>"
	))

GLOBAL_LIST_INIT(blueberry_nearing_limit__flavour, list(
	"<span class='danger'>The pressure is getting unbearable! Your body softly creaks as it's struggling to contain all the juice inside you!</span>",
	"<span class='danger'>Your body creaks and stretches, as your tight body tries to find more space for the juice!</span>"
	))

GLOBAL_LIST_INIT(blueberry_about_to_blow_flavour, list(
	"<span class='danger'>Oh god... too big...</span>",
	"<span class='danger'>It's too much! I'm gonna pop!</span>",
	"<span class='danger'>I can't...</span>"
	))

/datum/reagent/blueberry_juice
	name = "Blueberry Juice"
	description = "Totally infectious."
	//reagent_state = LIQUID
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	color = "#0004ff"
	var/mob_color = "#0004ff"
	//var/list/random_color_list = list("#0058db","#5d00c7","#0004ff","#0057e7")
	taste_description = "blueberry pie"
	var/no_mob_color = FALSE
	// put this back in later value = 10	//it sells. Make that berry factory
	purge_multiplier = 3
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/blueberry_juice/on_mob_life(mob/living/carbon/berry, seconds_per_tick)
	if(berry?.client)
		if(!(berry?.client?.prefs?.read_preference(/datum/preference/toggle/blueberry_inflation)))
			berry.reagents.remove_reagent(/datum/reagent/blueberry_juice, volume)
			return
		if(!no_mob_color)
			berry.add_atom_colour(color, WASHABLE_COLOUR_PRIORITY)
		//M.adjust_fatness(1, FATTENING_TYPE_CHEM)
	if(volume >= 999)
		berry.add_quirk(/datum/quirk/permaberry)

	// Add bursting mechanics
	if(berry?.client?.prefs?.read_preference(/datum/preference/numeric/helplessness/blueberry_max_before_burst) > 0)
		handle_capacity(berry, seconds_per_tick)
	..()

/datum/reagent/blueberry_juice/on_mob_add(mob/living/berry, amount)
	if(iscarbon(berry))
		var/mob/living/carbon/affected_mob = berry
		if(!affected_mob?.client || !(affected_mob?.client?.prefs?.read_preference(/datum/preference/toggle/blueberry_inflation)))
			affected_mob.reagents.remove_reagent(/datum/reagent/blueberry_juice, volume)
			return
		affected_mob.hider_add(src)

		// Play generic gurgle sound every time juice gets added
		playsound(berry.loc, pick(GLOB.blueberry_growing), BLUEBERRY_INFLATION_VOLUME, 1, 1, 1.2, ignore_walls = FALSE)

	else
		berry.reagents.remove_reagent(/datum/reagent/blueberry_juice, volume)
	..()

/datum/reagent/blueberry_juice/on_mob_delete(mob/living/berry)
	if(!iscarbon(berry))
		return
	var/mob/living/carbon/berry_carbon = berry
	berry_carbon.hider_remove(src)
	berry_carbon.blueberry_inflate_loop.stop()

/datum/reagent/blueberry_juice/proc/fat_hide()
	return (124 * (volume * volume))/1000	//123'840 600% size, about 56'000 400% size, calc was: (3 * (volume * volume))/50

/**
 * Calculates and handles what the current state of our berry is. Depending on their relative capacity, different effects will occur such as sounds, messages, and juice discharges.
 * Arguments:
 * * berry - The Carbon that's being berrified.
 * * seconds_per_Tick - The current "Tickrate" when the proc was called. This is used for probability calculations.
 */
/datum/reagent/blueberry_juice/proc/handle_capacity(mob/living/carbon/berry, seconds_per_tick)
	var/max_before_burst = berry?.client?.prefs?.read_preference(/datum/preference/numeric/helplessness/blueberry_max_before_burst)
	if(!max_before_burst)
		return FALSE

	switch((berry.reagents.get_reagent_amount(/datum/reagent/blueberry_juice)/max_before_burst))
		if(0 to 0.7)
			if (SPT_PROB(5, seconds_per_tick))
				playsound(berry.loc, pick(GLOB.blueberry_growing), BLUEBERRY_INFLATION_VOLUME, 1, 1, 1.2, ignore_walls = FALSE)
				berry.visible_message("<span class='warning'>[berry]'s belly let's out an audible groan as the juice sloshes inside them!</span>", pick(GLOB.blueberry_growing_flavour))
			if (SPT_PROB(1, seconds_per_tick))
				splatter_juice(berry)
		if(0.7 to 0.9)
			if (SPT_PROB(10, seconds_per_tick))
				berry.visible_message("<span class='warning'>[berry]'s body softly creaks under the strain of being filled with juice!</span>", pick(GLOB.blueberry_nearing_limit__flavour))
				playsound(berry.loc, pick(GLOB.blueberry_growing_nearing_limit), BLUEBERRY_INFLATION_VOLUME, 1, 1, 1.2, ignore_walls = FALSE)
			if (SPT_PROB(5, seconds_per_tick))
				splatter_juice(berry)
		if(0.9 to INFINITY)
			if (SPT_PROB(15, seconds_per_tick))
				berry.visible_message("<span class='warning'>[berry]'s body softly creaks under the strain of being filled with juice!</span>", pick(GLOB.blueberry_about_to_blow_flavour))
				playsound(berry.loc, pick(GLOB.blueberry_growing_nearing_limit), BLUEBERRY_INFLATION_VOLUME, 1, 1, 1.2, ignore_walls = TRUE)
			if (SPT_PROB(35, seconds_per_tick))
				splatter_juice(berry)
			if (SPT_PROB(5, seconds_per_tick))
				splatter_juice(berry, TRUE)

	if((berry.reagents.get_reagent_amount(/datum/reagent/blueberry_juice)/berry?.client?.prefs?.read_preference(/datum/preference/numeric/helplessness/blueberry_max_before_burst)) > (1 + berry.burst_delay_modifier))
		berry.trigger_burst()


/**
 * Create a streak or puddle of juice from a carbon. If the character is a human, gather the equipped genitals and create flavour text based on them.
 * Arguments:
 * * berry - The Carbon that's being berrified. The decal or puddle will be spawned on the turf below it.
 * * puddle - whether to spawn a streak decal, or a skyrat puddle
 */
/datum/reagent/blueberry_juice/proc/splatter_juice(mob/living/carbon/berry, puddle = FALSE)
	var/list/possible_descriptions = list()

	if(ishuman(berry)) // Humans can have genitalia, so we can be more specific in our descriptions
		var/mob/living/carbon/human/burstee_human= berry
		if(puddle)
			burstee_human.add_juice_splatter_floor(get_turf(burstee_human), TRUE)
			possible_descriptions.Add(BLUEBERRY_SPLASH_BELLY)
			if(burstee_human.has_vagina())
				possible_descriptions.Add(BLUEBERRY_SPLASH_VAGINA)
			if(burstee_human.has_penis())
				possible_descriptions.Add(BLUEBERRY_SPLASH_PENIS)
			if(burstee_human.has_breasts())
				possible_descriptions.Add(BLUEBERRY_SPLASH_BREASTS)
			burstee_human.try_lewd_autoemote("moan")
		else
			burstee_human.add_juice_splatter_floor(get_turf(burstee_human), FALSE)
			possible_descriptions.Add(BLUEBERRY_SPILL_BELLY)
			if(burstee_human.has_vagina())
				possible_descriptions.Add(BLUEBERRY_SPILL_VAGINA)
			if(burstee_human.has_penis())
				possible_descriptions.Add(BLUEBERRY_SPILL_PENIS)
			if(burstee_human.has_breasts())
				possible_descriptions.Add(BLUEBERRY_SPILL_BREASTS)
			burstee_human.try_lewd_autoemote("blush")
	else // Keep it generic for carbons
		if(puddle)
			berry.add_juice_splatter_floor(get_turf(berry), TRUE)
			possible_descriptions.Add(BLUEBERRY_SPLASH_GENERIC)
		else
			berry.add_juice_splatter_floor(get_turf(berry), FALSE)
			possible_descriptions.Add(BLUEBERRY_SPILL_GENERIC)

	to_chat(berry, pick(possible_descriptions))


/datum/looping_sound/blueberry_inflation
	mid_sounds = list('modular_gs/sound/effects/inflation/berryloop.ogg')
	mid_length = 8 SECONDS
	volume = BLUEBERRY_INFLATION_VOLUME

// Add BB Inflation related stuff to carbon
/mob/living/carbon
	var/datum/looping_sound/blueberry_inflation/blueberry_inflate_loop
	var/burst_delay_modifier = DELAY_BURST_MODIFIER
	var/burst_triggered = FALSE


/mob/living/carbon/Initialize(mapload)
	. = ..()
	blueberry_inflate_loop = new(src, FALSE)

/mob/living/carbon/Destroy()
	QDEL_NULL(blueberry_inflate_loop)
	return ..()

/**
 * Initiates the burst popup. Giving the player the choice between bursting or delaying.
 */
/mob/living/carbon/proc/trigger_burst()
	if (burst_triggered) // Don't open a thousand windows
		return
	burst_triggered = TRUE
	var/list/buttons = list(BURST_IMMEDIATELY, DELAY_BURST)
	var/burst_choice = tgui_alert(src, "Don't worry, nothing will happen until you've made a choice here!\nChoose if you want to burst now, or if you'd rather delay for a bit. If click on the burst now option, you will have 7 seconds before you burst. If you click on the delay option, nothing will happen and you will get the option to burst again in 5 minutes.", "You feel ready to pop!", buttons)
	visible_message("<span class='warning'>[src]'s body wobbles violently, they look ready to burst!</span>", pick(GLOB.blueberry_about_to_blow_flavour))
	if(!burst_choice || burst_choice == BURST_IMMEDIATELY)
		burst()
	if(!burst_choice || burst_choice == DELAY_BURST)
		burst_delay_modifier = burst_delay_modifier * 2 // We double the buffer for each delay choice
		burst_triggered = FALSE

/**
 * Burst the carbon. Depending on the players prefs, this will cause the character to also Gib and die.
 */
/mob/living/carbon/proc/burst()
	var/safe_popping = client?.prefs?.read_preference(/datum/preference/toggle/reform_after_bursting)
	playsound(loc, pick(GLOB.blueberry_burst), BLUEBERRY_INFLATION_VOLUME, 1, 1, 1.2, ignore_walls = TRUE)

	if (!do_after(src, 7 SECONDS, src))
		return

	var/liquid_to_spill = reagents.get_reagent_amount(/datum/reagent/blueberry_juice)
	var/turf/the_turf = get_turf(src)
	the_turf.add_liquid(/datum/reagent/blueberry_juice, liquid_to_spill, FALSE, 312)
	reagents.remove_reagent(/datum/reagent/blueberry_juice, liquid_to_spill)
	var/datum/effect_system/fluid_spread/smoke/blueberry/smoke = new
	smoke.set_up(2, holder = src, location = src)
	smoke.start()
	playsound(loc, BLUEBBERY_BURST_SOUND, BLUEBERRY_INFLATION_VOLUME * 1.5, 1, 1, 1.2, ignore_walls = TRUE)
	qdel(smoke)
	burst_triggered = FALSE

	if(!safe_popping)
		gib(DROP_ALL_REMAINS)

/**
 * Spawn a streak or puddle of juice on the floor of a carbon.
 * Arguments:
 * * berry - The Carbon that's being berrified. The decal or puddle will be spawned on the turf below it.
 * * puddle - whether to spawn a streak decal, or a skyrat puddle
 */
/mob/living/carbon/proc/add_juice_splatter_floor(turf/the_turf, puddle = FALSE)
	if(!the_turf)
		the_turf = get_turf(src)
	if(!puddle)
		var/selected_type = pick(/obj/effect/decal/cleanable/juice, /obj/effect/decal/cleanable/juice/streak)
		var/atom/stain = new selected_type(the_turf, get_static_viruses())
		stain.add_mob_blood(src) //I'm not adding a new forensics category for cumstains
	else
		var/liquid_to_spill = min((reagents.get_reagent_amount(/datum/reagent/blueberry_juice) / 100 * BLUEBERRY_SPLASH_AMOUNT_PERCENTAGE), BLUEBERRY_SPLASH_AMOUNT_MAX) // Sploosh out BLUEBERRY_SPLASH_AMOUNT_PERCENTAGE percent of total juice, or 100 units, whichever is smallest.
		the_turf.add_liquid(/datum/reagent/blueberry_juice, liquid_to_spill, FALSE, 312)
		reagents.remove_reagent(/datum/reagent/blueberry_juice, liquid_to_spill)

/obj/effect/decal/cleanable/juice
	name = "berry juice"
	desc = "It's blue and smells enticingly sweet."
	icon = 'modular_gs/icons/turf/berry_decal.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")
	beauty = -50

/obj/effect/decal/cleanable/juice/streak
	random_icon_states = list("streak1", "streak2", "streak3", "streak4", "streak5")

/////////////////////////////////////////////
// Blueberry smoke
/////////////////////////////////////////////
// Used as an effect when a berry goes pop. Spreads the disease to whoever breathed it in.
/obj/effect/particle_effect/fluid/smoke/blueberry
	name = "blueberry smoke"
	color = COLOR_BLUE_LIGHT
	lifetime = 2 SECONDS

/// A factory which produces green smoke that makes you cough.
/datum/effect_system/fluid_spread/smoke/blueberry
	effect_type = /obj/effect/particle_effect/fluid/smoke/blueberry

// /obj/item/food/meat/steak/troll
// 	name = "Troll steak"
// 	desc = "In its sliced state it remains dormant, but once the troll meat comes in contact with stomach acids, it begins a perpetual cycle of constant regrowth and digestion. You probably shouldn't eat this."
// 	var/hunger_threshold = NUTRITION_LEVEL_FULL
// 	var/nutrition_amount = 20 // somewhere around 5 pounds
// 	var/fullness_to_add = 10
// 	var/message = "<span class='notice'>You feel fuller...</span>" // GS13

