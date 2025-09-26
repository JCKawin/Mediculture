import { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { 
  Search, 
  Package, 
  AlertTriangle, 
  Calendar,
  Filter,
  RefreshCw,
  Plus
} from 'lucide-react';
import { useMedications } from '@/hooks/useApi';
import { Medication } from '@/types/pharmacy';

export const InventoryManagement = () => {
  const { data: medications, loading, refetch } = useMedications();
  const [searchTerm, setSearchTerm] = useState('');
  const [categoryFilter, setCategoryFilter] = useState<string>('all');
  const [stockFilter, setStockFilter] = useState<string>('all');

  // Get unique categories for filter dropdown
  const categories = [...new Set(medications.map(med => med.category))];

  // Filter medications based on search and filters
  const filteredMedications = medications.filter(med => {
    const matchesSearch = med.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         med.genericName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         med.category.toLowerCase().includes(searchTerm.toLowerCase());
    
    const matchesCategory = categoryFilter === 'all' || med.category === categoryFilter;
    
    const matchesStock = stockFilter === 'all' ||
                        (stockFilter === 'low' && med.stockQuantity <= med.minStockLevel) ||
                        (stockFilter === 'sufficient' && med.stockQuantity > med.minStockLevel);

    return matchesSearch && matchesCategory && matchesStock;
  });

  const getStockStatus = (medication: Medication) => {
    if (medication.stockQuantity <= medication.minStockLevel) {
      return {
        label: 'Low Stock',
        variant: medication.stockQuantity <= medication.minStockLevel * 0.5 ? 'critical' : 'warning'
      };
    }
    return { label: 'In Stock', variant: 'success' };
  };

  const isExpiringSoon = (expiryDate: string) => {
    const expiry = new Date(expiryDate);
    const now = new Date();
    const threeDaysFromNow = new Date(now.getTime() + (30 * 24 * 60 * 60 * 1000)); // 30 days
    return expiry <= threeDaysFromNow;
  };

  const formatCurrency = (amount: number) => `$${amount.toFixed(2)}`;

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between space-y-4 sm:space-y-0">
        <div>
          <h1 className="text-3xl font-bold text-foreground">Inventory Management</h1>
          <p className="text-muted-foreground">Monitor and manage medication stock levels</p>
        </div>
        <div className="flex space-x-2">
          <Button variant="outline" size="sm">
            <RefreshCw className="h-4 w-4 mr-2" />
            Refresh
          </Button>
          <Button size="sm">
            <Plus className="h-4 w-4 mr-2" />
            Add Medication
          </Button>
        </div>
      </div>

      {/* Filters */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center space-x-2">
            <Filter className="h-5 w-5" />
            <span>Search & Filter</span>
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex flex-col sm:flex-row space-y-4 sm:space-y-0 sm:space-x-4">
            <div className="flex-1">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                <Input
                  placeholder="Search medications..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-10"
                />
              </div>
            </div>
            <Select value={categoryFilter} onValueChange={setCategoryFilter}>
              <SelectTrigger className="w-full sm:w-48">
                <SelectValue placeholder="All Categories" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Categories</SelectItem>
                {categories.map(category => (
                  <SelectItem key={category} value={category}>{category}</SelectItem>
                ))}
              </SelectContent>
            </Select>
            <Select value={stockFilter} onValueChange={setStockFilter}>
              <SelectTrigger className="w-full sm:w-48">
                <SelectValue placeholder="Stock Status" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Stock Levels</SelectItem>
                <SelectItem value="low">Low Stock</SelectItem>
                <SelectItem value="sufficient">Sufficient Stock</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </CardContent>
      </Card>

      {/* Inventory Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {filteredMedications.map((medication) => {
          const stockStatus = getStockStatus(medication);
          const expiringSoon = isExpiringSoon(medication.expiryDate);
          
          return (
            <Card key={medication.id} className="relative">
              <CardHeader className="pb-3">
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <CardTitle className="text-lg">{medication.name}</CardTitle>
                    {medication.genericName && (
                      <CardDescription>{medication.genericName}</CardDescription>
                    )}
                  </div>
                  <Badge variant={stockStatus.variant as any} className="ml-2">
                    {stockStatus.label}
                  </Badge>
                </div>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="flex items-center justify-between">
                  <span className="text-sm font-medium">Category:</span>
                  <Badge variant="outline">{medication.category}</Badge>
                </div>

                <div className="grid grid-cols-2 gap-4 text-sm">
                  <div>
                    <span className="text-muted-foreground">Stock:</span>
                    <p className="font-semibold">{medication.stockQuantity} {medication.unit}</p>
                  </div>
                  <div>
                    <span className="text-muted-foreground">Min Level:</span>
                    <p className="font-semibold">{medication.minStockLevel} {medication.unit}</p>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4 text-sm">
                  <div>
                    <span className="text-muted-foreground">Price:</span>
                    <p className="font-semibold">{formatCurrency(medication.price)}</p>
                  </div>
                  <div>
                    <span className="text-muted-foreground">Batch:</span>
                    <p className="font-mono text-xs">{medication.batchNumber}</p>
                  </div>
                </div>

                <div className="flex items-center justify-between pt-2 border-t">
                  <div className="flex items-center space-x-1">
                    <Calendar className="h-4 w-4 text-muted-foreground" />
                    <span className="text-sm text-muted-foreground">
                      Exp: {new Date(medication.expiryDate).toLocaleDateString()}
                    </span>
                    {expiringSoon && (
                      <AlertTriangle className="h-4 w-4 text-warning ml-1" />
                    )}
                  </div>
                  <Button variant="outline" size="sm">
                    Update
                  </Button>
                </div>

                {medication.description && (
                  <p className="text-xs text-muted-foreground border-t pt-2">
                    {medication.description}
                  </p>
                )}
              </CardContent>
            </Card>
          );
        })}
      </div>

      {filteredMedications.length === 0 && (
        <Card>
          <CardContent className="text-center py-8">
            <Package className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
            <h3 className="text-lg font-semibold text-foreground mb-2">No medications found</h3>
            <p className="text-muted-foreground">Try adjusting your search criteria or filters.</p>
          </CardContent>
        </Card>
      )}
    </div>
  );
};