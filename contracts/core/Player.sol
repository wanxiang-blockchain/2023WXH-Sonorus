// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

struct PlayerMeta {
    uint256 rechargePrice;
    uint256 batteryLifeBlockHeight;
    uint256 copyTokenId;
    uint256 copyCount;
}

contract SnrsPlayer is ERC721 {

    uint256 public BlockHeightPerRecharge;
    uint256 public MintPrice;
    mapping(uint256 => PlayerMeta) TokenMeta;

    constructor() ERC721("SnrsPlayer", "SPL") {}

    function setMintPrice(uint256 price) public {
        MintPrice = price;
    }

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }

    function bindCopy(uint256 tokenId, uint256 copyTokenId) public {
        require(ownerOf(tokenId) == msg.sender, "Not owner");
        require(TokenMeta[tokenId].copyTokenId == 0, "Already binded");
        TokenMeta[tokenId].copyTokenId = copyTokenId;
    }

    function unbindCopy(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "Not owner");
        require(TokenMeta[tokenId].copyTokenId != 0, "Not binded");
        TokenMeta[tokenId].copyTokenId = 0;
    }

    function recharge(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "Not owner");
        require(TokenMeta[tokenId].copyTokenId != 0, "Not binded");
        TokenMeta[tokenId].batteryLifeBlockHeight = block.number + BlockHeightPerRecharge;
    }
}
