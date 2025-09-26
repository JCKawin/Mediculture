import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { 
  Package, 
  AlertTriangle, 
  Clock, 
  AlertCircle,
  CheckCircle,
  DollarSign,
  TrendingUp,
  Activity,
  Zap,
  RefreshCw
} from 'lucide-react';
import { useDashboardStats, useOrders, useAlerts } from '@/hooks/useApi';

interface DashboardProps {
  onSectionChange: (section: string) => void;
}

export const Dashboard = ({ onSectionChange }: DashboardProps) => {
  const { data: stats, loading: statsLoading } = useDashboardStats();
  const { data: orders, loading: ordersLoading } = useOrders();
  const { data: alerts, loading: alertsLoading } = useAlerts();
  
  const recentOrders = orders?.slice(0, 3) || [];
  const criticalAlerts = alerts?.filter(alert => alert.severity === 'critical') || [];

  const StatCard = ({ title, value, description, icon: Icon, color = "primary", trend, gradient }: {
    title: string;
    value: string | number;
    description: string;
    icon: any;
    color?: string;
    trend?: string;
    gradient?: boolean;
  }) => (
    <Card className={`relative overflow-hidden transition-all duration-300 hover:shadow-elegant hover:scale-[1.02] ${
      gradient ? 'bg-gradient-card' : ''
    }`}>
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
        <CardTitle className="text-sm font-medium text-muted-foreground">{title}</CardTitle>
        <div className={`p-2 rounded-lg ${
          color === 'critical' ? 'bg-gradient-critical' :
          color === 'warning' ? 'bg-gradient-warning' :
          color === 'success' ? 'bg-gradient-success' :
          'bg-gradient-primary'
        }`}>
          <Icon className="h-4 w-4 text-white" />
        </div>
      </CardHeader>
      <CardContent>
        <div className="text-3xl font-bold text-foreground mb-1">{value}</div>
        <p className="text-sm text-muted-foreground">{description}</p>
        {trend && (
          <div className="flex items-center mt-3 p-2 bg-success/10 rounded-lg">
            <TrendingUp className="h-3 w-3 text-success mr-1" />
            <span className="text-xs font-medium text-success">{trend}</span>
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

  return (
    <div className="space-y-8 animate-fade-in">
      {(statsLoading || ordersLoading || alertsLoading) && (
        <div className="text-center py-8">
          <RefreshCw className="h-8 w-8 animate-spin mx-auto mb-2" />
          <p>Loading dashboard data...</p>
        </div>
      )}
      
      {!stats && !statsLoading && (
        <Alert className="border-warning bg-warning/10">
          <AlertCircle className="h-4 w-4" />
          <AlertDescription>
            Unable to load dashboard data. Using fallback values.
          </AlertDescription>
        </Alert>
      )}
      {/* Modern Header with Live Status */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-4xl font-bold bg-gradient-primary bg-clip-text text-transparent">
            Dashboard
          </h1>
          <p className="text-muted-foreground text-lg">Real-time pharmacy operations center</p>
        </div>
        <Button variant="outline" size="sm" className="flex items-center space-x-2">
          <RefreshCw className="h-4 w-4" />
          <span>Live Updates</span>
        </Button>
      </div>

      {/* PRIORITY SECTION 1: Critical Alerts - Full Width at Top */}
      {criticalAlerts.length > 0 && (
        <Alert className="border-critical bg-gradient-critical/5 shadow-critical animate-pulse-glow">
          <AlertCircle className="h-5 w-5 text-critical" />
          <div className="flex items-center justify-between w-full">
            <div>
              <h3 className="text-lg font-semibold text-critical mb-2">⚠️ Critical Alerts Requiring Immediate Action</h3>
              <AlertDescription className="text-critical-foreground/80">
                {criticalAlerts.length} critical issue{criticalAlerts.length > 1 ? 's' : ''} detected
              </AlertDescription>
            </div>
            <Button 
              variant="outline" 
              className="border-critical text-critical hover:bg-critical hover:text-critical-foreground"
              onClick={() => onSectionChange('alerts')}
            >
              <Zap className="h-4 w-4 mr-2" />
              Review Now
            </Button>
          </div>
        </Alert>
      )}

      {/* PRIORITY SECTION 2: Recent Orders & Quick Stats - Side by Side */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Recent Orders - Takes 2/3 width */}
        <Card className="lg:col-span-2 shadow-elegant hover:shadow-glow transition-all duration-300">
          <CardHeader className="bg-gradient-card">
            <CardTitle className="flex items-center justify-between text-xl">
              <div className="flex items-center space-x-2">
                <Clock className="h-5 w-5 text-primary" />
                <span>Recent Orders</span>
                <Badge variant="secondary" className="ml-2">
                  {recentOrders.filter(o => o.priority === 'sos').length} SOS
                </Badge>
              </div>
              <Button 
                variant="outline" 
                size="sm"
                onClick={() => onSectionChange('orders')}
                className="hover:bg-primary hover:text-primary-foreground"
              >
                View All Orders
              </Button>
            </CardTitle>
            <CardDescription>Latest prescription orders with triage priority</CardDescription>
          </CardHeader>
          <CardContent className="p-6">
            <div className="space-y-4">
              {recentOrders.map((order, index) => (
                <div 
                  key={order.id} 
                  className={`flex items-center justify-between p-4 rounded-xl transition-all duration-300 hover:scale-[1.02] ${
                    order.priority === 'sos' 
                      ? 'bg-gradient-critical/10 border border-critical/20 shadow-critical' 
                      : order.priority === 'urgent'
                      ? 'bg-gradient-warning/10 border border-warning/20'
                      : 'bg-gradient-card hover:shadow-lg'
                  }`}
                  style={{ animationDelay: `${index * 100}ms` }}
                >
                  <div className="flex-1">
                    <div className="flex items-center space-x-3 mb-2">
                      {order.priority === 'sos' && <Zap className="h-4 w-4 text-critical animate-pulse" />}
                      <p className="font-semibold text-foreground text-lg">{order.patientName}</p>
                      <Badge 
                        variant={getPriorityColor(order.priority) as any}
                        className={`font-medium ${
                          order.priority === 'sos' ? 'animate-pulse' : ''
                        }`}
                      >
                        {order.priority.toUpperCase()}
                      </Badge>
                    </div>
                    <p className="text-sm text-muted-foreground">
                      <strong>{order.medications.length}</strong> medication(s) • Order #{order.id}
                    </p>
                  </div>
                  <div className="text-right">
                    <Badge 
                      variant={getStatusColor(order.status) as any}
                      className="text-sm font-medium mb-2"
                    >
                      {order.status}
                    </Badge>
                    <p className="text-xs text-muted-foreground">
                      {new Date(order.createdAt).toLocaleTimeString()}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Quick Actions - Takes 1/3 width */}
        <Card className="shadow-elegant">
          <CardHeader className="bg-gradient-card">
            <CardTitle className="flex items-center space-x-2">
              <Activity className="h-5 w-5 text-primary" />
              <span>Quick Actions</span>
            </CardTitle>
            <CardDescription>Essential pharmacy operations</CardDescription>
          </CardHeader>
          <CardContent className="p-6">
            <div className="space-y-3">
              <Button 
                variant="outline" 
                className="w-full h-16 flex items-center justify-start space-x-3 text-left hover:bg-primary hover:text-primary-foreground transition-all duration-300 hover:scale-[1.02]"
                onClick={() => onSectionChange('new-order')}
              >
                <Package className="h-6 w-6" />
                <div>
                  <div className="font-medium">New Order</div>
                  <div className="text-xs opacity-70">Create prescription</div>
                </div>
              </Button>
              <Button 
                variant="outline" 
                className="w-full h-16 flex items-center justify-start space-x-3 text-left hover:bg-warning hover:text-warning-foreground transition-all duration-300 hover:scale-[1.02]"
                onClick={() => onSectionChange('inventory')}
              >
                <Activity className="h-6 w-6" />
                <div>
                  <div className="font-medium">Check Stock</div>
                  <div className="text-xs opacity-70">Inventory status</div>
                </div>
              </Button>
              <Button 
                variant="outline" 
                className="w-full h-16 flex items-center justify-start space-x-3 text-left hover:bg-success hover:text-success-foreground transition-all duration-300 hover:scale-[1.02]"
                onClick={() => onSectionChange('orders')}
              >
                <Clock className="h-6 w-6" />
                <div>
                  <div className="font-medium">Order Status</div>
                  <div className="text-xs opacity-70">Track progress</div>
                </div>
              </Button>
              <Button 
                variant="outline" 
                className="w-full h-16 flex items-center justify-start space-x-3 text-left hover:bg-critical hover:text-critical-foreground transition-all duration-300 hover:scale-[1.02]"
                onClick={() => onSectionChange('alerts')}
              >
                <AlertTriangle className="h-6 w-6" />
                <div>
                  <div className="font-medium">View Alerts</div>
                  <div className="text-xs opacity-70">System notifications</div>
                </div>
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Key Stats Grid - Below Priority Sections */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          title="Total Medications"
          value={stats?.totalMedications || 0}
          description="Items in inventory"
          icon={Package}
          color="primary"
          gradient={true}
        />
        <StatCard
          title="Low Stock Alerts"
          value={stats?.lowStockItems || 0}
          description="Require attention"
          icon={AlertTriangle}
          color="warning"
          gradient={true}
        />
        <StatCard
          title="Pending Orders"
          value={stats?.pendingOrders || 0}
          description="Awaiting processing"
          icon={Clock}
          color="secondary"
          gradient={true}
        />
        <StatCard
          title="Completed Today"
          value={stats?.completedToday || 0}
          description="Orders dispensed"
          icon={CheckCircle}
          color="success"
          trend="+12% from yesterday"
          gradient={true}
        />
      </div>
    </div>
  );
};