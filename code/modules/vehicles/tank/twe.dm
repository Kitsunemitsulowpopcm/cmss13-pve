
/obj/vehicle/multitile/twe
	name = "M88 Tankette"
	desc = "An M88 Tankette. A lightly armored vehicle armed with a few goodies. Entrances at the back."

	icon = 'icons/obj/vehicles/twe_tank.dmi'
	icon_state = "twe_base"
	pixel_x = -32
	pixel_y = -32

	bound_width = 96
	bound_height = 96

	bound_x = -32
	bound_y = -32

	interior_map = /datum/map_template/interior/tank_twe

	passengers_slots = 6
	xenos_slots = 3

	entrances = list(
		"back" = list(0, 2)
	)

	entrance_speed = 0.5 SECONDS

	required_skill = SKILL_VEHICLE_LARGE

	movement_sound = 'sound/vehicles/tank_driving.ogg'

	light_range = 4

	var/gunner_view_buff = 10

	hardpoints_allowed = list(
		/obj/item/hardpoint/primary/autocannon,
		/obj/item/hardpoint/secondary/m56cupola,
		/obj/item/hardpoint/locomotion/treads,
		/obj/item/hardpoint/locomotion/treads/robust,
	)

	seats = list(
		VEHICLE_DRIVER = null,
		VEHICLE_GUNNER = null,
	)

	active_hp = list(
		VEHICLE_DRIVER = null,
		VEHICLE_GUNNER = null,
	)

	vehicle_flags = VEHICLE_CLASS_LIGHT

	dmg_multipliers = list(
		"all" = 1,
		"acid" = 1.6,
		"slash" = 1.8,
		"bullet" = 0.6,
		"explosive" = 0.7,
		"blunt" = 0.7,
		"abstract" = 1
	)

	move_max_momentum = 3
	move_momentum_build_factor = 2
	move_turn_momentum_loss_factor = 0.8

	vehicle_ram_multiplier = VEHICLE_TRAMPLE_DAMAGE_APC_REDUCTION

/obj/vehicle/multitile/twe/Initialize()
	. = ..()

	var/turf/gotten_turf = get_turf(src)
	if(gotten_turf && gotten_turf.z)
		SSminimaps.add_marker(src, gotten_turf.z, MINIMAP_FLAG_USCM, "apc", 'icons/ui_icons/map_blips_large.dmi')

/obj/vehicle/multitile/twe/load_role_reserved_slots()
	var/datum/role_reserved_slots/RRS = new
	RRS.category_name = "Crewmen"
	RRS.roles = list(JOB_CREWMAN, JOB_WO_CREWMAN, JOB_UPP_CREWMAN, JOB_PMC_CREWMAN)
	RRS.total = 2
	role_reserved_slots += RRS

	RRS = new
	RRS.category_name = "Synthetic Unit"
	RRS.roles = list(JOB_SYNTH, JOB_WO_SYNTH)
	RRS.total = 1
	role_reserved_slots += RRS

/obj/vehicle/multitile/twe/add_seated_verbs(mob/living/M, seat)
	if(!M.client)
		return
	add_verb(M.client, list(
		/obj/vehicle/multitile/proc/get_status_info,
		/obj/vehicle/multitile/proc/open_controls_guide
	))
	if(seat == VEHICLE_DRIVER)
		add_verb(M.client, list(
			/obj/vehicle/multitile/proc/toggle_door_lock,
			/obj/vehicle/multitile/proc/activate_horn,
			/obj/vehicle/multitile/proc/name_vehicle
		))
	else if(seat == VEHICLE_GUNNER)
		add_verb(M.client, list(
			/obj/vehicle/multitile/proc/switch_hardpoint,
			/obj/vehicle/multitile/proc/cycle_hardpoint,
			/obj/vehicle/multitile/proc/toggle_shift_click,
			/obj/vehicle/multitile/proc/name_vehicle
		))

/obj/vehicle/multitile/twe/remove_seated_verbs(mob/living/M, seat)
	if(!M.client)
		return
	remove_verb(M.client, list(
		/obj/vehicle/multitile/proc/get_status_info,
		/obj/vehicle/multitile/proc/open_controls_guide,
	))
	SStgui.close_user_uis(M, src)
	if(seat == VEHICLE_DRIVER)
		remove_verb(M.client, list(
			/obj/vehicle/multitile/proc/toggle_door_lock,
			/obj/vehicle/multitile/proc/activate_horn,
			/obj/vehicle/multitile/proc/name_vehicle,
		))
	else if(seat == VEHICLE_GUNNER)
		remove_verb(M.client, list(
			/obj/vehicle/multitile/proc/switch_hardpoint,
			/obj/vehicle/multitile/proc/cycle_hardpoint,
			/obj/vehicle/multitile/proc/toggle_shift_click,
			/obj/vehicle/multitile/proc/name_vehicle,
		))

/obj/vehicle/multitile/twe/initialize_cameras(change_tag = FALSE)
	if(!camera)
		camera = new /obj/structure/machinery/camera/vehicle(src)
	if(change_tag)
		camera.c_tag = "#[rand(1,100)] M88 \"[nickname]\" APC"
		if(camera_int)
			camera_int.c_tag = camera.c_tag + " interior"
	else
		camera.c_tag = "#[rand(1,100)] M88 Tankette"
		if(camera_int)
			camera_int.c_tag = camera.c_tag + " interior"

/*
** PRESETS SPAWNERS
*/
/obj/effect/vehicle_spawner/twe
	name = "Light tank Spawner"
	icon = 'icons/obj/vehicles/apc.dmi'
	icon_state = "apc_base"
	pixel_x = -32
	pixel_y = -32


/obj/effect/vehicle_spawner/twe/Initialize()
	. = ..()
	spawn_vehicle()
	qdel(src)

//PRESET: FPWs, no hardpoints
/obj/effect/vehicle_spawner/twe/spawn_vehicle()
	var/obj/vehicle/multitile/twe/tank = new (loc)

	load_misc(tank)
	load_hardpoints(tank)
	handle_direction(tank)
	tank.update_icon()

//PRESET: FPWs, wheels installed
/obj/effect/vehicle_spawner/twe/plain/load_hardpoints(obj/vehicle/multitile/apc/V)
	V.add_hardpoint(new /obj/item/hardpoint/locomotion/treads)
	V.add_hardpoint(new /obj/item/hardpoint/secondary/m56cupola)
	V.add_hardpoint(new /obj/item/hardpoint/primary/autocannon)
