// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

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

    error NotOwner(uint256 landId, address caller);


    modifier onlyOwner(uint256 _landId) {
        if (lands[_landId].owner == msg.sender) {
            revert NotOwner(_landId, msg.sender);
        }
        _;
    }

    function registerLand(string memory _location, uint256 _size) public {
        require(_size > 0, "Size must be greater than zero");
        
        lands[nextLandId] = Land(nextLandId, _location, _size, msg.sender);
        emit LandRegistered(nextLandId, _location, _size, msg.sender);
        
        nextLandId++;
    }

    function transferLand(uint256 _landId, address _newOwner) public onlyOwner(_landId) {
        require(_landId < nextLandId, "Land does not exist");
        require(_newOwner != address(0), "New owner cannot be the zero address");

        address previousOwner = lands[_landId].owner;
        lands[_landId].owner = _newOwner;

        emit LandTransferred(_landId, previousOwner, _newOwner);
    }
}