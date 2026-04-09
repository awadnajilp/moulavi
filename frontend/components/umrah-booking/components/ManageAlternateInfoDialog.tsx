'use client';

import React, { useState, useEffect } from 'react';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter, DialogDescription } from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Loader2, Plane, Building, Truck, Route, Save, Info, AlertCircle } from 'lucide-react';
import { umrahVisaAPI, locationMasterAPI, cityMasterAPI, vehicleTypeMasterAPI } from '@/lib/api';
import { toast } from 'sonner';
import { TravelDetailsForm } from './TravelDetailsForm';
import { AccommodationStep } from '../steps/AccommodationStep';
import { TransportVehicleSelectionStep } from '../steps/TransportVehicleSelectionStep';
import { MovementDetailsStep } from '../steps/MovementDetailsStep';
import { Card, CardContent } from '@/components/ui/card';
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert';

interface ManageAlternateInfoDialogProps {
  isOpen: boolean;
  onClose: () => void;
  booking: any;
  onSuccess: () => void;
}

export const ManageAlternateInfoDialog: React.FC<ManageAlternateInfoDialogProps> = ({
  isOpen,
  onClose,
  booking,
  onSuccess,
}) => {
  const [activeTab, setActiveTab] = useState('travel');
  const [isSaving, setIsSaving] = useState(false);
  const [masterData, setMasterData] = useState<any>({
    airports: [],
    locations: [],
    cities: [],
    vehicleTypes: [],
  });
  const [loadingMaster, setLoadingMaster] = useState(false);

  // Form States for Alternate Info
  const [travelData, setTravelData] = useState<any>({
    arrivalDate: '',
    arrivalTime: '',
    arrivalFlightNumber: '',
    arrivalAirportId: '',
    departureDate: '',
    departureTime: '',
    departureFlightNumber: '',
    departureAirportId: '',
  });

  const [hotelBookings, setHotelBookings] = useState<any[]>([]);
  const [transportBookings, setTransportBookings] = useState<any[]>([]);
  const [movementDetails, setMovementDetails] = useState<any[]>([]);

  useEffect(() => {
    if (isOpen && booking) {
      loadMasterData();
      initializeData();
    }
  }, [isOpen, booking]);

  const loadMasterData = async () => {
    try {
      setLoadingMaster(true);
      const [airportsRes, locationsRes, citiesRes, vehiclesRes] = await Promise.all([
        locationMasterAPI.getActive({ locationType: 'AIRPORT' }),
        locationMasterAPI.getAll(),
        cityMasterAPI.getAll(),
        vehicleTypeMasterAPI.getAll(),
      ]);

      setMasterData({
        airports: airportsRes.data,
        locations: locationsRes.data,
        cities: citiesRes.data,
        vehicleTypes: vehiclesRes.data,
      });
    } catch (error) {
      console.error('Error loading master data:', error);
      toast.error('Failed to load required data');
    } finally {
      setLoadingMaster(false);
    }
  };

  const initializeData = () => {
    // Find existing alternate info if any
    const altTravel = booking.travelDetails?.find((t: any) => t.isAlternate);
    const altHotels = booking.hotelBookings?.filter((h: any) => h.isAlternate) || [];
    const altTransports = booking.transportBookings?.filter((t: any) => t.isAlternate) || [];
    const altMovements = booking.movementDetails?.filter((m: any) => m.isAlternate) || [];

    if (altTravel) {
      const arrival = new Date(altTravel.arrivalDateTime);
      const departure = new Date(altTravel.departureDateTime);
      setTravelData({
        arrivalDate: arrival.toISOString().split('T')[0],
        arrivalTime: arrival.toTimeString().slice(0, 5),
        arrivalFlightNumber: altTravel.arrivalFlightNumber || '',
        arrivalAirportId: altTravel.arrivalAirportId || '',
        departureDate: departure.toISOString().split('T')[0],
        departureTime: departure.toTimeString().slice(0, 5),
        departureFlightNumber: altTravel.departureFlightNumber || '',
        departureAirportId: altTravel.departureAirportId || '',
      });
    } else {
      // Default to today
      const today = new Date().toISOString().split('T')[0];
      setTravelData({
        arrivalDate: today,
        arrivalTime: '12:00',
        arrivalFlightNumber: '',
        arrivalAirportId: '',
        departureDate: today,
        departureTime: '12:00',
        departureFlightNumber: '',
        departureAirportId: '',
      });
    }

    setHotelBookings(altHotels.map((h: any) => ({
      id: h.id,
      cityId: h.cityId,
      hotelId: h.hotelId,
      checkInDate: h.checkInDate.split('T')[0],
      checkOutDate: h.checkOutDate.split('T')[0],
      brn: h.brn || '',
    })));

    setTransportBookings(altTransports.map((t: any) => ({
      id: t.id,
      transportMasterId: t.transportMasterId,
      travelDateTime: t.travelDateTime,
    })));

    setMovementDetails(altMovements.map((m: any) => ({
      id: m.id,
      travelDateTime: m.travelDateTime,
      fromCityId: m.fromCityId,
      fromLocationId: m.fromLocationId,
      toCityId: m.toCityId,
      toLocationId: m.toLocationId,
    })));
  };

  const handleSave = async () => {
    try {
      setIsSaving(true);
      
      // Combine travel date/time
      const arrivalDateTime = new Date(`${travelData.arrivalDate}T${travelData.arrivalTime}:00`).toISOString();
      const departureDateTime = new Date(`${travelData.departureDate}T${travelData.departureTime}:00`).toISOString();

      const payload = {
        travelDetails: {
          arrivalDateTime,
          arrivalAirportId: travelData.arrivalAirportId,
          arrivalFlightNumber: travelData.arrivalFlightNumber,
          departureDateTime,
          departureAirportId: travelData.departureAirportId,
          departureFlightNumber: travelData.departureFlightNumber,
        },
        hotelBookings: hotelBookings.map(h => ({
          cityId: h.cityId,
          hotelId: h.hotelId,
          checkInDate: new Date(h.checkInDate).toISOString(),
          checkOutDate: new Date(h.checkOutDate).toISOString(),
          brn: h.brn,
        })),
        transportBookings: transportBookings.map(t => ({
          transportMasterId: t.transportMasterId,
          travelDateTime: t.travelDateTime,
        })),
        movementDetails: movementDetails.map(m => ({
          travelDateTime: new Date(m.travelDateTime).toISOString(),
          fromCityId: m.fromCityId,
          fromLocationId: m.fromLocationId,
          toCityId: m.toCityId,
          toLocationId: m.toLocationId,
        })),
      };

      await umrahVisaAPI.updateAlternateInfo(booking.id, payload);
      toast.success('Alternate booking information updated successfully');
      onSuccess();
    } catch (error: any) {
      console.error('Error saving alternate info:', error);
      toast.error(error.response?.data?.message || 'Failed to save alternate information');
    } finally {
      setIsSaving(false);
    }
  };

  const getHotelsForLocation = (locationId: string) => {
    return masterData.locations.filter((loc: any) => loc.cityId === locationId && loc.locationType === 'HOTEL');
  };

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="max-w-5xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle className="text-2xl flex items-center gap-2 text-secondary">
            <Route className="h-6 w-6" /> Manage Alternate Booking Information
          </DialogTitle>
          <DialogDescription>
            Add or update placeholder/dummy booking details. These will be stored separately from the main booking information.
          </DialogDescription>
        </DialogHeader>

        <Alert className="bg-blue-50 border-blue-200 text-blue-800 mb-4">
          <Info className="h-4 w-4" />
          <AlertTitle>Information</AlertTitle>
          <AlertDescription>
            Alternate information is used when the final travel details are not yet confirmed. You can switch between main and alternate information in the booking view.
          </AlertDescription>
        </Alert>

        {loadingMaster ? (
          <div className="flex flex-col items-center justify-center py-20">
            <Loader2 className="h-10 w-10 animate-spin text-primary mb-4" />
            <p className="text-gray-500">Loading master data...</p>
          </div>
        ) : (
          <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
            <TabsList className="grid grid-cols-4 mb-6">
              <TabsTrigger value="travel" className="flex items-center gap-2">
                <Plane className="h-4 w-4" /> Flights
              </TabsTrigger>
              <TabsTrigger value="stay" className="flex items-center gap-2">
                <Building className="h-4 w-4" /> Stay
              </TabsTrigger>
              <TabsTrigger value="transport" className="flex items-center gap-2">
                <Truck className="h-4 w-4" /> Transport
              </TabsTrigger>
              <TabsTrigger value="movements" className="flex items-center gap-2">
                <Route className="h-4 w-4" /> Movements
              </TabsTrigger>
            </TabsList>

            <TabsContent value="travel" className="space-y-4">
              <Card>
                <CardContent className="pt-6">
                  <TravelDetailsForm 
                    data={travelData} 
                    onChange={(newData) => setTravelData({ ...travelData, ...newData })}
                    airports={masterData.airports}
                  />
                </CardContent>
              </Card>
            </TabsContent>

            <TabsContent value="stay" className="space-y-4">
              <div className="bg-white border rounded-lg p-1">
                <AccommodationStep 
                  data={{ accommodationType: 'hotel', hotelBookings: hotelBookings } as any} 
                  onChange={(newData: any) => {
                    if (newData.hotelBookings) {
                      setHotelBookings(newData.hotelBookings);
                    }
                  }} 
                  locations={masterData.cities} 
                  hotels={masterData.locations.filter((l: any) => l.locationType === 'HOTEL')}
                  arrivalDate={travelData.arrivalDate}
                  departureDate={travelData.departureDate}
                  getHotelsForLocation={getHotelsForLocation}
                  onLoadHotels={async () => {}}
                />
                
                {/* Manual display of bookings as the Step component is designed for creation flow */}
                <div className="mt-4 px-4 pb-4">
                  <h4 className="text-sm font-semibold mb-2">Alternate Hotels ({hotelBookings.length})</h4>
                  <div className="space-y-2">
                    {hotelBookings.map((h, idx) => (
                      <div key={h.id || idx} className="flex items-center justify-between p-3 bg-gray-50 rounded border">
                        <div className="text-sm">
                          <span className="font-medium">{masterData.cities.find((c: any) => c.id === h.cityId)?.name}</span> - 
                          <span> {masterData.locations.find((l: any) => l.id === h.hotelId)?.name}</span>
                          <div className="text-xs text-gray-500">{h.checkInDate} to {h.checkOutDate}</div>
                        </div>
                        <Button variant="ghost" size="sm" className="text-destructive" onClick={() => setHotelBookings(hotelBookings.filter((_, i) => i !== idx))}>Remove</Button>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </TabsContent>

            <TabsContent value="transport" className="space-y-4">
              <div className="bg-white border rounded-lg">
                <TransportVehicleSelectionStep 
                  data={{ 
                    selectedTransports: transportBookings.map(t => ({ 
                      ...t, 
                      transportMaster: masterData.locations.find((l: any) => l.id === t.transportMasterId) 
                    })),
                  } as any}
                  step1Data={{} as any}
                  step2Data={{ 
                    arrivalDate: travelData.arrivalDate,
                    departureDate: travelData.departureDate,
                  } as any}
                  onChange={(newData: any) => {
                    if (newData.selectedTransports) {
                      setTransportBookings(newData.selectedTransports);
                    }
                  }}
                  locationMasters={masterData.locations}
                />
              </div>
            </TabsContent>

            <TabsContent value="movements" className="space-y-4">
              <div className="bg-white border rounded-lg">
                <MovementDetailsStep 
                  data={{ 
                    movements: movementDetails,
                  } as any}
                  onChange={(newData: any) => {
                    if (newData.movements) {
                      setMovementDetails(newData.movements);
                    }
                  }}
                  locationMasters={masterData.locations}
                  locations={masterData.locations}
                  hotelBookings={hotelBookings.map(h => ({
                    ...h,
                    hotel: masterData.locations.find((l: any) => l.id === h.hotelId),
                    city: masterData.cities.find((c: any) => c.id === h.cityId)
                  }))}
                  arrivalDate={travelData.arrivalDate}
                  departureDate={travelData.departureDate}
                  arrivalAirportId={travelData.arrivalAirportId}
                  departureAirportId={travelData.departureAirportId}
                />
              </div>
            </TabsContent>
          </Tabs>
        )}

        <DialogFooter className="mt-6 border-t pt-4">
          <Button variant="outline" onClick={onClose} disabled={isSaving}>Cancel</Button>
          <Button 
            className="bg-secondary hover:bg-secondary/90 text-white" 
            onClick={handleSave} 
            disabled={isSaving || loadingMaster}
          >
            {isSaving ? (
              <>
                <Loader2 className="h-4 w-4 animate-spin mr-2" />
                Saving...
              </>
            ) : (
              <>
                <Save className="h-4 w-4 mr-2" />
                Save Alternate Information
              </>
            )}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
};
