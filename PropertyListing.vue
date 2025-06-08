<template>
  <div class="view-container">
    <!-- (Optional) Wallet Info if needed -->
    <div class="wallet-info" v-if="account">
      <p>Connected Account: {{ shortenAddress(account) }}</p>
    </div>
    <h2>Available Properties</h2>
    <div v-if="mergedProperties.length">
      <div v-for="property in mergedProperties" :key="property.tokenId || property._id" class="property-card">
        <h3>{{ property.propertyAddress || property.address }}</h3>
        <p><strong>Location:</strong> {{ property.location }}</p>
        <p><strong>Floors:</strong> {{ property.floors }}</p>
        <p><strong>Price:</strong> {{ property.price }} ETH</p>
        <p><strong>For Sale:</strong> {{ property.forSale || property.isForSale ? "Yes" : "No" }}</p>
        <p v-if="property.propertyType !== undefined">
          <strong>Type:</strong> {{ property.propertyType === 0 ? 'Land' : 'House' }}
        </p>
        <p v-if="property.tokenId"><strong>Token ID:</strong> {{ property.tokenId }}</p>
      </div>
    </div>
    <div v-else>
      <p>No properties found. Displaying default listing:</p>
      <div class="property-card">
        <h3>123 Default Property</h3>
        <p><strong>Location:</strong> Default City</p>
        <p><strong>Floors:</strong> 1</p>
        <p><strong>Price:</strong> 1.0000 ETH</p>
        <p><strong>For Sale:</strong> Yes</p>
        <p><strong>Type:</strong> House</p>
        <p><strong>Token ID:</strong> 1</p>
      </div>
    </div>
    <footer class="footer">
      <p>© A Web3 Application by the Business Application of Blockchain Technology Class, 2025. All rights reserved.</p>
    </footer>
  </div>
</template>

<script>
import { BrowserProvider, Contract } from 'ethers';
import axios from 'axios';
import PropertyManagement from '../abis/PropertyManagement.json';
const contractAddress = process.env.VUE_APP_CONTRACT_ADDRESS;

export default {
  name: 'PropertyListing',
  data() {
    return {
      onChainProperties: [],
      offChainProperties: [],
      account: null
    }
  },
  async mounted() {
    await this.loadOnChainProperties();
    await this.loadOffChainProperties();
  },
  methods: {
    async loadOnChainProperties() {
      if (!window.ethereum) {
        console.warn("MetaMask not detected! Using default listing.");
        return;
      }
      try {
        const provider = new BrowserProvider(window.ethereum);
        const contract = new Contract(contractAddress, PropertyManagement.abi, provider);
        const tokenIdsBN = await contract._tokenIds();
        const tokenCount = parseInt(tokenIdsBN.toString());
        this.onChainProperties = [];
        if (tokenCount > 0) {
          for (let i = 1; i <= tokenCount; i++) {
            const property = await contract.getProperty(i);
            this.onChainProperties.push({
              tokenId: i,
              propertyAddress: property[0],
              location: property[1],
              floors: property[2],
              price: (Number(property[3]) / 1e18).toFixed(4),
              forSale: property[4],
              propertyType: property[5]
            });
          }
        }
      } catch (err) {
        console.error("Error loading on-chain properties:", err);
      }
    },
    async loadOffChainProperties() {
      try {
        // Query your backend endpoint for off-chain property data stored in MongoDB.
        const response = await axios.get('http://localhost:3000/api/properties');
        this.offChainProperties = response.data;
      } catch (err) {
        console.error("Error loading off-chain properties:", err);
      }
    },
    shortenAddress(address) {
      return address.slice(0, 6) + "..." + address.slice(-4);
    }
  },
  computed: {
    // Merge on-chain and off-chain properties for display.
    mergedProperties() {
      // Here we simply concatenate the arrays.
      return [...this.onChainProperties, ...this.offChainProperties];
    }
  }
}
</script>

<style scoped>
.view-container {
  max-width: 800px;
  margin: 20px auto;
  padding: 20px;
  background: #f5f5f5;
  font-family: 'Arial', sans-serif;
}
h2 {
  text-align: center;
  margin-bottom: 1.5rem;
  color: #283e51;
}
.property-card {
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 15px;
  margin-bottom: 1rem;
  background-color: #fff;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}
.property-card h3 {
  margin-top: 0;
  color: #283e51;
}
.property-card p {
  margin: 5px 0;
  color: #555;
}
.footer {
  text-align: center;
  padding: 1rem;
  font-size: 0.9rem;
  color: #888;
  border-top: 1px solid #eee;
  margin-top: 2rem;
}
</style>
