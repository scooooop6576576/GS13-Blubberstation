// holy crap Lois, we really need to refactor this code later.

/obj/belly/release_all_contents(include_absorbed = FALSE, silent = FALSE)
	if(iscarbon(owner))
		var/mob/living/carbon/predator = owner
		predator.hider_remove(src)
	. = ..()

/obj/belly/release_specific_contents(atom/movable/M, silent = FALSE)
	if(iscarbon(owner))
		var/mob/living/carbon/predator = owner
		var/found = FALSE
		for(var/prey in contents)
			if(istype(prey, /mob/living/carbon))
				found = TRUE
		if(found)
			predator.hider_add(src)
		else
			predator.hider_remove(src)
	. = ..()

/obj/belly/process_belly(times_fired,wait)
////////////////////////// Vore Fatness /////////////////////////////
	if(iscarbon(owner))
		var/mob/living/carbon/predator = owner
		var/found = FALSE
		for(var/prey in contents)
			if(istype(prey, /mob/living/carbon))
				found = TRUE
		if(found)
			predator.hider_add(src)
		else
			predator.hider_remove(src)
///////////////////////////// DM_FATTEN /////////////////////////////
	if(digest_mode == DM_FATTEN)
		if(iscarbon(owner))
			var/mob/living/carbon/predator = owner
			for(var/mob/living/M in contents)
				var/mob/living/carbon/prey = M
				if(iscarbon(prey) && predator.fatness_real)
					if(predator.fatness_real > 50)
						prey.adjust_fatness(predator.fatness_real * 0.02, FATTENING_TYPE_FOOD)
						predator.adjust_fatness(-predator.fatness_real * 0.02, FATTENING_TYPE_FOOD)
						if(predator.nutrition > NUTRITION_LEVEL_HUNGRY)
							predator.nutrition -= 3
	. = ..()

/obj/belly/proc/fat_hide(mob/living/carbon/user)
	var/preys_fatness = 0
	for(var/prey in contents)
		if(iscarbon(prey))
			var/mob/living/carbon/cprey = prey
			preys_fatness += cprey.fatness
	return preys_fatness
