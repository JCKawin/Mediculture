# 🔌 MongoDB API Integration Guide

This guide explains how to integrate your pharmacy management system with a MongoDB backend.

## 📋 Quick Setup

### 1. Environment Variables

Create a `.env` file in your project root with your MongoDB connection details:

```bash
# Copy from .env.example
cp .env.example .env
```

Then update the values:

```env
# MongoDB Configuration
VITE_MONGODB_URI=mongodb://your-mongodb-host:27017/pharmacy
VITE_MONGODB_DB_NAME=pharmacy_db

# API Configuration  
VITE_API_BASE_URL=https://your-api-domain.com/api
```

### 2. Replace Mock Data

The system currently uses mock data. To switch to real API calls:

```typescript
// In your components, replace:
import { mockOrders } from '@/data/mockData';

// With:
import { useOrders } from '@/hooks/useApi';
const { data: orders, loading, error } = useOrders();
```

## 🗂️ Database Schema

### Collections Structure

```javascript
// medications collection
{
  _id: ObjectId,
  name: String,
  genericName: String,
  category: String,
  stockQuantity: Number,
  minStockLevel: Number,
  unit: String,
  price: Number,
  expiryDate: Date,
  batchNumber: String,
  supplier: String,
  description: String
}

// orders collection
{
  _id: ObjectId,
  patientName: String,
  patientId: String,
  medications: [{
    medicationId: ObjectId,
    medicationName: String,
    quantity: Number,
    unit: String,
    dosage: String,
    instructions: String
  }],
  status: String, // 'pending', 'processing', 'ready', 'dispensed', 'cancelled'
  priority: String, // 'routine', 'urgent', 'sos'
  createdAt: Date,
  updatedAt: Date,
  assignedPharmacist: String,
  notes: String,
  estimatedCompletionTime: Date
}

// alerts collection
{
  _id: ObjectId,
  medicationId: ObjectId,
  medicationName: String,
  type: String, // 'low_stock', 'expired', 'expiring_soon'
  message: String,
  severity: String, // 'info', 'warning', 'critical'
  createdAt: Date
}
```

## 🚀 API Endpoints Required

Your backend should implement these endpoints:

### Dashboard
- `GET /api/dashboard/stats` - Dashboard statistics

### Medications
- `GET /api/medications` - List all medications
- `GET /api/medications/:id` - Get specific medication
- `PATCH /api/medications/:id` - Update medication stock

### Orders
- `GET /api/orders` - List all orders
- `GET /api/orders/:id` - Get specific order
- `POST /api/orders` - Create new order
- `PATCH /api/orders/:id` - Update order status

### Alerts
- `GET /api/alerts` - List all alerts
- `DELETE /api/alerts/:id` - Dismiss alert

## 💡 Usage Examples

### Creating a New Order

```typescript
import { useCreateOrder } from '@/hooks/useApi';

const { createOrder, loading } = useCreateOrder();

const handleSubmit = async (orderData) => {
  try {
    const newOrder = await createOrder({
      patientName: "John Doe",
      medications: [
        {
          medicationId: "507f1f77bcf86cd799439011",
          medicationName: "Aspirin",
          quantity: 30,
          unit: "tablets",
          dosage: "100mg",
          instructions: "Take once daily"
        }
      ],
      status: "pending",
      priority: "routine"
    });
    console.log('Order created:', newOrder);
  } catch (error) {
    console.error('Failed to create order:', error);
  }
};
```

### Fetching Live Data

```typescript
import { useOrders, useAlerts } from '@/hooks/useApi';

function OrdersComponent() {
  const { data: orders, loading, error, refetch } = useOrders();
  const { data: alerts } = useAlerts();

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;

  return (
    <div>
      <button onClick={refetch}>Refresh</button>
      {orders?.map(order => (
        <div key={order.id}>{order.patientName}</div>
      ))}
    </div>
  );
}
```

## 🔄 Real-time Updates

For live updates, implement WebSocket or Server-Sent Events:

```typescript
// In your backend
const io = require('socket.io')(server);

// Emit updates when data changes
io.emit('order-updated', updatedOrder);
io.emit('alert-created', newAlert);

// In your React app
useEffect(() => {
  const socket = io('your-backend-url');
  
  socket.on('order-updated', (order) => {
    // Update your local state
  });
  
  return () => socket.disconnect();
}, []);
```

## 🛡️ Error Handling

The API hooks include built-in error handling with toast notifications:

```typescript
const { data, loading, error } = useOrders();

// Errors are automatically displayed as toast notifications
// You can also handle them manually:
if (error) {
  // Custom error handling
}
```

## 🔧 Customization

### Adding New API Endpoints

1. Add to `src/services/api.ts`:

```typescript
async getPharmacists(): Promise<Pharmacist[]> {
  return this.request<Pharmacist[]>('/pharmacists');
}
```

2. Create a hook in `src/hooks/useApi.ts`:

```typescript
export function usePharmacists() {
  return useApi<Pharmacist[]>(() => apiService.getPharmacists());
}
```

3. Use in your components:

```typescript
const { data: pharmacists } = usePharmacists();
```

## 📝 Notes

- All API calls include proper TypeScript typing
- Error handling is automatic with toast notifications  
- Loading states are managed automatically
- The system gracefully falls back to mock data if API is unavailable
- Environment validation warns about missing configuration