// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {LandRegistry} from "src/LandRegistry.sol";

contract DeployLandRegistry is Script {
    function run() external returns (LandRegistry) {
        vm.startBroadcast();
        LandRegistry landRegistry = new LandRegistry();
        vm.stopBroadcast();
        return landRegistry;
    }
}
