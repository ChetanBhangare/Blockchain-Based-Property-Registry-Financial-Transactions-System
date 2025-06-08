/*
In this file, I define a schema for the mongodb database that mirrors many of the on‑chain fields for a land or house property.
This schema includes fields for the property address, location, number of floors, price, and whether the property is for sale
(such as property address, location, floors, price, forSale status, etc.) 
I also include timestamps so that each document automatically records its creation and update times.
*/

const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const PropertySchema = new Schema({
  propertyAddress: { type: String, required: true },
  location: { type: String, required: true },
  floors: { type: Number, required: true },
  price: { type: Number, required: true }, // price stored in wei or converted to ETH as desired
  isForSale: { type: Boolean, default: false },
  approvers: [{ type: String }], // Ethereum addresses stored as strings
  requiredApprovals: { type: Number, required: true },
  propertyType: { 
    type: String, 
    enum: ["Land", "House"], 
    required: true 
  },
  additionalDetails: { type: Map, of: String }
}, { timestamps: true });

module.exports = mongoose.model('Property', PropertySchema);
