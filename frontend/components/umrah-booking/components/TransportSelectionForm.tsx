'use client';

import React, { useEffect, useState, useMemo } from 'react';
import { Truck, Loader2, Users, MapPin, Plus, Minus, Star } from 'lucide-react';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import { Skeleton } from '@/components/ui/skeleton';
import { Button } from '@/components/ui/button';
import { transportRouteMasterAPI, transportMasterAPI } from '@/lib/api';
import { TransportRouteMaster, TransportMaster, RouteType, LocationMaster } from '@/types';
import { toast } from 'sonner';
import { cn } from '@/lib/utils';

interface TransportSelectionFormProps {
  data: any;
  airport?: any;
  departureAirport?: any;
  onChange: (data: any) => void;
  disabled?: boolean;
  locationMasters: any[];
  passengerCount?: number;
}

export const TransportSelectionForm: React.FC<TransportSelectionFormProps> = ({
  data,
  airport,
  departureAirport,
  onChange,
  disabled = false,
  locationMasters,
  passengerCount = 0,
}) => {
  const [loadingRoutes, setLoadingRoutes] = useState(false);
  const [loadingTransports, setLoadingTransports] = useState(false);
  const [selectedRouteId, setSelectedRouteId] = useState<string | null>(null);
  const [routeTypeFilter, setRouteTypeFilter] = useState<RouteType | 'all'>('all');
  const [availableRoutes, setAvailableRoutes] = useState<TransportRouteMaster[]>([]);
  const [routeTransports, setRouteTransports] = useState<TransportMaster[]>([]);
  const [selectedVehicles, setSelectedVehicles] = useState<Map<string, number>>(new Map());

  // Helper function to format route display
  const formatRouteDisplay = (route: TransportRouteMaster): string => {
    const cities = [
      route.city1?.name,
      route.city2?.name,
      route.city3?.name,
      route.city4?.name,
    ].filter(Boolean);
    const routeString = cities.join(' → ');
    const routeTypeLabel = route.routeType
      .replace(/([a-z])([A-Z])/g, '$1 $2')
      .split(' ')
      .map(word => word.charAt(0).toUpperCase() + word.slice(1))
      .join(' ');
    return `${routeString} (${routeTypeLabel})`;
  };

  // Load all active routes
  useEffect(() => {
    const loadRoutes = async () => {
      setLoadingRoutes(true);
      try {
        const response = await transportRouteMasterAPI.getActive();
        const routes = response.data.transportRouteMasters || [];
        setAvailableRoutes(routes);
      } catch (error: any) {
        console.error('Error loading routes:', error);
        toast.error('Failed to load routes');
      } finally {
        setLoadingRoutes(false);
      }
    };
    loadRoutes();
  }, []);

  // Load transports when route is selected
  useEffect(() => {
    const loadTransports = async () => {
      if (!selectedRouteId) {
        setRouteTransports([]);
        setSelectedVehicles(new Map());
        return;
      }

      setLoadingTransports(true);
      try {
        const response = await transportMasterAPI.getByRoute(selectedRouteId);
        const transports = response.data.transportMasters || [];
        setRouteTransports(transports);
      } catch (error: any) {
        console.error('Error loading transports:', error);
        toast.error('Failed to load transport vehicles');
      } finally {
        setLoadingTransports(false);
      }
    };
    loadTransports();
  }, [selectedRouteId]);

  // Sync selected vehicles with data prop
  useEffect(() => {
    if (data.selectedTransports && data.selectedTransports.length > 0) {
      const vehicleMap = new Map<string, number>();
      data.selectedTransports.forEach((st: any) => {
        vehicleMap.set(st.transportId, st.quantity);
      });
      setSelectedVehicles(vehicleMap);
      if (!selectedRouteId && data.selectedTransports[0]?.routeId) {
        setSelectedRouteId(data.selectedTransports[0].routeId);
      }
    } else if (data.selectedTransport) {
      const vehicleMap = new Map<string, number>();
      vehicleMap.set(data.selectedTransport.transportId, 1);
      setSelectedVehicles(vehicleMap);
    } else {
      setSelectedVehicles(new Map());
    }
  }, [data, selectedRouteId]);

  const handleQuantityChange = (transportId: string, delta: number) => {
    const currentQty = selectedVehicles.get(transportId) || 0;
    const newQty = Math.max(0, currentQty + delta);
    
    const newMap = new Map(selectedVehicles);
    if (newQty === 0) newMap.delete(transportId);
    else newMap.set(transportId, newQty);
    
    const selectedTransports = Array.from(newMap.entries())
      .map(([id, quantity]) => {
        const transport = routeTransports.find(t => t.id === id);
        if (!transport || !transport.vehicleType) return null;
        return {
          routeId: transport.routeId,
          transportId: transport.id,
          vehicleTypeId: transport.vehicleType.id,
          price: Number(transport.price),
          quantity,
        };
      })
      .filter(Boolean);

    onChange({
      selectedTransports: selectedTransports.length > 0 ? selectedTransports : undefined,
      selectedTransport: undefined,
    });
  };

  const filteredRoutes = useMemo(() => {
    if (routeTypeFilter === 'all') return availableRoutes;
    return availableRoutes.filter(route => route.routeType === routeTypeFilter);
  }, [availableRoutes, routeTypeFilter]);

  return (
    <div className="p-4 space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div className="space-y-1">
          <label className="text-[10px] font-bold text-primary/60 uppercase ml-1 tracking-widest">Filter by Route Type</label>
          <Select value={routeTypeFilter} onValueChange={(v) => setRouteTypeFilter(v as any)} disabled={disabled || loadingRoutes}>
            <SelectTrigger className="h-9 rounded-lg border-gray-100 bg-white text-[10px] font-bold">
              <SelectValue placeholder="Select type" />
            </SelectTrigger>
            <SelectContent className="rounded-xl border-0 shadow-2xl p-1">
              <SelectItem value="all" className="text-[9px] font-bold p-2 uppercase">All Route Types</SelectItem>
              <SelectItem value="fulltrip" className="text-[9px] font-bold p-2 uppercase">Full Trip</SelectItem>
              <SelectItem value="airporttocity" className="text-[9px] font-bold p-2 uppercase">Airport to City</SelectItem>
              <SelectItem value="citytoairport" className="text-[9px] font-bold p-2 uppercase">City to Airport</SelectItem>
            </SelectContent>
          </Select>
        </div>

        <div className="space-y-1">
          <label className="text-[10px] font-bold text-primary/60 uppercase ml-1 tracking-widest">Select Route</label>
          <Select value={selectedRouteId || ''} onValueChange={(v) => setSelectedRouteId(v || null)} disabled={disabled || loadingRoutes || filteredRoutes.length === 0}>
            <SelectTrigger className="h-9 rounded-lg border-gray-100 bg-white text-[10px] font-bold overflow-hidden">
              <SelectValue placeholder="Select a route" />
            </SelectTrigger>
            <SelectContent className="rounded-xl border-0 shadow-2xl p-1 max-w-[300px]">
              {filteredRoutes.map((route) => (
                <SelectItem key={route.id} value={route.id} className="text-[9px] font-bold p-2">{formatRouteDisplay(route)}</SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      </div>

      {selectedRouteId && (
        <div className="animate-in fade-in slide-in-from-top-2 duration-500">
          {loadingTransports ? (
            <div className="flex items-center justify-center py-10"><Loader2 className="h-6 w-6 text-primary animate-spin" /></div>
          ) : (
            <div className="bg-white rounded-xl border border-secondary/10 shadow-sm overflow-hidden">
              <Table>
                <TableHeader className="bg-primary/5">
                  <TableRow className="h-8 border-b border-secondary/5">
                    <TableHead className="px-4 text-[8px] font-bold uppercase py-0 text-primary/40">Vehicle Name</TableHead>
                    <TableHead className="text-[8px] font-bold uppercase py-0 text-primary/40 text-center">Capacity</TableHead>
                    <TableHead className="text-[8px] font-bold uppercase py-0 text-primary/40">Price</TableHead>
                    <TableHead className="text-[8px] font-bold uppercase py-0 text-primary/40 text-center">Quantity</TableHead>
                    <TableHead className="px-4 text-[8px] font-bold uppercase py-0 text-primary/40 text-right">Total</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {routeTransports.map((transport) => {
                    if (!transport.vehicleType) return null;
                    const quantity = selectedVehicles.get(transport.id) || 0;
                    const total = Number(transport.price) * quantity;
                    const isSelected = quantity > 0;
                    
                    return (
                      <TableRow key={transport.id} className={cn("h-10 transition-colors", isSelected ? 'bg-primary/5' : '')}>
                        <TableCell className="px-4 py-0">
                          <div className="flex items-center gap-2">
                            <Truck className={cn("h-3.5 w-3.5", isSelected ? "text-primary" : "text-muted-foreground")} />
                            <span className="text-[10px] font-bold text-primary uppercase">{transport.vehicleType.vehicleName}</span>
                          </div>
                        </TableCell>
                        <TableCell className="text-center py-0"><span className="text-[9px] font-bold bg-muted px-1.5 py-0.5 rounded uppercase">{transport.vehicleType.paxCount} PAX</span></TableCell>
                        <TableCell className="py-0"><span className="text-[10px] font-bold text-primary">SAR {Number(transport.price).toLocaleString()}</span></TableCell>
                        <TableCell className="py-0">
                          <div className="flex items-center justify-center gap-2 bg-gray-50 p-0.5 rounded-md border border-gray-100 w-fit mx-auto">
                            <Button variant="ghost" size="icon" onClick={() => handleQuantityChange(transport.id, -1)} disabled={disabled || quantity === 0} className="h-5 w-5 rounded hover:text-destructive"><Minus className="h-2 w-2" /></Button>
                            <span className="text-[10px] font-bold w-3 text-center">{quantity}</span>
                            <Button variant="ghost" size="icon" onClick={() => handleQuantityChange(transport.id, 1)} disabled={disabled} className="h-5 w-5 rounded hover:text-emerald-600"><Plus className="h-2 w-2" /></Button>
                          </div>
                        </TableCell>
                        <TableCell className="px-4 py-0 text-right"><span className={cn("text-[10px] font-bold", isSelected ? 'text-secondary' : 'text-primary/10')}>SAR {total.toLocaleString()}</span></TableCell>
                      </TableRow>
                    );
                  })}
                </TableBody>
              </Table>
            </div>
          )}
        </div>
      )}
    </div>
  );
};
