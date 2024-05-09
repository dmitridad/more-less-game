import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { Game } from '../wrappers/Game';
import '@ton/test-utils';

describe('Game', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let game: SandboxContract<Game>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        deployer = await blockchain.treasury('deployer');

        game = blockchain.openContract(await Game.fromInit(deployer.address, 1n, 2n));

        const deployResult = await game.send(
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
            to: game.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and game are ready to use
    });
});
