// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./Rs.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract SnrsProtocol {
    address public RsAddress;
    uint256 public RankCalculationBlockHeightInterval;
    mapping(uint256 => bytes32) public RankMerkleRoots;

    constructor() {}

    function setRsAddress(address addr) public {
        RsAddress = addr;
    }

    function setRankCalculationBlockHeightInterval(uint256 interval) public {
        RankCalculationBlockHeightInterval = interval;
    }

    function setRankMerkleRoot(
        uint256 blockHeight,
        bytes32 root
    ) public {
        RankMerkleRoots[blockHeight] = root;
    }

    function verifyProof(
        bytes32 root,
        bytes32[] memory proof,
        address addr,
        uint256 amount
    ) internal pure returns (bool) {
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(addr, amount)))
        );
        return MerkleProof.verify(proof, root, leaf);
    }

    function redeemReward(
        uint256 blockHeight,
        bytes32[] memory proof,
        uint256 amount
    ) public {
        bytes32 root = RankMerkleRoots[blockHeight];
        require(
            verifyProof(
                root,
                proof,
                msg.sender,
                amount
            ),
            "Invalid proof"
        );
        SnrsRs rs = SnrsRs(RsAddress);
        rs.mint(msg.sender, amount);
    }
}
