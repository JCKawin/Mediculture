// React hooks for API integration with proper error handling and loading states
import { useState, useEffect, useCallback } from 'react';
import { apiService } from '@/services/api';
import { useToast } from '@/hooks/use-toast';
import type { Medication, Order, InventoryAlert, DashboardStats } from '@/types/pharmacy';

// Generic API hook for consistent error handling and loading states
export function useApi<T>(
  apiCall: () => Promise<T>,
  dependencies: any[] = []
) {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const { toast } = useToast();

  const fetchData = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      const result = await apiCall();
      setData(result);
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'An error occurred';
      setError(errorMessage);
      toast({
        title: "Error",
        description: errorMessage,
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  }, dependencies);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  return { data, loading, error, refetch: fetchData };
}

// Specific hooks for different data types
export function useDashboardStats() {
  return useApi<DashboardStats>(() => apiService.getDashboardStats());
}

export function useMedications() {
  return useApi<Medication[]>(() => apiService.getMedications());
}

export function useOrders() {
  return useApi<Order[]>(() => apiService.getOrders());
}

export function useAlerts() {
  return useApi<InventoryAlert[]>(() => apiService.getAlerts());
}

// Hook for creating orders with optimistic updates
export function useCreateOrder() {
  const [loading, setLoading] = useState(false);
  const { toast } = useToast();

  const createOrder = async (orderData: Omit<Order, 'id' | 'createdAt' | 'updatedAt'>) => {
    try {
      setLoading(true);
      const newOrder = await apiService.createOrder(orderData);
      toast({
        title: "Success",
        description: "Order created successfully",
      });
      return newOrder;
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Failed to create order';
      toast({
        title: "Error",
        description: errorMessage,
        variant: "destructive",
      });
      throw error;
    } finally {
      setLoading(false);
    }
  };

  return { createOrder, loading };
}