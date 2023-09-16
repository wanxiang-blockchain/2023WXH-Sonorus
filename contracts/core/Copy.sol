// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./Rs.sol";

contract SnrsCopy is ERC1155 {
    address public rs;

    uint256 public CurrentCount;
    mapping(uint256 => uint256) public TokenCount;
    mapping(uint256 => uint256) public TokenInitPrice;

    constructor(string memory uri_) ERC1155(uri_) {
    }

    function mint(uint256 tokenId, uint256 initprice) public {
        TokenInitPrice[tokenId] = initprice;
        _mint(msg.sender, tokenId, 1, "");
    }

    function buy(uint256 tokenId, uint256 payamount) public {
        SnrsRs _rs = SnrsRs(rs);
        require(_rs.balanceOf(msg.sender) >= payamount, "Not enough money");
        require(_rs.allowance(msg.sender, address(this)) >= payamount, "Not enough money");

        uint256 current = TokenCount[tokenId];
        uint256 price = TokenInitPrice[tokenId] + (current + 1) * 20;
        require(payamount >= price, "Not enough money");
        _rs.burn(msg.sender, payamount);

        _mint(msg.sender, tokenId, 1, "");
        TokenCount[tokenId] = current + 1;
    }

    function setRs(address _rs) public {
        rs = _rs;
    }
}
