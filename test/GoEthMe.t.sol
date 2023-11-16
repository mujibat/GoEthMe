//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import "../src/GoEthMe.sol";
import "./Helpers.sol";

contract GoEthMeTest is Helpers {
    GoEthMe goeth;
    GoFund gofund;

    address _userA;
    address _userB;

    uint256 _privKeyA;
    uint256 _privKeyB;

    function setUp() public {
        goeth = new GoEthMe();
        (_userA, _privKeyA) = mkaddr("USERA");
        (_userB, _privKeyB) = mkaddr("USERB");
    }

    function testCreateGofundme() public {
        vm.startPrank(_userA);
        goeth.createGofundme(
            _userA,
            "Wildlife",
            "something",
            "anystring",
            5 ether,
            1 hours
        );
        assertEq(goeth.getfunder(1).owner, _userA);
        assertEq(goeth.getfunder(1).title, "Wildlife");
        assertEq(goeth.getfunder(1).tokenUri, "anystring");
        assertEq(goeth.getfunder(1).fundingGoal, 5 ether);
        assertEq(goeth.getfunder(1).durationTime, 1 hours + block.timestamp);
    }

    function testInputAmount() public {
        vm.startPrank(_userA);
        vm.expectRevert(GoEthMe.InsufficientInput.selector);
        uint _ID = 1;
        goeth.contributeEth{value: 0 ether}(_ID);
        vm.stopPrank();
    }

    function testNotActive() public {
        uint _ID = 1;
        vm.expectRevert(GoEthMe.NotActive.selector);
        goeth.contributeEth{value: 4 ether}(_ID);
    }

    function testExceededFundingGoal() public {
        uint _ID = 1;
        goeth.createGofundme(
            _userA,
            "Wildlife",
            "something",
            "anystring",
            5 ether,
            1 hours
        );
        vm.expectRevert(GoEthMe.ExceededFundingGoal.selector);
        goeth.contributeEth{value: 7 ether}(_ID);
    }

    function testNotInDuration() public {
        uint _ID = 1;
        goeth.createGofundme(
            _userA,
            "Wildlife",
            "something",
            "anystring",
            5 ether,
            block.timestamp + 1 hours
        );
        vm.warp(2 hours);
        vm.expectRevert(GoEthMe.NotInDuration.selector);
        goeth.contributeEth{value: 1 ether}(_ID);
    }

    function testContributeEth() public {
        vm.startPrank(_userB);
        vm.deal(_userB, 3 ether);
        uint _ID = 1;
        goeth.createGofundme(
            _userA,
            "Wildlife",
            "something",
            "anystring",
            5 ether,
            block.timestamp + 1 hours
        );
        goeth.contributeEth{value: 2 ether}(_ID);
    }

    function testNotActiveFunds() public {
        uint id = 1;
        vm.expectRevert(GoEthMe.NotActiveCause.selector);
        goeth.getContributedFunds(id);
    }

    function testNotOwner() public {
        uint id = 1;
        vm.prank(_userA);
        goeth.createGofundme(
            _userA,
            "Wildlife",
            "something",
            "anystring",
            5 ether,
            block.timestamp + 1 hours
        );
        vm.startPrank(_userB);
        vm.expectRevert(GoEthMe.NotOwner.selector);
        goeth.getContributedFunds(id);
    }

    function testTimeNotReached() public {
        vm.startPrank(_userA);
        uint id = 1;
        goeth.createGofundme(
            _userA,
            "Wildlife",
            "something",
            "anystring",
            5 ether,
            12 hours
        );
        vm.expectRevert(GoEthMe.TimeNotReached.selector);
        goeth.getContributedFunds(id);
    }

    function testGetContributedFunds() public {
        vm.startPrank(_userA);
        goeth.createGofundme(
            _userA,
            "Wildlife",
            "something",
            "anystring",
            5 ether,
            1 hours
        );
        uint id = 1;
        vm.stopPrank();
        vm.startPrank(_userB);
        vm.deal(_userB, 5 ether);
        goeth.contributeEth{value: 4 ether}(id);
        vm.stopPrank();
        vm.startPrank(_userA);
        vm.warp(2 hours);
        assertEq(goeth.getfunder(1).fundingBalance, 4 ether);
        goeth.getContributedFunds(id);
    }

    function testGetContributors() public {
        vm.startPrank(_userA);
        goeth.createGofundme(
            _userA,
            "Wildlife",
            "something",
            "anystring",
            5 ether,
            1 hours
        );
        vm.stopPrank();
        uint id = 1;
        hoax(_userB, 2 ether);
        goeth.contributeEth{value: 1 ether}(id);
        goeth.getContributors(1);
    }
}
