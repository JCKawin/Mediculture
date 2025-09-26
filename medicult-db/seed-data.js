// seed-data.js
const mongoose = require('mongoose');
require('dotenv').config();

const User = require('./models/User');
const Medicine = require('./models/Medicine');
const Appointment = require('./models/Appointment');

const MONGODB_URI = process.env.MONGODB_URI;

async function seedDatabase() {
  try {
    await mongoose.connect(MONGODB_URI);
    console.log('Connected to MongoDB');

    // Clear existing data
    await User.deleteMany({});
    await Medicine.deleteMany({});
    await Appointment.deleteMany({});

    // Sample Users
    const users = [
      {
        firebaseUid: 'user123',
        email: 'john.doe@example.com',
        displayName: 'John Doe',
        phoneNumber: '+1234567890',
        dateOfBirth: new Date('1990-01-15'),
        gender: 'male',
        height: '5\'8"',
        weight: '70kg',
        medicalInfo: {
          bloodGroup: 'O+',
          allergies: ['Peanuts', 'Shellfish'],
          chronicConditions: [],
          currentMedications: ['Vitamin D']
        },
        healthStats: {
          bloodPressure: '120/80',
          heartRate: '72',
          bloodSugar: '95',
          bmi: '22.4'
        },
        membershipType: 'Premium'
      }
    ];

    // Sample Medicines
    const medicines = [
      {
        name: 'Paracetamol',
        genericName: 'Acetaminophen',
        manufacturer: 'HealthCorp',
        category: 'Pain Relief',
        description: 'Effective pain relief and fever reducer',
        price: 25,
        originalPrice: 30,
        discount: 17,
        dosage: '500mg',
        packaging: '10 tablets',
        prescriptionRequired: false,
        stock: 100,
        rating: { average: 4.5, count: 150 }
      },
      {
        name: 'Vitamin D3',
        genericName: 'Cholecalciferol',
        manufacturer: 'VitaLife',
        category: 'Vitamins',
        description: 'Essential vitamin D supplement',
        price: 150,
        originalPrice: 180,
        discount: 17,
        dosage: '1000 IU',
        packaging: '30 capsules',
        prescriptionRequired: false,
        stock: 50,
        rating: { average: 4.8, count: 89 }
      },
      {
        name: 'Amoxicillin',
        genericName: 'Amoxicillin',
        manufacturer: 'MediPharm',
        category: 'Antibiotics',
        description: 'Broad-spectrum antibiotic',
        price: 120,
        dosage: '250mg',
        packaging: '21 capsules',
        prescriptionRequired: true,
        stock: 30,
        rating: { average: 4.2, count: 45 }
      }
    ];

    const savedUsers = await User.insertMany(users);
    const savedMedicines = await Medicine.insertMany(medicines);

    // Sample Appointments
    const appointments = [
      {
        userId: 'user123',
        doctorName: 'Dr. Sarah Smith',
        specialty: 'General Medicine',
        appointmentDate: new Date('2024-02-01T10:00:00Z'),
        timeSlot: '10:00 AM',
        type: 'consultation',
        symptoms: ['Headache', 'Fever'],
        status: 'scheduled',
        fees: { consultation: 300, total: 300 }
      },
      {
        userId: 'user123',
        doctorName: 'Dr. Mike Johnson',
        specialty: 'Cardiology',
        appointmentDate: new Date('2024-01-15T14:00:00Z'),
        timeSlot: '2:00 PM',
        type: 'checkup',
        status: 'completed',
        fees: { consultation: 500, total: 500 }
      }
    ];

    await Appointment.insertMany(appointments);

    console.log('✅ Sample data inserted successfully!');
    console.log(`📊 Created: ${savedUsers.length} users, ${savedMedicines.length} medicines, ${appointments.length} appointments`);
    
  } catch (error) {
    console.error('Error seeding database:', error);
  } finally {
    mongoose.connection.close();
  }
}

seedDatabase();
