// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol"; 

contract HelperConfig {
    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if(block.chainid == 1) {
            activeNetworkConfig = getMainnetEthonfig();
        } else {
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig(
            {
                priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
            }
        );
        return sepoliaConfig;
    }

    function getAnvilEthConfig() public pure returns (NetworkConfig memory) {
        
    }

    function getMainnetEthonfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ethConfig = NetworkConfig(
            {
                priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
            }
        );
        return ethConfig;
    }
}