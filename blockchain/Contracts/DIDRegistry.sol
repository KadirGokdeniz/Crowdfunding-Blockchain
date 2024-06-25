// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DIDRegistry {
    mapping(address => string) public dids;

    event DIDRegistered(address indexed user, string did);

    function registerDID(string calldata did) external {
        dids[msg.sender] = did;
        emit DIDRegistered(msg.sender, did);
    }

    function getDID(address user) external view returns (string memory) {
        return dids[user];
    }
}