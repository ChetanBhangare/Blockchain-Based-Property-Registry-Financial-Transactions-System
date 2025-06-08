require('dotenv').config();
const HDWalletProvider = require('@truffle/hdwallet-provider');

const mnemonic = process.env.MNEMONIC;
const privateKey = process.env.PRIVATE_KEY;
const alchemyUrl = process.env.ALCHEMY_SEPOLIA_URL;

const provider = () => {
  if (mnemonic) {
    return new HDWalletProvider({ mnemonic: { phrase: mnemonic }, providerOrUrl: alchemyUrl });
  } else if (privateKey) {
    return new HDWalletProvider({ privateKeys: [privateKey], providerOrUrl: alchemyUrl });
  } else {
    throw new Error("Please set MNEMONIC or PRIVATE_KEY in your .env file");
  }
};

module.exports = {
  networks: {
    sepolia: {
      provider: provider,
      network_id: 11155111, // Sepolia's network ID
      gas: 5500000,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    // Ensure you don't accidentally use the default Ganache network unless needed.
  },
  mocha: {
    reporter: 'eth-gas-reporter',
    reporterOptions: {
      currency: 'USD',
      gasPrice: 21
    }
  },
  compilers: {
    solc: {
      version: "0.8.20"
    }
  }
};
