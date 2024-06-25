// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VoteManager {
    struct Vote {
        bool isCandidate;
        bool votingStarted;
        uint positiveVotes;
        uint negativeVotes;
        bool voted;
    }
    mapping(address => mapping(uint => Vote)) public supplierVoting;
    mapping(address => mapping(uint => Vote)) public suspiciousTransactions;
    mapping(uint => Vote) public timeOverVote;

    function startSuspiciousTransactionVoting(uint campaignId, address supplierAddr) external {
        Vote storage suspiciousTrans = suspiciousTransactions[supplierAddr][campaignId];
        suspiciousTrans.isCandidate = true;
        suspiciousTrans.votingStarted = true;
    }

    function startTimeOverVoting(uint campaignId) external{
        Vote storage timeOver = timeOverVote[campaignId];
        timeOver.isCandidate = true;
        timeOver.votingStarted = true;
    }

    function castVote(uint campaignId, bool vote, string memory choice, address addr) external {
        if (keccak256(abi.encodePacked(choice)) == keccak256(abi.encodePacked("Supplier"))) {
            Vote storage supplierVote = supplierVoting[addr][campaignId];
            require(supplierVote.votingStarted, "Voting process for this supplier has not started yet.");
            if (vote) {
                supplierVote.positiveVotes++;
            } else {
                supplierVote.negativeVotes++;
            }
        } else if (keccak256(abi.encodePacked(choice)) == keccak256(abi.encodePacked("Transaction"))) {
            Vote storage suspiciousTrans = suspiciousTransactions[addr][campaignId];
            require(suspiciousTrans.votingStarted, "Voting process for this transaction has not started yet.");
            if (vote) {
                suspiciousTrans.positiveVotes++;
            } else {
                suspiciousTrans.negativeVotes++;
            }
        } else if (keccak256(abi.encodePacked(choice)) == keccak256(abi.encodePacked("TimeOver"))) {
            Vote storage timeOverVoting = timeOverVote[campaignId];
            require(timeOverVoting.votingStarted, "Voting process for this time over has not started yet.");
            if (vote) {
                timeOverVoting.positiveVotes++;
            } else {
                timeOverVoting.negativeVotes++;
            }
        } else {
            revert("Invalid choice");
        }
    }

    function getVote(uint campaignId, address addr, string memory choice) public view returns (Vote memory) {
        if (keccak256(abi.encodePacked(choice)) == keccak256(abi.encodePacked("Supplier"))) {
            return supplierVoting[addr][campaignId];
        } else if (keccak256(abi.encodePacked(choice)) == keccak256(abi.encodePacked("Transaction"))) {
            return suspiciousTransactions[addr][campaignId];
        } else if (keccak256(abi.encodePacked(choice)) == keccak256(abi.encodePacked("TimeOver"))) {
            return timeOverVote[campaignId];
        } else {
            revert("Invalid choice");
        }
    }

    function updateVote(uint campaignId,address addr,string memory choice) external {
         if (keccak256(abi.encodePacked(choice)) == keccak256(abi.encodePacked("Supplier"))) {
            Vote storage supplierVote = supplierVoting[addr][campaignId];
            supplierVote.isCandidate=false;
         }
         else if (keccak256(abi.encodePacked(choice)) == keccak256(abi.encodePacked("Transaction"))) {
            Vote storage suspiciousTrans = suspiciousTransactions[addr][campaignId];
            suspiciousTrans.isCandidate=false;
         }
         else if (keccak256(abi.encodePacked(choice)) == keccak256(abi.encodePacked("TimeOver"))) {
            Vote storage timeOverVoting = timeOverVote[campaignId];
            timeOverVoting.isCandidate=false;
         }
    }
}
