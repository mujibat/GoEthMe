// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/WildLifeGaurdian.sol";

contract WildLifeGuardianTokenScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        WildLifeGuardianToken Token = new WildLifeGuardianToken(
            0x8A91F5D0FaC39AB37c4E281a498eb68eA24ae078,
            "ipfs://QmfToDCX5to1KqEuKJczvqFQ8qwe4XniN5qT3vcsUbVP9M"
        );

        vm.stopBroadcast();
    }
}

// ADMIN: 0x8A91F5D0FaC39AB37c4E281a498eb68eA24ae078
// WILDLIFE CONTRACT: 0xEF301a98bef1f93C4D2F03122b59410f7a72eF3e
