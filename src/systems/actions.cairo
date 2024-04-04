use dojo_starter::models::moves::Direction;
use dojo_starter::models::position::Position;

// define the interface
#[dojo::interface]
trait IActions {
    fn spawn();
    fn move(direction: Direction);
}

// dojo decorator
#[dojo::contract]
mod actions {
    use super::{IActions, next_position};

    use starknet::{ContractAddress, get_caller_address};
    use dojo_starter::models::{position::{Position, Vec2}, moves::{Moves, Direction}};

    // // declaring custom event struct
    // #[event]
    // #[derive(Drop, starknet::Event)]
    // enum Event {
    //     Moved: Moved,
    // }

    // // declaring custom event struct
    // #[derive(starknet::Event, Model, Copy, Drop, Serde)]
    // struct Moved {
    //     #[key]
    //     player: ContractAddress,
    //     direction: Direction
    // }

    // impl: implement functions specified in trait
    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        fn spawn(world: IWorldDispatcher) {
            // Get the address of the current caller, possibly the player's address.
            let player = get_caller_address();
            // Retrieve the player's current position from the world.
            let position = get!(world, player, (Position));

            // Update the world state with the new data.
            // 1. Increase the player's remaining moves by 1.
            // 2. Move the player's position 10 units in both the x and y direction.
            set!(
                world,
                (
                    Moves { player, remaining: 100, last_direction: Direction::None(()) },
                    Position {
                        player, vec: Vec2 { x: position.vec.x + 10, y: position.vec.y + 10 }
                    },
                )
            );
        }

        // Implementation of the move function for the ContractState struct.
        fn move(world: IWorldDispatcher, direction: Direction) {
            // Get the address of the current caller, possibly the player's address.
            let player = get_caller_address();

            // Retrieve the player's current position and moves data from the world.
            let (mut position, mut moves) = get!(world, player, (Position, Moves));

            // Deduct one from the player's remaining moves.
            moves.remaining -= 1;

            // Update the last direction the player moved in.
            moves.last_direction = direction;

            // Calculate the player's next position based on the provided direction.
            let next = next_position(position, direction);

            // // Update the world state with the new moves data and position.
            set!(world, (moves, next));
        // Emit an event to the world to notify about the player's move.
        // emit!(world, Moved { player, direction });
        }
    }
}

// Define function like this:
fn next_position(mut position: Position, direction: Direction) -> Position {
    match direction {
        Direction::None => { return position; },
        Direction::Left => { position.vec.x -= 1; },
        Direction::Right => { position.vec.x += 1; },
        Direction::Up => { position.vec.y -= 1; },
        Direction::Down => { position.vec.y += 1; },
    };
    position
}
