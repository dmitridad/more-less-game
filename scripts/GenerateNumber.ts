import { Address, Dictionary, toNano } from '@ton/core';
import { Game } from '../wrappers/Game';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const gameAddress = Address.parse("EQAUcSyIJul_DyirgneXAyeeNopnVsCGsfdWoEledZ9Hnyic")
    const game = provider.open(Game.fromAddress(gameAddress));

    // set results to dictionary
    const dict = Dictionary.empty(Dictionary.Keys.BigInt(32), Dictionary.Values.Bool());
    dict.set(0n, false);
    dict.set(1n, false);

    // await game.send(
    //     provider.sender(),
    //     {
    //         value: toNano('0.05'),
    //     },
    //     {
    //         $$type: 'GenerateNumberSimple',
    //         results: dict,
    //     }
    // );

    // console.log("is game started - ", await game.getIsStarted());
    // console.log("players number - ", await game.getPlayersCounter());

    // let result = await game.send(
    //     provider.sender(),
    //     {
    //         value: toNano('0.02'),
    //     },
    //     {
    //         $$type: 'AddNewPlayer',
    //         player: provider.sender().address!!
    //     }
    // );

    console.log("is game started - ", await game.getIsStarted());
    console.log("game finished - ", await game.getIsFinished());
    console.log("players number - ", await game.getPlayersCounter());
    console.log("last number - ", await game.getLastNumber());
    console.log("winner - ", await game.getWinner());
}
