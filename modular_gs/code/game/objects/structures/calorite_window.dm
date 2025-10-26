/datum/armor/structure_window_calorite
	melee = 10
	fire = 80
	acid = 100

/obj/structure/window/calorite
	name = "calorite window"
	desc = "A window made out of a calorite-silicate alloy."
	icon_state = "calorite_window"
	armor_type = /datum/armor/structure_window_calorite
	max_integrity = 30
	glass_type = /obj/item/stack/sheet/calorite_glass
	rad_insulation = RAD_MEDIUM_INSULATION
	glass_material_datum = /datum/material/alloy/calorite_glass

/obj/structure/window/calorite/unanchored
	anchored = FALSE

/obj/structure/window/calorite/fulltile
	name = "full tile calorite window"
	desc = "A full tile window made out of a calorite-silicate alloy."
	icon = 'modular_gs/icons/obj/structure/window_calorite.dmi'
	fulltile = TRUE
	canSmoothWith = SMOOTH_GROUP_AIRLOCK + SMOOTH_GROUP_WINDOW_FULLTILE + SMOOTH_GROUP_WALLS
	flags_1 = PREVENT_CLICK_UNDER_1
	obj_flags = CAN_BE_HIT
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE
	glass_amount = 2
	max_integrity = 60

/obj/structure/window/calorite/fulltile/unanchored
	anchored = FALSE
