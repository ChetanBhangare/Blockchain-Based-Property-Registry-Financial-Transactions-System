// Load environment variables from .env file
//require('dotenv').config();
require('dotenv').config({ path: '../.env' });
// Import required packages
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');       // Security middleware to set various HTTP headers
const morgan = require('morgan');       // Logging middleware for HTTP request logging

// Import your property routes for CRUD operations
const propertyRoutes = require('./routes/property.routes');

const app = express();

// --- Production-Ready Middleware Setup ---

// 1. Security Enhancements:
// Helmet helps secure your Express apps by setting various HTTP headers.
app.use(helmet());

// 2. Enable CORS:
// This allows your frontend (which might run on a different domain/port) to access your backend.
app.use(cors());

// 3. Body Parser:
// Built-in middleware to parse JSON bodies in incoming requests.
app.use(express.json());

// 4. Logging:
// Morgan logs HTTP requests in a standard Apache combined log format.
// This is useful for monitoring and debugging production traffic.
app.use(morgan('combined'));

// --- Database Connection ---

// Connect to MongoDB using connection string from your .env file
mongoose.connect(process.env.MONGO_URI)
.then(() => console.log("Connected to MongoDB"))
.catch(err => console.error("MongoDB connection error:", err));

// --- Define Routes ---

// Health Check Endpoint:
// A simple route to verify that the server is running.
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'OK', message: 'Server is running' });
});

// Property Routes:
// All CRUD operations for properties will be handled by these routes.
app.use('/api/properties', propertyRoutes);

// --- Centralized Error Handling Middleware ---

// This middleware catches errors thrown by routes or middleware and sends a formatted JSON response.
app.use((err, req, res, next) => {
  console.error("Error encountered:", err);
  res.status(err.status || 500).json({
    error: {
      message: err.message || 'Internal Server Error'
    }
  });
});

// --- Start the Server ---

// Retrieve the port from environment variables or default to 3000.
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});





// The server.js file is the entry point for your Node.js application. It sets up the Express server, connects to the MongoDB database, defines routes, and starts the server listening on a specified port.

/*
Production-Ready Additions
Helmet:
Adds security-related HTTP headers to your responses, reducing vulnerabilities.

Morgan:
Provides logging for every HTTP request, which is vital for monitoring and troubleshooting in production.

Health Check Endpoint (/health):
A simple GET route that confirms your server is up and running.

Centralized Error Handling Middleware:
Catches errors across the application, logs them, and returns a consistent error response to the client.

CORS and Express JSON Parser:
Ensures that your backend can accept JSON payloads and handle cross-origin requests properly.
*/