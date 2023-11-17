// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/DAO.sol";

contract GofundmeDAOScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        GofundmeDAO dao = new GofundmeDAO(
            0x8112bb06138Be983465c4100ea3c358Df18B6f1a,
            0x8A91F5D0FaC39AB37c4E281a498eb68eA24ae078,
            0xEF301a98bef1f93C4D2F03122b59410f7a72eF3e
        );

        vm.stopBroadcast();
    }
}

// DAO CONTRACT WITHOUT VOTE TIMER: 0xff29e9DB150B2aBe5E2939fb4E92C343b7eD2761
// DAO CONTRACT WITH VOTE TIMER: 0x464Ec2B6ec0c5C55Cbbb56C24F81A5A8fc7122AD
