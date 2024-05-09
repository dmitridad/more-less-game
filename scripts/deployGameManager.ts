import { toNano } from '@ton/core';
import { GameManager } from '../wrappers/GameManager';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const gameManager = provider.open(await GameManager.fromInit(1n));

    // await gameManager.send(
    //     provider.sender(),
    //     {
    //         value: toNano('0.05'),
    //     },
    //     {
    //         $$type: 'Deploy',
    //         queryId: 0n,
    //     }
    // );

    // await provider.waitForDeploy(gameManager.address);

    let seqno = await gameManager.getNumGames();
    console.log("contract address - ", gameManager.address);
    console.log("contract balance - ", await gameManager.getBalance());
    console.log("contract num games - ", seqno);
    console.log("contract owner - ", await gameManager.getOwner());
    console.log("gameAddress - ", await gameManager.getGameAddress(seqno));
}
