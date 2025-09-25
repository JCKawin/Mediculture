// Mock data for Pharmacy Management System demonstration

import { Medication, Order, InventoryAlert, DashboardStats } from '@/types/pharmacy';

export const mockMedications: Medication[] = [
  {
    id: '1',
    name: 'Amoxicillin 500mg',
    genericName: 'Amoxicillin',
    category: 'Antibiotics',
    stockQuantity: 150,
    minStockLevel: 50,
    unit: 'capsules',
    price: 0.25,
    expiryDate: '2025-06-15',
    batchNumber: 'AMX-2024-001',
    supplier: 'PharmaCorp Ltd',
    description: 'Broad-spectrum antibiotic for bacterial infections'
  },
  {
    id: '2',
    name: 'Lisinopril 10mg',
    genericName: 'Lisinopril',
    category: 'Cardiovascular',
    stockQuantity: 25,
    minStockLevel: 30,
    unit: 'tablets',
    price: 0.15,
    expiryDate: '2025-03-20',
    batchNumber: 'LIS-2024-002',
    supplier: 'MediSupply Inc',
    description: 'ACE inhibitor for hypertension and heart failure'
  },
  {
    id: '3',
    name: 'Metformin 850mg',
    genericName: 'Metformin HCl',
    category: 'Diabetes',
    stockQuantity: 200,
    minStockLevel: 75,
    unit: 'tablets',
    price: 0.18,
    expiryDate: '2025-08-10',
    batchNumber: 'MET-2024-003',
    supplier: 'Global Pharma',
    description: 'Antidiabetic medication for type 2 diabetes'
  },
  {
    id: '4',
    name: 'Ibuprofen 400mg',
    genericName: 'Ibuprofen',
    category: 'Pain Relief',
    stockQuantity: 8,
    minStockLevel: 25,
    unit: 'tablets',
    price: 0.12,
    expiryDate: '2024-12-31',
    batchNumber: 'IBU-2024-004',
    supplier: 'PharmaCorp Ltd',
    description: 'Non-steroidal anti-inflammatory drug (NSAID)'
  },
  {
    id: '5',
    name: 'Omeprazole 20mg',
    genericName: 'Omeprazole',
    category: 'Gastric',
    stockQuantity: 180,
    minStockLevel: 40,
    unit: 'capsules',
    price: 0.22,
    expiryDate: '2025-07-05',
    batchNumber: 'OME-2024-005',
    supplier: 'MediSupply Inc',
    description: 'Proton pump inhibitor for acid reflux and ulcers'
  }
];

export const mockOrders: Order[] = [
  {
    id: 'ORD-001',
    patientName: 'John Smith',
    patientId: 'PAT-001',
    medications: [
      { medicationId: '1', medicationName: 'Amoxicillin 500mg', quantity: 21, unit: 'capsules', dosage: '500mg', instructions: 'Take 3 times daily with food' }
    ],
    status: 'processing',
    priority: 'sos',
    createdAt: '2024-01-15T10:30:00Z',
    updatedAt: '2024-01-15T10:45:00Z',
    assignedPharmacist: 'Dr. Wilson',
    estimatedCompletionTime: '2024-01-15T11:15:00Z',
    notes: 'Patient allergic to penicillin - verified amoxicillin tolerance'
  },
  {
    id: 'ORD-002',
    patientName: 'Mary Johnson',
    patientId: 'PAT-002',
    medications: [
      { medicationId: '2', medicationName: 'Lisinopril 10mg', quantity: 30, unit: 'tablets', dosage: '10mg', instructions: 'Take once daily in morning' },
      { medicationId: '3', medicationName: 'Metformin 850mg', quantity: 60, unit: 'tablets', dosage: '850mg', instructions: 'Take twice daily with meals' }
    ],
    status: 'ready',
    priority: 'routine',
    createdAt: '2024-01-15T09:15:00Z',
    updatedAt: '2024-01-15T10:30:00Z',
    assignedPharmacist: 'Dr. Chen',
    notes: 'Regular monthly refill - no changes'
  },
  {
    id: 'ORD-003',
    patientName: 'Robert Davis',
    patientId: 'PAT-003',
    medications: [
      { medicationId: '4', medicationName: 'Ibuprofen 400mg', quantity: 20, unit: 'tablets', dosage: '400mg', instructions: 'Take as needed for pain, max 3 times daily' }
    ],
    status: 'pending',
    priority: 'urgent',
    createdAt: '2024-01-15T11:00:00Z',
    updatedAt: '2024-01-15T11:00:00Z',
    notes: 'Post-operative pain management'
  }
];

export const mockAlerts: InventoryAlert[] = [
  {
    id: 'ALERT-001',
    medicationId: '2',
    medicationName: 'Lisinopril 10mg',
    type: 'low_stock',
    message: 'Stock level below minimum threshold (25/30)',
    severity: 'warning',
    createdAt: '2024-01-15T08:00:00Z'
  },
  {
    id: 'ALERT-002',
    medicationId: '4',
    medicationName: 'Ibuprofen 400mg',
    type: 'low_stock',
    message: 'Critical stock level (8/25) - immediate reorder required',
    severity: 'critical',
    createdAt: '2024-01-15T09:30:00Z'
  },
  {
    id: 'ALERT-003',
    medicationId: '4',
    medicationName: 'Ibuprofen 400mg',
    type: 'expiring_soon',
    message: 'Batch IBU-2024-004 expires in 11 days',
    severity: 'warning',
    createdAt: '2024-01-15T07:15:00Z'
  }
];

export const mockDashboardStats: DashboardStats = {
  totalMedications: 247,
  lowStockItems: 12,
  pendingOrders: 8,
  sosOrders: 2,
  completedToday: 24,
  revenue: 1847.50
};