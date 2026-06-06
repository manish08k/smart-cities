import '../core/api_client.dart';
import '../models/parking_floor.dart';
import '../models/parking_slot.dart';

class ParkingService {
  final ApiClient _client = ApiClient.instance;

  // ── Get all floors with slots ─────────────────────────────
  Future<List<ParkingFloor>> getFloors() async {
    final response = await _client.get('/parking/floors');
    final list = response.data as List<dynamic>;
    return list
        .map((f) => ParkingFloor.fromJson(f as Map<String, dynamic>))
        .toList();
  }

  // ── Get single floor ──────────────────────────────────────
  Future<ParkingFloor> getFloor(String floorId) async {
    final response = await _client.get('/parking/floors/$floorId');
    return ParkingFloor.fromJson(response.data as Map<String, dynamic>);
  }

  // ── Reserve a slot ────────────────────────────────────────
  Future<ParkingSlot> reserveSlot({
    required String slotId,
    required String reservedBy,
    required String reservedTime,
  }) async {
    final response = await _client.post(
      '/parking/slots/$slotId/reserve',
      data: {
        'reserved_by':   reservedBy,
        'reserved_time': reservedTime,
      },
    );
    return ParkingSlot.fromJson(response.data as Map<String, dynamic>);
  }

  // ── Release a slot ────────────────────────────────────────
  Future<ParkingSlot> releaseSlot(String slotId) async {
    final response = await _client.patch('/parking/slots/$slotId/release');
    return ParkingSlot.fromJson(response.data as Map<String, dynamic>);
  }

  // ── Get parking summary ───────────────────────────────────
  Future<Map<String, dynamic>> getSummary() async {
    final response = await _client.get('/parking/summary');
    return response.data as Map<String, dynamic>;
  }
}