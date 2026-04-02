class EscalationRule {
  final int severityLevel;
  final String alertType;
  final int minPositionLevel;
  final List<String> notificationChannels;
  final int delayMinutes;

  EscalationRule({
    required this.severityLevel,
    required this.alertType,
    required this.minPositionLevel,
    required this.notificationChannels,
    this.delayMinutes = 0,
  });

  static List<EscalationRule> getDefaultRules() {
    return [
      // Severity 1 (Informasi)
      EscalationRule(
        severityLevel: 1,
        alertType: 'HM_GAP',
        minPositionLevel: 3, // Supervisor
        notificationChannels: ['app'],
      ),
      EscalationRule(
        severityLevel: 1,
        alertType: 'TOTALIZER_GAP',
        minPositionLevel: 3,
        notificationChannels: ['app'],
      ),
      
      // Severity 2 (Peringatan)
      EscalationRule(
        severityLevel: 2,
        alertType: 'HM_GAP',
        minPositionLevel: 4, // Section Head
        notificationChannels: ['app', 'email'],
        delayMinutes: 30,
      ),
      EscalationRule(
        severityLevel: 2,
        alertType: 'TOTALIZER_GAP',
        minPositionLevel: 4,
        notificationChannels: ['app', 'email'],
        delayMinutes: 30,
      ),
      
      // Severity 3 (Kritis)
      EscalationRule(
        severityLevel: 3,
        alertType: 'HM_MANIPULATION',
        minPositionLevel: 5, // Department Head
        notificationChannels: ['app', 'email', 'whatsapp'],
      ),
      EscalationRule(
        severityLevel: 3,
        alertType: 'TOTALIZER_MANIPULATION',
        minPositionLevel: 5,
        notificationChannels: ['app', 'email', 'whatsapp'],
      ),
      EscalationRule(
        severityLevel: 3,
        alertType: 'HM_GAP',
        minPositionLevel: 5,
        notificationChannels: ['app', 'email', 'whatsapp'],
        delayMinutes: 60,
      ),
      
      // Severity 4 (Sangat Kritis)
      EscalationRule(
        severityLevel: 4,
        alertType: 'HM_MANIPULATION',
        minPositionLevel: 8, // Direksi
        notificationChannels: ['app', 'email', 'whatsapp', 'sms'],
      ),
      EscalationRule(
        severityLevel: 4,
        alertType: 'TOTALIZER_MANIPULATION',
        minPositionLevel: 8,
        notificationChannels: ['app', 'email', 'whatsapp', 'sms'],
      ),
      EscalationRule(
        severityLevel: 4,
        alertType: 'HM_GAP',
        minPositionLevel: 8,
        notificationChannels: ['app', 'email', 'whatsapp', 'sms'],
        delayMinutes: 120,
      ),
    ];
  }
}