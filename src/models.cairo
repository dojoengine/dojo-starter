use starknet::ContractAddress;

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Inventory {
    #[key]
    pub address: ContractAddress,
    pub items_quantity: u32,
    pub available_slots: u32,
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct InventoryItem {
    #[key]
    pub address: ContractAddress,
    #[key]
    pub slot: u32,
    pub item_id: u32,
    pub quantity: u32,
}

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
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Owners {
    #[key]
    pub key: felt252,
    pub owners: Span<ContractAddress>,
}
