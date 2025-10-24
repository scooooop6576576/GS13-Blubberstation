/mob/living/carbon/human/ghostize(can_reenter_corpse)
	if (isnull(client))
		return ..()
	
	if (isnull(client.prefs))
		return ..()
	
	var/datum/preferences/prefs = client.prefs

	if (prefs.read_preference(/datum/preference/toggle/weight_gain_persistent))
		prefs.write_preference(GLOB.preference_entries[/datum/preference/numeric/starting_fatness], fatness_real)

	prefs.write_preference(GLOB.preference_entries[/datum/preference/numeric/perma_fat_value], fatness_perma)

	. = ..()

