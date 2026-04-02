// ============================================================
// PRICING CONFIGURATION
// Fuel Tracker & Control System
// Update: 1 April 2026 - VERSI 2.0 with Launch Promo
// ============================================================

class PricingTier {
  final String name;
  final String priceMonthly;
  final String priceYearly;
  final List<String> features;
  final bool isPopular;
  final String color;
  final int normalUnits;
  final int promoUnits;
  final bool hasApiAccess;
  final String savingsEstimate;
  final bool isPromoActive;

  const PricingTier({
    required this.name,
    required this.priceMonthly,
    required this.priceYearly,
    required this.features,
    this.isPopular = false,
    this.color = 'blue',
    this.normalUnits = 5,
    this.promoUnits = 5,
    this.hasApiAccess = false,
    this.savingsEstimate = '',
    this.isPromoActive = false,
  });
  
  int get currentUnits => isPromoActive ? promoUnits : normalUnits;
  String get unitsDisplay => currentUnits == -1 
      ? 'Unlimited Units' 
      : 'Up to $currentUnits Units';
  String get originalUnitsDisplay => normalUnits == -1 
      ? 'Unlimited' 
      : '$normalUnits Units';
}

class PricingConfig {
  // ============================================================
  // HARGA VERSI 2.0 - MULTI-LAYER AUTHENTICATION
  // ============================================================
  
  // FLAG PROMO AWAL (3 bulan pertama setelah launch)
  static bool _isLaunchPromoActive = true; // Set ke false setelah periode promo berakhir
  
  // GETTER PUBLIC untuk akses dari luar
  static bool get isLaunchPromoActive => _isLaunchPromoActive;
  
  static const Map<String, dynamic> pricing = {
    'basic': {
      'name': 'Basic',
      'price_monthly': 7500000,
      'price_yearly': 75000000,
      'price_formatted': 'Rp 7.500.000',
      'price_yearly_formatted': 'Rp 75.000.000',
      'description': 'Solusi fuel tracking dengan Face ID',
      'savings_estimate': 'Hemat hingga Rp 35 Juta/bulan',
      'normal_units': 5,
      'promo_units': 10,
      'api_access': false,
      'color': 'blue',
      'features': [
        '✅ Fuel Entry & Tracking',
        '✅ Face ID + Liveness Verification',
        '✅ PIN Authentication (Backup)',
        '✅ GPS Location Tracking',
        '✅ Photo Documentation',
        '✅ Basic Reports (Excel/PDF)',
        '✅ Email Support (8x5)',
        '✅ 7 Days Data Retention',
      ],
    },
    'premium': {
      'name': 'Premium',
      'price_monthly': 18000000,
      'price_yearly': 180000000,
      'price_formatted': 'Rp 18.000.000',
      'price_yearly_formatted': 'Rp 180.000.000',
      'description': 'Fitur lengkap dengan Face ID + Fingerprint',
      'savings_estimate': 'Hemat hingga Rp 120 Juta/bulan',
      'normal_units': 15,
      'promo_units': 30,
      'api_access': false,
      'is_popular': true,
      'color': 'green',
      'features': [
        '✅ Everything in Basic',
        '✅ Fingerprint Authentication (NEW!)',
        '✅ Multi-Layer Auth Selector',
        '✅ Auto Detection Manipulation',
        '✅ Advanced Analytics Dashboard',
        '✅ Gap Analysis & Loss Estimation',
        '✅ Priority Support (24x7)',
        '✅ 30 Days Data Retention',
        '✅ WhatsApp & Email Notifications',
        '✅ Approval Workflow (3 levels)',
        '✅ Alert & Escalation Engine',
      ],
    },
    'suite': {
      'name': 'Suite',
      'price_monthly': 40000000,
      'price_yearly': 400000000,
      'price_formatted': 'Rp 40.000.000',
      'price_yearly_formatted': 'Rp 400.000.000',
      'description': 'Solusi enterprise dengan Multi-Layer Auth',
      'savings_estimate': 'Hemat hingga Rp 250 Juta/bulan',
      'normal_units': -1, // unlimited
      'promo_units': -1, // unlimited
      'api_access': true,
      'color': 'purple',
      'features': [
        '✅ Everything in Premium',
        '✅ Supervisor Verification (NEW!)',
        '✅ Manual Entry with Audit Trail (NEW!)',
        '✅ Offline Sync Engine (NEW!)',
        '✅ Admin Biometric Management (NEW!)',
        '✅ Unlimited Units',
        '✅ Full API Access',
        '✅ Custom Integration Support',
        '✅ 24/7 Dedicated Support',
        '✅ Unlimited Data Retention',
        '✅ Multi-Company Management',
        '✅ Custom Reports Builder',
        '✅ Complete Audit Trail',
        '✅ White-label Option',
        '✅ On-site Training (2 days)',
        '✅ SLA Guarantee 99.9%',
        '✅ Custom Feature Development',
      ],
    },
  };

  static List<PricingTier> get tiers {
    return [
      PricingTier(
        name: pricing['basic']!['name'],
        priceMonthly: pricing['basic']!['price_formatted'],
        priceYearly: pricing['basic']!['price_yearly_formatted'],
        features: List<String>.from(pricing['basic']!['features']),
        normalUnits: pricing['basic']!['normal_units'],
        promoUnits: pricing['basic']!['promo_units'],
        hasApiAccess: pricing['basic']!['api_access'],
        savingsEstimate: pricing['basic']!['savings_estimate'],
        color: pricing['basic']!['color'],
        isPromoActive: _isLaunchPromoActive,
      ),
      PricingTier(
        name: pricing['premium']!['name'],
        priceMonthly: pricing['premium']!['price_formatted'],
        priceYearly: pricing['premium']!['price_yearly_formatted'],
        features: List<String>.from(pricing['premium']!['features']),
        isPopular: pricing['premium']!['is_popular'],
        normalUnits: pricing['premium']!['normal_units'],
        promoUnits: pricing['premium']!['promo_units'],
        hasApiAccess: pricing['premium']!['api_access'],
        savingsEstimate: pricing['premium']!['savings_estimate'],
        color: pricing['premium']!['color'],
        isPromoActive: _isLaunchPromoActive,
      ),
      PricingTier(
        name: pricing['suite']!['name'],
        priceMonthly: pricing['suite']!['price_formatted'],
        priceYearly: pricing['suite']!['price_yearly_formatted'],
        features: List<String>.from(pricing['suite']!['features']),
        normalUnits: pricing['suite']!['normal_units'],
        promoUnits: pricing['suite']!['promo_units'],
        hasApiAccess: pricing['suite']!['api_access'],
        savingsEstimate: pricing['suite']!['savings_estimate'],
        color: pricing['suite']!['color'],
        isPromoActive: _isLaunchPromoActive,
      ),
    ];
  }

  static String formatPrice(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
  }

  static int getMonthlyPrice(String tier) {
    switch (tier) {
      case 'basic':
        return pricing['basic']!['price_monthly'];
      case 'premium':
        return pricing['premium']!['price_monthly'];
      case 'suite':
        return pricing['suite']!['price_monthly'];
      default:
        return 0;
    }
  }

  static int getYearlyPrice(String tier) {
    switch (tier) {
      case 'basic':
        return pricing['basic']!['price_yearly'];
      case 'premium':
        return pricing['premium']!['price_yearly'];
      case 'suite':
        return pricing['suite']!['price_yearly'];
      default:
        return 0;
    }
  }

  static String getROIEstimate(String tier) {
    switch (tier) {
      case 'basic':
        return 'Investasi Rp 7,5 Juta/bulan, potensi hemat Rp 35 Juta/bulan (ROI 467%)';
      case 'premium':
        return 'Investasi Rp 18 Juta/bulan, potensi hemat Rp 120 Juta/bulan (ROI 667%)';
      case 'suite':
        return 'Investasi Rp 40 Juta/bulan, potensi hemat Rp 250 Juta/bulan (ROI 625%)';
      default:
        return '';
    }
  }
  
  static String getPromoInfo() {
    if (!_isLaunchPromoActive) return '';
    
    return '''
🎉 LAUNCH PROMO! 🎉
• Basic: 5 → 10 Units (BONUS +100%)
• Premium: 15 → 30 Units (BONUS +100%)
• Periode: 3 bulan pertama setelah launch
• Harga tetap, kapasitas ganda!
''';
  }
  
  static String getPromoBadge(String tier) {
    if (!_isLaunchPromoActive) return '';
    
    switch (tier) {
      case 'basic':
        return '5 → 10 UNITS';
      case 'premium':
        return '15 → 30 UNITS';
      default:
        return '';
    }
  }
}