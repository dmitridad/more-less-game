import "@stdlib/deploy";
import "./messages";
import "./structs";
import "./traits";

contract Game with Deployable, Costs {

    parent: Address;
    seqno: Int as uint256;

    isStarted: Bool = false;
    isFinished: Bool = false;

    players: map<Int as uint8, Address>;
    playersCounter: Int as uint8 = 0;
    maxPlayers: Int as uint8;

    // initial value is -1
    lastNumber: Int = -1;
    // list of generated numbers
    numbers: map<Int as uint8, Int>;
    numbersCounter: Int as uint8 = 0;

    winner: Address? = null;
    fewWinners: Bool = false;

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
        require(context().value >= self.GAME_COST, "Low cost of the game");
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
        self.appendNumber(self.lastNumber);

        let players: map<Int as uint8, Address> = self.players;
        foreach (key, value in players) {
            let playerAddress: Address = self.players.get(key)!!;
            if (msg.results.get(playerAddress) == null) {
                self.sendRemainingValue(sender(), "Non-existent player address");

                return;
            }

            let playerAnswer: Bool = msg.results.get(playerAddress)!!;

            if (playerAnswer == rightAnswer) {
                if (rightAnswerPlayerAddress == null) {
                    rightAnswerPlayerAddress = playerAddress;
                } else {
                    // when we have more than one right answer
                    rightAnswerPlayerAddress = null;
                    self.fewWinners = true;
                }
            }
        }

        if (rightAnswerPlayerAddress != null) {
            self.winner = rightAnswerPlayerAddress;
        }

        self.isFinished = true;
        self.distributeBalance();
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
        self.appendNumber(self.lastNumber);

        let players: map<Int as uint8, Address> = self.players;
        foreach (key, value in players) {
            let playerAddress: Address = self.players.get(key)!!;
            if (msg.results.get(key) == null) {
                self.sendRemainingValue(sender(), "Non-existent player key");

                return;
            }

            let playerAnswer: Bool = msg.results.get(key)!!;

            if (playerAnswer == rightAnswer) {
                if (rightAnswerPlayerAddress == null) {
                    rightAnswerPlayerAddress = playerAddress;
                } else {
                    // when we have more than one right answer
                    rightAnswerPlayerAddress = null;
                    self.fewWinners = true;
                }
            }
        }

        if (rightAnswerPlayerAddress != null) {
            self.winner = rightAnswerPlayerAddress;
        }

        self.isFinished = true;
        self.distributeBalance();
    }

    fun addNewPlayer(playerAddress: Address) {
        require(!self.isStarted, "Game already started");
        require(!self.isGameFull(), "Game is full");

        if (self.playersCounter == 0) {
            self.appendPlayer(playerAddress);
        } else {
            let players: map<Int as uint8, Address> = self.players;
            foreach (key, value in players) {
                if(self.players.get(key)!! != playerAddress) {
                    self.appendPlayer(playerAddress);
                } else {
                    // send remaining value, player is already in the game
                    self.sendRemainingValue(playerAddress, null);

                    return;
                }
            }
        }

        if(self.isGameFull()) {
            self.isStarted = true;
            self.lastNumber = self.runRandom();
            self.appendNumber(self.lastNumber);
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
        // if no winner, send remaining balance to the sender
        if (!self.fewWinners && self.winner == null) {
            send(SendParameters{
                to: sender(),
                value: 0,
                mode: SendRemainingBalance + SendIgnoreErrors,
                body: "No winner".asComment()
            });

            return;
        }

        // send remaining value to the sender
        self.sendRemainingValue(sender(), null);

        if (self.winner != null) {
            send(SendParameters{
                to: self.winner!!,
                value: 0,
                mode: SendRemainingBalance + SendIgnoreErrors,
                body: "Congrats, you are the winner!".asComment()
            });
        } else {
            // amount for transaction fee
            let safeAmount: Int = ton("0.025");
            let amount: Int = (myBalance() / self.playersCounter) - safeAmount;
            let players: map<Int as uint8, Address> = self.players;

            foreach (key, value in players) {
                send(SendParameters{
                    to: self.players.get(key)!!,
                    value: amount,
                    mode: SendIgnoreErrors,
                    body: "Money refund".asComment()
                });
            }
        }
    }

    fun appendPlayer(playerAddress: Address) {
        self.players.set(self.playersCounter, playerAddress);
        self.playersCounter += 1;
    }

    fun appendNumber(number: Int) {
        self.numbers.set(self.numbersCounter, number);
        self.numbersCounter += 1;
    }

    fun runRandom(): Int {
        nativeRandomize(abs(randomInt() - myBalance()) + now());
        nativeRandomizeLt();

        return random(1, 1000);
    }

    fun sendRemainingValue(address: Address, msg: String?) {
        if (msg == null) {
            msg = "Refund of the remaining value";
        }

        send(SendParameters{
            to: address,
            value: 0,
            mode: SendRemainingValue,
            body: msg!!.asComment()
        });
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

    get fun numbers(): map<Int as uint8, Int> {
        return self.numbers;
    }

    get fun context(): GameContext {
        return GameContext{
            parent: self.parent,
            seqno: self.seqno,
            isStarted: self.isStarted,
            isFinished: self.isFinished,
            playersCounter: self.playersCounter,
            maxPlayers: self.maxPlayers,
            lastNumber: self.lastNumber,
            winner: self.winner,
            fewWinners: self.fewWinners,
            isGameFull: self.isGameFull(),
            balance: myBalance()
        };
    }
}
