class CountryCode {
  const CountryCode({
    required this.name,
    required this.flag,
    required this.dialCode,
    required this.hint,
  });

  final String name;
  final String flag;
  final String dialCode;
  final String hint;
}

class CountryCodes {
  const CountryCodes._();

  static const CountryCode brazil = CountryCode(
    name: "Brasil",
    flag: "🇧🇷",
    dialCode: "+55",
    hint: "(11) 99999-9999",
  );

  static const List<CountryCode> values = [
    brazil,
    CountryCode(name: "Argentina", flag: "🇦🇷", dialCode: "+54", hint: "11 2345-6789"),
    CountryCode(name: "Australia", flag: "🇦🇺", dialCode: "+61", hint: "412 345 678"),
    CountryCode(name: "Bolivia", flag: "🇧🇴", dialCode: "+591", hint: "71234567"),
    CountryCode(name: "Canada", flag: "🇨🇦", dialCode: "+1", hint: "(555) 123-4567"),
    CountryCode(name: "Chile", flag: "🇨🇱", dialCode: "+56", hint: "9 6123 4567"),
    CountryCode(name: "Colombia", flag: "🇨🇴", dialCode: "+57", hint: "301 2345678"),
    CountryCode(name: "Deutschland", flag: "🇩🇪", dialCode: "+49", hint: "1512 3456789"),
    CountryCode(name: "Ecuador", flag: "🇪🇨", dialCode: "+593", hint: "99 123 4567"),
    CountryCode(name: "España", flag: "🇪🇸", dialCode: "+34", hint: "612 34 56 78"),
    CountryCode(name: "France", flag: "🇫🇷", dialCode: "+33", hint: "6 12 34 56 78"),
    CountryCode(name: "Ireland", flag: "🇮🇪", dialCode: "+353", hint: "85 012 3456"),
    CountryCode(name: "Italia", flag: "🇮🇹", dialCode: "+39", hint: "312 345 6789"),
    CountryCode(name: "Japan", flag: "🇯🇵", dialCode: "+81", hint: "90-1234-5678"),
    CountryCode(name: "México", flag: "🇲🇽", dialCode: "+52", hint: "55 1234 5678"),
    CountryCode(name: "Nederland", flag: "🇳🇱", dialCode: "+31", hint: "6 12345678"),
    CountryCode(name: "Paraguay", flag: "🇵🇾", dialCode: "+595", hint: "961 456789"),
    CountryCode(name: "Perú", flag: "🇵🇪", dialCode: "+51", hint: "912 345 678"),
    CountryCode(name: "Portugal", flag: "🇵🇹", dialCode: "+351", hint: "912 345 678"),
    CountryCode(name: "United Kingdom", flag: "🇬🇧", dialCode: "+44", hint: "7400 123456"),
    CountryCode(name: "United States", flag: "🇺🇸", dialCode: "+1", hint: "(555) 123-4567"),
    CountryCode(name: "Uruguay", flag: "🇺🇾", dialCode: "+598", hint: "94 231 234"),
    CountryCode(name: "Venezuela", flag: "🇻🇪", dialCode: "+58", hint: "412-1234567"),
  ];
}
