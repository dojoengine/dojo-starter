use array::ArrayTrait;

#[derive(Component, Copy, Drop, Serde, SerdeLen)]
struct Hp {
    maxValue: u32,
    value: u32
}

trait HpTrait {
    fn is_zero(self: Hp) -> bool;
}

impl HpImpl of HpTrait {
    fn is_zero(self: Hp) -> bool {
        if self.value == 0 {
            return true;
        }
        false
    }
}

#[test]
#[available_gas(100000)]
fn test_hp_is_zero() {
    assert(HpTrait::is_zero(Hp { maxValue: 100, value: 100 }), 'not zero');
}