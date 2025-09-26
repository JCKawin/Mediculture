// API service layer for MongoDB integration
import { ENV, COLLECTIONS } from '@/lib/env';
import type { Medication, Order, InventoryAlert, DashboardStats } from '@/types/pharmacy';

class ApiService {
  private baseUrl: string;

  constructor() {
    this.baseUrl = ENV.API_BASE_URL;
  }

  private async request<T>(endpoint: string, options?: RequestInit): Promise<T> {
    const url = `${this.baseUrl}${endpoint}`;
    
    const response = await fetch(url, {
      headers: {
        'Content-Type': 'application/json',
        ...options?.headers,
      },
      ...options,
    });

    if (!response.ok) {
      throw new Error(`API request failed: ${response.statusText}`);
    }

    return response.json();
  }

  // Dashboard APIs
  async getDashboardStats(): Promise<DashboardStats> {
    return this.request<DashboardStats>('/dashboard/stats');
  }

  // Medication APIs
  async getMedications(): Promise<Medication[]> {
    return this.request<Medication[]>(`/${COLLECTIONS.MEDICATIONS}`);
  }

  async getMedication(id: string): Promise<Medication> {
    return this.request<Medication>(`/${COLLECTIONS.MEDICATIONS}/${id}`);
  }

  async updateMedicationStock(id: string, quantity: number): Promise<Medication> {
    return this.request<Medication>(`/${COLLECTIONS.MEDICATIONS}/${id}`, {
      method: 'PATCH',
      body: JSON.stringify({ stockQuantity: quantity }),
    });
  }

  // Order APIs
  async getOrders(): Promise<Order[]> {
    return this.request<Order[]>(`/${COLLECTIONS.ORDERS}`);
  }

  async getOrder(id: string): Promise<Order> {
    return this.request<Order>(`/${COLLECTIONS.ORDERS}/${id}`);
  }

  async createOrder(order: Omit<Order, 'id' | 'createdAt' | 'updatedAt'>): Promise<Order> {
    return this.request<Order>(`/${COLLECTIONS.ORDERS}`, {
      method: 'POST',
      body: JSON.stringify(order),
    });
  }

  async updateOrderStatus(id: string, status: Order['status']): Promise<Order> {
    return this.request<Order>(`/${COLLECTIONS.ORDERS}/${id}`, {
      method: 'PATCH',
      body: JSON.stringify({ status }),
    });
  }

  // Alert APIs
  async getAlerts(): Promise<InventoryAlert[]> {
    return this.request<InventoryAlert[]>(`/${COLLECTIONS.ALERTS}`);
  }

  async dismissAlert(id: string): Promise<void> {
    await this.request(`/${COLLECTIONS.ALERTS}/${id}`, {
      method: 'DELETE',
    });
  }

  // Live updates - can be enhanced with WebSocket or Server-Sent Events
  async getRealtimeUpdates(callback: (data: any) => void): Promise<void> {
    // Placeholder for real-time connection
    // Implementation would depend on your backend (Socket.io, WebSockets, etc.)
    console.log('Real-time updates would be implemented here');
  }
}

export const apiService = new ApiService();