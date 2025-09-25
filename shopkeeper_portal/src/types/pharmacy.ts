// Pharmacy Management System Type Definitions

export interface Medication {
  id: string;
  name: string;
  genericName?: string;
  category: string;
  stockQuantity: number;
  minStockLevel: number;
  unit: string;
  price: number;
  expiryDate: string;
  batchNumber: string;
  supplier: string;
  description?: string;
}

export interface Order {
  id: string;
  patientName: string;
  patientId?: string;
  medications: OrderItem[];
  status: OrderStatus;
  priority: OrderPriority;
  createdAt: string;
  updatedAt: string;
  assignedPharmacist?: string;
  notes?: string;
  estimatedCompletionTime?: string;
}

export interface OrderItem {
  medicationId: string;
  medicationName: string;
  quantity: number;
  unit: string;
  dosage?: string;
  instructions?: string;
}

export type OrderStatus = 
  | 'pending'
  | 'processing' 
  | 'ready'
  | 'dispensed'
  | 'cancelled';

export type OrderPriority = 
  | 'routine'
  | 'urgent' 
  | 'sos'; // Save Our Souls - Emergency priority

export interface InventoryAlert {
  id: string;
  medicationId: string;
  medicationName: string;
  type: 'low_stock' | 'expired' | 'expiring_soon';
  message: string;
  severity: 'info' | 'warning' | 'critical';
  createdAt: string;
}

export interface DashboardStats {
  totalMedications: number;
  lowStockItems: number;
  pendingOrders: number;
  sosOrders: number;
  completedToday: number;
  revenue: number;
}