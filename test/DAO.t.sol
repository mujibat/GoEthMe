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
        (Admin, _privKeyAd) = mkaddr("ADMIN");
        Token = new WildLifeGuardianToken(Admin, "token Uri");
        goethme = new GoEthMe();
        gofundmedao = new GofundmeDAO(address(goethme), Admin, address(Token));
        (_userA, _privKeyA) = mkaddr("USERA");
        (_userB, _privKeyB) = mkaddr("USERB");
        (_userC, _privKeyC) = mkaddr("USERC");
        (_userD, _privKeyD) = mkaddr("USERD");
    }

    function testCreateGofundme() public {
        vm.startPrank(_userA);
        gofundmedao.createGofundme("jjj", 5 ether, 86400, "http");
    }
    function testOnlyAdmin() public {
        vm.startPrank(_userA);
        vm.expectRevert(GofundmeDAO.OnlyAdmin.selector);
        gofundmedao.removeMember();
    }
    function testNotYetTime() public {
        vm.startPrank(_userA);
        gofundmedao.createGofundme("jjj", 5 ether, 86400, "http");
        vm.stopPrank();

        vm.startPrank(Admin);
        vm.expectRevert(GofundmeDAO.NotYetTime.selector);
        gofundmedao.removeMember();
    }
  function testCannotRemove() public {
       vm.startPrank(_userA);
        gofundmedao.createGofundme("jjj", 5 ether, 86400, "http");
        vm.stopPrank();
          vm.startPrank(Admin);
        // Token.safeMint(members);
        vm.warp(3245678900);
        vm.expectRevert("cannot remove");
        gofundmedao.removeMember();
        vm.stopPrank();
    }
  function testRemoveMember() public {
       vm.startPrank(_userA);
        gofundmedao.createGofundme("jjj", 5 ether, 86400, "http");
        vm.stopPrank();
         vm.startPrank(_userB);
        gofundmedao.createGofundme("jjj", 5 ether, 86400, "http");
        vm.stopPrank();
          vm.startPrank(Admin);
        Token.safeMint(members);
        vm.warp(31 days);
        gofundmedao.removeMember();
        vm.stopPrank();
  
  }  
  function testNotMember() public {
        vm.startPrank(_userA);
    gofundmedao.createGofundme("jjj", 5 ether, 86400, "http");
    vm.stopPrank();
    // Token.balanceOf(test1);
    vm.startPrank(test1);
    vm.expectRevert(GofundmeDAO.NotDAOMember.selector);
    gofundmedao.vote(1, vote_);

  }
  function testNotActive() public {
    vm.startPrank(Admin);
    Token.safeMint(members);
    vm.stopPrank();
    vm.startPrank(test1);
    vm.expectRevert(GofundmeDAO.NotActive.selector);
    gofundmedao.vote(1, vote_);
  }
  function testAlreadyVoted() public {
     vm.startPrank(_userA);
    gofundmedao.createGofundme("jjj", 5 ether, 86400, "http");
    vm.stopPrank();
      vm.startPrank(Admin);
    Token.safeMint(members);
    vm.stopPrank();
    vm.startPrank(test1);
    gofundmedao.vote(1, vote_);
    vm.expectRevert(GofundmeDAO.AlreadyVoted.selector);
     gofundmedao.vote(1, vote_);
  }

  function testVotingTimeElapsed() public {
     vm.startPrank(_userA);
    gofundmedao.createGofundme("jjj", 5 ether, 86400, "http");
    vm.stopPrank();
      vm.startPrank(Admin);
    Token.safeMint(members);
    vm.stopPrank();
    vm.startPrank(test1);
    vm.warp(2 days);
    vm.expectRevert(GofundmeDAO.VotingTimeElapsed.selector);
     gofundmedao.vote(1, vote_);
  }

  function testVote() public {
     vm.startPrank(_userA);
    gofundmedao.createGofundme("jjj", 5 ether, 86400, "http");
    vm.stopPrank();
      vm.startPrank(Admin);
    Token.safeMint(members);
    vm.stopPrank();
    vm.startPrank(test1);
     gofundmedao.vote(1, vote_);
     vm.stopPrank();
      vm.startPrank(test2);
     gofundmedao.vote(1, vote_);
     vm.stopPrank();
      vm.startPrank(test3);
     gofundmedao.vote(1, vote_);
     vm.stopPrank();
     vm.startPrank(test4);
     gofundmedao.vote(1, vote_);
     vm.stopPrank();
  }
  function testNotAdmin() public {
    vm.prank(_userB);
    vm.expectRevert(GofundmeDAO.NotAdmin.selector);
    gofundmedao.approveProposal(1);
  }

  function testVotingInProgress() public {
     vm.startPrank(_userA);
    gofundmedao.createGofundme("jjj", 5 ether, 86400, "http");
    vm.stopPrank();
    vm.prank(Admin);
    vm.expectRevert(GofundmeDAO.VotingInProgress.selector);
    gofundmedao.approveProposal(1);
  }
  function testApproveProposal() public {
     vm.startPrank(_userA);
    gofundmedao.createGofundme("jjj", 5 ether, 86400, "http");
    vm.stopPrank();
    vm.prank(Admin);
    Token.safeMint(members);
    vm.stopPrank();
     vm.startPrank(test1);
     gofundmedao.vote(1, vote_);
     vm.stopPrank();
      vm.startPrank(test2);
     gofundmedao.vote(1, vote_);
     vm.stopPrank();
      vm.startPrank(test3);
     gofundmedao.vote(1, vote_);
     vm.stopPrank();
     vm.prank(Admin);
    vm.warp(2 days);
    gofundmedao.approveProposal(1);
  }

}
