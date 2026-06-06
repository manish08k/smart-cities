import 'parking_slot.dart';

class ParkingFloor {
  final String id;
  final String name;
  final int totalSlots;
  final List<ParkingSlot> slots;

  ParkingFloor({
    required this.id,
    required this.name,
    required this.totalSlots,
    required this.slots,
  });

  factory ParkingFloor.fromJson(Map<String, dynamic> json) {
    final slotList = (json['slots'] as List<dynamic>)
        .map((s) => ParkingSlot.fromJson(s as Map<String, dynamic>))
        .toList();
    return ParkingFloor(
      id:         json['id']          as String,
      name:       json['name']        as String,
      totalSlots: json['total_slots'] as int,
      slots:      slotList,
    );
  }

  int get availableCount => slots.where((s) => s.isAvailable).length;
  int get occupiedCount  => slots.where((s) => s.isOccupied).length;
  int get reservedCount  => slots.where((s) => s.isReserved).length;

  ParkingFloor withUpdatedSlot(ParkingSlot updated) {
    final newSlots = slots.map((s) => s.id == updated.id ? updated : s).toList();
    return ParkingFloor(id: id, name: name, totalSlots: totalSlots, slots: newSlots);
  }
}