// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {PCoin} from "../src/PCoin.sol";
import {DeployPCoin} from "../script/DeployPCoin.s.sol";

contract PCoinTest is Test {
    PCoin public pCoin;
    DeployPCoin public deployPCoin;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_USER_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployPCoin();
        pCoin = deployer.run();

        vm.prank(address(deployer));
        pCoin.transfer(bob, STARTING_USER_BALANCE);
    }

    function testBobBalance() public {
        assert(STARTING_USER_BALANCE, pCoin.balanceOf(bob));
    }
}