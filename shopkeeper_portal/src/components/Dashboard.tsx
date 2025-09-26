import { useEffect, useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { 
  Package, 
  AlertTriangle, 
  Clock, 
  AlertCircle,
  CheckCircle,
  DollarSign,
  TrendingUp,
  Activity
} from 'lucide-react';
import { fetchDashboardStats } from '@/lib/utils';


interface DashboardProps {
  onSectionChange: (section: string) => void;
}

export const Dashboard = ({ onSectionChange }: DashboardProps) => {
  const [stats, setStats] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchDashboardStats()
      .then(data => {
        setStats(data);
        setLoading(false);
      })
      .catch(err => {
        setError(err.message);
        setLoading(false);
      });
  }, []);

  const recentOrders = mockOrders.slice(0, 3);
  const criticalAlerts = mockAlerts.filter(alert => alert.severity === 'critical');

  const StatCard = ({ title, value, description, icon: Icon, color = "primary", trend }: {
    title: string;
    value: string | number;
    description: string;
    icon: any;
    color?: string;
    trend?: string;
  }) => (
    <Card className="relative overflow-hidden">
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
        <CardTitle className="text-sm font-medium text-muted-foreground">{title}</CardTitle>
        <Icon className={`h-4 w-4 text-${color}`} />
      </CardHeader>
      <CardContent>
        <div className="text-2xl font-bold text-foreground">{value}</div>
        <p className="text-xs text-muted-foreground mt-1">{description}</p>
        {trend && (
          <div className="flex items-center mt-2">
            <TrendingUp className="h-3 w-3 text-success mr-1" />
            <span className="text-xs text-success">{trend}</span>
          </div>
        )}
      </CardContent>
    </Card>
  );

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'sos': return 'critical';
      case 'urgent': return 'warning';
      default: return 'secondary';
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'ready': return 'success';
      case 'processing': return 'warning';
      case 'pending': return 'secondary';
      default: return 'secondary';
    }
  };

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-foreground">Dashboard</h1>
        <p className="text-muted-foreground">Pharmacy management system overview</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          title="Total Medications"
          value={stats.totalMedications}
          description="Items in inventory"
          icon={Package}
          color="primary"
        />
        <StatCard
          title="Low Stock Alerts"
          value={stats.lowStockItems}
          description="Require attention"
          icon={AlertTriangle}
          color="warning"
        />
        <StatCard
          title="Pending Orders"
          value={stats.pendingOrders}
          description="Awaiting processing"
          icon={Clock}
          color="secondary"
        />
        <StatCard
          title="Completed Today"
          value={stats.completedToday}
          description="Orders dispensed"
          icon={CheckCircle}
          color="success"
          trend="+12% from yesterday"
        />
      </div>

      {/* Critical Alerts */}
      {criticalAlerts.length > 0 && (
        <Card className="border-critical">
          <CardHeader>
            <CardTitle className="flex items-center space-x-2 text-critical">
              <AlertCircle className="h-5 w-5" />
              <span>Critical Alerts</span>
            </CardTitle>
            <CardDescription>Immediate attention required</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {criticalAlerts.map((alert) => (
                <div key={alert.id} className="flex items-center justify-between p-3 bg-critical/10 rounded-lg border border-critical/20">
                  <div>
                    <p className="font-medium text-foreground">{alert.medicationName}</p>
                    <p className="text-sm text-muted-foreground">{alert.message}</p>
                  </div>
                  <Button 
                    size="sm" 
                    variant="outline"
                    onClick={() => onSectionChange('inventory')}
                  >
                    Review
                  </Button>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Recent Orders */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center justify-between">
              <span>Recent Orders</span>
              <Button 
                variant="outline" 
                size="sm"
                onClick={() => onSectionChange('orders')}
              >
                View All
              </Button>
            </CardTitle>
            <CardDescription>Latest prescription orders</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {recentOrders.map((order) => (
                <div key={order.id} className="flex items-center justify-between p-3 bg-muted/50 rounded-lg">
                  <div className="flex-1">
                    <div className="flex items-center space-x-2 mb-1">
                      <p className="font-medium text-foreground">{order.patientName}</p>
                      <Badge variant={getPriorityColor(order.priority) as any}>
                        {order.priority.toUpperCase()}
                      </Badge>
                    </div>
                    <p className="text-sm text-muted-foreground">
                      {order.medications.length} medication(s) • {order.id}
                    </p>
                  </div>
                  <Badge variant={getStatusColor(order.status) as any}>
                    {order.status}
                  </Badge>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Quick Actions */}
        <Card>
          <CardHeader>
            <CardTitle>Quick Actions</CardTitle>
            <CardDescription>Common pharmacy tasks</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-2 gap-3">
              <Button 
                variant="outline" 
                className="h-20 flex flex-col space-y-2"
                onClick={() => onSectionChange('new-order')}
              >
                <Package className="h-6 w-6" />
                <span className="text-sm">New Order</span>
              </Button>
              <Button 
                variant="outline" 
                className="h-20 flex flex-col space-y-2"
                onClick={() => onSectionChange('inventory')}
              >
                <Activity className="h-6 w-6" />
                <span className="text-sm">Check Stock</span>
              </Button>
              <Button 
                variant="outline" 
                className="h-20 flex flex-col space-y-2"
                onClick={() => onSectionChange('orders')}
              >
                <Clock className="h-6 w-6" />
                <span className="text-sm">Order Status</span>
              </Button>
              <Button 
                variant="outline" 
                className="h-20 flex flex-col space-y-2"
                onClick={() => onSectionChange('alerts')}
              >
                <AlertTriangle className="h-6 w-6" />
                <span className="text-sm">View Alerts</span>
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
};