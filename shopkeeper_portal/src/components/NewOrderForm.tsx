import { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { 
  Plus, 
  Minus, 
  Search, 
  AlertCircle,
  CheckCircle,
  Trash2,
  User,
  Package
} from 'lucide-react';
import { useMedications, useCreateOrder } from '@/hooks/useApi';
import { Medication, OrderPriority, OrderItem } from '@/types/pharmacy';
import { useToast } from '@/hooks/use-toast';

export const NewOrderForm = () => {
  const { toast } = useToast();
  const { data: medications, loading: medicationsLoading } = useMedications();
  const { createOrder, loading: creatingOrder } = useCreateOrder();
  const [patientName, setPatientName] = useState('');
  const [patientId, setPatientId] = useState('');
  const [priority, setPriority] = useState<OrderPriority>('routine');
  const [notes, setNotes] = useState('');
  const [orderItems, setOrderItems] = useState<OrderItem[]>([]);
  const [medicationSearch, setMedicationSearch] = useState('');

  // Filter medications based on search term
  const filteredMedications = (medications || []).filter(med =>
    med.name.toLowerCase().includes(medicationSearch.toLowerCase()) ||
    med.genericName?.toLowerCase().includes(medicationSearch.toLowerCase()) ||
    med.category.toLowerCase().includes(medicationSearch.toLowerCase())
  );

  const addMedication = (medication: Medication) => {
    const existingItem = orderItems.find(item => item.medicationId === medication.id);
    
    if (existingItem) {
      // Increase quantity if medication already exists
      setOrderItems(orderItems.map(item =>
        item.medicationId === medication.id
          ? { ...item, quantity: item.quantity + 1 }
          : item
      ));
    } else {
      // Add new medication
      const newItem: OrderItem = {
        medicationId: medication.id,
        medicationName: medication.name,
        quantity: 1,
        unit: medication.unit,
        dosage: '',
        instructions: ''
      };
      setOrderItems([...orderItems, newItem]);
    }
    setMedicationSearch('');
  };

  const updateOrderItem = (medicationId: string, field: keyof OrderItem, value: any) => {
    setOrderItems(orderItems.map(item =>
      item.medicationId === medicationId
        ? { ...item, [field]: value }
        : item
    ));
  };

  const removeOrderItem = (medicationId: string) => {
    setOrderItems(orderItems.filter(item => item.medicationId !== medicationId));
  };

  const validateStock = (medicationId: string, quantity: number) => {
    const medication = medications?.find(med => med.id === medicationId);
    if (!medication) return false;
    return medication.stockQuantity >= quantity;
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    // Validation
    if (!patientName.trim()) {
      toast({
        title: "Validation Error",
        description: "Patient name is required",
        variant: "destructive"
      });
      return;
    }

    if (orderItems.length === 0) {
      toast({
        title: "Validation Error", 
        description: "At least one medication must be added",
        variant: "destructive"
      });
      return;
    }

    // Check stock availability
    for (const item of orderItems) {
      if (!validateStock(item.medicationId, item.quantity)) {
        const medication = medications?.find(med => med.id === item.medicationId);
        toast({
          title: "Stock Insufficient",
          description: `Not enough stock for ${medication?.name}. Available: ${medication?.stockQuantity}`,
          variant: "destructive"
        });
        return;
      }
    }

    // Create order (in a real app, this would call an API)
    const orderId = `ORD-${Date.now().toString().slice(-6)}`;
    
    toast({
      title: "Order Created Successfully",
      description: `Order ${orderId} has been created for ${patientName}`,
      variant: "default"
    });

    // Reset form
    setPatientName('');
    setPatientId('');
    setPriority('routine');
    setNotes('');
    setOrderItems([]);
  };

  const getPriorityConfig = (priority: OrderPriority) => {
    switch (priority) {
      case 'sos':
        return {
          label: 'SOS (Emergency)',
          description: 'Immediate processing - bypasses normal queue',
          color: 'critical'
        };
      case 'urgent':
        return {
          label: 'Urgent',
          description: 'High priority - expedited processing',
          color: 'warning'
        };
      case 'routine':
        return {
          label: 'Routine',
          description: 'Standard processing time',
          color: 'secondary'
        };
    }
  };

  const currentPriorityConfig = getPriorityConfig(priority);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-foreground">New Order</h1>
        <p className="text-muted-foreground">Create a new prescription order</p>
      </div>

      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Patient Information */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <User className="h-5 w-5" />
              <span>Patient Information</span>
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <Label htmlFor="patientName">Patient Name *</Label>
                <Input
                  id="patientName"
                  value={patientName}
                  onChange={(e) => setPatientName(e.target.value)}
                  placeholder="Enter patient's full name"
                  required
                />
              </div>
              <div>
                <Label htmlFor="patientId">Patient ID (Optional)</Label>
                <Input
                  id="patientId"
                  value={patientId}
                  onChange={(e) => setPatientId(e.target.value)}
                  placeholder="Enter patient ID if available"
                />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Order Priority */}
        <Card>
          <CardHeader>
            <CardTitle>Order Priority</CardTitle>
            <CardDescription>Select the urgency level for this prescription</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <Select value={priority} onValueChange={(value: OrderPriority) => setPriority(value)}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="routine">Routine - Standard processing</SelectItem>
                  <SelectItem value="urgent">Urgent - High priority</SelectItem>
                  <SelectItem value="sos">SOS - Emergency (immediate)</SelectItem>
                </SelectContent>
              </Select>
              
              <div className={`p-3 rounded-lg border ${
                priority === 'sos' ? 'bg-critical/10 border-critical/20' :
                priority === 'urgent' ? 'bg-warning/10 border-warning/20' :
                'bg-secondary/10 border-secondary/20'
              }`}>
                <div className="flex items-center space-x-2">
                  <Badge variant={currentPriorityConfig.color as any}>
                    {currentPriorityConfig.label}
                  </Badge>
                </div>
                <p className="text-sm mt-1 text-muted-foreground">
                  {currentPriorityConfig.description}
                </p>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Medication Selection */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <Package className="h-5 w-5" />
              <span>Add Medications</span>
            </CardTitle>
            <CardDescription>Search and add medications to this order</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            {/* Search Input */}
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Search medications by name, generic name, or category..."
                value={medicationSearch}
                onChange={(e) => setMedicationSearch(e.target.value)}
                className="pl-10"
              />
            </div>

            {/* Search Results */}
            {medicationSearch && (
              <div className="border rounded-lg max-h-48 overflow-y-auto">
                {filteredMedications.map((medication) => (
                  <div
                    key={medication.id}
                    className="flex items-center justify-between p-3 border-b last:border-b-0 hover:bg-muted/50 cursor-pointer"
                    onClick={() => addMedication(medication)}
                  >
                    <div className="flex-1">
                      <div className="flex items-center space-x-2">
                        <p className="font-medium">{medication.name}</p>
                        <Badge variant="outline">{medication.category}</Badge>
                      </div>
                      {medication.genericName && (
                        <p className="text-sm text-muted-foreground">{medication.genericName}</p>
                      )}
                      <p className="text-xs text-muted-foreground">
                        Stock: {medication.stockQuantity} {medication.unit}
                      </p>
                    </div>
                    <Button size="sm" variant="outline">
                      <Plus className="h-4 w-4 mr-1" />
                      Add
                    </Button>
                  </div>
                ))}
                {filteredMedications.length === 0 && (
                  <div className="p-4 text-center text-muted-foreground">
                    No medications found matching your search
                  </div>
                )}
              </div>
            )}
          </CardContent>
        </Card>

        {/* Selected Medications */}
        {orderItems.length > 0 && (
          <Card>
            <CardHeader>
              <CardTitle>Selected Medications ({orderItems.length})</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {orderItems.map((item) => {
                  const medication = medications?.find(med => med.id === item.medicationId);
                  const hasStockIssue = !validateStock(item.medicationId, item.quantity);

                  return (
                    <div key={item.medicationId} className="border rounded-lg p-4 space-y-3">
                      <div className="flex items-start justify-between">
                        <div className="flex-1">
                          <div className="flex items-center space-x-2">
                            <h4 className="font-medium">{item.medicationName}</h4>
                            {hasStockIssue && (
                              <Badge variant="critical">
                                <AlertCircle className="h-3 w-3 mr-1" />
                                Insufficient Stock
                              </Badge>
                            )}
                          </div>
                          {medication && (
                            <p className="text-sm text-muted-foreground">
                              Available: {medication.stockQuantity} {medication.unit}
                            </p>
                          )}
                        </div>
                        <Button
                          type="button"
                          variant="outline"
                          size="sm"
                          onClick={() => removeOrderItem(item.medicationId)}
                        >
                          <Trash2 className="h-4 w-4" />
                        </Button>
                      </div>

                      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
                        <div>
                          <Label>Quantity *</Label>
                          <div className="flex items-center space-x-2">
                            <Button
                              type="button"
                              variant="outline"
                              size="sm"
                              onClick={() => updateOrderItem(item.medicationId, 'quantity', Math.max(1, item.quantity - 1))}
                            >
                              <Minus className="h-3 w-3" />
                            </Button>
                            <Input
                              type="number"
                              value={item.quantity}
                              onChange={(e) => updateOrderItem(item.medicationId, 'quantity', parseInt(e.target.value) || 1)}
                              min="1"
                              className="text-center"
                            />
                            <Button
                              type="button"
                              variant="outline"
                              size="sm"
                              onClick={() => updateOrderItem(item.medicationId, 'quantity', item.quantity + 1)}
                            >
                              <Plus className="h-3 w-3" />
                            </Button>
                          </div>
                        </div>

                        <div>
                          <Label>Dosage</Label>
                          <Input
                            value={item.dosage}
                            onChange={(e) => updateOrderItem(item.medicationId, 'dosage', e.target.value)}
                            placeholder="e.g., 500mg"
                          />
                        </div>

                        <div className="sm:col-span-2">
                          <Label>Instructions</Label>
                          <Input
                            value={item.instructions}
                            onChange={(e) => updateOrderItem(item.medicationId, 'instructions', e.target.value)}
                            placeholder="e.g., Take twice daily with food"
                          />
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            </CardContent>
          </Card>
        )}

        {/* Additional Notes */}
        <Card>
          <CardHeader>
            <CardTitle>Additional Notes</CardTitle>
            <CardDescription>Any special instructions or notes for this order</CardDescription>
          </CardHeader>
          <CardContent>
            <Textarea
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              placeholder="Enter any special instructions, allergies, or notes..."
              rows={3}
            />
          </CardContent>
        </Card>

        {/* Submit Button */}
        <div className="flex justify-end space-x-4">
          <Button type="button" variant="outline">
            Save as Draft
          </Button>
          <Button 
            type="submit" 
            disabled={!patientName.trim() || orderItems.length === 0}
            className="min-w-32"
          >
            <CheckCircle className="h-4 w-4 mr-2" />
            Create Order
          </Button>
        </div>
      </form>
    </div>
  );
};