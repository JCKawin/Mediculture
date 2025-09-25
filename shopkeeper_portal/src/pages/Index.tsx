import { useState } from 'react';
import { Navigation } from '@/components/Navigation';
import { Dashboard } from '@/components/Dashboard';
import { InventoryManagement } from '@/components/InventoryManagement';
import { OrderTracking } from '@/components/OrderTracking';
import { NewOrderForm } from '@/components/NewOrderForm';
import { AlertsManagement } from '@/components/AlertsManagement';

const Index = () => {
  const [activeSection, setActiveSection] = useState('dashboard');

  const renderContent = () => {
    switch (activeSection) {
      case 'dashboard':
        return <Dashboard onSectionChange={setActiveSection} />;
      case 'inventory':
        return <InventoryManagement />;
      case 'orders':
        return <OrderTracking />;
      case 'new-order':
        return <NewOrderForm />;
      case 'alerts':
        return <AlertsManagement />;
      default:
        return <Dashboard onSectionChange={setActiveSection} />;
    }
  };

  return (
    <div className="min-h-screen bg-background">
      <Navigation activeSection={activeSection} onSectionChange={setActiveSection} />
      
      {/* Main Content */}
      <div className="lg:ml-64 min-h-screen">
        <div className="p-6 pt-16 lg:pt-6">
          {renderContent()}
        </div>
      </div>
    </div>
  );
};

export default Index;
