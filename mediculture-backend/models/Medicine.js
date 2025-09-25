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
    enum: ['Pain Relief', 'Vitamins', 'Antibiotics', 'Skincare', 'Other']
  },
  description: String,
  price: {
    type: Number,
    required: true
  },
  dosage: String,
  sideEffects: [String],
  contraindications: [String],
  prescription: {
    required: {
      type: Boolean,
      default: false
    }
  },
  stock: {
    type: Number,
    default: 0
  },
  images: [String],
  rating: {
    average: {
      type: Number,
      default: 0
    },
    count: {
      type: Number,
      default: 0
    }
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Medicine', medicineSchema);
