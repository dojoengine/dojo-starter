use starknet::ContractAddress;

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct SeasonProgress {
    #[key]
    pub address: ContractAddress,
    #[key]
    pub season_id: u32,
    pub season_xp: u256,
    pub has_season_pass: bool,
    pub claimable_rewards_id: Span<u32>,
    pub tier: u32,
    pub level: u32,
}

#[derive(Copy, Drop, Serde, Debug, PartialEq, Introspect)]
pub enum MissionDifficulty {
    Easy,
    Medium,
    Hard,
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct DailyProgress {
    #[key]
    pub address: ContractAddress,
    #[key]
    pub day: u64,
    pub daily_xp: u32,
    pub easy_missions: u32,
    pub medium_missions: u32,
    pub hard_missions: u32,
    pub level_completions: Span<u32>,
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct MissionXPConfig {
    #[key]
    pub season_id: u32,
    #[key]
    pub difficulty: MissionDifficulty,
    #[key]
    pub completion_count: u32,
    pub xp_reward: u32,
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct LevelXPConfig {
    #[key]
    pub season_id: u32,
    #[key]
    pub level: u32,
    #[key]
    pub completion_count: u32,
    pub xp_reward: u32,
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct SeasonConfig {
    #[key]
    pub season_id: u32,
    pub is_active: bool,
}

#[derive(Drop, Serde, Debug)]
#[dojo::model]
pub struct SeasonLevelConfig {
    #[key]
    pub season_id: u32,
    #[key]
    pub level: u32,
    pub required_xp: u256,
    pub free_rewards: Span<u32>,
    pub premium_rewards: Span<u32>,
}
