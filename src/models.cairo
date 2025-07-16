use starknet::ContractAddress;

#[derive(Drop, Serde, Debug)]
#[dojo::model]
pub struct Profile {
    #[key]
    pub address: ContractAddress,
    pub username: ByteArray,
    pub xp: u256,
    pub level: u32,
    pub available_games: u8,
    pub max_available_games: u8,
    pub daily_streak: u16,
    pub banned: bool,
    pub badges_ids: Span<u32>,
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct PlayerStats {
    #[key]
    pub address: ContractAddress,
    // Games
    pub games_played: u32,
    pub games_won: u32,
    // Plays
    pub high_card_played: u32,
    pub pair_played: u32,
    pub two_pair_played: u32,
    pub three_of_a_kind_played: u32,
    pub four_of_a_kind_played: u32,
    pub five_of_a_kind_played: u32,
    pub full_house_played: u32,
    pub flush_played: u32,
    pub straight_played: u32,
    pub straight_flush_played: u32,
    pub royal_flush_played: u32,
    // Store
    pub loot_boxes_purchased: u32,
    pub cards_purchased: u32,
    pub specials_purchased: u32,
    pub power_ups_purchased: u32,
    pub level_ups_purchased: u32,
    pub modifiers_purchased: u32,
}

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
