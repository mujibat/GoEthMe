// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/GoEthMe.sol";

contract GoEthMeScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        GoEthMe fund = new GoEthMe();

        vm.stopBroadcast();
    }
}

// GOETHME CONTRACT: 0x8112bb06138Be983465c4100ea3c358Df18B6f1a
