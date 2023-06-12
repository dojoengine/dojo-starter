#[system]
mod Spawn {
    use array::ArrayTrait;
    use traits::Into;

    use dojo_examples::components::Position;
    use dojo_examples::components::Moves;

    // note: ignore linting of Context and commands
    fn execute(ctx: Context) {
        let player = commands::set_entity(
            ctx.caller_account.into(), (Moves { remaining: 10 }, Position { x: 0, y: 0 }, )
        );
        return ();
    }
}

#[system]
mod Move {
    use array::ArrayTrait;
    use traits::Into;

    use dojo_examples::components::Position;
    use dojo_examples::components::Moves;


    #[derive(Serde, Drop)]
    enum Direction {
        Left: (),
        Right: (),
        Up: (),
        Down: (),
    }

    impl DirectionIntoFelt252 of Into<Direction, felt252> {
        fn into(self: Direction) -> felt252 {
            match self {
                Direction::Left(()) => 0,
                Direction::Right(()) => 1,
                Direction::Up(()) => 2,
                Direction::Down(()) => 3,
            }
        }
    }

    // note: ignore linting of Context and commands
    fn execute(ctx: Context, direction: Direction) {
        let (position, moves) = commands::<Position, Moves>::entity(ctx.caller_account.into());
        let next = next_position(position, direction);
        let uh = commands::set_entity(
            ctx.caller_account.into(),
            (Moves { remaining: moves.remaining - 1 }, Position { x: next.x, y: next.y }, )
        );
        return ();
    }

    fn next_position(position: Position, direction: Direction) -> Position {
        match direction {
            Direction::Left(()) => {
                Position { x: position.x - 1, y: position.y }
            },
            Direction::Right(()) => {
                Position { x: position.x + 1, y: position.y }
            },
            Direction::Up(()) => {
                Position { x: position.x, y: position.y - 1 }
            },
            Direction::Down(()) => {
                Position { x: position.x, y: position.y + 1 }
            },
        }
    }
}
