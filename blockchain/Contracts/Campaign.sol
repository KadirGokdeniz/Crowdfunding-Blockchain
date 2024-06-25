// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SupplierManager.sol";

contract Campaign {
    address public organizer;
    uint public goalAmount;
    uint public raisedAmount;
    uint public deadline;
    bool public completed;
    mapping(address => uint) public contributions;
    address[] public suppliers;
    address[] public transactions;
    address[] public contributors;

    SupplierManager public supplierManager;

    constructor(address _organizer, uint _goalAmount, uint _duration) {
        organizer = _organizer;
        goalAmount = _goalAmount;
        deadline = block.timestamp + _duration;
        raisedAmount = 0;
        completed = false;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }

    function contribute() external payable {
        require(block.timestamp < deadline, "Campaign has ended");
        raisedAmount += msg.value;
        contributions[msg.sender] += msg.value;
        contributors.push(msg.sender);
    }

    function addSupplier(address supplier) external onlyOrganizer {
        suppliers.push(supplier);
    }

    function addTransaction(address supplier) external onlyOrganizer{
        transactions.push(supplier);
    }

    
    function getDeadline() external view returns (uint) {
        return deadline;
    }

    function extendDeadline(uint additionalTime) external onlyOrganizer {
        deadline += additionalTime;
    }

    function getCompleted() external view returns (bool) {
        return completed;
    }
    
    function getLengthTransaction() external view returns(uint){
        return transactions.length;
    }

    function getTransactionSupplier(uint transaction) external view returns(address){
        return transactions[transaction];
    }

    function getGoalAmount() external view returns(uint){
        return goalAmount;
    }

    function getRaisedAmount() external  view returns(uint){
        return raisedAmount;
    }

    function refundContributors(uint rate) external onlyOrganizer {
        completed=true; 
        require(rate <= 100, "Rate must be less than or equal to 100");
        uint contributorsLength = contributors.length;
        for (uint i = 0; i < contributorsLength; i++) {
            address contributor = contributors[i];
            uint contribution = contributions[contributor];
            uint refundAmount = (contribution * rate) / 100;
            
            if (refundAmount > 0) {
                payable(contributor).transfer(refundAmount);
                contributions[contributor] -= refundAmount;
                raisedAmount-=refundAmount;
            }
        }
    }

    function transferEth(uint campaignId,address payable supplierAddr, uint amount) external onlyOrganizer {
        require(address(this).balance >= amount, "Insufficient contract balance");
        require(supplierManager.getSupplier(campaignId,supplierAddr).isCandidate, "Candidate supplier cannot provide any service.");
        supplierAddr.transfer(amount);
    }
}