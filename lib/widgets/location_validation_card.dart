import 'package:flutter/material.dart';
import '../models/attendance_model.dart';

class LocationValidationCard extends StatelessWidget {
  final LocationValidation locationValidation;

  const LocationValidationCard({
    super.key,
    required this.locationValidation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: locationValidation.validated
                ? [Colors.green[600]!, Colors.green[400]!]
                : [Colors.red[600]!, Colors.red[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      locationValidation.validated
                          ? Icons.location_on
                          : Icons.location_off,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location Validation',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          locationValidation.validated ? 'Validated' : 'Failed',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (locationValidation.matchedLocation != null)
                _buildMatchedLocationInfo(),
              if (locationValidation.validationDetails != null)
                _buildValidationDetails(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchedLocationInfo() {
    final matchedLocation = locationValidation.matchedLocation!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Matched Location',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          if (matchedLocation.name != null)
            _buildLocationDetail('Name', matchedLocation.name!),
          if (matchedLocation.distanceFromCenter != null)
            _buildLocationDetail(
              'Distance',
              '${matchedLocation.distanceFromCenter!.toStringAsFixed(1)}m',
            ),
          if (matchedLocation.allowedRadius != null)
            _buildLocationDetail(
              'Allowed Radius',
              '${matchedLocation.allowedRadius}m',
            ),
        ],
      ),
    );
  }

  Widget _buildValidationDetails() {
    final details = locationValidation.validationDetails!;
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Validation Details',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          if (details.locationName != null)
            _buildLocationDetail('Location', details.locationName!),
          if (details.actualDistance != null)
            _buildLocationDetail(
              'Actual Distance',
              '${details.actualDistance!.toStringAsFixed(1)}m',
            ),
          if (details.allowedRadius != null)
            _buildLocationDetail(
              'Max Allowed',
              '${details.allowedRadius}m',
            ),
          if (details.accuracyPercentage != null)
            _buildLocationDetail(
              'Accuracy',
              '${details.accuracyPercentage!.toStringAsFixed(1)}%',
            ),
          if (details.allLocationsChecked != null)
            _buildLocationDetail(
              'Locations Checked',
              '${details.allLocationsChecked}',
            ),
        ],
      ),
    );
  }

  Widget _buildLocationDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
