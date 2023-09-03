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
        deployPCoin = new DeployPCoin();
        pCoin = deployPCoin.run();

        vm.prank(msg.sender);
        pCoin.transfer(bob, STARTING_USER_BALANCE);
    }

    function testBobBalance() public {
        assertEq(STARTING_USER_BALANCE, pCoin.balanceOf(bob));
    }

    function testAllowancesWorks() public {
        uint256 initialAllowance = 1000;

        vm.prank(bob);
        pCoin.approve(alice, initialAllowance);

        uint256 transferAmount = 500;
        vm.prank(alice);
        pCoin.transferFrom(bob, alice, 500);

        assertEq(pCoin.balanceOf(alice), transferAmount);
        assertEq(pCoin.balanceOf(bob), STARTING_USER_BALANCE - transferAmount);
    }
}