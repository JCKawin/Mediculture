// models/Medicine.js
const mongoose = require('mongoose');

const medicineSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  genericName: String,
  manufacturer: String,
  category: {
    type: String,
    required: true,
    enum: ['Pain Relief', 'Vitamins', 'Antibiotics', 'Skincare', 'Heart Health', 'Diabetes', 'Other']
  },
  description: String,
  price: {
    type: Number,
    required: true
  },
  originalPrice: Number,
  discount: {
    type: Number,
    default: 0
  },
  dosage: String,
  packaging: String,
  sideEffects: [String],
  contraindications: [String],
  prescriptionRequired: {
    type: Boolean,
    default: false
  },
  stock: {
    type: Number,
    default: 0
  },
  images: [String],
  rating: {
    average: {
      type: Number,
      default: 0,
      min: 0,
      max: 5
    },
    count: {
      type: Number,
      default: 0
    }
  },
  isActive: {
    type: Boolean,
    default: true
  },
  tags: [String]
}, {
  timestamps: true
});

// Index for better search performance
medicineSchema.index({ name: 'text', genericName: 'text', category: 'text' });

module.exports = mongoose.model('Medicine', medicineSchema);
