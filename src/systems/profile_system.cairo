use starknet::ContractAddress;
use crate::models::{Profile, PlayerStats, InventoryItem, SeasonProgress};

#[starknet::interface]
trait IJokersProfile<T> {
    fn create_profile(ref self: T, address: ContractAddress, username: ByteArray);
    fn add_xp(ref self: T, address: ContractAddress, season_id: u32, xp: u256);
    fn add_stats(ref self: T, player_stats: PlayerStats);

    fn get_profile(self: @T, player_address: ContractAddress) -> Profile;
    fn get_player_stats(self: @T, player_address: ContractAddress) -> PlayerStats;
    fn get_season(self: @T, season_id: u32);
    fn get_season_progress(
        self: @T, player_address: ContractAddress, season_id: u32,
    ) -> SeasonProgress;
    fn get_inventory(self: @T, player_address: ContractAddress) -> Span<InventoryItem>;
}

#[dojo::contract]
pub mod profile_system {
    use super::IJokersProfile;
    use crate::{
        utils::contains_address, models::{Profile, PlayerStats, InventoryItem, SeasonProgress},
        store::StoreTrait,
    };
    use starknet::ContractAddress;

    fn dojo_init(ref self: ContractState, owners: Span<ContractAddress>) {
        let mut store = StoreTrait::new(self.world_default());
        store.set_owners(owners);
    }

    #[abi(embed_v0)]
    impl ProfileImpl of IJokersProfile<ContractState> {
        fn create_profile(ref self: ContractState, address: ContractAddress, username: ByteArray) {
            self.assert_caller_ownership();
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

        fn add_xp(ref self: ContractState, address: ContractAddress, season_id: u32, xp: u256) {
            self.assert_caller_ownership();
            let mut store = StoreTrait::new(self.world_default());
            let mut profile = store.get_profile(address);
            let mut season_progress = store.get_season_progress(address, season_id);

            profile.xp += xp;
            season_progress.season_xp += xp;

            store.set_profile(profile);
            store.set_season_progress(season_progress);
            // TODO: Check if player has new season unlockeables
        }

        fn add_stats(ref self: ContractState, player_stats: PlayerStats) {
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

        fn get_inventory(
            self: @ContractState, player_address: ContractAddress,
        ) -> Span<InventoryItem> {
            let mut store = StoreTrait::new(self.world_default());
            let mut items = array![];
            let inventory = store.get_inventory(player_address);

            for slot in 0..inventory.items_quantity {
                items.append(store.get_inventory_item(player_address, slot));
            };
            items.span()
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"jokers_of_neon_profile")
        }

        fn assert_caller_ownership(self: @ContractState) {
            let mut store = StoreTrait::new(self.world_default());
            assert!(
                contains_address(@store.get_owners().owners, starknet::get_caller_address()),
                "Profile: Not authorized",
            );
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

            store.set_player_stats(current_player_stats);
        }
    }
}
