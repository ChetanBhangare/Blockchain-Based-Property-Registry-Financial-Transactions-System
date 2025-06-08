# Solution File to Final Project

This document provides detailed instructions for designing, developing, and deploying a blockchain-based property registry system. The solution uses a combined smart contract (**PropertyRegistry.sol**) built on the ERC721 standard with multi-signature transfer approvals. It includes steps for deploying on the Sepolia test network (with options for mnemonic or private key authentication), integrating with a Vue.js front end using ethers.js, and containerizing the front end with Docker (containerizing is optional).

8# The Business Case for your Presentation and Report
Traditional property management systems are plagued by lengthy processing times and vulnerabilities that enable title fraud. In many regions, transferring property ownership can take 30–50 days, during which fraudulent actors may manipulate paperwork, impersonate property owners, or exploit gaps in regulatory oversight. This not only delays rightful ownership but also undermines the integrity of property market rights, creates legal disputes, and increases the risk of fraudulent transactions.

Blockchain‑based property systems, however, address these challenges by utilizing decentralized, immutable ledgers and smart contracts that enforce strict role‑based access and multi‑signature approvals. By automating property registration and transfer processes, the blockchain solution significantly reduces transaction time and fraud risk. Regulatory bodies benefit from transparent, auditable records that improve compliance oversight and enforce market rights, ultimately fostering trust and efficiency in property ownership and market transactions.
---
To avoid development challenges, use different terminals for the project root directory, frontend and backend directory operations
## Step 1: Environment Setup

1. **Install Required Tools if not installed on your computer/server:**
   - Node.js (v16 or higher)
   - npm (v7 or higher)
   - Truffle Suite (npm install -g truffle)
   - MetaMask browser extension. Use Sepolia testnet for your development. Get free sepolia eth tokens from the following after every 24-72 hours: 
    https://cloud.google.com/application/web3/faucet/ethereum/sepolia
    https://faucets.alchemy.com/faucets/ethereum-sepolia
   - A code editor (e.g., Visual Studio Code)

2. **Create Project Structure:**
   - Create a new folder called `PROPERTYMANAGEMENTSYSTEM`.
   - Open a terminal in that folder and initialize a new Truffle project:
     ```bash
mkdir PROPERTYMANAGEMENTSYSTEM
cd PROPERTYMANAGEMENTSYSTEM


3. **Initialize a Truffle Project**
truffle init
    
4. **Install Project Dependencies:**
   In your project directory, open a ```bash terminal if not already and install the following packages:

npm install @openzeppelin/contracts @truffle/hdwallet-provider @chainlink/contracts dotenv express mongoose cors
npm audit fix --force

    These dependencies include:
      OpenZeppelin Contracts: For ERC721, AccessControl, etc.
      HDWallet Provider: For deployment.
      Chainlink Contracts: For the Oracle integration.

  
      dotenv: For loading environment variables.
      Express, mongoose, cors: For the backend (if integrating off-chain data).

5. **Setup .env File:** 
   In the root folder (PROPERTYMANAGEMENTSYSTEM), create a file named .env and add:

PRIVATE_KEY= "your private key"       # Add your private key before deployment  # or use MNEMONIC="your mnemonic here" 
ALCHEMY_SEPOLIA_URL= "your alchemy sepolia URL"  # Add your RPC URL from Alchemy before deployment
VUE_APP_CONTRACT_ADDRESS= "0x.." # Update with your smart contract address after deployment
USE_MOCK_AGGREGATOR = true #Set to false to use Chainlink price feed oracle
CHAINLINK_PRICE_FEED_ADDRESS = 0x0000000000000000000000000000000000000000  #(this will be overridden by the mock aggregator address) #"0x694AA1769357215DE4FAC081bf1f309aDC325306"  --the address for ETH/USD price conversion from Chainlink price feed oracle 
ADDR1="0x6f4e3Ef41AF0351F3F91d95afd74a0a365f1e7a0" # Add your address before deployment, the approver address
MONGO_URI="mongodb+srv://dtreku:12345@propertyownershipdapp.8tntb.mongodb.net/propertyDApp?retryWrites=true&w=majority&appName=PropertyOwnershipDApp" # Add your MongoDB URI before deployment
PORT=3000


## Step 2: Smart Contract Development
1. **Develop the Smart Contract:**

   - Copy your updated PropertyManagement.sol (the version that includes AccessControl, Chainlink integration, compliance checks,transfer request functions, etc.) into the `contracts/` folder.
   - Use the `PropertyManagement.sol` script provided on Canvas:
   - Acquaint yourself with the smart contract functionalities as given in the project brief**


2. **Compile the Contract**

truffle compile


3. **Truffle Config file**
  - Update your truffle-config.js file with the Sepolia network settings and support for authentication using either a mnemonic or a private key. Use the truffle-config.js file provided on Canvas.


4. **Deployment Script**
  - In your `migrations/` folder, create a deployment script named: 1_deploy_PropertyManagement.js , this script is also on Canvas in Final Project module


5. **Run Deployment**

truffle migrate --network sepolia


## Step 3: Testing and Interaction

1. **Unit Testing:**
 - Create test scripts in the test directory 
 - Create a test script file called `PropertyManagement.test.js in your DAPP project's test directory or folder. Use the file provided on Canvas.
 - Run:
 npm install --save-dev @openzeppelin/test-helpers

Change the following checkCompliance function in your solidity file to the following when testing:

  - Run your tests using:
 truffle test



2. **Interacting with the Contract:**

We will be using the Truffle Console, ethers.js scripts to interact with the deployed contract.
  - We want to test functionalities such as:
      Registering a Property
      Creating and Approving Transfer Requests
      Listing Properties for Sale
      Showing list of properties
      Buying Properties
      Compliance check
      Getting property details


## Step 4: Backend Setup (Express & MongoDB)
1. **Create the Backend Folder**
- In your project root, create a folder called property-management-backend

2. **Initialize Node & Install Dependencies**

cd property-management-backend
npm init -y
npm install express mongoose cors dotenv helmet morgan


3. **Create a Mongoose Model**
- Create a folder named `models` in the property-management-backend directory. 
- Create a new file named `property.model.js` inside the models folder.
- Paste the code for `property.model.js` file provided on Canvas

- Adjust field types or required validations if application requires different formats.


4. **Creating Express Routes for CRUD Operations**
- Create a folder named `routes` in the property-management-backend directory.
- Create a new file named `property.routes.js` inside the routes folder.
- Paste the code for `property.routes.js` file provided on Canvas

5. **Create a Server Script to Routes in our Backend Server**
Create a file named `server.js` in the property-management-backend directory.
- Paste the code for `server.js` file provided on Canvas

6.**Run the Backend**
- Ensure your .env file (in the project root or backend folder) contains your MongoDB connection string (MONGO_URI) and desired port (PORT).
- Run your server with:
node server.js
- Verify that your backend is running on localhost (e.g., http://localhost:3000).


## Step 5: Frontend Development with Vue.js //You may use react and other front end packages
   # Using ethers.js for blockchain interactions //You may use web3.js library instead 

1. **Project Setup with Vue (a frontend stack):**
- Install Vue CLI globally (if needed):
npm install -g @vue/cli

- Install babel dependency
npm install --save-dev @babel/plugin-transform-private-methods

2 **Create a new Vue project** 
- Run:
vue create property-management-frontend


3. **Accept the default selection which is the following** 
Default ([Vue 3] babel, eslint)

4. **Install frontend dependencies**
- Navigate to the `property-management-frontend` folder using cd property-management-frontend 
cd property-Management-frontend

npm install --save-dev ethers dotenv @walletconnect/web3-provider axios

5.**Configure Vue Router**

- create a folder called router inside src/ and inside the folder (property-management-frontend/src/router/) create a file named `index.js`
- Paste the code from `index.js` file provided on Canvas.

- In `main.js` file (i.e., property-management-frontend/src/main.js), replace the code with the `main.js` script provided on Canvas.

6. **Vue script Configurations**
- In the `babel.config.js` file (property-management-frontend/babel.config.js), replace the code with the
babel.config.js script provided on Canvas

- Update your `vue.config.js` file (property-management-frontend/vue.config.js) to include the required packages. Replace the code with the vue.config.js script provided on Canvas


7. **Integrate ABI file from deployed smart contract**
- Create a folder named abis inside your src directory (i.e. property-management-frontend/src/abis)   
- Copy and paste your compiled contract ABI file, `PropertyManagement.json`, generated by Truffle into the abis folder. 
- Your ABI file, PropertyManagement.json, is in the build\contracts folder which is in the main project root directory:  `PROPERTYMANAGEMENTSYSTEM`  
***Note that if you deploy your contract again you must update the copied PropertyManagement.json version in the abis folder***


8. **Set up vue-router for router links and update App.vue**

- Install and Configure Vue Router.Still in property-management-frontend, run:
npm install vue-router

- In `App.vue` file (i.e., property-management-frontend/src/App.vue), replace the code with the `App.vue` script provided on Canvas.

9. **Creating Vue Components based on smart contract functionalities:**
- create a folder called views in the src folder within property-management-frontend and create the following vue files inside the views.
      - Create a new component file `AssignRoles.vue` in src/views, admin view for assigning, revoking, and updating roles. The contract deployer is the owner of the contract and the admin.

      - Create a new component file `PropertyListings.vue` in src/views - Use the PropertyListing.vue file (for publicly viewable properties) provided on Canvas for the script*** It loads on‑chain properties via ethers.js and also queries off‑chain property metadata stored in MongoDB via an Axios GET request

      - Create a new component file `RegisterProperty.vue` in src/views Use the RegisterProperty.vue file (requires wallet to register) provided on Canvas for the script***

      - Create a new component file `ListProperty.vue` in src/views - Use the ListProperty.vue file (to List a property for sale) provided on Canvas for the script***

      - Create a new component file `BuyProperty.vue` in src/views - Use the BuyProperty.vue file (for purchasing properties) provided on Canvas for the script***
      
      - Create a new component file `ApproveTransfer.vue` in src/views, enables approvers to approve transfer requests.

      - Create a new component file `PropertyPriceUpdate.vue` in src/views, allows authorized users to update property prices via Chainlink Oracle.

      - Create a new component file `Compliance.vue` in src/views, a view to check property compliance using the smart contract via oracles.

      - Create a new component file `CreateTransferRequest.vue` in src/views, a view for property owners to create transfer requests.

10.**Your frontend folder structure**
- Your frontend folder structure should look like:

property-management-frontend/
├── package.json
├── vue.config.js
├── public/
│   └── index.html
└── src/
    ├── assets/
    │   └── logo.png
    ├── abis/
    │   └── PropertyManagement.json
    ├── views/
    │   ├── PropertyListing.vue
    │   ├── RegisterProperty.vue
    │   ├── ListProperty.vue
    │   ├── BuyProperty.vue
    │   ├── PropertyPriceUpdate.vue
    │   ├── ApproveTransfer.vue
    │   ├── CreateTransferRequest.vue
    │   ├── AssignRoles.vue
    │   └── Compliance.vue
    ├── router/
    │   └── index.js
    ├── components/
    │   └── (any shared UI components, e.g., NavigationBar.vue, Footer.vue)
    ├── App.vue
    └── main.js


11. **Build and Serve the Frontend:**
 - In the Vue project root, run:

 //npm uninstall vue-template-compiler  //to handle Vue 3 and Vue compatibility issues.
 //npm install --save-dev @vue/compiler-sfc

 npm run serve



## Step 6: Dockerizing the application
***Dockerfile for Frontend (in property-registry-frontend/):***


FROM node:16
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
RUN npm install -g serve
EXPOSE 8080
CMD ["serve", "-s", "dist", "-l", "8080"]


***Dockerfile for Backend (in property-management-backend/):***
FROM node:16
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD [ "node", "server.js" ]


***Docker Compose Configuration***
docker-compose.yml (in the project root):
version: '3.8'
services:
  frontend:
    build: ./property-registry-frontend
    ports:
      - "8080:8080"
    environment:
      - VUE_APP_CONTRACT_ADDRESS=${DAPP_CONTRACT_ADDRESS}

  backend:
    build: ./property-management-backend
    ports:
      - "3000:3000"
    environment:
      - MONGO_URI=${MONGO_URI}
      - PORT=3000

  mongodb:
    image: mongo:5
    restart: always
    ports:
      - "27017:27017"
    volumes:
      - mongo-data:/data/db

volumes:
  mongo-data:


***Run with***
docker-compose up --build
