<template>
  <div id="app">
    <!-- Header with Menu (left), Logo/Title (center), and Wallet Connection (right) -->
    <header class="header-bar">
      <div class="menu-section">
        <button class="dropdown-btn" @click="toggleDropdown">
          Menu <span v-if="dropdownOpen">&#9650;</span><span v-else>&#9660;</span>
        </button>
        <ul v-if="dropdownOpen" class="dropdown-menu">
          <li><router-link to="/listings" @click="closeDropdown">Property Listings</router-link></li>
          <li><router-link to="/register" @click="closeDropdown">Register Property</router-link></li>
          <li><router-link to="/list" @click="closeDropdown">List for Sale</router-link></li>
          <li><router-link to="/buy" @click="closeDropdown">Buy Property</router-link></li>
          <li><router-link to="/update-price" @click="closeDropdown">Update Price</router-link></li>
          <li><router-link to="/approve" @click="closeDropdown">Approve Transfer</router-link></li>
          <li><router-link to="/create-transfer" @click="closeDropdown">Create Transfer Request</router-link></li>
          <li><router-link to="/assign-roles" @click="closeDropdown">Assign Roles</router-link></li>
          <li><router-link to="/compliance" @click="closeDropdown">Compliance</router-link></li>
        </ul>
      </div>

      <div class="logo-title">
        <img src="./assets/logo.png" alt="Logo" class="logo" />
        <h1>Blockchain Property Management System</h1>
      </div>

      <div class="wallet-section">
        <button class="connect-btn" @click="connectWallet">
          {{ connectedAccount ? shortenAddress(connectedAccount) : "Connect Wallet" }}
        </button>
      </div>
    </header>

    <!-- Main Content Rendered by Vue Router -->
    <main>
      <router-view />
    </main>

    <!-- Footer -->
    <footer class="footer">
      <p>© Blockchain for Business Application Class 2025. All rights reserved.</p>
    </footer>
  </div>
</template>

<script>
export default {
  name: 'App',
  data() {
    return {
      connectedAccount: null,
      dropdownOpen: false
    }
  },
  methods: {
    async connectWallet() {
      if (window.ethereum) {
        try {
          const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
          this.connectedAccount = accounts[0];
          console.log("Connected account:", this.connectedAccount);
        } catch (err) {
          console.error("Error connecting wallet:", err);
        }
      } else {
        alert("Please install MetaMask!");
      }
    },
    shortenAddress(address) {
      return address.slice(0, 6) + "..." + address.slice(-4);
    },
    toggleDropdown() {
      this.dropdownOpen = !this.dropdownOpen;
    },
    closeDropdown() {
      this.dropdownOpen = false;
    }
  }
}
</script>

<style scoped>
/* Header Layout: a flex row with three sections */
.header-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: #283e51;
  padding: 1rem 2rem;
  color: #fff;
}

/* Left: Menu Section */
.menu-section {
  position: relative;
}
.dropdown-btn {
  background-color: #ffca28;
  border: none;
  padding: 0.5rem 1rem;
  font-weight: bold;
  border-radius: 4px;
  cursor: pointer;
}
.dropdown-menu {
  list-style: none;
  margin: 0;
  padding: 0.5rem 0;
  position: absolute;
  top: 110%;
  left: 0;
  background: #fff;
  border: 1px solid #ddd;
  border-radius: 4px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  z-index: 1000;
  width: 200px;
}
.dropdown-menu li {
  padding: 0.5rem 1rem;
}
.dropdown-menu li a {
  color: #283e51;
  text-decoration: none;
  font-weight: 500;
}
.dropdown-menu li:hover {
  background: #f0f0f0;
}

/* Center: Logo and Title */
.logo-title {
  display: flex;
  flex-direction: column;
  align-items: center;
}
.logo {
  height: 40px;
  margin-bottom: 0.5rem;
}
h1 {
  margin: 0;
  font-size: 1.5rem;
}

/* Right: Wallet Section */
.wallet-section {
  text-align: right;
}
.connect-btn {
  background-color: #ffca28;
  border: none;
  padding: 0.5rem 1rem;
  font-weight: bold;
  border-radius: 4px;
  cursor: pointer;
}

/* Main Content */
main {
  padding: 2rem;
}

/* Footer */
.footer {
  text-align: center;
  padding: 1rem;
  font-size: 0.9rem;
  background-color: #f0f0f0;
  border-top: 1px solid #ddd;
  margin-top: 2rem;
}
</style>
