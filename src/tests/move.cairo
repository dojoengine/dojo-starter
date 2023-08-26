#[cfg(test)]
mod tests {
    // cairo core imports
    use core::traits::Into;
    use array::ArrayTrait;

    // dojo core imports
    use dojo::world::{IWorldDispatcherTrait, IWorldDispatcher};
    use dojo::test_utils::spawn_test_world;

    // project imports
    use dojo_examples::components::{position, Position};
    use dojo_examples::components::{moves, Moves};
    use dojo_examples::systems::spawn;
    use dojo_examples::systems::move;

    // helper setup function
    // reuse this function for all tests
    fn setup_world() -> IWorldDispatcher {
        // components
        let mut components = array![position::TEST_CLASS_HASH, moves::TEST_CLASS_HASH];

        // systems
        let mut systems = array![spawn::TEST_CLASS_HASH, move::TEST_CLASS_HASH];

        // deploy executor, world and register components/systems
        spawn_test_world(components, systems)
    }

    #[test]
    #[available_gas(30000000)]
    fn test_move() {
        let world = setup_world();

        // spawn entity
        world.execute('spawn', array![]);

        // move entity
        world.execute('move', array![move::Direction::Right(()).into()]);

        // call data for entity - it is just the caller
        let caller = starknet::contract_address_const::<0x0>();
        let call_data = array![caller.into()].span();

        // check entity
        let moves = world.entity('Moves', call_data, 0, dojo::SerdeLen::<Moves>::len());
        assert(*moves[0] == 99, 'moves is wrong');

        // check position
        let new_position = world
            .entity('Position', call_data, 0, dojo::SerdeLen::<Position>::len());
        assert(*new_position[0] == 1001, 'position x is wrong');
        assert(*new_position[1] == 1000, 'position y is wrong');
    }
}
