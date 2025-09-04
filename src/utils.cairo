use crate::models::MissionDifficulty;
use crate::store::StoreTrait;
use dojo::world::WorldStorage;

pub fn get_current_day() -> u64 {
    starknet::get_block_timestamp() / 86400 // Seconds per day
}

pub fn get_mission_xp_configurable(
    world: WorldStorage, season_id: u32, difficulty: MissionDifficulty, completion_count: u32,
) -> u32 {
    let mut store = StoreTrait::new(world);
    let config = store.get_mission_xp_config(season_id, difficulty, completion_count);
    config.xp_reward
}

pub fn get_level_xp_configurable(
    world: WorldStorage, season_id: u32, level: u32, completion_count: u32,
) -> u32 {
    let mut store = StoreTrait::new(world);
    let config = store.get_level_xp_config(season_id, level, completion_count);
    config.xp_reward
}


pub fn get_tier_from_level(level: u32) -> u32 {
    if level >= 1 && level <= 11 {
        1 // Casual
    } else if level >= 12 && level <= 25 {
        2 // Average
    } else if level >= 26 && level <= 32 {
        3 // Hardcore
    } else { // if level >= 33
        4 // Legend
    }
}
