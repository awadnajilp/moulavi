import React from 'react';

interface HotelCoverageIndicatorProps {
  coveredDays: number;
  totalDays: number;
  coveragePercentage: number;
  remainingDays: number;
  showDetails?: boolean;
  totalBookedDays?: number; // Total days booked (may exceed trip duration)
  daysBeyond?: number; // Days booked beyond trip duration
}

export const HotelCoverageIndicator: React.FC<HotelCoverageIndicatorProps> = ({
  coveredDays,
  totalDays,
  coveragePercentage,
  remainingDays,
  showDetails = true,
  totalBookedDays,
  daysBeyond = 0,
}) => {
  if (totalDays === 0) return null;

  // Show total booked days if it exceeds trip duration
  const displayDays = daysBeyond > 0 ? (totalBookedDays || coveredDays) : coveredDays;
  const displayPercentage = daysBeyond > 0 
    ? Math.round(((totalBookedDays || coveredDays) / totalDays) * 100)
    : coveragePercentage;

  return (
    <div className="mt-2">
      <div className="flex items-center gap-2 text-xs">
        <span className="text-gray-600">Coverage:</span>
        <div className="flex-1 bg-gray-200 rounded-full h-2">
          <div
            className={`h-2 rounded-full transition-all duration-300 ${
              daysBeyond > 0
                ? 'bg-primary'
                : coveragePercentage === 100
                ? 'bg-green-500'
                : coveragePercentage >= 80
                ? 'bg-yellow-500'
                : 'bg-primary'
            }`}
            style={{ width: `${Math.min(100, displayPercentage)}%` }}
          />
        </div>
        <span
          className={`font-medium ${
            daysBeyond > 0
              ? 'text-primary'
              : coveragePercentage === 100
              ? 'text-green-600'
              : coveragePercentage >= 80
              ? 'text-yellow-600'
              : 'text-primary'
          }`}
        >
          {displayDays}/{totalDays} days ({displayPercentage}%)
          {daysBeyond > 0 && (
            <span className="ml-1 text-primary">
              ({daysBeyond} day{daysBeyond > 1 ? 's' : ''} beyond)
            </span>
          )}
        </span>
        {showDetails && remainingDays > 0 && (
          <span className="text-primary font-medium">
            ⚠️ {remainingDays} day{remainingDays > 1 ? 's' : ''} uncovered
          </span>
        )}
      </div>
    </div>
  );
};

