import "@stdlib/deploy";
import "./messages";

contract Game with Deployable {

    parent: Address;
    seqno: Int as uint256;

    isStarted: Bool = false;
    isFinished: Bool = false;

    players: map<Int as uint8, Address>;
    playersCounter: Int as uint8 = 0;
    maxPlayers: Int as uint8;

    // initial value is -1
    lastNumber: Int = -1;
    winner: Address? = null;

    init(parent: Address, seqno: Int, maxPlayers: Int) {
        self.parent = parent;
        self.seqno = seqno;
        self.maxPlayers = maxPlayers;
    }

    // for internal use
    receive(msg: AddNewPlayer) {
        self.addNewPlayer(msg.player);
    }

    // for external use
    receive("AddNewPlayer") {
        self.addNewPlayer(sender());
    }

    receive(msg: GenerateNumber) {
        require(self.isStarted, "Game not started yet");
        require(!self.isFinished, "Game already finished");

        let rightAnswerPlayerAddress: Address? = null;

        // TODO: need to find a way to generate a real random number
        let newNumber: Int = self.runRandom();
        let rightAnswer: Bool? = self.getRightAnswer(newNumber);

        self.lastNumber = newNumber;

        let i: Int = 0;
        while (i < self.playersCounter) {
            let playerAddress: Address = self.players.get(i)!!;
            // TODO: temporary solution (we need to check if we have this player address)
            let playerAnswer: Bool = msg.results.get(playerAddress)!!;

            if (playerAnswer == rightAnswer) {
                if (rightAnswerPlayerAddress == null) {
                    rightAnswerPlayerAddress = playerAddress;
                } else {
                    // TODO: no winner (temporary solution; now, in any case, the money will be divided equally)
                    rightAnswerPlayerAddress = null;
                }
            }
            
            i += 1;
        }

        if (rightAnswerPlayerAddress != null) {
            self.winner = rightAnswerPlayerAddress;
        }

        self.isFinished = true;
        // temporarary commented
        // self.distributeBalance();
    }

    // TODO: most likely a temporary method
    receive(msg: GenerateNumberSimple) {
        require(self.isStarted, "Game not started yet");
        require(!self.isFinished, "Game already finished");

        let rightAnswerPlayerAddress: Address? = null;

        // TODO: need to find a way to generate a real random number
        let newNumber: Int = self.runRandom();
        let rightAnswer: Bool? = self.getRightAnswer(newNumber);

        self.lastNumber = newNumber;

        let i: Int = 0;
        while (i < self.playersCounter) {
            let playerAddress: Address = self.players.get(i)!!;
            let playerAnswer: Bool = msg.results.get(i)!!;

            if (playerAnswer == rightAnswer) {
                if (rightAnswerPlayerAddress == null) {
                    rightAnswerPlayerAddress = playerAddress;
                } else {
                    // TODO: no winner (temporary solution; now, in any case, the money will be divided equally)
                    rightAnswerPlayerAddress = null;
                }
            }
            
            i += 1;
        }

        if (rightAnswerPlayerAddress != null) {
            self.winner = rightAnswerPlayerAddress;
        }

        self.isFinished = true;
        self.distributeBalance();
    }

    fun addNewPlayer(playerAddress: Address) {
        // TODO: check amount of tons
        require(!self.isStarted, "Game already started");
        require(!self.isGameFull(), "Game is full");

        if (self.playersCounter == 0) {
            self.appendPlayer(playerAddress);
        } else {
            // TODO: use foreach (k, v in m) {}
            let i: Int = 0;
            while (i < self.playersCounter) {
                if(self.players.get(i)!! != playerAddress) {
                    self.appendPlayer(playerAddress);
                }

                i += 1;
            }
        }

        if(self.isGameFull()) {
            self.isStarted = true;
            self.lastNumber = self.runRandom();
        }
    }

    fun getRightAnswer(newNumber: Int): Bool? {
        let rightAnswer: Bool? = null;
        // TODO: we don't handle equal numbers (temporary)
        if(newNumber > self.lastNumber) {
            rightAnswer = true;
        } else if (newNumber < self.lastNumber) {
            rightAnswer = false;
        }

        return rightAnswer;
    }

    fun distributeBalance() {
        if (self.winner != null) {
            send(SendParameters{
                to: self.winner!!,
                value: 0,
                mode: SendRemainingBalance + SendIgnoreErrors,
                body: "Congrats, you are the winner!".asComment()
            });
        } else {
            // send remaining value to the sender
            send(SendParameters{
                to: sender(),
                value: 0,
                mode: SendRemainingValue,
                body: "Remaining value to sender".asComment()
            });
            
            // TODO: distribute the balance so that the players spend the same amount of money in any case
            let balance: Int = myBalance();
            // amount for transaction fee
            let safeAmount: Int = ton("0.025");
            let amount: Int = (balance / self.playersCounter) - safeAmount;

            // TODO: use foreach (k, v in m) {}
            let i: Int = 0;
            while (i < self.playersCounter) {
                send(SendParameters{
                    to: self.players.get(i)!!,
                    value: amount,
                    mode: SendIgnoreErrors,
                    body: "Money refund".asComment()
                });
            
                i += 1;
            }
        }
    }

    fun appendPlayer(playerAddress: Address) {
        self.players.set(self.playersCounter, playerAddress);
        self.playersCounter += 1;
    }

    fun runRandom(): Int {
        return random(1, 1000);
    }

    fun isGameFull(): Bool {
        return self.playersCounter == self.maxPlayers;
    }

    get fun maxPlayers(): Int {
        return self.maxPlayers;
    }

    get fun playersCounter(): Int {
        return self.playersCounter;
    }

    get fun gameIsFull(): Bool {
        return self.isGameFull();
    }

    get fun lastNumber(): Int {
        return self.lastNumber;
    }

    get fun isStarted(): Bool {
        return self.isStarted;
    }

    get fun isFinished(): Bool {
        return self.isFinished;
    }

    get fun balance(): Int {
        return myBalance();
    }

    get fun players(): map<Int as uint8, Address> {
        return self.players;
    }

    get fun winner(): Address? {
        return self.winner;
    }
}
