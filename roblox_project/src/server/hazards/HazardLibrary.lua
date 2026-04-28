local Hazards = {}

Hazards.list = {
	"lava_gap",
	"spinning_beam",
	"moving_platform",
	"falling_tiles",
	"crusher",
	"laser_grid",
	"wind_push",
	"ice_slide",
	"teleport_gap",
	"fake_platform",
	"bounce_pad",
	"speed_boost_trap",
	"gravity_flip_zone",
	"rotating_ring",
	"timed_bridge",
	"collapsing_floor",
	"moving_lasers",
	"random_platform_swap",
	"vertical_climb_spikes",
	"horizontal_spike_wall",

	-- expand to 50+
	"blade_swing",
	"fire_wave",
	"electric_floor",
	"darkness_zone",
	"memory_platforms",
	"invisible_path",
	"fake_checkpoint",
	"reverse_controls_zone",
	"wind_tunnel",
	"meteor_drop",
	"ice_break_tiles",
	"trap_doors",
	"wall_climb_chase",
	"homing_projectiles",
	"laser_turrets",
	"moving_spike_floor",
	"collapsing_bridge_chain",
	"jump_timing_orbs",
	"rolling_boulder",
	"lava_rise_timer",
	"platform_shuffle",
	"gravity_well",
	"speed_zone_switch",
	"teleport_maze",
	"laser_crossfire",
	"timed_rotating_blocks",
	"falling_stairs",
	"energy_surge_zones",
	"boss_platform_event"
}

function Hazards.getRandom(seed, i)
	local idx = math.abs(math.sin(seed + i) * 10000) % #Hazards.list
	return Hazards.list[math.floor(idx) + 1]
end

return Hazards
