// models/Appointment.js
const mongoose = require('mongoose');

const appointmentSchema = new mongoose.Schema({
  userId: {
    type: String, // Firebase UID
    required: true
  },
  doctorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Doctor'
  },
  doctorName: {
    type: String,
    required: true
  },
  specialty: {
    type: String,
    required: true
  },
  appointmentDate: {
    type: Date,
    required: true
  },
  timeSlot: {
    type: String,
    required: true
  },
  type: {
    type: String,
    enum: ['consultation', 'checkup', 'follow-up', 'emergency'],
    default: 'consultation'
  },
  symptoms: [String],
  notes: String,
  status: {
    type: String,
    enum: ['scheduled', 'confirmed', 'completed', 'cancelled', 'rescheduled'],
    default: 'scheduled'
  },
  fees: {
    consultation: {
      type: Number,
      default: 0
    },
    total: {
      type: Number,
      default: 0
    }
  },
  prescription: {
    medicines: [{
      medicineId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Medicine'
      },
      medicineName: String,
      dosage: String,
      frequency: String,
      duration: String
    }],
    instructions: String
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Appointment', appointmentSchema);
