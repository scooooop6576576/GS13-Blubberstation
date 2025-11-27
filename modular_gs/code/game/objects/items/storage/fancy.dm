/obj/item/storage/fancy/large_donut_box // not inheriting from a regular box of donuts for now because I don't want the icon changes...
	name = "large donut box"
	desc = "For when security just can't get enough."
	icon = 'modular_gs/icons/obj/food/containers_34x32.dmi'
	icon_state = "large_donut_box"
	base_icon_state = "large_donut_box"
	spawn_type = /obj/item/food/donut/plain
	storage_type = /datum/storage/donut_box/large
	spawn_count = 16
	open_status = FALSE
	custom_premium_price = PAYCHECK_COMMAND * 3
	contents_tag = "donut"
	appearance_flags = KEEP_TOGETHER|LONG_GLIDE

/datum/storage/donut_box/large
	max_slots = 16
	max_total_storage = WEIGHT_CLASS_SMALL * 16

/obj/item/storage/fancy/large_donut_box/PopulateContents()
	. = ..()
	update_appearance()

/obj/item/storage/fancy/large_donut_box/update_icon_state()
	..()
	if(open_status)
		icon_state = "large_donut_box_open"
	else
		icon_state = "large_donut_box"

#define DONUT_INBOX_SPRITE_WIDTH 4
#define DONUT_INBOX_SPRITE_HEIGHT 6

/obj/item/storage/fancy/large_donut_box/update_overlays()
	. = ..()

	if (!open_status)
		return

	var/donuts = 0

	for (var/_donut in contents)
		var/obj/item/food/donut/donut = _donut
		if (!istype(donut))
			continue

		var/image/donut_image = image(icon = 'icons/obj/food/donuts.dmi', icon_state = donut.in_box_sprite())
		if (donuts < 8)
			donut_image.pixel_w = donuts * DONUT_INBOX_SPRITE_WIDTH - 3
			donut_image.pixel_z = -DONUT_INBOX_SPRITE_HEIGHT
		else
			donut_image.pixel_w = (donuts - 8) * DONUT_INBOX_SPRITE_WIDTH - 3
		. += donut_image
		donuts += 1

#undef DONUT_INBOX_SPRITE_WIDTH
#undef DONUT_INBOX_SPRITE_HEIGHT
