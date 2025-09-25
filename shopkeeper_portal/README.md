# Pharmacy Management System - MedPharm

A comprehensive pharmacy management system built for medical suites, featuring inventory management, order processing, and priority-based triage system.

## 🏥 System Overview

This web application provides a complete pharmacy management solution with the following core functionalities:

### 1. **Dashboard** 📊
- **Purpose**: Central command center with key metrics and system overview
- **Features**: 
  - Real-time statistics (total medications, low stock alerts, pending orders)
  - Recent order activity
  - Critical alerts display
  - Quick action buttons for common tasks
- **API Integration Points**: 
  - `GET /api/dashboard/stats` - Fetch dashboard statistics
  - `GET /api/dashboard/recent-orders` - Get recent order activity

### 2. **Inventory Management** 📦
- **Purpose**: Monitor and manage medication stock levels
- **Features**:
  - Real-time stock level monitoring
  - Search and filter medications by category, name, or stock status
  - Low stock alerts with color-coded priority levels
  - Expiry date tracking with early warning system
  - Batch number and supplier information
- **API Integration Points**:
  - `GET /api/inventory` - Fetch all medications
  - `PUT /api/inventory/{id}` - Update medication details
  - `POST /api/inventory` - Add new medication
  - `GET /api/inventory/alerts` - Get stock alerts

### 3. **Order Tracking with Triage System** 🚨
- **Purpose**: Live order status tracking with intelligent priority management
- **Features**:
  - **Priority-based triage system**:
    - **SOS (Save Our Souls)**: Emergency priority - bypasses all queues
    - **Urgent**: High priority - expedited processing
    - **Routine**: Standard processing time
  - Real-time order status updates (Pending → Processing → Ready → Dispensed)
  - Estimated completion times for active orders
  - Pharmacist assignment tracking
  - Patient information and prescription details
- **API Integration Points**:
  - `GET /api/orders` - Fetch all orders with filtering
  - `PUT /api/orders/{id}/status` - Update order status
  - `GET /api/orders/{id}` - Get detailed order information
  - `POST /api/orders/{id}/priority` - Update order priority

### 4. **Order Placement** 📝
- **Purpose**: Create new prescription orders with validation
- **Features**:
  - Patient information capture
  - Medication search and selection
  - Real-time stock validation
  - Dosage and instruction specification
  - Priority level assignment
  - Stock availability checking before order creation
- **API Integration Points**:
  - `POST /api/orders` - Create new order
  - `GET /api/medications/search` - Search available medications
  - `GET /api/medications/{id}/stock` - Check medication availability

### 5. **Alerts Management** ⚠️
- **Purpose**: Monitor and manage system-wide alerts
- **Features**:
  - **Alert Types**:
    - Low Stock: When inventory falls below minimum levels
    - Expired: Medications past expiry date
    - Expiring Soon: Medications nearing expiry (30-day warning)
  - **Severity Levels**: Critical, Warning, Info
  - Alert dismissal and resolution workflows
  - Automated alert generation based on system rules
- **API Integration Points**:
  - `GET /api/alerts` - Fetch active alerts
  - `POST /api/alerts/{id}/dismiss` - Dismiss alert
  - `POST /api/alerts/{id}/resolve` - Mark alert as resolved

## 🎨 Design System

The application uses a medical-grade design system with:

- **Primary Colors**: Professional blue (#3B82F6) for trust and reliability
- **Alert Colors**: 
  - Success Green (#10B981) for completed actions
  - Warning Orange (#F59E0B) for attention-needed items
  - Critical Red (#EF4444) for emergency situations
- **Typography**: Clean, readable fonts optimized for medical professionals
- **Responsive Design**: Works seamlessly on desktop, tablet, and mobile devices

## 🔧 Technical Architecture

### Frontend Stack
- **React 18** with TypeScript for type safety
- **Tailwind CSS** with custom design system
- **shadcn/ui** components with medical-themed customizations
- **React Router** for navigation
- **TanStack Query** for state management and API caching

### Component Structure
```
src/
├── components/
│   ├── Navigation.tsx          # Main navigation sidebar
│   ├── Dashboard.tsx           # Dashboard with metrics and overview
│   ├── InventoryManagement.tsx # Stock level monitoring
│   ├── OrderTracking.tsx       # Order status with triage system
│   ├── NewOrderForm.tsx        # Order creation form
│   ├── AlertsManagement.tsx    # System alerts management
│   └── ui/                     # Reusable UI components
├── types/
│   └── pharmacy.ts             # TypeScript definitions
├── data/
│   └── mockData.ts             # Sample data for development
└── pages/
    └── Index.tsx               # Main application entry point
```

### Data Models

#### Medication
```typescript
interface Medication {
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
}
```

#### Order
```typescript
interface Order {
  id: string;
  patientName: string;
  patientId?: string;
  medications: OrderItem[];
  status: 'pending' | 'processing' | 'ready' | 'dispensed' | 'cancelled';
  priority: 'routine' | 'urgent' | 'sos';
  createdAt: string;
  updatedAt: string;
  assignedPharmacist?: string;
  estimatedCompletionTime?: string;
}
```

#### Alert
```typescript
interface InventoryAlert {
  id: string;
  medicationId: string;
  medicationName: string;
  type: 'low_stock' | 'expired' | 'expiring_soon';
  severity: 'info' | 'warning' | 'critical';
  message: string;
  createdAt: string;
}
```

## 🚀 API Integration Guide

### Backend Requirements

To fully integrate this system, your backend should provide:

1. **Authentication Endpoints**
   - User login/logout
   - Role-based access control (Pharmacist, Admin, etc.)

2. **Real-time Features**
   - WebSocket connections for live order updates
   - Push notifications for critical alerts

3. **Database Schema**
   - Medications table with stock tracking
   - Orders table with status history
   - Alerts table with automated triggers
   - Users table with role management

### Environment Variables
```env
VITE_API_BASE_URL=https://your-api-domain.com/api
VITE_WS_URL=wss://your-websocket-domain.com
```

## 📱 Mobile Responsiveness

The application is fully responsive and optimized for:
- **Desktop**: Full sidebar navigation with multi-column layouts
- **Tablet**: Collapsible navigation with responsive grids
- **Mobile**: Bottom navigation with stacked layouts

## 🔒 Security Considerations

- Input validation on all forms
- Stock level validation before order processing
- Role-based access control ready for implementation
- Audit trail capabilities for all critical actions

## 🧪 Development & Testing

### Mock Data
The application includes comprehensive mock data for development and testing:
- Sample medications with various stock levels
- Test orders with different priorities and statuses
- Simulated alerts of different severity levels

### Sample Workflows

1. **Emergency Order Processing**:
   - New SOS order created → Immediately prioritized → Bypasses queue → Rapid processing

2. **Stock Management**:
   - Low stock detected → Alert generated → Reorder initiated → Stock replenished

3. **Order Lifecycle**:
   - Order placed → Validated → Queued by priority → Processed → Ready → Dispensed

## 🎯 Future Enhancements

Ready for integration with:
- **Supabase**: For authentication, database, and real-time features
- **Payment Processing**: For billing and insurance claims
- **Barcode Scanning**: For medication verification
- **Reporting System**: For analytics and compliance
- **External APIs**: Lab results, patient records, insurance verification

---

This system provides a solid foundation for pharmacy management while being easily extensible for additional medical suite requirements.