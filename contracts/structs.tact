struct GameManagerContext {
    version: Int as uint8;
    owner: Address;
    numGames: Int as uint256;
    maxPlayers: Int as uint8;
    balance: Int;
}

struct GameContext {
    parent: Address;
    seqno: Int as uint256;
    isStarted: Bool;
    isFinished: Bool;
    players: map<Int as uint8, Address>;
    playersCounter: Int as uint8;
    maxPlayers: Int as uint8;
    lastNumber: Int;
    winner: Address?;
    fewWinners: Bool;
    isGameFull: Bool;
    balance: Int;
}