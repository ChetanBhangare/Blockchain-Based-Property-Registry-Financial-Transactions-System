/*
In this file, I create an Express router with endpoints for creating, reading, updating, and deleting property documents.
This is known as CRUD functionality (Create, Read, Update, Delete) in database systems.
The router uses the Property model to interact with the MongoDB database and perform these operations.
The endpoints also These endpoints expose a RESTful API that your front end (using Axios, for example) 
can call to retrieve and manage off‑chain property data.
*/

const express = require('express');
const router = express.Router();
const Property = require('../models/property.model');

// Create a new property
router.post('/', async (req, res) => {
  try {
    const newProperty = new Property(req.body);
    await newProperty.save();
    res.status(201).json(newProperty);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get all properties
router.get('/', async (req, res) => {
  try {
    const properties = await Property.find();
    res.json(properties);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get a single property by ID
router.get('/:id', async (req, res) => {
  try {
    const property = await Property.findById(req.params.id);
    if (!property) return res.status(404).json({ error: "Property not found" });
    res.json(property);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update a property by ID
router.put('/:id', async (req, res) => {
  try {
    const property = await Property.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!property) return res.status(404).json({ error: "Property not found" });
    res.json(property);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete a property by ID
router.delete('/:id', async (req, res) => {
  try {
    const property = await Property.findByIdAndDelete(req.params.id);
    if (!property) return res.status(404).json({ error: "Property not found" });
    res.json({ message: "Property deleted" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
