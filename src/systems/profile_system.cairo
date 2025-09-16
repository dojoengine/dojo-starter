use starknet::ContractAddress;
use crate::models::SeasonProgress;
use jokers_of_neon_lib::models::external::profile::{PlayerStats, Profile};


#[starknet::interface]
pub trait IJokersProfile<T> {
    fn create_profile(ref self: T, address: ContractAddress, username: ByteArray);
    fn add_stats(ref self: T, player_stats: PlayerStats);

    fn get_profile(self: @T, player_address: ContractAddress) -> Profile;
    fn get_player_stats(self: @T, player_address: ContractAddress) -> PlayerStats;
    fn get_season(self: @T, season_id: u32);
    fn get_season_progress(
        self: @T, player_address: ContractAddress, season_id: u32,
    ) -> SeasonProgress;
}

#[dojo::contract]
pub mod profile_system {
    use super::IJokersProfile;
    use crate::{models::SeasonProgress, store::StoreTrait};
    use jokers_of_neon_lib::models::external::profile::{PlayerStats, Profile};
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
    }

    const WRITER_ROLE: felt252 = selector!("WRITER_ROLE");

    fn dojo_init(ref self: ContractState, owner: ContractAddress) {
        self.accesscontrol.initializer();
        self.accesscontrol._grant_role(DEFAULT_ADMIN_ROLE, owner);
        self.accesscontrol._grant_role(WRITER_ROLE, owner);
    }

    #[abi(embed_v0)]
    impl ProfileImpl of IJokersProfile<ContractState> {
        fn create_profile(ref self: ContractState, address: ContractAddress, username: ByteArray) {
            // self.accesscontrol.assert_only_role(WRITER_ROLE);
            let mut store = StoreTrait::new(self.world_default());

            store
                .set_profile(
                    Profile {
                        address,
                        username,
                        xp: 0,
                        level: 1,
                        available_games: 3,
                        max_available_games: 3,
                        daily_streak: 1,
                        banned: false,
                        badges_ids: [].span(),
                    },
                )
        }

        fn add_stats(ref self: ContractState, player_stats: PlayerStats) {
            // self.accesscontrol.assert_only_role(WRITER_ROLE);
            self._add_stats(player_stats)
        }

        fn get_profile(self: @ContractState, player_address: ContractAddress) -> Profile {
            let mut store = StoreTrait::new(self.world_default());
            store.get_profile(player_address)
        }

        fn get_player_stats(self: @ContractState, player_address: ContractAddress) -> PlayerStats {
            let mut store = StoreTrait::new(self.world_default());
            store.get_player_stats(player_address)
        }

        fn get_season(self: @ContractState, season_id: u32) {
            assert!(1 == 0, "Profile: `get_season` not implemented")
        }

        fn get_season_progress(
            self: @ContractState, player_address: ContractAddress, season_id: u32,
        ) -> SeasonProgress {
            let mut store = StoreTrait::new(self.world_default());
            store.get_season_progress(player_address, season_id)
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"jokers_of_neon_profile")
        }

        fn _add_stats(self: @ContractState, player_stats: PlayerStats) {
            let mut store = StoreTrait::new(self.world_default());
            let mut current_player_stats = store.get_player_stats(player_stats.address);

            current_player_stats.games_played += player_stats.games_played;
            current_player_stats.games_won += player_stats.games_won;
            current_player_stats.high_card_played += player_stats.high_card_played;
            current_player_stats.pair_played += player_stats.pair_played;
            current_player_stats.two_pair_played += player_stats.two_pair_played;
            current_player_stats.three_of_a_kind_played += player_stats.three_of_a_kind_played;
            current_player_stats.four_of_a_kind_played += player_stats.four_of_a_kind_played;
            current_player_stats.five_of_a_kind_played += player_stats.five_of_a_kind_played;
            current_player_stats.full_house_played += player_stats.full_house_played;
            current_player_stats.flush_played += player_stats.flush_played;
            current_player_stats.straight_played += player_stats.straight_played;
            current_player_stats.straight_flush_played += player_stats.straight_flush_played;
            current_player_stats.royal_flush_played += player_stats.royal_flush_played;

            current_player_stats.loot_boxes_purchased += player_stats.loot_boxes_purchased;
            current_player_stats.cards_purchased += player_stats.cards_purchased;
            current_player_stats.specials_purchased += player_stats.specials_purchased;
            current_player_stats.power_ups_purchased += player_stats.power_ups_purchased;
            current_player_stats.level_ups_purchased += player_stats.level_ups_purchased;
            current_player_stats.modifiers_purchased += player_stats.modifiers_purchased;
            current_player_stats.rerolls_purchased += player_stats.rerolls_purchased;
            current_player_stats.burn_purchased += player_stats.burn_purchased;
            current_player_stats.specials_sold += player_stats.specials_sold;

            store.set_player_stats(current_player_stats);
        }
    }
}
