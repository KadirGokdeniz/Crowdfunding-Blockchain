// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Campaign.sol";
import "./DIDRegistry.sol";
import "./SupplierManager.sol";
import "./VoteManager.sol";

contract Crowdfunding {
    DIDRegistry public didRegistry;
    SupplierManager public supplierManager;
    VoteManager public voteManager;

    struct Participant {
        uint points;
        bool exists;
    }

    struct Organizer {
        uint reputation;
        bool exists;
    }

    struct CampaignInfo {
        uint index;
        address campaignAddress;
    }

    mapping(address => mapping(uint => Participant)) public participants; 
    mapping(address => mapping(uint => Organizer)) public organizers;     
    mapping(uint => address) public campaigns;
    uint public campaignCount;

    constructor(address didRegistryAddress, address supplierManagerAddress, address voteManagerAddress) {
        didRegistry = DIDRegistry(didRegistryAddress);
        supplierManager = SupplierManager(supplierManagerAddress);
        voteManager = VoteManager(voteManagerAddress);
    }

    function verifyDID() internal view returns (bool) {
        string memory did = didRegistry.getDID(msg.sender);
        return bytes(did).length > 0;
    }

    modifier didVerified() {
        require(verifyDID(), "DID verification failed");
        _;
    }

    modifier onlyParticipant(uint campaignId) {
        require(participants[msg.sender][campaignId].exists, "Only participants can call this function");
        _;
    }

    modifier onlyOrganizer(uint campaignId) {
        require(organizers[msg.sender][campaignId].exists, "Only organizers can call this function");
        _;
    }

    modifier onlyCandidate(uint campaignId) {
        require(!participants[msg.sender][campaignId].exists, "Only candidate participants can call this function");
        require(!organizers[msg.sender][campaignId].exists, "Only candidate participants can call this function");
        require(!supplierManager.getSupplier(campaignId, msg.sender).exists, "Only candidate participants can call this function");
        _;
    }

    function registerParticipant(uint campaignId) external didVerified onlyCandidate(campaignId) payable {
        require(campaignId <= campaignCount && campaignId > 0, "Invalid campaign ID");
        Campaign campaign = Campaign(campaigns[campaignId]);
        require(!campaign.getCompleted(), "The campaign has ended.");
        require(block.timestamp <= campaign.getDeadline(), "The campaign has expired.");
        require(msg.value >= 1 ether, "Not enough value");
        campaign.contribute{value: msg.value}();
        participants[msg.sender][campaignId] = Participant(10, true);
    }

    function registerOrganizer(uint goalAmount, uint duration) didVerified external {
        uint reputation = 0;
        if (organizers[msg.sender][0].exists) {
            reputation = organizers[msg.sender][0].reputation;
        } 
        campaignCount++;
        Campaign newCampaign = new Campaign(msg.sender, goalAmount, duration);
        campaigns[campaignCount] = address(newCampaign);
        organizers[msg.sender][campaignCount] = Organizer(reputation, true);
    }

    function registerSupplier(uint campaignId) external didVerified onlyCandidate(campaignId) {
        uint reputation = 0;
        require(campaignId <= campaignCount && campaignId > 0, "Invalid campaign ID");
        Campaign campaign = Campaign(campaigns[campaignId]);
        if (supplierManager.getSupplier(campaignId, msg.sender).exists) { 
            reputation = supplierManager.getSupplier(campaignId, msg.sender).reputation;
        }
        require(!campaign.getCompleted(), "The campaign has ended.");
        require(block.timestamp <= campaign.getDeadline(), "The campaign has expired.");
        campaign.addSupplier(msg.sender);
        supplierManager.registerSupplier(campaignId, msg.sender, reputation);
    }

    function Vote(uint campaignId, bool vote, string memory choice, address addr) external onlyParticipant(campaignId) {
        voteManager.castVote(campaignId, vote, choice, addr);
        participants[msg.sender][campaignId].points += 10;
    }

    function getVoteCount(uint campaignId, string memory choice, address addr) internal view returns (uint positiveVotes, uint negativeVotes) {
        VoteManager.Vote memory voteData = voteManager.getVote(campaignId, addr, choice);
        return (voteData.positiveVotes, voteData.negativeVotes);
    }

    function evaluateVote(uint campaignId, string memory choice, address addr) external onlyOrganizer(campaignId) {
        Campaign campaign = Campaign(campaigns[campaignId]);
        VoteManager.Vote memory voteData = voteManager.getVote(campaignId, addr, choice);

        if (keccak256(abi.encodePacked(choice)) == keccak256(abi.encodePacked("Supplier"))) {
            require(voteData.voted, "There is a pre-assessed vote.");
            require(voteData.isCandidate, "Supplier does not need evaluation.");
            (uint positiveVotes, uint negativeVotes) = getVoteCount(campaignId, "Supplier", addr);
            require(positiveVotes + negativeVotes >= 180, "Total votes must be greater than or equal to 180"); // 90% attendance
            uint threshold = (positiveVotes + negativeVotes) * 7 / 10; // 70% threshold
            if (positiveVotes >= threshold) {
                voteManager.updateVote(campaignId,addr,"Supplier");
                supplierManager.confirmSupplier(campaignId, addr); //confirm Candidate
            }
            supplierManager.updateVote(campaignId,addr);

        } else if (keccak256(abi.encodePacked(choice)) == keccak256(abi.encodePacked("Transaction"))) {
            require(voteData.voted, "There is a pre-assessed vote.");
            require(voteData.isCandidate, "Transaction does not need evaluation.");
            (uint positiveVotes, uint negativeVotes) = getVoteCount(campaignId, "Transaction", addr);
            require(positiveVotes + negativeVotes >= 150, "Total votes must be greater than or equal to 150"); // 75% attendance
            uint threshold = (positiveVotes + negativeVotes) * 5 / 10; // 50% threshold
            if (positiveVotes >= threshold) { 
                voteManager.updateVote(campaignId,addr,"Transaction"); //transaction available after voting
            }    

        } else if (keccak256(abi.encodePacked(choice)) == keccak256(abi.encodePacked("TimeOver"))) {
            (uint positiveVotes, uint negativeVotes) = getVoteCount(campaignId, "TimeOver", addr); // random account address, not used in the code.
            require(positiveVotes + negativeVotes >= 150, "Total votes must be greater than or equal to 150"); // 75% attendance
            uint threshold = (positiveVotes + negativeVotes) * 7 / 10; // 70% threshold
            if (positiveVotes >= threshold) {
                voteManager.updateVote(campaignId,addr,"TimeOver");//Timeover voting sucessfull refund required.
                campaign.refundContributors(80); // Refund 80%
            } else {
                campaign.extendDeadline(1_209_600); // extend deadline by two weeks
            }
            
        } else {
            revert("Invalid choice");
        }
    }

    function isSuspiciousTransaction(uint campaignId, uint amount, address supplierAddr) internal view returns (bool) {
        Campaign campaign = Campaign(campaigns[campaignId]);
        if (isSameSupplierInLastTransactions(campaignId, supplierAddr)) {
            return true;
        }
        if (amount >= (campaign.getGoalAmount() * 20 / 100)) {
            return true;
        }
        return false;
    }

    function isSameSupplierInLastTransactions(uint campaignId, address supplierAddr) internal view returns (bool) {
        Campaign campaign = Campaign(campaigns[campaignId]);
        uint transactionCount = campaign.getLengthTransaction();
        if (transactionCount >= 5) {
            uint suspiciousTransNumb = 0;
            for (uint i = 0; i < 5; i++) {
                if(campaign.getTransactionSupplier(transactionCount - 1 - i) != supplierAddr){
                    suspiciousTransNumb++;
                }
            }
            if (suspiciousTransNumb >= 3) { // 60% similarites in the last 5 transaction
                return true;
            }
        }
        return false;
    }

    function transaction(uint campaignId, uint amount, address supplierAddr) external onlyOrganizer(campaignId) {
        require(voteManager.getVote(campaignId,supplierAddr, "Transaction").isCandidate);
        if (isSuspiciousTransaction(campaignId, amount, supplierAddr)) {
            VoteManager.Vote memory voteData = voteManager.getVote(campaignId, supplierAddr, "Transaction");
            if(!(voteData.isCandidate==false && voteData.voted==true)){
                voteManager.startSuspiciousTransactionVoting(campaignId, supplierAddr);}
        } else {
            Campaign campaign = Campaign(campaigns[campaignId]);
            require(campaign.getRaisedAmount() >= campaign.getGoalAmount(), "Campaign goal not reached");
            campaign.transferEth(campaignId,payable(supplierAddr), amount);
            Organizer storage organizer = organizers[msg.sender][campaignId];
            supplierManager.incrementReputationSupplier(campaignId, supplierAddr, 2);
            organizer.reputation += 2;
        }
    }

    function startTimeOverVoting(uint campaignId) external onlyParticipant(campaignId){
        Campaign campaign = Campaign(campaigns[campaignId]);
        require(block.timestamp >= campaign.getDeadline() && campaign.getGoalAmount() > campaign.getRaisedAmount(), "The campaign has not expired or raised amount bigger than goal amount.");
        voteManager.startTimeOverVoting(campaignId);
    }

    function getAllCampaigns() external view returns (CampaignInfo[] memory) {
        CampaignInfo[] memory allCampaigns = new CampaignInfo[](campaignCount);
        for (uint i = 1; i <= campaignCount; i++) {
            allCampaigns[i - 1] = CampaignInfo({
                index: i,
                campaignAddress: campaigns[i]
            });
        }
        return allCampaigns;
    }
}
