<template>
    <div class="view-container">
      <!-- Wallet Connection Section -->
      <div class="wallet-container" v-if="!account">
        <button class="connect-btn" @click="connectWallet">Connect MetaMask</button>
      </div>
      <div class="wallet-info" v-else>
        <p>Connected Account: {{ shortenAddress(account) }}</p>
      </div>
  
      <!-- Compliance Check Form -->
      <div class="view-content">
        <h2>Check Property Compliance</h2>
        <form @submit.prevent="checkCompliance" class="form-container">
          <div class="form-group">
            <label for="tokenId">Token ID:</label>
            <input type="number" id="tokenId" v-model.number="tokenId" required />
          </div>
          <button type="submit" class="action-btn" :disabled="loading">
            {{ loading ? "Checking..." : "Check Compliance" }}
          </button>
        </form>
        <p v-if="result !== null" class="result-message">
          {{ result ? "Property meets compliance requirements." : "Property does NOT meet compliance requirements." }}
        </p>
        <p v-if="error" class="error-message">{{ error }}</p>
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
    name: 'Compliance',
    data() {
      return {
        tokenId: '',
        loading: false,
        error: null,
        result: null,
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
      async checkCompliance() {
        this.error = null;
        this.result = null;
        if (!this.account) {
          await this.connectWallet();
          if (!this.account) return;
        }
        this.loading = true;
        try {
          const provider = new BrowserProvider(window.ethereum);
          const signer = await provider.getSigner();
          const contract = new Contract(contractAddress, PropertyManagement.abi, signer);
          // Call checkCompliance; it returns a boolean value.
          this.result = await contract.checkCompliance(this.tokenId);
        } catch (err) {
          this.error = "Error checking compliance: " + err.message;
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
  .result-message {
    color: #283e51;
    text-align: center;
    margin-top: 1rem;
    font-weight: bold;
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
  