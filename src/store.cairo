use crate::models::{Owners, Profile, PlayerStats, InventoryItem, Inventory, SeasonProgress};
use dojo::{model::ModelStorage, world::WorldStorage};
use starknet::ContractAddress;

#[derive(Drop)]
struct Store {
    world: WorldStorage,
}

#[generate_trait]
pub impl StoreImpl of StoreTrait {
    #[inline(always)]
    fn new(world: WorldStorage) -> Store {
        Store { world: world }
    }

    fn get_profile(ref self: Store, address: ContractAddress) -> Profile {
        self.world.read_model(address)
    }

    fn set_profile(ref self: Store, profile: Profile) {
        self.world.write_model(@profile)
    }

    fn get_player_stats(ref self: Store, address: ContractAddress) -> PlayerStats {
        self.world.read_model(address)
    }

    fn set_player_stats(ref self: Store, player_stats: PlayerStats) {
        self.world.write_model(@player_stats)
    }

    fn get_inventory_item(ref self: Store, address: ContractAddress, slot: u32) -> InventoryItem {
        self.world.read_model((address, slot))
    }

    fn set_inventory_item(ref self: Store, inventory_item: InventoryItem) {
        self.world.write_model(@inventory_item)
    }

    fn get_inventory(ref self: Store, address: ContractAddress) -> Inventory {
        self.world.read_model(address)
    }

    fn set_inventory(ref self: Store, inventory: Inventory) {
        self.world.write_model(@inventory)
    }

    fn get_season_progress(
        ref self: Store, address: ContractAddress, season_id: u32,
    ) -> SeasonProgress {
        self.world.read_model((address, season_id))
    }

    fn set_season_progress(ref self: Store, season_progress: SeasonProgress) {
        self.world.write_model(@season_progress)
    }

    fn get_owners(ref self: Store) -> Owners {
        self.world.read_model('OWNERS_KEY')
    }

    fn set_owners(ref self: Store, owners: Span<ContractAddress>) {
        self.world.write_model(@Owners { key: 'OwNERS_KEY', owners })
    }
}
