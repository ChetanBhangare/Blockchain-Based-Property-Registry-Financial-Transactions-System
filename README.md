# Blockchain-Based Property Registry & Financial Transactions System 🏠🔗

A decentralized property management system built with Solidity, Chainlink, MongoDB, and Docker, enabling tamper-proof property registration, secure transfer, real-time compliance checks, and ERC721-based ownership tokenization.

## 🚀 Features

- **Tamper-Proof Smart Contracts**: Property registration, listing, and transfer executed via Solidity on Ethereum blockchain using the ERC721 token standard.
- **Multi-Signature Approvals**: Requires approvals from multiple authorities before a property can be transferred—enhancing security.
- **Chainlink Oracle Integration**: Fetches real-time property valuations and compliance data from external sources.
- **Role-Based Access**: Admin, Approvers, Buyers, and Sellers have distinct permissions secured by OpenZeppelin Access Control.
- **MongoDB Backend**: Stores off-chain metadata for properties with Express.js-based RESTful APIs.
- **Vue.js/React.js Frontend**: Enables users to register, view, buy, and approve property transfers with seamless Web3 MetaMask integration.
- **Dockerized Deployment**: Portable, scalable system deployed using Docker for cross-environment consistency.

## 🏗️ Tech Stack

- **Blockchain**: Solidity, Truffle, OpenZeppelin, Chainlink, ERC721, Sepolia Testnet
- **Backend**: Node.js, Express.js, MongoDB, Mongoose
- **Frontend**: Vue.js / React.js, Web3.js, Axios
- **Deployment**: Docker, Alchemy, Etherscan
- **Testing**: Mocha, Chai, OpenZeppelin Test Helpers

## 🧪 Smart Contract Functionalities

- Property Registration & Allotment
- Multi-Signature Property Transfers
- Oracle-Based Real-Time Pricing
- ERC721 Tokenized Ownership
- On-chain Event Emissions for Property Activities

## 📦 Docker Instructions

```bash
# Build and run the Docker container
docker build -t property-dapp .
docker run -p 3000:3000 property-dapp
