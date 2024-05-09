import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { Address, Dictionary, toNano } from '@ton/core';
import { GameManager } from '../wrappers/GameManager';
import '@ton/test-utils';
import { Game } from '../wrappers/Game';

describe('GameManager', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let gameManager: SandboxContract<GameManager>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();
    
        gameManager = blockchain.openContract(await GameManager.fromInit(1n));

        deployer = await blockchain.treasury('deployer');

        const deployResult = await gameManager.send(
            deployer.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            }
        );

        expect(deployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: gameManager.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and gameManager are ready to use
    });

    it("should create new game", async()=>{
        
        const firstPlayer = await blockchain.treasury('firstPlayer');
        const secondPlayer = await blockchain.treasury('secondPlayer');

        console.log('first address - ', firstPlayer.address);
        console.log('second address - ', secondPlayer.address);

        console.log('first balance start - ', await firstPlayer.getBalance());
        console.log('second balance start - ', await secondPlayer.getBalance());

        console.log('GAME_MANAGER balance start - ', await gameManager.getBalance());

        await gameManager.send(firstPlayer.getSender(), {
            value: toNano("1")
        }, 'CreateNewGame');

        console.log('first balance after 1st trans - ', await firstPlayer.getBalance());
        console.log('second balance after 1st trans - ', await secondPlayer.getBalance());

        console.log('GAME_MANAGER balance after 1st trans - ', await gameManager.getBalance());

        let seqno = await gameManager.getNumGames();
        // console.log('number of games - ', seqno);
        // console.log('game manager balance - ', await gameManager.getBalance());

        const gameAddress = await gameManager.getGameAddress(seqno);

        // console.log('game address - ', gameAddress);

        const game: SandboxContract<Game> = blockchain.openContract(Game.fromAddress(gameAddress!));

        // console.log('game balance - ', await game.getBalance());
        // console.log('number of game players - ', await game.getPlayersCounter());
        // console.log('last random number - ', await game.getLastNumber());
        // console.log('is game full? - ', await game.getGameIsFull());
        // console.log('max players - ', await game.getMaxPlayers());
        // console.log('is started? - ', await game.getIsStarted());
        // console.log('is finished? - ', await game.getIsFinished());

        await game.send(secondPlayer.getSender(), {
            value: toNano("1")
        }, "AddNewPlayer");

        // console.log('2nd player created');

        // console.log('game balance - ', await game.getBalance());
        // console.log('number of game players - ', await game.getPlayersCounter());
        // console.log('last random number - ', await game.getLastNumber());
        // console.log('is game full? - ', await game.getGameIsFull());
        // console.log('max players - ', await game.getMaxPlayers());
        // console.log('is started? - ', await game.getIsStarted());
        // console.log('is finished? - ', await game.getIsFinished());
        // console.log('players - ', (await game.getPlayers()));

        // set results to dictionary (temporary commented)
        // const dict = Dictionary.empty(Dictionary.Keys.Address(), Dictionary.Values.Bool());
        // dict.set(firstPlayer.getSender().address, true);
        // dict.set(secondPlayer.getSender().address, false);

        const dict = Dictionary.empty(Dictionary.Keys.BigInt(32), Dictionary.Values.Bool());
        dict.set(0n, true);
        dict.set(1n, true);

        console.log('first balance before results - ', await firstPlayer.getBalance());
        console.log('second balance before results - ', await secondPlayer.getBalance());

        console.log('GAME balance before results - ', await game.getBalance());

        console.log('deployer balance before results - ', await deployer.getBalance());

        console.log('GAME last number - ', await game.getLastNumber());

        // need to solve problem with sender
        let result = await game.send(deployer.getSender(), {
            value: toNano("0.05")
        }, {
            $$type: 'GenerateNumberSimple',
            results: dict,
        });

        console.log('GAME new last number - ', await game.getLastNumber());

        console.log('deployer balance after results - ', await deployer.getBalance());

        console.log('winner address - ', await game.getWinner());

        console.log('first balance after results - ', await firstPlayer.getBalance());
        console.log('second balance after results - ', await secondPlayer.getBalance());

        console.log('GAME balance after results - ', await game.getBalance());

        console.log('result - ', result.events);
    })
});
