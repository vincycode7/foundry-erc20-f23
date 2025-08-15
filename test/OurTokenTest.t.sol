// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";
import {Test} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract OurTokenTest is StdCheats, Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address public owner;
    address public bob = makeAddr("bob");
    address public alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();
        owner = address(this); // Test contract is the deployer/owner

        // Give some tokens to bob for testing transfers
        vm.prank(owner);
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function testInitialSupply() public view {
        assertEq(ourToken.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(ourToken)).mint(address(this), 1);
    }

    function testTransferSuccess() public {
        uint256 transferAmount = 10 ether;

        vm.prank(bob);
        ourToken.transfer(alice, transferAmount);

        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function testTransferFailsIfInsufficientBalance() public {
        vm.prank(alice); // Alice has 0 tokens
        vm.expectRevert();
        ourToken.transfer(bob, 1 ether);
    }

    function testApproveAndTransferFrom() public {
        uint256 amount = 50 ether;

        vm.prank(bob);
        ourToken.approve(alice, amount);

        // Alice transfers on behalf of Bob
        vm.prank(alice);
        ourToken.transferFrom(bob, alice, amount);

        assertEq(ourToken.balanceOf(alice), amount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - amount);
        assertEq(ourToken.allowance(bob, alice), 0); // Spent all allowance
    }

    function testTransferFromFailsWithoutApproval() public {
        vm.prank(alice);
        vm.expectRevert();
        ourToken.transferFrom(bob, alice, 1 ether);
    }

    function testApproveEventEmitted() public {
        vm.expectEmit(true, true, false, true);
        emit Approval(bob, alice, 100 ether);

        vm.prank(bob);
        ourToken.approve(alice, 100 ether);
    }

    function testTransferEventEmitted() public {
        uint256 amount = 1 ether;

        vm.expectEmit(true, true, false, true);
        emit Transfer(bob, alice, amount);

        vm.prank(bob);
        ourToken.transfer(alice, amount);
    }

    // Event declarations needed for expectEmit
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
