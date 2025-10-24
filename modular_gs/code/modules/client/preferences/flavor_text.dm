/datum/preference/text/ws_text
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "ws_rounded"
	maximum_value_length = 300 // I feel like this is reasonable?

/datum/preference/text/ws_text/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	target.dna.features["ws_rounded"] = value

/datum/preference/text/ws_text/fat
	savefile_key = "ws_fat"

/datum/preference/text/ws_text/fat/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	target.dna.features["ws_fat"] = value

/datum/preference/text/ws_text/very_fat
	savefile_key = "ws_very_fat"

/datum/preference/text/ws_text/very_fat/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	target.dna.features["ws_very_fat"] = value

/datum/preference/text/ws_text/obese
	savefile_key = "ws_obese"

/datum/preference/text/ws_text/obese/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	target.dna.features["ws_obese"] = value

/datum/preference/text/ws_text/morbidly_obese
	savefile_key = "ws_morbidly_obese"

/datum/preference/text/ws_text/morbidly_obese/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	target.dna.features["ws_morbidly_obese"] = value

/datum/preference/text/ws_text/extremely_obese
	savefile_key = "ws_extremely_obese"

/datum/preference/text/ws_text/extremely_obese/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	target.dna.features["ws_extremely_obese"] = value

/datum/preference/text/ws_text/barely_mobile
	savefile_key = "ws_barely_mobile"

/datum/preference/text/ws_text/barely_mobile/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	target.dna.features["ws_barely_mobile"] = value

/datum/preference/text/ws_text/immobile
	savefile_key = "ws_immobile"

/datum/preference/text/ws_text/immobile/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	target.dna.features["ws_immobile"] = value

/datum/preference/text/ws_text/fatty_blob
	savefile_key = "ws_fatty_blob"

/datum/preference/text/ws_text/fatty_blob/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	target.dna.features["ws_fatty_blob"] = value
