// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/DAO.sol";

contract GofundmeDAOScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        GofundmeDAO dao = new GofundmeDAO(
            0x0E88826015c8EE5A8551c1B3725affBd544F1712,
            0x8A91F5D0FaC39AB37c4E281a498eb68eA24ae078,
            0xE11FfA003Ad8F330d7F09A1cFf8b4F289979f171
        );

        vm.stopBroadcast();
    }
}

// DAO CONTRACT: 0xdb942f2ea6492757739d70aacd31ecd9476448fe
