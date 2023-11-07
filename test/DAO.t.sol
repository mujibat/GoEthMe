// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import "../src/DAO.sol";
import "../src/GoEthMe.sol";
import "../src/WildLifeGaurdian.sol";
import "./Helpers.sol";

contract DAOTest is Helpers {
    GofundmeDAO gofundmedao;
    GofundmeDAO.Votes vote_;
    GoEthMe goethme;
    WildLifeGuardianToken Token;
    GoFund fund;
    uint _time;
    address _userA;
    address _userB;
    address _userC;
    address _userD;

    address Admin;
    uint256 _privKeyAd;

    uint256 _privKeyA;
    uint256 _privKeyB;
    uint256 _privKeyC;
    uint256 _privKeyD;
    address test1 = makeAddr("test1");
    address test2 = makeAddr("test2");
    address test3 = makeAddr("test3");
    address test4 = makeAddr("test4");
    address test5 = makeAddr("test5");

    address[] members = [test1, test2, test3, test4];

    function setUp() public {
        (Admin, _privKeyAd) = mkaddr("Admin");
        console2.log(address(goethme));
        gofundmedao = new GofundmeDAO(Admin);
        Token = new WildLifeGuardianToken(Admin, "token Uri");
        (_userA, _privKeyA) = mkaddr("USERA");
        (_userB, _privKeyB) = mkaddr("USERB");
        (_userC, _privKeyC) = mkaddr("USERC");
        (_userD, _privKeyD) = mkaddr("USERD");
    }

    function testCreateGofundme() public {
        vm.startPrank(_userA);
        gofundmedao.createGofundme("jjj", 5 ether, 86400, "http");
    }

    // function testOnlyAdmin() public {
    //     vm.startPrank(_userA);
    //     vm.expectRevert(GofundmeDAO.OnlyAdmin.selector);
    // }

    // function testNotYetTime() public {
    //     vm.startPrank(_userA);
    //     gofundmedao.createGofundme("jjj", 5 ether, 86400, "http");
    //     vm.stopPrank();

    //     vm.startPrank(Admin);
    //     vm.expectRevert(GofundmeDAO.NotYetTime.selector);
    // }

    // function testRemoveMember() public {
    //     vm.startPrank(Admin);
    //     Token.safeMint(members);
    //     vm.stopPrank();

    //     vm.startPrank(_userA);
    //     gofundmedao.createGofundme("jjj", 5 ether, 86400, "http");
    //     vm.stopPrank();

    //     vm.startPrank(Admin);
    //     vm.warp(31 days);
    //     assertEq(Token.balanceOf(test3), 0);
    // }

    function testNotMember() public {
        vm.startPrank(_userA);
        gofundmedao.createGofundme("jjj", 5 ether, 86400, "http");
        vm.stopPrank();
        vm.startPrank(Admin);
        vm.expectRevert(GofundmeDAO.NotMember.selector);
        gofundmedao.vote(1, vote_);
    }
}
