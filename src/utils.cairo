use starknet::ContractAddress;

pub fn contains_address(span: @Span<ContractAddress>, address: ContractAddress) -> bool {
    let mut span_copy = *span;
    let mut founded = false;
    loop {
        match span_copy.pop_front() {
            Option::Some(_address) => { if *_address == address {
                founded = true;
                break;
            } },
            Option::None => { break; },
        }
    };
    founded
}
