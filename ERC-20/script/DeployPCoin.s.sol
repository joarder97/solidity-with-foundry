// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {PCoin} from "../src/PCoin.sol";

contract DeployPCoin is Script {
    uint256 public constant INITIAL_SUPPLY = 1000 ether;

    function run() external returns(PCoin) {
        vm.startBroadcast();
        PCoin pc = new PCoin(INITIAL_SUPPLY);
        vm.stopBroadcast();
        return pc;
    }
}