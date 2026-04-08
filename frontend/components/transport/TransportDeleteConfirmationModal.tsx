'use client';

import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog';
import { TransportMaster } from '@/types';

interface TransportDeleteConfirmationModalProps {
  transport: TransportMaster | null;
  open: boolean;
  loading: boolean;
  onConfirm: () => void;
  onCancel: () => void;
}

export default function TransportDeleteConfirmationModal({
  transport,
  open,
  loading,
  onConfirm,
  onCancel,
}: TransportDeleteConfirmationModalProps) {
  const getRouteString = () => {
    if (!transport?.route) return 'N/A';
    const cities = [
      transport.route.city1?.name,
      transport.route.city2?.name,
      transport.route.city3?.name,
      transport.route.city4?.name,
    ].filter(Boolean);
    return cities.join(' → ');
  };

  return (
    <AlertDialog open={open} onOpenChange={onCancel}>
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>Delete Transport</AlertDialogTitle>
          <AlertDialogDescription>
            Are you sure you want to delete this transport? This action cannot be undone.
            {transport && (
              <div className="mt-2 text-sm text-gray-600">
                <p>Route: {getRouteString()}</p>
                <p>Vehicle: {transport.vehicleType?.vehicleName} ({transport.vehicleType?.paxCount} PAX)</p>
                <p>Price: ₹{Number(transport.price).toLocaleString()}</p>
              </div>
            )}
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel disabled={loading}>Cancel</AlertDialogCancel>
          <AlertDialogAction
            onClick={onConfirm}
            disabled={loading}
            className="bg-primary hover:bg-primary/90"
          >
            {loading ? 'Deleting...' : 'Delete'}
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  );
}

