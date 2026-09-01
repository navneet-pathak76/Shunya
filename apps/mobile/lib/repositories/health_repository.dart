import '../models/body_measurement.dart';
import '../models/health_profile.dart';

abstract interface class HealthRepository {
  Future<HealthProfile?> getProfile();
  Future<void> saveProfile(HealthProfile profile);
  Future<List<BodyMeasurement>> getMeasurements({DateTime? from, DateTime? to});
  Future<void> saveMeasurement(BodyMeasurement measurement);
}
