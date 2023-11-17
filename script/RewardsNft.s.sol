// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/RewardsNft.sol";

contract RewardsNftScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        RewardsNft NFT = new RewardsNft("REWARDS", "DRT");

        vm.stopBroadcast();
    }
}

// DAO CONTRACT: 0xdb942f2ea6492757739d70aacd31ecd9476448fe
