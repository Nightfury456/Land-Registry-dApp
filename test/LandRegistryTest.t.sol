// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {LandRegistry} from "src/LandRegistry.sol";
import {DeployLandRegistry} from "script/DeployLandRegistry.s.sol";

contract LandRegistryTest is Test {
    DeployLandRegistry public deployer;
    LandRegistry public landRegistry;

    function setUp() public {
        deployer = new DeployLandRegistry();
        landRegistry = deployer.run();
    }

    function testRevertWithZeroSize() public {
        string memory location = "Test Location";
        uint256 size = 0;
        address owner = address(this);

        vm.expectRevert(abi.encodeWithSelector(LandRegistry.zeroSize.selector, size));
        landRegistry.registerLand(location, size, owner);
    }

    function testLandRegistration() public {
        string memory location = "Test Location";
        uint256 size = 100;
        address owner = address(this);

        landRegistry.registerLand(location, size, owner);

        LandRegistry.Land memory registeredLand = landRegistry.getLand(0);
        assertEq(registeredLand.id, 0);
        assertEq(registeredLand.location, location);
        assertEq(registeredLand.size, size);
        assertEq(registeredLand.owner, owner);
    }

    function testLandIdIncrement() public {
        string memory location1 = "Location 1";
        uint256 size1 = 100;
        address owner1 = address(this);

        landRegistry.registerLand(location1, size1, owner1);

        string memory location2 = "Location 2";
        uint256 size2 = 200;
        address owner2 = address(this);

        landRegistry.registerLand(location2, size2, owner2);

        LandRegistry.Land memory land1 = landRegistry.getLand(0);
        LandRegistry.Land memory land2 = landRegistry.getLand(1);

        assertEq(land1.id, 0);
        assertEq(land2.id, 1);
    }

    function testRevertWhenNotOwner() public {
        string memory location = "Test Location";
        uint256 size = 100;
        address owner = address(this);
        address nonOwner = address(1);

        landRegistry.registerLand(location, size, owner);

        vm.expectRevert(abi.encodeWithSelector(LandRegistry.notOwner.selector, 0, nonOwner));
        vm.prank(nonOwner);
        landRegistry.transferLand(0, address(2));
    }

    function testRevertWhenLandDoesNotExist() public {
        uint256 landId = landRegistry.nextLandId();
        address owner = address(this);
        vm.expectRevert(abi.encodeWithSelector(LandRegistry.landDoesNotExist.selector, landId));
        vm.prank(owner);
        landRegistry.transferLand(landId, address(1));
    }

    function testRevertWithZeroNewOwner() public {
        string memory location = "Test Location";
        uint256 size = 100;
        address owner = address(this);

        landRegistry.registerLand(location, size, owner);

        vm.expectRevert(LandRegistry.zeroAddress.selector);
        vm.prank(owner);
        landRegistry.transferLand(0, address(0));
    }

    function testTransferLand() public {
        string memory location = "Test Location";
        uint256 size = 100;
        address curentOwner = address(this);
        address newOwner = address(1);

        landRegistry.registerLand(location, size, curentOwner);

        vm.prank(curentOwner);
        landRegistry.transferLand(0, newOwner);

        LandRegistry.Land memory transferredLand = landRegistry.getLand(0);
        assertEq(transferredLand.owner, newOwner);
    }
}
