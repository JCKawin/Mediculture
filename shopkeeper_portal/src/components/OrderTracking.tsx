import { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { 
  Clock, 
  User, 
  Package, 
  AlertCircle,
  CheckCircle,
  Search,
  Filter,
  RefreshCw,
  Eye
} from 'lucide-react';
import { useOrders } from '@/hooks/useApi';
import { Order, OrderPriority, OrderStatus } from '@/types/pharmacy';

export const OrderTracking = () => {
  const { data: orders, loading, refetch } = useOrders();
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<string>('all');
  const [priorityFilter, setPriorityFilter] = useState<string>('all');

  // Filter orders based on search and filters
  const filteredOrders = (orders || []).filter(order => {
    const matchesSearch = order.patientName.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         order.id.toLowerCase().includes(searchTerm.toLowerCase());
    
    const matchesStatus = statusFilter === 'all' || order.status === statusFilter;
    const matchesPriority = priorityFilter === 'all' || order.priority === priorityFilter;

    return matchesSearch && matchesStatus && matchesPriority;
  });

  const getPriorityConfig = (priority: OrderPriority) => {
    switch (priority) {
      case 'sos':
        return {
          label: 'SOS (Emergency)',
          variant: 'critical' as const,
          icon: AlertCircle,
          description: 'Highest priority - immediate attention required'
        };
      case 'urgent':
        return {
          label: 'Urgent',
          variant: 'warning' as const,
          icon: Clock,
          description: 'High priority - process as soon as possible'
        };
      case 'routine':
        return {
          label: 'Routine',
          variant: 'secondary' as const,
          icon: Package,
          description: 'Standard priority - normal processing time'
        };
    }
  };

  const getStatusConfig = (status: OrderStatus) => {
    switch (status) {
      case 'pending':
        return { label: 'Pending Review', variant: 'secondary' as const, icon: Clock };
      case 'processing':
        return { label: 'Processing', variant: 'warning' as const, icon: Package };
      case 'ready':
        return { label: 'Ready for Pickup', variant: 'success' as const, icon: CheckCircle };
      case 'dispensed':
        return { label: 'Dispensed', variant: 'success' as const, icon: CheckCircle };
      case 'cancelled':
        return { label: 'Cancelled', variant: 'destructive' as const, icon: AlertCircle };
    }
  };

  const formatDateTime = (dateString: string) => {
    return new Date(dateString).toLocaleString();
  };

  const getEstimatedCompletion = (order: Order) => {
    if (order.estimatedCompletionTime) {
      const estimated = new Date(order.estimatedCompletionTime);
      const now = new Date();
      const diffMinutes = Math.round((estimated.getTime() - now.getTime()) / (1000 * 60));
      
      if (diffMinutes > 0) {
        return `~${diffMinutes} minutes remaining`;
      } else {
        return 'Should be ready now';
      }
    }
    return null;
  };

  // Sort orders by priority (SOS first, then urgent, then routine) and creation time
  const sortedOrders = [...filteredOrders].sort((a, b) => {
    const priorityOrder = { sos: 0, urgent: 1, routine: 2 };
    const priorityDiff = priorityOrder[a.priority] - priorityOrder[b.priority];
    
    if (priorityDiff !== 0) return priorityDiff;
    
    return new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime();
  });

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between space-y-4 sm:space-y-0">
        <div>
          <h1 className="text-3xl font-bold text-foreground">Order Tracking</h1>
          <p className="text-muted-foreground">Monitor prescription orders with priority triage</p>
        </div>
        <Button variant="outline" size="sm">
          <RefreshCw className="h-4 w-4 mr-2" />
          Refresh Status
        </Button>
      </div>

      {/* Priority Info Banner */}
      <Card className="border-primary/20 bg-primary/5">
        <CardHeader>
          <CardTitle className="flex items-center space-x-2 text-primary">
            <AlertCircle className="h-5 w-5" />
            <span>Triage System Active</span>
          </CardTitle>
          <CardDescription>
            Orders are automatically prioritized: <strong>SOS (Emergency)</strong> → <strong>Urgent</strong> → <strong>Routine</strong>. 
            SOS orders are processed immediately and bypass standard queues.
          </CardDescription>
        </CardHeader>
      </Card>

      {/* Filters */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center space-x-2">
            <Filter className="h-5 w-5" />
            <span>Search & Filter Orders</span>
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex flex-col sm:flex-row space-y-4 sm:space-y-0 sm:space-x-4">
            <div className="flex-1">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                <Input
                  placeholder="Search by patient name or order ID..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-10"
                />
              </div>
            </div>
            <Select value={statusFilter} onValueChange={setStatusFilter}>
              <SelectTrigger className="w-full sm:w-48">
                <SelectValue placeholder="All Statuses" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Statuses</SelectItem>
                <SelectItem value="pending">Pending</SelectItem>
                <SelectItem value="processing">Processing</SelectItem>
                <SelectItem value="ready">Ready</SelectItem>
                <SelectItem value="dispensed">Dispensed</SelectItem>
                <SelectItem value="cancelled">Cancelled</SelectItem>
              </SelectContent>
            </Select>
            <Select value={priorityFilter} onValueChange={setPriorityFilter}>
              <SelectTrigger className="w-full sm:w-48">
                <SelectValue placeholder="All Priorities" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Priorities</SelectItem>
                <SelectItem value="sos">SOS (Emergency)</SelectItem>
                <SelectItem value="urgent">Urgent</SelectItem>
                <SelectItem value="routine">Routine</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </CardContent>
      </Card>

      {/* Orders List */}
      <div className="space-y-4">
        {sortedOrders.map((order) => {
          const priorityConfig = getPriorityConfig(order.priority);
          const statusConfig = getStatusConfig(order.status);
          const PriorityIcon = priorityConfig.icon;
          const StatusIcon = statusConfig.icon;
          const estimatedCompletion = getEstimatedCompletion(order);

          return (
            <Card 
              key={order.id} 
              className={`${order.priority === 'sos' ? 'border-critical bg-critical/5' : ''} transition-all hover:shadow-md`}
            >
              <CardHeader>
                <div className="flex flex-col sm:flex-row sm:items-start sm:justify-between space-y-2 sm:space-y-0">
                  <div className="flex-1">
                    <div className="flex items-center space-x-2 mb-2">
                      <CardTitle className="text-lg">{order.patientName}</CardTitle>
                      <Badge variant={priorityConfig.variant}>
                        <PriorityIcon className="h-3 w-3 mr-1" />
                        {priorityConfig.label}
                      </Badge>
                      <Badge variant={statusConfig.variant}>
                        <StatusIcon className="h-3 w-3 mr-1" />
                        {statusConfig.label}
                      </Badge>
                    </div>
                    <CardDescription className="flex items-center space-x-4">
                      <span>Order ID: {order.id}</span>
                      {order.patientId && <span>Patient ID: {order.patientId}</span>}
                    </CardDescription>
                  </div>
                  <Button variant="outline" size="sm">
                    <Eye className="h-4 w-4 mr-2" />
                    View Details
                  </Button>
                </div>
              </CardHeader>
              <CardContent className="space-y-4">
                {/* Medications */}
                <div>
                  <h4 className="font-medium text-foreground mb-2">Prescribed Medications:</h4>
                  <div className="space-y-2">
                    {order.medications.map((medication, index) => (
                      <div key={index} className="flex items-center justify-between p-2 bg-muted/50 rounded">
                        <div>
                          <p className="font-medium">{medication.medicationName}</p>
                          <p className="text-sm text-muted-foreground">
                            {medication.quantity} {medication.unit}
                            {medication.dosage && ` • ${medication.dosage}`}
                          </p>
                          {medication.instructions && (
                            <p className="text-xs text-muted-foreground italic">{medication.instructions}</p>
                          )}
                        </div>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Order Details */}
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 text-sm">
                  <div>
                    <span className="text-muted-foreground">Created:</span>
                    <p className="font-medium">{formatDateTime(order.createdAt)}</p>
                  </div>
                  <div>
                    <span className="text-muted-foreground">Last Updated:</span>
                    <p className="font-medium">{formatDateTime(order.updatedAt)}</p>
                  </div>
                  {order.assignedPharmacist && (
                    <div>
                      <span className="text-muted-foreground">Pharmacist:</span>
                      <p className="font-medium">{order.assignedPharmacist}</p>
                    </div>
                  )}
                </div>

                {/* Estimated Completion Time */}
                {estimatedCompletion && order.status === 'processing' && (
                  <div className="flex items-center space-x-2 p-2 bg-warning/10 rounded border border-warning/20">
                    <Clock className="h-4 w-4 text-warning" />
                    <span className="text-sm font-medium text-warning-foreground">
                      {estimatedCompletion}
                    </span>
                  </div>
                )}

                {/* Notes */}
                {order.notes && (
                  <div className="border-t pt-3">
                    <span className="text-sm text-muted-foreground">Notes:</span>
                    <p className="text-sm mt-1">{order.notes}</p>
                  </div>
                )}

                {/* Priority Description for SOS orders */}
                {order.priority === 'sos' && (
                  <div className="bg-critical/10 border border-critical/20 rounded p-3">
                    <div className="flex items-center space-x-2">
                      <AlertCircle className="h-4 w-4 text-critical" />
                      <span className="text-sm font-medium text-critical-foreground">
                        Emergency Priority - {priorityConfig.description}
                      </span>
                    </div>
                  </div>
                )}
              </CardContent>
            </Card>
          );
        })}
      </div>

      {sortedOrders.length === 0 && (
        <Card>
          <CardContent className="text-center py-8">
            <Package className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
            <h3 className="text-lg font-semibold text-foreground mb-2">No orders found</h3>
            <p className="text-muted-foreground">Try adjusting your search criteria or filters.</p>
          </CardContent>
        </Card>
      )}
    </div>
  );
};