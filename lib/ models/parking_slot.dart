class ParkingSlot {
  final String id;
  final String floorId;
  final bool isOccupied;
  final bool isReserved;
  final String? reservedBy;
  final String? reservedAt;
  final String? reservedTime;

  ParkingSlot({
    required this.id,
    required this.floorId,
    required this.isOccupied,
    required this.isReserved,
    this.reservedBy,
    this.reservedAt,
    this.reservedTime,
  });

  factory ParkingSlot.fromJson(Map<String, dynamic> json) {
    return ParkingSlot(
      id:           json['id']           as String,
      floorId:      json['floor_id']     as String,
      isOccupied:   json['is_occupied']  as bool,
      isReserved:   json['is_reserved']  as bool,
      reservedBy:   json['reserved_by']  as String?,
      reservedAt:   json['reserved_at']  as String?,
      reservedTime: json['reserved_time'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':            id,
    'floor_id':      floorId,
    'is_occupied':   isOccupied,
    'is_reserved':   isReserved,
    'reserved_by':   reservedBy,
    'reserved_at':   reservedAt,
    'reserved_time': reservedTime,
  };

  ParkingSlot copyWith({
    bool? isOccupied,
    bool? isReserved,
    String? reservedBy,
    String? reservedAt,
    String? reservedTime,
  }) {
    return ParkingSlot(
      id:           id,
      floorId:      floorId,
      isOccupied:   isOccupied   ?? this.isOccupied,
      isReserved:   isReserved   ?? this.isReserved,
      reservedBy:   reservedBy   ?? this.reservedBy,
      reservedAt:   reservedAt   ?? this.reservedAt,
      reservedTime: reservedTime ?? this.reservedTime,
    );
  }

  bool get isAvailable => !isOccupied && !isReserved;
}