library;

enum DocumentLabel {
  passport('Passport'),
  contract('Contract'),
  representationAgreement('Representation Agreement (RA)'),
  medicalCertificate('Medical Certificate'),
  workPermit('Work Permit'),
  visa('Visa'),
  transferAgreement('Transfer Agreement'),
  releaseLetter('Release Letter'),
  insurance('Insurance'),
  other('Other');

  const DocumentLabel(this.displayName);

  final String displayName;

  static DocumentLabel? fromDisplayName(String value) {
    for (final label in values) {
      if (label.displayName == value) return label;
    }
    return null;
  }

  static List<DocumentLabel> get selectableOptions => values;
}
