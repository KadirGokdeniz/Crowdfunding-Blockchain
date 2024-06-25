# Blockchain Project

## Project Description
This project involves the development of various smart contracts and related components. It includes modules for crowdfunding, identity management, supplier management, and voting management.

### Detailed Description
The blockchain project aims to provide a decentralized platform that includes the following components:

1. **Crowdfunding**: A decentralized crowdfunding platform where organizers can create campaigns and participants can contribute funds. This ensures transparency and trust in the funding process.

2. **Decentralized Identity (DID) Management**: A system for registering and managing decentralized identities. This allows users to have control over their identity and personal data without relying on a central authority.

3. **Supplier Management**: A contract to manage suppliers, ensuring that only verified suppliers can participate in the platform. This includes mechanisms for registering suppliers and managing supplier-related activities.

4. **Voting Management**: A robust voting system that allows participants to vote on various proposals. The voting process is transparent and secure, leveraging the immutability of blockchain.

## Technologies Used
- Solidity
- Ethereum Blockchain
- Truffle Suite
- Ganache

## Installation and Setup Instructions

### Requirements
- Node.js and npm
- Truffle
- Ganache

### Steps
1. Clone the repository:
    ```bash
    git clone https://github.com/username/blockchain-project.git
    cd blockchain-project
    ```

2. Install the necessary dependencies:
    ```bash
    npm install
    ```

3. Start Ganache and create a blockchain network.

4. Compile and deploy the smart contracts:
    ```bash
    truffle compile
    truffle migrate
    ```

5. Run the tests:
    ```bash
    truffle test
    ```

## Features
- **Campaign.sol**: Smart contract to manage crowdfunding campaigns.
- **Crowdfunding.sol**: General contract for community funding.
- **DIDRegistry.sol**: Contract to manage decentralized identity records.
- **SupplierManager.sol**: Smart contract to manage suppliers.
- **VoteManager.sol**: Smart contract to manage voting processes.

## UML Diagrams
- [Campaign UML](./UMLs/Campaign.png)
- [Crowdfunding UML](./UMLs/Crowdfunding.png)
- [DIDRegistry UML](./UMLs/DIDRegistry.png)
- [SupplierManager UML](./UMLs/SupplierManager.png)
- [VoteManager UML](./UMLs/VoteManager.png)

## Use Cases
- [DID Initialization and Registration](./Use-Cases/DID_initialization_and_registiration_to_DID.jpg)
- [Registration as Organizer and Creating Campaign](./Use-Cases/regisitation_as_organizer_and_creatin_campaign.jpg)
- [Registration as Participant and Contributing](./Use-Cases/registiration_as_participant_and_contribute.jpg)
- [Registration as Supplier and Supplier Voting Algorithm](./Use-Cases/registiration_supplier_and_supplier_voting_algorithm.jpg)
- [Suspicious Voting Algorithm](./Use-Cases/Suspicious_voting_algorithm.jpg)
- [Time Over Voting and Refund Algorithm](./Use-Cases/Time_over_voting_and_refund_algorithm.jpg)

## Contributors
- **Kadir Gökdeniz**
- **Mehmet Bayram Alpay**
- **Yusuf Batuhan Kılıçarslan**

## License
This project is licensed under the MIT License. See the `LICENSE` file for more details.
