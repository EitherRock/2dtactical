extends Node


enum UnitType {
	INFANTRY,
	HEAVY,
	TANK
}

const UNIT_TYPE_NAMES = {
	UnitType.INFANTRY: "infantry",
	UnitType.HEAVY: "heavy",
	UnitType.TANK: "tank",
}

const DAMAGE_TABLE = {
	'infantry': {
		'infantry': 55,
		'heavy': 45,
		'tank': -1
	}
}

#const DAMAGE_TABLE = {
	#"INF": {
		#"INF": 55,
		#"MEC": 45,
		#"RECON": -1,
		#"TANK": -1,
		#"MD_TANK": -1,
		#"APC": -1,
	#},
	#"MEC": {
		#"INF": 65,
		#"MEC": 55,
		#"RECON": 50,
		#"TANK": 15,
		#"MD_TANK": 5,
		#"APC": 45,
	#},
	#"TANK": {
		#"INF": 75,
		#"MEC": 70,
		#"RECON": 65,
		#"TANK": 55,
		#"MD_TANK": 15,
		#"APC": 70,
	#},
	#"MD_TANK": {
		#"INF": 105,
		#"MEC": 95,
		#"RECON": 90,
		#"TANK": 85,
		#"MD_TANK": 55,
		#"APC": 105,
	#},
	#"RECON": {
		#"INF": 70,
		#"MEC": 60,
		#"RECON": 45,
		#"TANK": 35,
		#"MD_TANK": 6,
		#"APC": 60,
	#},
#}


var color_sprites = {
	'done_neutral': {
		'units': {
			'infantry': "res://graphics/Tiles/tile_0106.png",
			'infantry_heavy': "res://graphics/Tiles/tile_0107.png",
			'tank': "res://graphics/Tiles/tile_0098.png",
			'artillery': "res://graphics/Tiles/tile_0099.png",
			'transport_land': "res://graphics/Tiles/tile_0096.png",
			'plane': "res://graphics/Tiles/tile_0100.png",
			'helicopter': "res://graphics/Tiles/tile_0101.png",
			'transport_air': "res://graphics/Tiles/tile_0102.png",
			'boat_artillery': "res://graphics/Tiles/tile_0104.png",
			'ship': "res://graphics/Tiles/tile_0105.png"
		},
		'buildings': {
			'hq': "res://graphics/Tiles/tile_0010.png",
			'city': "res://graphics/Tiles/tile_0008.png",
			'factory': "res://graphics/Tiles/tile_0011.png"
		}
	},
	'blue': {
		'units': {
			'infantry': "res://graphics/Tiles/tile_0142.png",
			'infantry_heavy': "res://graphics/Tiles/tile_0143.png",
			'tank': "res://graphics/Tiles/tile_0134.png",
			'artillery': "res://graphics/Tiles/tile_0135.png",
			'transport_land': "res://graphics/Tiles/tile_0132.png",
			'plane': "res://graphics/Tiles/tile_0136.png",
			'helicopter': "res://graphics/Tiles/tile_0137.png",
			'transport_air': "res://graphics/Tiles/tile_0138.png",
			'boat_artillery': "res://graphics/Tiles/tile_0140.png",
			'ship': "res://graphics/Tiles/tile_0141.png"
		},
		'buildings': {
			'hq': "res://graphics/Tiles/tile_0046.png",
			'city': "res://graphics/Tiles/tile_0044.png",
			'factory': "res://graphics/Tiles/tile_0047.png"
		}
	},
	'orange': {
		'units': {
			'infantry': "res://graphics/Tiles/tile_0178.png",
			'infantry_heavy': "res://graphics/Tiles/tile_0179.png",
			'tank': "res://graphics/Tiles/tile_0170.png",
			'artillery': "res://graphics/Tiles/tile_0171.png",
			'transport_land': "res://graphics/Tiles/tile_0168.png",
			'plane': "res://graphics/Tiles/tile_0172.png",
			'helicopter': "res://graphics/Tiles/tile_0173.png",
			'transport_air': "res://graphics/Tiles/tile_0174.png",
			'boat_artillery': "res://graphics/Tiles/tile_0176.png",
			'ship': "res://graphics/Tiles/tile_0177.png"
		},
		'buildings': {
			'hq': "res://graphics/Tiles/tile_0082.png",
			'city': "res://graphics/Tiles/tile_0080.png",
			'factory': "res://graphics/Tiles/tile_0083.png"
		}
	}
}

var terrain_defense = {
	'tree': 2,
	'city': 3
}


func calculate_damage(attacker: Unit, target: Unit) -> int:
	print('unit type', attacker.unit_type)
	var attacker_name = UNIT_TYPE_NAMES[attacker.unit_type]
	var target_name = UNIT_TYPE_NAMES[target.unit_type]
	var base_percent = DAMAGE_TABLE.get(attacker_name, {}).get(target_name, -1)
	
	
	if base_percent < 0:
		return 0 # cannot attack
		
	var defense = target.defense
	var hp_factor = attacker.current_health / 10.0
	var terrain_reduction = 1.0 - (defense * 0.1)
	var rand_bonus = randi_range(0, 9)
	
	var percent_damage = floor(base_percent * hp_factor * terrain_reduction) + rand_bonus
	var hp_damage = floor(percent_damage / target.max_health)
	
	return clamp(hp_damage, 0, 100)
