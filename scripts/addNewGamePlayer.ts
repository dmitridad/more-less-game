import { Address, toNano } from '@ton/core';
import { Game } from '../wrappers/Game';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const gameAddress = Address.parse("EQAUcSyIJul_DyirgneXAyeeNopnVsCGsfdWoEledZ9Hnyic")
    const game = provider.open(Game.fromAddress(gameAddress));

    // let result = await game.send(
    //     provider.sender(),
    //     {
    //         value: toNano('0.05'),
    //     },
    //     "AddNewPlayer"
    // );

    console.log('players counter - ', await game.getPlayersCounter());
    console.log('is game started - ', await game.getIsStarted());
    console.log('random number - ', await game.getLastNumber());
}
