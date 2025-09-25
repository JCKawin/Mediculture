// models/User.js
const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  firebaseUid: {
    type: String,
    required: true,
    unique: true
  },
  email: {
    type: String,
    required: true,
    unique: true
  },
  displayName: {
    type: String,
    required: true
  },
  phoneNumber: String,
  dateOfBirth: Date,
  gender: {
    type: String,
    enum: ['male', 'female', 'other']
  },
  height: String,
  weight: String,
  profilePicture: String,
  address: {
    street: String,
    city: String,
    state: String,
    zipCode: String,
    country: String
  },
  medicalInfo: {
    bloodGroup: {
      type: String,
      enum: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
    },
    allergies: [String],
    chronicConditions: [String],
    currentMedications: [String],
    emergencyContact: {
      name: String,
      phone: String,
      relationship: String
    }
  },
  healthStats: {
    bloodPressure: String,
    heartRate: String,
    bloodSugar: String,
    bmi: String,
    lastUpdated: {
      type: Date,
      default: Date.now
    }
  },
  preferences: {
    notifications: {
      type: Boolean,
      default: true
    },
    language: {
      type: String,
      default: 'English'
    },
    theme: {
      type: String,
      default: 'Light'
    }
  },
  membershipType: {
    type: String,
    enum: ['Basic', 'Premium', 'Gold'],
    default: 'Basic'
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('User', userSchema);
