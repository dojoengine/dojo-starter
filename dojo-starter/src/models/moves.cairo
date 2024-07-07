use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Moves {
    #[key]
    player: ContractAddress,
    remaining: u8,
    last_direction: Direction,
    can_move: bool,
}

#[derive(Drop, Serde)]
#[dojo::model]
struct DirectionsAvailable {
    #[key]
    player: ContractAddress,
    directions: Array<Direction>,
}

#[derive(Serde, Copy, Drop, Introspect)]
enum Direction {
    None,
    Left,
    Right,
    Up,
    Down,
}

impl DirectionIntoFelt252 of Into<Direction, felt252> {
    fn into(self: Direction) -> felt252 {
        match self {
            Direction::None => 0,
            Direction::Left => 1,
            Direction::Right => 2,
            Direction::Up => 3,
            Direction::Down => 4,
        }
    }
}

