/// Country code data class for the phone number country picker.
///
/// Each entry provides a country [name], international [dialCode],
/// [flag] emoji, and ISO 3166-1 alpha-2 [code]. The [all] list is
/// easily extensible by downstream projects.
library;

class CountryCode {
  const CountryCode({
    required this.name,
    required this.dialCode,
    required this.flag,
    required this.code,
  });

  /// Country display name (English).
  final String name;

  /// International dial code including the leading `+` (e.g. "+971").
  final String dialCode;

  /// Unicode flag emoji (e.g. "🇦🇪").
  final String flag;

  /// ISO 3166-1 alpha-2 country code (e.g. "AE").
  final String code;

  /// Curated list of countries with dial codes.
  ///
  /// Downstream projects can extend this list by adding entries.
  static const List<CountryCode> all = [
    CountryCode(name: 'United Arab Emirates', dialCode: '+971', flag: '🇦🇪', code: 'AE'),
    CountryCode(name: 'United States', dialCode: '+1', flag: '🇺🇸', code: 'US'),
    CountryCode(name: 'United Kingdom', dialCode: '+44', flag: '🇬🇧', code: 'GB'),
    CountryCode(name: 'Saudi Arabia', dialCode: '+966', flag: '🇸🇦', code: 'SA'),
    CountryCode(name: 'Egypt', dialCode: '+20', flag: '🇪🇬', code: 'EG'),
    CountryCode(name: 'India', dialCode: '+91', flag: '🇮🇳', code: 'IN'),
    CountryCode(name: 'Germany', dialCode: '+49', flag: '🇩🇪', code: 'DE'),
    CountryCode(name: 'France', dialCode: '+33', flag: '🇫🇷', code: 'FR'),
    CountryCode(name: 'Italy', dialCode: '+39', flag: '🇮🇹', code: 'IT'),
    CountryCode(name: 'Spain', dialCode: '+34', flag: '🇪🇸', code: 'ES'),
    CountryCode(name: 'Canada', dialCode: '+1', flag: '🇨🇦', code: 'CA'),
    CountryCode(name: 'Australia', dialCode: '+61', flag: '🇦🇺', code: 'AU'),
    CountryCode(name: 'Pakistan', dialCode: '+92', flag: '🇵🇰', code: 'PK'),
    CountryCode(name: 'Bangladesh', dialCode: '+880', flag: '🇧🇩', code: 'BD'),
    CountryCode(name: 'Indonesia', dialCode: '+62', flag: '🇮🇩', code: 'ID'),
    CountryCode(name: 'Turkey', dialCode: '+90', flag: '🇹🇷', code: 'TR'),
    CountryCode(name: 'Brazil', dialCode: '+55', flag: '🇧🇷', code: 'BR'),
    CountryCode(name: 'Mexico', dialCode: '+52', flag: '🇲🇽', code: 'MX'),
    CountryCode(name: 'Japan', dialCode: '+81', flag: '🇯🇵', code: 'JP'),
    CountryCode(name: 'South Korea', dialCode: '+82', flag: '🇰🇷', code: 'KR'),
  ];
}
