class Unit {
  String unitCode;
  String unitName;
  String type;
  String category;
  String qrCode;
  bool isActive;

  Unit({
    required this.unitCode,
    required this.unitName,
    required this.type,
    required this.category,
    required this.qrCode,
    this.isActive = true,
  });

  factory Unit.fromMap(Map<String, dynamic> map) {
    return Unit(
      unitCode: map['unit_code'] ?? '',
      unitName: map['unit_name'] ?? '',
      type: map['type'] ?? '',
      category: map['category'] ?? '',
      qrCode: map['qr_code'] ?? '',
      isActive: map['is_active'] == 1 || map['is_active'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'unit_code': unitCode,
      'unit_name': unitName,
      'type': type,
      'category': category,
      'qr_code': qrCode,
      'is_active': isActive ? 1 : 0,
    };
  }

  // Method untuk mendapatkan kapasitas tangki berdasarkan tipe (dapat dikustomisasi)
  double getTankCapacity() {
    // Default kapasitas berdasarkan tipe
    if (category.toLowerCase().contains('dump') || 
        category.toLowerCase().contains('truck')) {
      return 1200.0; // Dump Truck: 1200 Liter
    } else if (category.toLowerCase().contains('excavator')) {
      return 800.0; // Excavator: 800 Liter
    } else if (category.toLowerCase().contains('bulldozer')) {
      return 1000.0; // Bulldozer: 1000 Liter
    } else if (category.toLowerCase().contains('loader')) {
      return 600.0; // Loader: 600 Liter
    } else if (category.toLowerCase().contains('grader')) {
      return 500.0; // Grader: 500 Liter
    } else {
      return 800.0; // Default: 800 Liter
    }
  }

  // Method untuk mendapatkan baseline konsumsi fuel per jam
  double getBaselineConsumption() {
    // Default konsumsi berdasarkan tipe (Liter per jam)
    if (category.toLowerCase().contains('dump') || 
        category.toLowerCase().contains('truck')) {
      return 35.0; // Dump Truck: 35 L/jam
    } else if (category.toLowerCase().contains('excavator')) {
      return 22.0; // Excavator: 22 L/jam
    } else if (category.toLowerCase().contains('bulldozer')) {
      return 40.0; // Bulldozer: 40 L/jam
    } else if (category.toLowerCase().contains('loader')) {
      return 25.0; // Loader: 25 L/jam
    } else if (category.toLowerCase().contains('grader')) {
      return 20.0; // Grader: 20 L/jam
    } else {
      return 25.0; // Default: 25 L/jam
    }
  }

  // Method untuk menampilkan nama lengkap unit
  String getFullName() {
    return '$unitCode - $unitName';
  }

  @override
  String toString() {
    return 'Unit(unitCode: $unitCode, unitName: $unitName, type: $type, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Unit && other.unitCode == unitCode;
  }

  @override
  int get hashCode => unitCode.hashCode;
}