struct GameManagerContext {
    version: Int as uint8;
    owner: Address;
    numGames: Int as uint256;
    maxPlayers: Int as uint8;
    lastGameAddr: Address?;
    balance: Int;
}

struct GameContext {
    parent: Address;
    seqno: Int as uint256;
    isStarted: Bool;
    isFinished: Bool;
    playersCounter: Int as uint8;
    maxPlayers: Int as uint8;
    lastNumber: Int;
    winner: Address?;
    fewWinners: Bool;
    isGameFull: Bool;
    balance: Int;
}