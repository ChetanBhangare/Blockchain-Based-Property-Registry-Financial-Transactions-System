<template>
  <div class="view-container">
    <!-- Wallet Connection Section -->
    <div class="wallet-container" v-if="!account">
      <button class="connect-btn" @click="connectWallet">Connect MetaMask</button>
    </div>
    <div class="wallet-info" v-else>
      <p>Connected Account: {{ shortenAddress(account) }}</p>
    </div>

    <!-- Approve Transfer Request Form -->
    <div class="view-content">
      <h2>Approve Transfer Request</h2>
      <form @submit.prevent="approveTransfer" class="form-container">
        <div class="form-group">
          <label for="requestId">Request ID:</label>
          <input type="number" id="requestId" v-model.number="requestId" required />
        </div>
        <button type="submit" class="action-btn" :disabled="loading">
          {{ loading ? "Approving..." : "Approve Request" }}
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
import { BrowserProvider, Contract } from 'ethers';
import PropertyManagement from '../abis/PropertyManagement.json';
const contractAddress = process.env.VUE_APP_CONTRACT_ADDRESS;
export default {
  name: 'ApproveTransfer',
  data() {
    return {
      requestId: '',
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
    async approveTransfer() {
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
        const tx = await contract.approveTransfer(this.requestId);
        await tx.wait();
        this.success = "Transfer request approved successfully!";
        this.requestId = '';
      } catch (err) {
        this.error = "Error approving transfer request: " + err.message;
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
.view-content {
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}
h2 {
  text-align: center;
  margin-bottom: 1.5rem;
  color: #283e51;
}
.form-container {
  display: flex;
  flex-direction: column;
}
.form-group {
  margin-bottom: 1rem;
}
.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
}
.form-group input {
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
