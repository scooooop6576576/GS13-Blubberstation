#define CALORITE_POISONING	"calorite_poisoning"
#define CALORITE_HUNGER		"calorite_hunger"
#define CALORITE_STARVATION	"calorite_starvation"

/mob/living/carbon/proc/handle_calorite_poisoning()
	micro_calorite_poisoning = clamp(micro_calorite_poisoning, 0, 100)

	if (micro_calorite_poisoning < 0.1)	// sanity to make sure we aren't applying stupid effects for very low doses
		return

	var/calorite_poisoning = micro_calorite_poisoning / 100	// we assume 100 micro calorite poisoning is 100%, so we divide by 100 to get the percentage value
	micro_calorite_poisoning -= 0.0001

	if (isnull(client))
		return
	
	if (isnull(client.prefs))
		return

	if (!client.prefs.read_preference(/datum/preference/toggle/severe_fatness_penalty))
		remove_weight_gain_modifier(CALORITE_POISONING)
		remove_weight_loss_modifier(CALORITE_POISONING)

	set_weight_gain_modifier(CALORITE_POISONING, calorite_poisoning)
	set_weight_loss_modifier(CALORITE_POISONING, -calorite_poisoning)

	adjust_hunger(calorite_poisoning * 5)

	if (calorite_poisoning > 0.3)
		if (prob(5))
			emote("gurgle")

	if (calorite_poisoning > 0.4)
		if (has_quirk(/datum/quirk/fat_aversion))
			remove_quirk(/datum/quirk/fat_aversion)

	if (calorite_poisoning > 0.5)
		if (get_fullness() < NUTRITION_LEVEL_FAT)
			add_mood_event(CALORITE_STARVATION, /datum/mood_event/calorite_poisoning_starving)

	if (calorite_poisoning > 0.7 && !has_quirk(/datum/quirk/fat_affinity))
		add_quirk(/datum/quirk/fat_affinity)

	if (calorite_poisoning > 0.8 && get_fullness() < FULLNESS_LEVEL_BLOATED)
		add_mood_event(CALORITE_HUNGER, /datum/mood_event/calorite_poisoning_hunger)
		if(prob(1 * calorite_poisoning))
			Stun(20, ignore_canstun = TRUE)

	if (calorite_poisoning > 0.9)
		adjust_fatness(10 * (calorite_poisoning - 0.9), FATTENING_TYPE_MAGIC)
	
	if (calorite_poisoning > 0.97)
		adjust_perma(1, FATTENING_TYPE_MAGIC, TRUE)

/// in case we ever want to add special effects onto it
/mob/living/carbon/proc/adjust_calorite_poisoning(amount)
	micro_calorite_poisoning += amount

/datum/mood_event/calorite_poisoning_hunger
	description = span_bolddanger("I'm so hungry!")
	mood_change = -6
	timeout = 3 MINUTES

/datum/mood_event/calorite_poisoning_starving
	description = span_bolddanger("I'M STARVING!!")
	mood_change = -8
	timeout = 3 MINUTES