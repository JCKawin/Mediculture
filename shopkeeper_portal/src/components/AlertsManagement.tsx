import { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { 
  AlertTriangle, 
  AlertCircle,
  Info,
  CheckCircle,
  Clock,
  Package,
  Calendar,
  Filter,
  RefreshCw,
  X
} from 'lucide-react';
import { useAlerts } from '@/hooks/useApi';
import { useToast } from '@/hooks/use-toast';
import { InventoryAlert } from '@/types/pharmacy';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';

export const AlertsManagement = () => {
  const { data: alerts, loading, refetch } = useAlerts();
  const { toast } = useToast();
  const [severityFilter, setSeverityFilter] = useState<string>('all');
  const [typeFilter, setTypeFilter] = useState<string>('all');

  // Filter alerts based on severity and type
  const filteredAlerts = (alerts || []).filter(alert => {
    const matchesSeverity = severityFilter === 'all' || alert.severity === severityFilter;
    const matchesType = typeFilter === 'all' || alert.type === typeFilter;
    return matchesSeverity && matchesType;
  });

  // Sort alerts by severity (critical first) and creation time
  const sortedAlerts = [...filteredAlerts].sort((a, b) => {
    const severityOrder = { critical: 0, warning: 1, info: 2 };
    const severityDiff = severityOrder[a.severity] - severityOrder[b.severity];
    
    if (severityDiff !== 0) return severityDiff;
    
    return new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime();
  });

  const getAlertConfig = (alert: InventoryAlert) => {
    const baseConfig = {
      low_stock: {
        icon: Package,
        title: 'Low Stock Alert',
        actionLabel: 'Reorder'
      },
      expired: {
        icon: AlertCircle,
        title: 'Expired Medication',
        actionLabel: 'Remove'
      },
      expiring_soon: {
        icon: Calendar,
        title: 'Expiring Soon',
        actionLabel: 'Review'
      }
    };

    const severityConfig = {
      critical: {
        variant: 'critical' as const,
        bgColor: 'bg-critical/10',
        borderColor: 'border-critical/20',
        textColor: 'text-critical-foreground'
      },
      warning: {
        variant: 'warning' as const,
        bgColor: 'bg-warning/10',
        borderColor: 'border-warning/20',
        textColor: 'text-warning-foreground'
      },
      info: {
        variant: 'secondary' as const,
        bgColor: 'bg-secondary/10',
        borderColor: 'border-secondary/20',
        textColor: 'text-secondary-foreground'
      }
    };

    return {
      ...baseConfig[alert.type],
      ...severityConfig[alert.severity]
    };
  };

  const handleDismissAlert = (alertId: string) => {
    // API call would be made here to dismiss the alert
    toast({
      title: "Alert Dismissed",
      description: "The alert has been successfully dismissed.",
    });
    refetch();
  };

  const handleResolveAlert = (alertId: string) => {
    // In a real app, this would trigger appropriate actions like reordering stock
    toast({
      title: "Alert Resolved",
      description: "The alert has been resolved.",
    });
    refetch();
  };

  const formatDateTime = (dateString: string) => {
    return new Date(dateString).toLocaleString();
  };

  const getSeverityStats = () => {
    const stats = {
      critical: alerts.filter(a => a.severity === 'critical').length,
      warning: alerts.filter(a => a.severity === 'warning').length,
      info: alerts.filter(a => a.severity === 'info').length
    };
    return stats;
  };

  const stats = getSeverityStats();

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between space-y-4 sm:space-y-0">
        <div>
          <h1 className="text-3xl font-bold text-foreground">Alerts Management</h1>
          <p className="text-muted-foreground">Monitor and manage system alerts</p>
        </div>
        <Button variant="outline" size="sm">
          <RefreshCw className="h-4 w-4 mr-2" />
          Refresh Alerts
        </Button>
      </div>

      {/* Alert Statistics */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Card className={stats.critical > 0 ? 'border-critical' : ''}>
          <CardContent className="flex items-center justify-between p-6">
            <div>
              <p className="text-2xl font-bold text-foreground">{stats.critical}</p>
              <p className="text-sm text-muted-foreground">Critical Alerts</p>
            </div>
            <AlertCircle className="h-8 w-8 text-critical" />
          </CardContent>
        </Card>
        
        <Card className={stats.warning > 0 ? 'border-warning' : ''}>
          <CardContent className="flex items-center justify-between p-6">
            <div>
              <p className="text-2xl font-bold text-foreground">{stats.warning}</p>
              <p className="text-sm text-muted-foreground">Warning Alerts</p>
            </div>
            <AlertTriangle className="h-8 w-8 text-warning" />
          </CardContent>
        </Card>
        
        <Card>
          <CardContent className="flex items-center justify-between p-6">
            <div>
              <p className="text-2xl font-bold text-foreground">{stats.info}</p>
              <p className="text-sm text-muted-foreground">Info Alerts</p>
            </div>
            <Info className="h-8 w-8 text-secondary" />
          </CardContent>
        </Card>
      </div>

      {/* Filters */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center space-x-2">
            <Filter className="h-5 w-5" />
            <span>Filter Alerts</span>
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex flex-col sm:flex-row space-y-4 sm:space-y-0 sm:space-x-4">
            <Select value={severityFilter} onValueChange={setSeverityFilter}>
              <SelectTrigger className="w-full sm:w-48">
                <SelectValue placeholder="All Severities" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Severities</SelectItem>
                <SelectItem value="critical">Critical</SelectItem>
                <SelectItem value="warning">Warning</SelectItem>
                <SelectItem value="info">Info</SelectItem>
              </SelectContent>
            </Select>
            
            <Select value={typeFilter} onValueChange={setTypeFilter}>
              <SelectTrigger className="w-full sm:w-48">
                <SelectValue placeholder="All Types" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Types</SelectItem>
                <SelectItem value="low_stock">Low Stock</SelectItem>
                <SelectItem value="expired">Expired</SelectItem>
                <SelectItem value="expiring_soon">Expiring Soon</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </CardContent>
      </Card>

      {/* Alerts List */}
      <div className="space-y-4">
        {sortedAlerts.map((alert) => {
          const config = getAlertConfig(alert);
          const AlertIcon = config.icon;

          return (
            <Card 
              key={alert.id} 
              className={`${config.bgColor} ${config.borderColor} transition-all hover:shadow-md`}
            >
              <CardHeader className="pb-3">
                <div className="flex items-start justify-between">
                  <div className="flex items-start space-x-3">
                    <div className={`p-2 rounded-lg ${config.bgColor}`}>
                      <AlertIcon className={`h-5 w-5 ${config.variant === 'critical' ? 'text-critical' : 
                                           config.variant === 'warning' ? 'text-warning' : 
                                           'text-secondary'}`} />
                    </div>
                    <div className="flex-1">
                      <div className="flex items-center space-x-2 mb-1">
                        <CardTitle className="text-lg">{alert.medicationName}</CardTitle>
                        <Badge variant={config.variant}>
                          {alert.severity.charAt(0).toUpperCase() + alert.severity.slice(1)}
                        </Badge>
                      </div>
                      <CardDescription className="text-sm">
                        {config.title} • {formatDateTime(alert.createdAt)}
                      </CardDescription>
                    </div>
                  </div>
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => handleDismissAlert(alert.id)}
                    className="text-muted-foreground hover:text-foreground"
                  >
                    <X className="h-4 w-4" />
                  </Button>
                </div>
              </CardHeader>
              
              <CardContent>
                <div className="space-y-4">
                  <p className="text-foreground">{alert.message}</p>
                  
                  <div className="flex items-center justify-between">
                    <div className="flex items-center space-x-2 text-sm text-muted-foreground">
                      <Clock className="h-4 w-4" />
                      <span>Alert ID: {alert.id}</span>
                    </div>
                    <div className="flex space-x-2">
                      <Button 
                        variant="outline" 
                        size="sm"
                        onClick={() => handleDismissAlert(alert.id)}
                      >
                        Dismiss
                      </Button>
                      <Button 
                        size="sm"
                        onClick={() => handleResolveAlert(alert.id)}
                      >
                        <CheckCircle className="h-4 w-4 mr-2" />
                        {config.actionLabel}
                      </Button>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          );
        })}
      </div>

      {sortedAlerts.length === 0 && (
        <Card>
          <CardContent className="text-center py-8">
            <CheckCircle className="h-12 w-12 text-success mx-auto mb-4" />
            <h3 className="text-lg font-semibold text-foreground mb-2">No alerts found</h3>
            <p className="text-muted-foreground">
              {alerts.length === 0 
                ? "All systems are running smoothly! No alerts to display."
                : "No alerts match your current filter criteria."
              }
            </p>
          </CardContent>
        </Card>
      )}
    </div>
  );
};