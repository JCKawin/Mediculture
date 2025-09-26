// server.js
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

// Import models
const User = require('./models/User');
const Medicine = require('./models/Medicine');
const Appointment = require('./models/Appointment');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// MongoDB connection
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb+srv://mediculture_user:YOUR_PASSWORD@cluster0.xxxxx.mongodb.net/mediculture?retryWrites=true&w=majority';

mongoose.connect(MONGODB_URI)
.then(() => console.log('✅ Connected to MongoDB Atlas'))
.catch(err => console.error('❌ MongoDB connection error:', err));

// Routes
app.get('/', (req, res) => {
  res.json({ 
    message: 'MEDICULTURE API is running with MongoDB!',
    timestamp: new Date().toISOString(),
    database: 'Connected to MongoDB Atlas'
  });
});

// ==================== USER ROUTES ====================

// Get user profile by Firebase UID
app.get('/api/users/profile', async (req, res) => {
  try {
    const { firebaseUid } = req.query;
    
    if (!firebaseUid) {
      return res.status(400).json({ error: 'Firebase UID is required' });
    }

    const user = await User.findOne({ firebaseUid });
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(user);
  } catch (error) {
    console.error('Error fetching user profile:', error);
    res.status(500).json({ error: 'Failed to fetch user profile' });
  }
});

// Create or update user profile
app.post('/api/users/profile', async (req, res) => {
  try {
    const userData = req.body;
    
    const user = await User.findOneAndUpdate(
      { firebaseUid: userData.firebaseUid },
      userData,
      { new: true, upsert: true }
    );

    res.json(user);
  } catch (error) {
    console.error('Error updating user profile:', error);
    res.status(500).json({ error: 'Failed to update user profile' });
  }
});

// Update user health stats
app.patch('/api/users/health-stats', async (req, res) => {
  try {
    const { firebaseUid, healthStats } = req.body;
    
    const user = await User.findOneAndUpdate(
      { firebaseUid },
      { 
        $set: { 
          healthStats: {
            ...healthStats,
            lastUpdated: new Date()
          }
        }
      },
      { new: true }
    );

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(user.healthStats);
  } catch (error) {
    console.error('Error updating health stats:', error);
    res.status(500).json({ error: 'Failed to update health stats' });
  }
});

// ==================== MEDICINE ROUTES ====================

// Get medicines with filtering and pagination
app.get('/api/medicines', async (req, res) => {
  try {
    const { 
      page = 1, 
      limit = 10, 
      category, 
      search, 
      sortBy = 'name',
      sortOrder = 'asc',
      prescriptionRequired
    } = req.query;

    let query = { isActive: true };
    
    // Category filter
    if (category && category !== 'All') {
      query.category = category;
    }
    
    // Search filter
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { genericName: { $regex: search, $options: 'i' } },
        { category: { $regex: search, $options: 'i' } }
      ];
    }

    // Prescription filter
    if (prescriptionRequired !== undefined) {
      query.prescriptionRequired = prescriptionRequired === 'true';
    }

    // Sort configuration
    const sortConfig = {};
    sortConfig[sortBy] = sortOrder === 'desc' ? -1 : 1;

    const medicines = await Medicine.find(query)
      .sort(sortConfig)
      .limit(parseInt(limit))
      .skip((parseInt(page) - 1) * parseInt(limit));

    const total = await Medicine.countDocuments(query);

    res.json({
      medicines,
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(total / parseInt(limit)),
        totalItems: total,
        itemsPerPage: parseInt(limit)
      }
    });
  } catch (error) {
    console.error('Error fetching medicines:', error);
    res.status(500).json({ error: 'Failed to fetch medicines' });
  }
});

// Get medicine by ID
app.get('/api/medicines/:id', async (req, res) => {
  try {
    const medicine = await Medicine.findById(req.params.id);
    
    if (!medicine || !medicine.isActive) {
      return res.status(404).json({ error: 'Medicine not found' });
    }

    res.json(medicine);
  } catch (error) {
    console.error('Error fetching medicine:', error);
    res.status(500).json({ error: 'Failed to fetch medicine' });
  }
});

// Get medicine categories
app.get('/api/medicines/categories/list', async (req, res) => {
  try {
    const categories = await Medicine.distinct('category', { isActive: true });
    res.json(categories);
  } catch (error) {
    console.error('Error fetching categories:', error);
    res.status(500).json({ error: 'Failed to fetch categories' });
  }
});

// ==================== APPOINTMENT ROUTES ====================

// Get user appointments
app.get('/api/appointments', async (req, res) => {
  try {
    const { firebaseUid, status, limit = 10 } = req.query;
    
    if (!firebaseUid) {
      return res.status(400).json({ error: 'Firebase UID is required' });
    }

    let query = { userId: firebaseUid };
    
    if (status) {
      query.status = status;
    }

    const appointments = await Appointment.find(query)
      .populate('prescription.medicines.medicineId', 'name genericName')
      .sort({ appointmentDate: -1 })
      .limit(parseInt(limit));

    res.json({ appointments });
  } catch (error) {
    console.error('Error fetching appointments:', error);
    res.status(500).json({ error: 'Failed to fetch appointments' });
  }
});

// Create new appointment
app.post('/api/appointments', async (req, res) => {
  try {
    const appointmentData = req.body;
    
    const appointment = new Appointment(appointmentData);
    await appointment.save();

    res.status(201).json(appointment);
  } catch (error) {
    console.error('Error creating appointment:', error);
    res.status(500).json({ error: 'Failed to create appointment' });
  }
});

// Update appointment status
app.patch('/api/appointments/:id/status', async (req, res) => {
  try {
    const { status } = req.body;
    
    const appointment = await Appointment.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true }
    );

    if (!appointment) {
      return res.status(404).json({ error: 'Appointment not found' });
    }

    res.json(appointment);
  } catch (error) {
    console.error('Error updating appointment:', error);
    res.status(500).json({ error: 'Failed to update appointment' });
  }
});

// ==================== UTILITY ROUTES ====================

// Test route
app.get('/api/test', (req, res) => {
  res.json({ 
    status: 'success', 
    message: 'API is working with MongoDB!',
    timestamp: new Date().toISOString()
  });
});

// Health check
app.get('/api/health', async (req, res) => {
  try {
    const dbStatus = mongoose.connection.readyState === 1 ? 'Connected' : 'Disconnected';
    const userCount = await User.countDocuments();
    const medicineCount = await Medicine.countDocuments();
    const appointmentCount = await Appointment.countDocuments();
    
    res.json({
      status: 'OK',
      database: dbStatus,
      collections: {
        users: userCount,
        medicines: medicineCount,
        appointments: appointmentCount
      },
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      status: 'Error',
      error: error.message
    });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`🚀 MEDICULTURE API running on http://localhost:${PORT}`);
  console.log(`📋 Health check: http://localhost:${PORT}/api/health`);
  console.log(`💊 Test medicines: http://localhost:${PORT}/api/medicines`);
  console.log(`👤 Database ready for real data!`);
});
