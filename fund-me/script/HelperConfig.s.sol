// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol"; 

contract HelperConfig {
    NetworkConfig public acticeNetworkConfig;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    function getSepoliaEthonfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = Netwokonfig(
            {
                priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
            }
        );
        return sepoliaConfig;
    }

    function getAnvilEthConfig() public pure {

    }
}