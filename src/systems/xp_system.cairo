use starknet::ContractAddress;
use crate::models::{
    MissionDifficulty, MissionXPConfig, LevelXPConfig, SeasonConfig, SeasonLevelConfig,
};

#[starknet::interface]
pub trait IXPSystem<T> {
    fn add_daily_mission_xp(ref self: T, address: ContractAddress, mission_type: MissionDifficulty);
    fn add_level_completion_xp(ref self: T, address: ContractAddress, level: u32);

    // Configuration methods
    fn set_mission_xp_config(ref self: T, config: MissionXPConfig);
    fn set_level_xp_config(ref self: T, config: LevelXPConfig);
    fn set_season_config(ref self: T, config: SeasonConfig);
    fn set_season_level_config(ref self: T, config: SeasonLevelConfig);

    // Setup methods for initializing default configurations
    fn setup_default_season_config(ref self: T, season_id: u32);
}

#[dojo::contract]
pub mod xp_system {
    use super::IXPSystem;
    use crate::{
        models::{
            MissionDifficulty, MissionXPConfig, LevelXPConfig, SeasonConfig, SeasonLevelConfig,
        },
        utils::{
            get_current_day, get_mission_xp_configurable, get_level_xp_configurable,
            get_tier_from_level,
        },
        store::{StoreTrait, Store},
    };
    use starknet::ContractAddress;
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::access::accesscontrol::{AccessControlComponent, DEFAULT_ADMIN_ROLE};

    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: AccessControlComponent, storage: accesscontrol, event: AccessControlEvent);

    #[abi(embed_v0)]
    impl AccessControlMixinImpl =
        AccessControlComponent::AccessControlMixinImpl<ContractState>;

    impl AccessControlInternalImpl = AccessControlComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        #[substorage(v0)]
        accesscontrol: AccessControlComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        SRC5Event: SRC5Component::Event,
        #[flat]
        AccessControlEvent: AccessControlComponent::Event,
        MissionXPAdded: MissionXPAdded,
        LevelXPAdded: LevelXPAdded,
    }

    #[derive(Drop, starknet::Event)]
    struct MissionXPAdded {
        #[key]
        player: ContractAddress,
        season_id: u32,
        mission_type: MissionDifficulty,
        xp_earned: u32,
        day: u64,
    }

    #[derive(Drop, starknet::Event)]
    struct LevelXPAdded {
        #[key]
        player: ContractAddress,
        season_id: u32,
        level: u32,
        xp_earned: u32,
        day: u64,
    }

    const WRITER_ROLE: felt252 = selector!("WRITER_ROLE");

    fn dojo_init(ref self: ContractState, owner: ContractAddress) {
        self.accesscontrol.initializer();
        self.accesscontrol._grant_role(DEFAULT_ADMIN_ROLE, owner);
        self.accesscontrol._grant_role(WRITER_ROLE, owner);
    }

    #[abi(embed_v0)]
    impl XPSystemImpl of IXPSystem<ContractState> {
        fn add_daily_mission_xp(
            ref self: ContractState, address: ContractAddress, mission_type: MissionDifficulty,
        ) {
            // self.accesscontrol.assert_only_role(WRITER_ROLE);

            let world = self.world_default();
            let mut store = StoreTrait::new(world);

            // TODO: Validate that the season is active
            let season_id = 1;
            let mut season_config = store.get_season_config(season_id);
            season_config.is_active = true;
            // let season_config = store.get_season_config(season_id);
            // assert(season_config.is_active, 'Season is not active');

            let current_day = get_current_day();
            let mut daily_progress = store.get_daily_progress(address, current_day);

            let completion_count = match mission_type {
                MissionDifficulty::Easy => daily_progress.easy_missions,
                MissionDifficulty::Medium => daily_progress.medium_missions,
                MissionDifficulty::Hard => daily_progress.hard_missions,
            };

            let xp_earned = get_mission_xp_configurable(
                world, season_id, mission_type, completion_count,
            );

            if xp_earned > 0 {
                match mission_type {
                    MissionDifficulty::Easy => daily_progress.easy_missions += 1,
                    MissionDifficulty::Medium => daily_progress.medium_missions += 1,
                    MissionDifficulty::Hard => daily_progress.hard_missions += 1,
                };

                daily_progress.daily_xp += xp_earned;
                store.set_daily_progress(daily_progress);

                self._add_profile_xp(ref store, address, xp_earned.into());

                if season_config.is_active {
                    self._add_season_xp(ref store, address, season_id, xp_earned.into());
                }

                self
                    .emit(
                        MissionXPAdded {
                            player: address, season_id, mission_type, xp_earned, day: current_day,
                        },
                    );
            }
        }

        fn add_level_completion_xp(ref self: ContractState, address: ContractAddress, level: u32) {
            // self.accesscontrol.assert_only_role(WRITER_ROLE);

            let world = self.world_default();
            let mut store = StoreTrait::new(world);

            // TODO: Validate that the season is active
            let season_id = 1;
            let mut season_config = store.get_season_config(season_id);
            season_config.is_active = true;
            // let season_config = store.get_season_config(season_id);
            // assert(season_config.is_active, 'Season is not active');

            let current_day = get_current_day();
            let mut daily_progress = store.get_daily_progress(address, current_day);

            let level_completions_len = daily_progress.level_completions.len();
            let completion_count = if level > 0 && level <= level_completions_len {
                *daily_progress.level_completions.at(level - 1)
            } else {
                0
            };

            let xp_earned = get_level_xp_configurable(world, season_id, level, completion_count);

            if xp_earned > 0 {
                if level > 0 {
                    let mut level_completions = array![];
                    let current_completions = daily_progress.level_completions;
                    let mut i = 0;

                    // Copy existing completions and increment the target level
                    while i < current_completions.len() {
                        if i == level - 1 {
                            level_completions.append(*current_completions.at(i) + 1);
                        } else {
                            level_completions.append(*current_completions.at(i));
                        }
                        i += 1;
                    };

                    // If the level is beyond current array size, extend the array
                    while level_completions.len() < level {
                        if level_completions.len() == level - 1 {
                            level_completions.append(1);
                        } else {
                            level_completions.append(0);
                        }
                    };

                    daily_progress.level_completions = level_completions.span();
                }

                daily_progress.daily_xp += xp_earned;
                store.set_daily_progress(daily_progress);

                self._add_profile_xp(ref store, address, xp_earned.into());

                if season_config.is_active {
                    self._add_season_xp(ref store, address, season_id, xp_earned.into());
                }

                self
                    .emit(
                        LevelXPAdded {
                            player: address, season_id, level, xp_earned, day: current_day,
                        },
                    );
            }
        }

        fn set_mission_xp_config(ref self: ContractState, config: MissionXPConfig) {
            self.accesscontrol.assert_only_role(DEFAULT_ADMIN_ROLE);
            let mut store = StoreTrait::new(self.world_default());
            store.set_mission_xp_config(config);
        }

        fn set_level_xp_config(ref self: ContractState, config: LevelXPConfig) {
            self.accesscontrol.assert_only_role(DEFAULT_ADMIN_ROLE);
            let mut store = StoreTrait::new(self.world_default());
            store.set_level_xp_config(config);
        }

        fn set_season_config(ref self: ContractState, config: SeasonConfig) {
            self.accesscontrol.assert_only_role(DEFAULT_ADMIN_ROLE);
            let mut store = StoreTrait::new(self.world_default());
            store.set_season_config(config);
        }

        fn set_season_level_config(ref self: ContractState, config: SeasonLevelConfig) {
            self.accesscontrol.assert_only_role(DEFAULT_ADMIN_ROLE);
            let mut store = StoreTrait::new(self.world_default());
            store.set_season_level_config(config);
        }

        fn setup_default_season_config(ref self: ContractState, season_id: u32) {
            self.accesscontrol.assert_only_role(DEFAULT_ADMIN_ROLE);
            let mut store = StoreTrait::new(self.world_default());

            // Set season config
            store.set_season_config(SeasonConfig { season_id, is_active: true });

            // Set mission XP configs based on sistema_xp.md
            // Easy missions
            store
                .set_mission_xp_config(
                    MissionXPConfig {
                        season_id,
                        difficulty: MissionDifficulty::Easy,
                        completion_count: 0,
                        xp_reward: 10,
                    },
                );
            store
                .set_mission_xp_config(
                    MissionXPConfig {
                        season_id,
                        difficulty: MissionDifficulty::Easy,
                        completion_count: 1,
                        xp_reward: 0,
                    },
                );

            // Medium missions
            store
                .set_mission_xp_config(
                    MissionXPConfig {
                        season_id,
                        difficulty: MissionDifficulty::Medium,
                        completion_count: 0,
                        xp_reward: 20,
                    },
                );
            store
                .set_mission_xp_config(
                    MissionXPConfig {
                        season_id,
                        difficulty: MissionDifficulty::Medium,
                        completion_count: 1,
                        xp_reward: 0,
                    },
                );

            // Hard missions
            store
                .set_mission_xp_config(
                    MissionXPConfig {
                        season_id,
                        difficulty: MissionDifficulty::Hard,
                        completion_count: 0,
                        xp_reward: 30,
                    },
                );
            store
                .set_mission_xp_config(
                    MissionXPConfig {
                        season_id,
                        difficulty: MissionDifficulty::Hard,
                        completion_count: 1,
                        xp_reward: 0,
                    },
                );

            // Set level XP configs
            // Level 1
            store
                .set_level_xp_config(
                    LevelXPConfig { season_id, level: 1, completion_count: 0, xp_reward: 5 },
                );
            store
                .set_level_xp_config(
                    LevelXPConfig { season_id, level: 1, completion_count: 1, xp_reward: 0 },
                );

            // Level 2
            store
                .set_level_xp_config(
                    LevelXPConfig { season_id, level: 2, completion_count: 0, xp_reward: 10 },
                );
            store
                .set_level_xp_config(
                    LevelXPConfig { season_id, level: 2, completion_count: 1, xp_reward: 0 },
                );

            // Level 3
            store
                .set_level_xp_config(
                    LevelXPConfig { season_id, level: 3, completion_count: 0, xp_reward: 15 },
                );
            store
                .set_level_xp_config(
                    LevelXPConfig { season_id, level: 3, completion_count: 1, xp_reward: 5 },
                );
            store
                .set_level_xp_config(
                    LevelXPConfig { season_id, level: 3, completion_count: 2, xp_reward: 0 },
                );

            // Level 4
            store
                .set_level_xp_config(
                    LevelXPConfig { season_id, level: 4, completion_count: 0, xp_reward: 20 },
                );
            store
                .set_level_xp_config(
                    LevelXPConfig { season_id, level: 4, completion_count: 1, xp_reward: 10 },
                );
            store
                .set_level_xp_config(
                    LevelXPConfig { season_id, level: 4, completion_count: 2, xp_reward: 0 },
                );

            // Level 5
            store
                .set_level_xp_config(
                    LevelXPConfig { season_id, level: 5, completion_count: 0, xp_reward: 25 },
                );
            store
                .set_level_xp_config(
                    LevelXPConfig { season_id, level: 5, completion_count: 1, xp_reward: 15 },
                );
            store
                .set_level_xp_config(
                    LevelXPConfig { season_id, level: 5, completion_count: 2, xp_reward: 5 },
                );
            store
                .set_level_xp_config(
                    LevelXPConfig { season_id, level: 5, completion_count: 3, xp_reward: 0 },
                );

            // Set season level configs based on sistema_xp.md
            // Leveles 1-11 - Casual (Tier 1)
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 1,
                        required_xp: 25,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 2,
                        required_xp: 50,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 3,
                        required_xp: 75,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 4,
                        required_xp: 100,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 5,
                        required_xp: 150,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 6,
                        required_xp: 200,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 7,
                        required_xp: 300,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 8,
                        required_xp: 400,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 9,
                        required_xp: 500,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 10,
                        required_xp: 600,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 11,
                        required_xp: 700,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            // Leveles 12-25 - Average (Tier 2)
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 12,
                        required_xp: 800,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 13,
                        required_xp: 900,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 14,
                        required_xp: 1000,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 15,
                        required_xp: 1100,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 16,
                        required_xp: 1200,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 17,
                        required_xp: 1300,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 18,
                        required_xp: 1400,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 19,
                        required_xp: 1500,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 20,
                        required_xp: 1600,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 21,
                        required_xp: 1700,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 22,
                        required_xp: 1800,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 23,
                        required_xp: 1900,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 24,
                        required_xp: 2000,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 25,
                        required_xp: 2100,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            // Leveles 26-32 - Hardcore (Tier 3)
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 26,
                        required_xp: 2200,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 27,
                        required_xp: 2300,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 28,
                        required_xp: 2400,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 29,
                        required_xp: 2500,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 30,
                        required_xp: 2750,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 31,
                        required_xp: 3000,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 32,
                        required_xp: 3500,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            // Leveles 33+ - Legend (Tier 4)
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 33,
                        required_xp: 4000,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
            store
                .set_season_level_config(
                    SeasonLevelConfig {
                        season_id,
                        level: 34,
                        required_xp: 5000,
                        free_rewards: [].span(),
                        premium_rewards: [].span(),
                    },
                );
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"jokers_of_neon_profile")
        }

        fn _add_profile_xp(
            ref self: ContractState, ref store: Store, address: ContractAddress, xp: u256,
        ) {
            let mut profile = store.get_profile(address);

            profile.xp += xp;
            store.set_profile(profile);
        }

        fn _add_season_xp(
            ref self: ContractState,
            ref store: Store,
            address: ContractAddress,
            season_id: u32,
            xp: u256,
        ) {
            let mut season_progress = store.get_season_progress(address, season_id);

            season_progress.season_xp += xp;

            let new_tier = get_tier_from_level(season_progress.level);
            if new_tier > season_progress.tier {
                season_progress.tier = new_tier;
            }

            store.set_season_progress(season_progress);
        }
    }
}
