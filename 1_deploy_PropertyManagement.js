require('dotenv').config();
const HDWalletProvider = require('@truffle/hdwallet-provider');
const PropertyManagement = artifacts.require("PropertyManagement");
const MockAggregator = artifacts.require("MockAggregator");

// Use the CHAINLINK_PRICE_FEED_ADDRESS from .env, or default to address(0) if not provided.
let priceFeedAddress = process.env.CHAINLINK_PRICE_FEED_ADDRESS || "0x0000000000000000000000000000000000000000";

module.exports = async function(deployer, network, accounts) {
  // If USE_MOCK_AGGREGATOR is set to "true", deploy the mock aggregator first.
  if (process.env.USE_MOCK_AGGREGATOR === "true") {
    // For example, setting the price to 1500 (with 8 decimals)
    const answer = 1500 * (10 ** 8);
    await deployer.deploy(MockAggregator, answer, 8, "ETH/USD");
    const mockAggregator = await MockAggregator.deployed();
    priceFeedAddress = mockAggregator.address;
    console.log("Using MockAggregator at:", priceFeedAddress);
  } else {
    console.log("Using Chainlink aggregator from env:", priceFeedAddress);
  }

  await deployer.deploy(PropertyManagement, priceFeedAddress);
};
