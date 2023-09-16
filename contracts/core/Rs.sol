// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SnrsRs is ERC20 {
    address public protocolAddress;

    constructor() ERC20("SnrsRs", "SRS") {
        _mint(msg.sender, 1000000000000000000000000000);
    }

    modifier onlyProtocol() {
        require(msg.sender == protocolAddress, "Not protocol");
        _;
    }

    function mint(address to, uint256 amount) onlyProtocol public {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public {
        _burn(from, amount);
    }
}
