const mongoose = require('mongoose');

const appointmentSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true
  },
  doctorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Doctor',
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
  specialty: {
    type: String,
    required: true
  },
  symptoms: [String],
  notes: String,
  status: {
    type: String,
    enum: ['scheduled', 'confirmed', 'completed', 'cancelled', 'rescheduled'],
    default: 'scheduled'
  },
  fees: {
    consultation: Number,
    total: Number
  },
  prescription: {
    medicines: [{
      medicineId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Medicine'
      },
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
