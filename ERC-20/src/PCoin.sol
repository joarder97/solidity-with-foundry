// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract PCoin is ERC20 {
    constructor(uint256 initialSupply) ERC20 ("PCoin", "PCOIN") {
        _mint(msg.sender, initialSupply);
    }
}