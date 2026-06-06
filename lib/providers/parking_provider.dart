import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/websocket_client.dart';
import '../models/parking_floor.dart';
import '../models/parking_slot.dart';
import '../services/parking_service.dart';

enum LoadState { idle, loading, loaded, error }

class ParkingProvider extends ChangeNotifier {
  final ParkingService _service = ParkingService();
  final WebSocketClient _ws     = WebSocketClient.instance;

  List<ParkingFloor> _floors     = [];
  int _selectedFloorIndex        = 0;
  ParkingSlot? _selectedSlot;
  String? _selectedTime;
  LoadState _state               = LoadState.idle;
  String? _error;
  String? _lastReservationSlotId;
  bool _reservationSuccess       = false;

  StreamSubscription? _wsSub;

  // ── Getters ──────────────────────────────────────────────
  List<ParkingFloor> get floors          => _floors;
  int get selectedFloorIndex             => _selectedFloorIndex;
  ParkingFloor? get selectedFloor        => _floors.isNotEmpty ? _floors[_selectedFloorIndex] : null;
  ParkingSlot?  get selectedSlot         => _selectedSlot;
  String?       get selectedTime         => _selectedTime;
  LoadState     get state                => _state;
  String?       get error                => _error;
  bool          get isLoading            => _state == LoadState.loading;
  String?       get lastReservationSlotId => _lastReservationSlotId;
  bool          get reservationSuccess   => _reservationSuccess;

  int get totalAvailable => _floors.fold(0, (sum, f) => sum + f.availableCount);

  // ── Init ─────────────────────────────────────────────────
  Future<void> init() async {
    await loadFloors();
    _connectWebSocket();
  }

  // ── Load floors ──────────────────────────────────────────
  Future<void> loadFloors() async {
    _state = LoadState.loading;
    _error = null;
    notifyListeners();

    try {
      _floors = await _service.getFloors();
      _state  = LoadState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = LoadState.error;
    }
    notifyListeners();
  }

  // ── WebSocket sync ────────────────────────────────────────
  void _connectWebSocket() {
    _ws.connect('/ws/parking');
    _wsSub = _ws.stream.listen(_onWsMessage);
  }

  void _onWsMessage(Map<String, dynamic> msg) {
    final event = msg['event'] as String?;
    if (event == 'slot_updated') {
      final slotData = msg['slot'] as Map<String, dynamic>;
      final updated  = ParkingSlot.fromJson(slotData);
      _patchSlot(updated);
    } else if (event == 'floor_refreshed') {
      final floorData = msg['floor'] as Map<String, dynamic>;
      final updated   = ParkingFloor.fromJson(floorData);
      _patchFloor(updated);
    }
  }

  void _patchSlot(ParkingSlot updated) {
    _floors = _floors.map((floor) {
      if (floor.id == updated.floorId) {
        return floor.withUpdatedSlot(updated);
      }
      return floor;
    }).toList();
    // Clear selection if the slot was taken by someone else
    if (_selectedSlot?.id == updated.id && !updated.isAvailable) {
      _selectedSlot = null;
      _selectedTime = null;
    }
    notifyListeners();
  }

  void _patchFloor(ParkingFloor updated) {
    _floors = _floors.map((f) => f.id == updated.id ? updated : f).toList();
    notifyListeners();
  }

  // ── Floor selection ───────────────────────────────────────
  void selectFloor(int index) {
    _selectedFloorIndex = index;
    _selectedSlot = null;
    _selectedTime = null;
    _reservationSuccess = false;
    notifyListeners();
  }

  // ── Slot selection ────────────────────────────────────────
  void selectSlot(ParkingSlot slot) {
    if (!slot.isAvailable) return;
    _selectedSlot = slot;
    _selectedTime = null;
    _reservationSuccess = false;
    notifyListeners();
  }

  void clearSelection() {
    _selectedSlot = null;
    _selectedTime = null;
    notifyListeners();
  }

  // ── Time selection ────────────────────────────────────────
  void selectTime(String time) {
    _selectedTime = time;
    notifyListeners();
  }

  // ── Reserve ───────────────────────────────────────────────
  Future<bool> reserve({String reservedBy = 'Guest User'}) async {
    if (_selectedSlot == null || _selectedTime == null) return false;

    _state = LoadState.loading;
    notifyListeners();

    try {
      final updated = await _service.reserveSlot(
        slotId:       _selectedSlot!.id,
        reservedBy:   reservedBy,
        reservedTime: _selectedTime!,
      );
      _patchSlot(updated);
      _lastReservationSlotId = updated.id;
      _reservationSuccess    = true;
      _selectedSlot          = null;
      _selectedTime          = null;
      _state                 = LoadState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _state = LoadState.error;
      notifyListeners();
      return false;
    }
  }

  // ── Release ───────────────────────────────────────────────
  Future<void> release(String slotId) async {
    try {
      final updated = await _service.releaseSlot(slotId);
      _patchSlot(updated);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void dismissSuccess() {
    _reservationSuccess = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    _ws.disconnect();
    super.dispose();
  }
}