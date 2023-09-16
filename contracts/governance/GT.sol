// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract GT is ERC20 {
   constructor() ERC20("GT", "GT") {
       _mint(msg.sender, 1000000000000000000000000000);
   }
}
