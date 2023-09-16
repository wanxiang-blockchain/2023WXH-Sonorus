import { ethers } from "hardhat";
import { SnrsPlayer, SnrsProtocol } from "../typechain-types";
import { StandardMerkleTree } from "@openzeppelin/merkle-tree";

async function main() {

  // set archive mode for all eth_call
  // custom height for validation
  const blockHeight = await ethers.provider.getBlockNumber();
  const targetBlockHeight = blockHeight + 10;

  const SProtocol = (await ethers.getContractFactory("SProtocol")).attach("xxx") as SnrsProtocol;
  const PlayerF = (await ethers.getContractFactory("SnrsPlayer")).attach("xxx") as SnrsPlayer;

  const playerCount = await PlayerF.CurrentPlayerCount();

  const playerArray = [] as Array<any>;
  const copyMap = {} as Record<string, number>;
  for (let i = 0; i < playerCount; i++) {
    const playerMeta = await PlayerF.TokenMeta(i);
    if (playerMeta.batteryLifeBlockHeight > targetBlockHeight && playerMeta.copyCount > 0) {
      playerArray.push(playerMeta);
      copyMap[playerMeta.copyTokenId.toString()] = (copyMap[playerMeta.copyTokenId.toString()] || 0) + Number(playerMeta.copyCount);
    }
  }
  const playerRewards = {} as Record<string, number>;
  const copyRewards = Object.entries(copyMap).sort((a, b) => b[1] - a[1]).map((e, i) => {
    if (i / Object.keys(copyMap).length < 0.5) {
      return [e[0], 2];
    } else if (i / Object.keys(copyMap).length < 0.8) {
      return [e[0], 1.5];
    } else {
      return [e[0], 1];
    }
  }).reduce((acc, cur) => {
    acc[cur[0] as number] = cur[1] as number;
    return acc;
  }, {} as Record<number, number>);

  for (const player of playerArray) {
    playerRewards[player.playerTokenId.toString()] = copyRewards[player.copyTokenId.toString()] || 0;
  }
  const values = {} as Record<string, number>;

  Object.entries(playerRewards).forEach(async ( cur) => {
    const [playerTokenId, reward] = cur;
    const add =  await PlayerF.ownerOf(playerTokenId)
    values[add] = (values[add] || 0) + reward;
  })
  
  // [
  //   ["0x1111111111111111111111111111111111111111", "5000000000000000000"],
  //   ["0x2222222222222222222222222222222222222222", "2500000000000000000"]
  // ];
  
  // (2)
  const tree = StandardMerkleTree.of(Object.entries(values), ["address", "uint256"]);

  SProtocol.setRankMerkleRoot(blockHeight ,tree.root);

}
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
