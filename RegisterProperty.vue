<template>
  <div class="view-container">
    <!-- Wallet Connection Section -->
    <div class="wallet-container" v-if="!account">
      <button class="connect-btn" @click="connectWallet">Connect MetaMask</button>
    </div>
    <div class="wallet-info" v-else>
      <p>Connected Account: {{ shortenAddress(account) }}</p>
    </div>

    <!-- Registration Form -->
    <div class="form-container">
      <h2>Register a New Property</h2>
      <form @submit.prevent="submitRegistration">
        <div class="form-group">
          <label for="propertyAddress">Property Address:</label>
          <input type="text" id="propertyAddress" v-model="form.propertyAddress" placeholder="e.g., 456 Elm Street" required />
        </div>
        <div class="form-group">
          <label for="location">Location:</label>
          <input type="text" id="location" v-model="form.location" placeholder="e.g., Downtown" required />
        </div>
        <div class="form-group">
          <label for="floors">Floors:</label>
          <input type="number" id="floors" v-model.number="form.floors" min="0" required />
        </div>
        <div class="form-group">
          <label for="price">Price (ETH):</label>
          <input type="number" id="price" v-model="form.price" step="0.01" placeholder="e.g., 1.5" required />
        </div>
        <div class="form-group">
          <label for="propertyType">Property Type:</label>
          <select id="propertyType" v-model.number="form.propertyType" required>
            <option :value="0">Land</option>
            <option :value="1">House</option>
          </select>
        </div>
        <div class="form-group">
          <label for="requiredApprovals">Required Approvals:</label>
          <input type="number" id="requiredApprovals" v-model.number="form.requiredApprovals" min="1" required />
        </div>
        <button type="submit" class="action-btn" :disabled="loading">
          {{ loading ? "Registering..." : "Register Property" }}
        </button>
      </form>
      <p v-if="error" class="error-message">{{ error }}</p>
      <p v-if="success" class="success-message">{{ success }}</p>
    </div>

    <!-- Footer -->
    <footer class="footer">
      <p>© A Web3 Application by the Business Application of Blockchain Technology Class, 2025. All rights reserved.</p>
    </footer>
  </div>
</template>

<script>
import { BrowserProvider, Contract, parseEther } from 'ethers';
import PropertyManagement from '../abis/PropertyManagement.json';

const contractAddress = process.env.VUE_APP_CONTRACT_ADDRESS;

export default {
  name: 'RegisterProperty',
  data() {
    return {
      form: {
        propertyAddress: '',
        location: '',
        floors: 0,
        price: '',
        propertyType: 1, // 0 = Land, 1 = House
        requiredApprovals: 1
      },
      loading: false,
      error: null,
      success: null,
      account: null
    }
  },
  methods: {
    async connectWallet() {
      if (window.ethereum) {
        try {
          const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
          this.account = accounts[0];
        } catch (err) {
          this.error = "Failed to connect wallet: " + err.message;
        }
      } else {
        this.error = "MetaMask is not installed!";
      }
    },
    shortenAddress(address) {
      return address.slice(0, 6) + "..." + address.slice(-4);
    },
    async submitRegistration() {
      this.error = null;
      this.success = null;
      if (!this.account) {
        await this.connectWallet();
        if (!this.account) return;
      }
      this.loading = true;
      try {
        const provider = new BrowserProvider(window.ethereum);
        const signer = await provider.getSigner();
        const contract = new Contract(contractAddress, PropertyManagement.abi, signer);
        const approvers = [this.account];
        const tx = await contract.registerProperty(
          this.account,
          this.form.propertyAddress,
          this.form.location,
          this.form.floors,
          parseEther(this.form.price.toString()),
          this.form.propertyType,
          approvers,
          this.form.requiredApprovals
        );
        await tx.wait();
        this.success = "Property registered successfully!";
        this.form = { propertyAddress: '', location: '', floors: 0, price: '', propertyType: 1, requiredApprovals: 1 };
      } catch (err) {
        this.error = "Error registering property: " + err.message;
        console.error(err);
      } finally {
        this.loading = false;
      }
    }
  }
}
</script>

<style scoped>
.view-container {
  max-width: 600px;
  margin: 2rem auto;
  padding: 20px;
  background: #f5f5f5;
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  justify-content: space-between;
}

.wallet-container, .wallet-info {
  text-align: right;
  margin-bottom: 1rem;
}

.connect-btn {
  background-color: #ffca28;
  border: none;
  padding: 0.75rem 1.5rem;
  font-size: 1rem;
  font-weight: bold;
  border-radius: 4px;
  cursor: pointer;
}

.form-container {
  background: #fff;
  max-width: 600px;
  width: 100%;
  margin: 0 auto;
  padding: 2rem;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  border-radius: 8px;
}

.form-container h2 {
  text-align: center;
  margin-bottom: 1.5rem;
  color: #283e51;
}

.form-group {
  margin-bottom: 1rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
}

.form-group input, .form-group select {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #ccc;
  border-radius: 4px;
  box-sizing: border-box;
}

.action-btn {
  width: 100%;
  padding: 1rem;
  background-color: #283e51;
  color: #fff;
  border: none;
  border-radius: 4px;
  font-size: 1.1rem;
  font-weight: bold;
  cursor: pointer;
  margin-top: 1rem;
}

.error-message {
  color: red;
  text-align: center;
  margin-top: 1rem;
}

.success-message {
  color: green;
  text-align: center;
  margin-top: 1rem;
}

.footer {
  text-align: center;
  padding: 1rem;
  font-size: 0.9rem;
  color: #666;
  border-top: 1px solid #eee;
  margin-top: 2rem;
}
</style>
