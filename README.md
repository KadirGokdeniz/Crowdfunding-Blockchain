# Blockchain Crowdfunding Platform

A decentralized crowdfunding platform built on Ethereum blockchain technology, featuring identity management, supplier verification, and democratic voting systems.

## Table of Contents
- [Project Description](#project-description)
- [Key Components](#key-components)
- [Technologies Used](#technologies-used)
- [Installation and Setup](#installation-and-setup)
- [Smart Contracts](#smart-contracts)
- [System Architecture](#system-architecture)
- [Use Cases](#use-cases)
- [Contributors](#contributors)
- [License](#license)

## Project Description
This project implements a comprehensive decentralized platform for crowdfunding using blockchain technology. The system addresses traditional crowdfunding challenges through:

✔ Transparent fund management  
✔ Decentralized identity verification  
✔ Democratic governance mechanisms  

Our implementation includes:
- Detailed role definitions
- Function specifications
- Carefully selected consensus mechanisms
- Solidity smart contracts

## Key Components

### Crowdfunding System
- Transparent campaign creation
- Traceable fund contributions
- Trustless execution via smart contracts

### Decentralized Identity (DID) Management
- User-controlled identity verification
- No centralized authorities
- Privacy-preserving design

### Supplier Management
- Verified supplier onboarding
- Reputation tracking
- Governance controls

### Voting Management
- Tamper-proof voting system
- Immutable decision records
- Transparent execution

## Technologies Used

| Technology | Purpose |
|------------|---------|
| Solidity | Smart contract development |
| Ethereum | Blockchain infrastructure |
| Truffle Suite | Development environment |
| Ganache | Local Ethereum blockchain |

## Installation and Setup

### Prerequisites
- Node.js (v12+)
- npm
- Truffle Suite (`npm install -g truffle`)
- Ganache CLI/GUI
- MetaMask wallet

### Setup
```bash
# Clone repository
git clone https://github.com/username/blockchain-project.git
cd blockchain-project

# Install dependencies
npm install

# Start local blockchain (Ganache)
ganache-cli -p 7545

# Compile and migrate contracts
truffle compile
truffle migrate --reset

# Run tests
truffle test

# For frontend development
cd client
npm install
npm start
```

# Smart Contracts
- Contract	            Purpose
- Campaign.sol	        Manages individual campaigns
- Crowdfunding.sol	    Core coordination
- DIDRegistry.sol	    Identity management
- SupplierManager.sol	Supplier verification
- VoteManager.sol	    Voting systems
- System Architecture   System Architecture

# Use Cases
- DID Initialization: User identity registration
- Campaign Creation: Organizer workflows
- Contribution Flow: Participant interactions
- Supplier Voting: Reputation management
- Suspicious Activity: Dispute resolution
- Refund Processing: Failed campaigns

# Contributors
- Kadir Gökdeniz
- Mehmet Bayram Alpay
- Yusuf Batuhan Kılıçarslan

# License
- MIT License - See LICENSE for details.
