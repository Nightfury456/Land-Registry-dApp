// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract LandRegistry {
    struct Land {
        uint256 id;
        string location;
        uint256 size; // in square meters
        address owner;
    }

    mapping(uint256 => Land) public lands;
    uint256 public nextLandId;

    event LandRegistered(uint256 indexed landId, string location, uint256 size, address indexed owner);
    event LandTransferred(uint256 indexed landId, address indexed from, address indexed to);

    error notOwner(uint256 landId, address caller);
    error landDoesNotExist(uint256 landId);
    error zeroSize(uint256 size);
    error zeroAddress();

    modifier currentOwner(uint256 _landId) {
        if (lands[_landId].owner != msg.sender) {
            revert notOwner(_landId, msg.sender);
        }
        _;
    }

    modifier onlyExistingLand(uint256 _landId) {
        if (_landId >= nextLandId) {
            revert landDoesNotExist(_landId);
        }
        _;
    }

    function registerLand(string memory _location, uint256 _size, address _owner) external {
        if (_size <= 0) {
            revert zeroSize(_size);
        }

        lands[nextLandId] = Land(nextLandId, _location, _size, _owner);
        emit LandRegistered(nextLandId, _location, _size, msg.sender);

        nextLandId++;
    }

    function transferLand(uint256 _landId, address _newOwner) public onlyExistingLand(_landId) currentOwner(_landId) {
        if (_newOwner == address(0)) {
            revert zeroAddress();
        }

        address previousOwner = lands[_landId].owner;
        lands[_landId].owner = _newOwner;

        emit LandTransferred(_landId, previousOwner, _newOwner);
    }

    /////////////////////
    // getter function //
    /////////////////////

    function getLand(uint256 _landId) external view onlyExistingLand(_landId) returns (Land memory) {
        return lands[_landId];
    }
}
