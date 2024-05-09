message AddNewPlayer {
    player: Address;
}

message NewGameResponse {
    seqno: Int as uint256;
}

message GenerateNumber {
    // player address => more or less (true or false)
    results: map<Address, Bool>;
}

message GenerateNumberSimple {
    // player counter (0, 1) => more or less (true or false)
    results: map<Int, Bool>;
}