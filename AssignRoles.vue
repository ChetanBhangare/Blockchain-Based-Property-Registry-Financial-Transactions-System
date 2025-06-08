<template>
    <div class="admin-view">
      <!-- Header Section -->
      <header class="admin-header">
        <div class="logo-section">
          <img src="@/assets/logo.png" alt="Logo" class="logo" />
          <h1>Admin Role Management</h1>
        </div>
        <div class="wallet-section">
          <button class="connect-btn" v-if="!account" @click="connectWallet">Connect MetaMask</button>
          <div v-else class="wallet-info">
            <p>Connected: {{ shortenAddress(account) }}</p>
          </div>
        </div>
      </header>
  
      <!-- Role Assignment Form -->
      <section class="role-assignment">
        <h2>Assign New Role</h2>
        <form @submit.prevent="assignRole" class="form-container">
          <div class="form-group">
            <label for="walletAddress">Wallet Address:</label>
            <input type="text" id="walletAddress" v-model="newRole.walletAddress" placeholder="0x..." required />
          </div>
          <div class="form-group">
            <label for="role">Role:</label>
            <select id="role" v-model="newRole.role" required>
              <option value="DEVELOPMENT_AUTHORITY">Development Authority</option>
              <option value="APPROVER_ROLE">Approver</option>
              <option value="BUYER_SELLER_ROLE">Buyer/Seller</option>
            </select>
          </div>
          <button type="submit" class="action-btn" :disabled="loading">
            {{ loading ? "Assigning..." : "Assign Role" }}
          </button>
        </form>
        <p v-if="error" class="error-message">{{ error }}</p>
        <p v-if="success" class="success-message">{{ success }}</p>
      </section>
  
      <!-- Role Assignments Table -->
      <section class="role-list">
        <h2>Current Role Assignments</h2>
        <table>
          <thead>
            <tr>
              <th>Wallet Address</th>
              <th>Role</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="assignment in roleAssignments" :key="assignment._id">
              <td>{{ assignment.walletAddress }}</td>
              <td>{{ assignment.role }}</td>
              <td>
                <button @click="revokeRole(assignment._id)" class="revoke-btn">Revoke</button>
                <button @click="openUpdateModal(assignment)" class="update-btn">Update</button>
              </td>
            </tr>
          </tbody>
        </table>
      </section>
  
      <!-- Update Modal -->
      <div v-if="showUpdateModal" class="modal-overlay">
        <div class="modal-content">
          <h3>Update Role for {{ currentAssignment.walletAddress }}</h3>
          <select v-model="currentAssignment.newRole" required>
            <option disabled value="">Select new role</option>
            <option value="DEVELOPMENT_AUTHORITY">Development Authority</option>
            <option value="APPROVER_ROLE">Approver</option>
            <option value="BUYER_SELLER_ROLE">Buyer/Seller</option>
          </select>
          <button class="action-btn" @click="updateRole">Update Role</button>
          <button class="cancel-btn" @click="closeUpdateModal">Cancel</button>
        </div>
      </div>
  
      <!-- Footer -->
      <footer class="footer">
        <p>© Blockchain for Business Application Class 2025. All rights reserved.</p>
      </footer>
    </div>
  </template>
  
  <script>
  import { BrowserProvider, Contract } from 'ethers';
  import axios from 'axios';
  import PropertyManagement from '../abis/PropertyManagement.json';
  
  // Contract address from environment variables (Vue CLI convention)
  const contractAddress = process.env.VUE_APP_CONTRACT_ADDRESS;
  
  export default {
    name: 'AdminRoles',
    data() {
      return {
        account: null,
        newRole: {
          walletAddress: '',
          role: ''
        },
        roleAssignments: [],
        loading: false,
        error: null,
        success: null,
        showUpdateModal: false,
        currentAssignment: {} // Used for role updates
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
      async fetchRoleAssignments() {
        try {
          // Query your backend API to get the stored role assignments
          const response = await axios.get('http://localhost:3000/api/roles');
          this.roleAssignments = response.data;
        } catch (err) {
          console.error("Error fetching role assignments:", err);
        }
      },
      async assignRole() {
        this.error = null;
        this.success = null;
        if (!this.account) {
          await this.connectWallet();
          if (!this.account) return;
        }
        this.loading = true;
        try {
          // On-chain role assignment via the smart contract
          const provider = new BrowserProvider(window.ethereum);
          const signer = await provider.getSigner();
          const contract = new Contract(contractAddress, PropertyManagement.abi, signer);
  
          // Map the role string to its corresponding constant from the contract
          const roleConstant = this.newRole.role === "DEVELOPMENT_AUTHORITY"
            ? await contract.DEVELOPMENT_AUTHORITY()
            : this.newRole.role === "APPROVER_ROLE"
            ? await contract.APPROVER_ROLE()
            : await contract.BUYER_SELLER_ROLE();
  
          const tx = await contract.grantRole(roleConstant, this.newRole.walletAddress);
          await tx.wait();
  
          // Save the role assignment off-chain via your backend
          await axios.post('http://localhost:3000/api/roles', {
            walletAddress: this.newRole.walletAddress,
            role: this.newRole.role
          });
          this.success = "Role assigned successfully!";
          this.newRole = { walletAddress: '', role: '' };
          this.fetchRoleAssignments();
        } catch (err) {
          this.error = "Error assigning role: " + err.message;
          console.error(err);
        } finally {
          this.loading = false;
        }
      },
      async revokeRole(id) {
        this.error = null;
        this.success = null;
        try {
          const assignment = this.roleAssignments.find(r => r._id === id);
          if (!assignment) throw new Error("Role assignment not found");
  
          const provider = new BrowserProvider(window.ethereum);
          const signer = await provider.getSigner();
          const contract = new Contract(contractAddress, PropertyManagement.abi, signer);
  
          const roleConstant = assignment.role === "DEVELOPMENT_AUTHORITY"
            ? await contract.DEVELOPMENT_AUTHORITY()
            : assignment.role === "APPROVER_ROLE"
            ? await contract.APPROVER_ROLE()
            : await contract.BUYER_SELLER_ROLE();
  
          const tx = await contract.revokeRole(roleConstant, assignment.walletAddress);
          await tx.wait();
  
          // Remove the role assignment from the backend database
          await axios.delete(`http://localhost:3000/api/roles/${id}`);
          this.success = "Role revoked successfully!";
          this.fetchRoleAssignments();
        } catch (err) {
          this.error = "Error revoking role: " + err.message;
          console.error(err);
        }
      },
      openUpdateModal(assignment) {
        this.currentAssignment = { ...assignment, newRole: '' };
        this.showUpdateModal = true;
      },
      closeUpdateModal() {
        this.showUpdateModal = false;
        this.currentAssignment = {};
      },
      async updateRole() {
        this.error = null;
        this.success = null;
        if (!this.currentAssignment.walletAddress || !this.currentAssignment.newRole) {
          this.error = "Please select a new role";
          return;
        }
        try {
          const provider = new BrowserProvider(window.ethereum);
          const signer = await provider.getSigner();
          const contract = new Contract(contractAddress, PropertyManagement.abi, signer);
  
          // Revoke the old role on-chain first
          const oldRoleConstant = this.currentAssignment.role === "DEVELOPMENT_AUTHORITY"
            ? await contract.DEVELOPMENT_AUTHORITY()
            : this.currentAssignment.role === "APPROVER_ROLE"
            ? await contract.APPROVER_ROLE()
            : await contract.BUYER_SELLER_ROLE();
  
          const revokeTx = await contract.revokeRole(oldRoleConstant, this.currentAssignment.walletAddress);
          await revokeTx.wait();
  
          // Grant the new role on-chain
          const newRoleConstant = this.currentAssignment.newRole === "DEVELOPMENT_AUTHORITY"
            ? await contract.DEVELOPMENT_AUTHORITY()
            : this.currentAssignment.newRole === "APPROVER_ROLE"
            ? await contract.APPROVER_ROLE()
            : await contract.BUYER_SELLER_ROLE();
  
          const grantTx = await contract.grantRole(newRoleConstant, this.currentAssignment.walletAddress);
          await grantTx.wait();
  
          // Update the assignment in the backend
          await axios.put(`http://localhost:3000/api/roles/${this.currentAssignment._id}`, {
            role: this.currentAssignment.newRole
          });
          this.success = "Role updated successfully!";
          this.closeUpdateModal();
          this.fetchRoleAssignments();
        } catch (err) {
          this.error = "Error updating role: " + err.message;
          console.error(err);
        }
      }
    },
    mounted() {
      this.fetchRoleAssignments();
    }
  }
  </script>
  
  <style scoped>
  .admin-view {
    max-width: 800px;
    margin: 20px auto;
    padding: 20px;
    background: #f5f5f5;
    font-family: 'Arial', sans-serif;
    display: flex;
    flex-direction: column;
    min-height: 100vh;
    justify-content: space-between;
  }
  .admin-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1rem;
  }
  .logo-section {
    display: flex;
    align-items: center;
    gap: 10px;
  }
  .logo {
    height: 40px;
  }
  .wallet-container,
  .wallet-info {
    text-align: right;
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
  .form-group input,
  .form-group select {
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
  .revoke-btn, .update-btn {
    padding: 0.5rem 1rem;
    border: none;
    border-radius: 4px;
    font-weight: bold;
    cursor: pointer;
    margin-right: 0.5rem;
  }
  .revoke-btn {
    background-color: #e74c3c;
    color: #fff;
  }
  .update-btn {
    background-color: #3498db;
    color: #fff;
  }
  .modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0,0,0,0.5);
    display: flex;
    justify-content: center;
    align-items: center;
  }
  .modal-content {
    background: #fff;
    padding: 2rem;
    border-radius: 8px;
    max-width: 400px;
    width: 100%;
    text-align: center;
  }
  .cancel-btn {
    margin-top: 1rem;
    background-color: #aaa;
    color: #fff;
    border: none;
    border-radius: 4px;
    padding: 0.5rem 1rem;
    cursor: pointer;
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
  