// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./Copy.sol";

struct PlayerMeta {
    uint256 rechargePrice;
    uint256 batteryLifeBlockHeight;
    uint256 copyTokenId;
    uint256 copyCount;
}

contract SnrsPlayer is ERC721 {
    address public CopyAddress;
    uint256 public CurrentPlayerCount;
    uint256 public BlockHeightPerRecharge;
    uint256 public MintPrice;
    mapping(uint256 => PlayerMeta) public TokenMeta;

    constructor() ERC721("SnrsPlayer", "SPL") {}

    function setMintPrice(uint256 price) public {
        MintPrice = price;
    }

    function mint(address to) public {
        _mint(to, CurrentPlayerCount);
        CurrentPlayerCount++;
        TokenMeta[CurrentPlayerCount].rechargePrice = 100000000;
        TokenMeta[CurrentPlayerCount].batteryLifeBlockHeight =
            block.number +
            BlockHeightPerRecharge;
    }

    function bindCopy(
        uint256 tokenId,
        uint256 copyTokenId,
        uint256 copyCount
    ) public {
        require(ownerOf(tokenId) == msg.sender, "Not owner");
        require(TokenMeta[tokenId].copyTokenId == 0, "Already binded");
        TokenMeta[tokenId].copyTokenId = copyTokenId;
        TokenMeta[tokenId].copyCount = copyCount;
        SnrsCopy c = SnrsCopy(CopyAddress);
        require(
            c.balanceOf(msg.sender, copyTokenId) >= copyCount,
            "Not enough copy"
        );
        c.safeTransferFrom(
            msg.sender,
            address(this),
            copyTokenId,
            copyCount,
            ""
        );
    }

    function unbindCopy(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "Not owner");
        require(TokenMeta[tokenId].copyTokenId != 0, "Not binded");
        require(TokenMeta[tokenId].copyCount != 0, "Not binded");
        SnrsCopy c = SnrsCopy(CopyAddress);
        c.safeTransferFrom(
            address(this),
            msg.sender,
            TokenMeta[tokenId].copyTokenId,
            TokenMeta[tokenId].copyCount,
            ""
        );
        TokenMeta[tokenId].copyTokenId = 0;
        TokenMeta[tokenId].copyCount = 0;
    }

    function recharge(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "Not owner");
        require(TokenMeta[tokenId].copyTokenId != 0, "Not binded");
        TokenMeta[tokenId].batteryLifeBlockHeight =
            block.number +
            BlockHeightPerRecharge;
    }
}
