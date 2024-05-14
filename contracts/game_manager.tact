import "@stdlib/deploy";
import "@stdlib/ownable";
import "./messages";
import "./structs";
import "./game";

contract GameManager with Deployable, Ownable {

    version: Int as uint8;
    owner: Address;
    numGames: Int as uint256 = 0;
    maxPlayers: Int as uint8 = 2;

    init(version: Int) {
        self.version = version;
        self.owner = sender();
    }

    receive("CreateNewGame") {
        self.numGames += 1;
        let init: StateInit = initOf Game(myAddress(), self.numGames, self.maxPlayers);

        // TODO: maybe we need to save some balance for the manager contract
        send(SendParameters{
            to: contractAddress(init),
            body: AddNewPlayer{player: sender()}.toCell(),
            value: 0,
            mode: SendRemainingValue + SendIgnoreErrors,
            code: init.code,
            data: init.data
        });

        self.reply(NewGameResponse{seqno: self.numGames}.toCell());
    }

    get fun numGames(): Int {
        return self.numGames;
    }

    get fun gameAddress(seqno: Int): Address?{
        if (seqno != 0) {
            return contractAddress(initOf Game(myAddress(), seqno, self.maxPlayers));
        }
        
        return null;
    }

    get fun balance(): Int {
        return myBalance();
    }

    get fun context(): GameManagerContext {
        return GameManagerContext{
            version: self.version,
            owner: self.owner,
            numGames: self.numGames,
            maxPlayers: self.maxPlayers,
            balance: myBalance()
        };
    }

    // TODO: add receive to upgrade maxPlayers
}
