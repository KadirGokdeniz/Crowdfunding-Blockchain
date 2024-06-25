// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SupplierManager {
    struct Supplier {
        uint reputation;
        bool exists;
        bool isCandidate;
        bool votingStarted;
        bool voted;
    }

    mapping(address => mapping(uint => Supplier)) public suppliers;

    function registerSupplier(uint campaignId, address supplierAddr, uint reputation) external {
        Supplier storage supplier = suppliers[supplierAddr][campaignId];
        supplier.reputation = reputation;
        supplier.exists = true;
        if (reputation < 20 ) {
            supplier.isCandidate = true;
            supplier.votingStarted = true;
        } else {
            supplier.isCandidate = false;
            supplier.votingStarted = false;
        }
    }

    function updateVote(uint campaignId, address supplierAddr) external {
        Supplier storage supplier = suppliers[supplierAddr][campaignId];
        require(supplier.votingStarted, "Voting process for this supplier has not started yet.");
        supplier.voted=true;
    }

    function getSupplier(uint campaignId, address supplierAddr) external view returns (Supplier memory) {
        return suppliers[supplierAddr][campaignId];
    }

    function confirmSupplier(uint campaignId, address supplierAddr) external {
        Supplier storage supplier = suppliers[supplierAddr][campaignId];
        supplier.isCandidate=false;
    }

    function incrementReputationSupplier(uint campaignId,address supplierAddr, uint reputation) external{
        Supplier storage supplier = suppliers[supplierAddr][campaignId];
        supplier.reputation+=reputation;
    }
}
