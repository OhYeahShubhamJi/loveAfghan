class Language {
  final int id;
  final String name;
  final String flag;
  final String languageCode;

  Language(this.id, this.name, this.flag, this.languageCode);

  static List<Language> languageList() {
    return <Language>[
      Language(1, 'English', '🇺🇸', 'en'),
      Language(2, 'Arabic', '🇦🇪', 'ar'),
      Language(3, 'Spanish', '🇪🇸', 'es'),
      Language(4, 'Dutch', '🇳🇱', 'nl'),
      Language(5, 'Russian', '🇷🇺', 'ru'),
      Language(6, 'Urdu', '🇵🇰', 'ur'),
      Language(7, 'Hindi', '🇮🇳', 'hi'),
      Language(8, 'German', '🇩🇪', 'de'),
      Language(9, 'French', '🇫🇷', 'fr'),
      Language(10, 'Farsi', '🇮🇷', 'fa'),
      Language(11, 'Pushto', '🇦🇫', 'ps'),
    ];
  }
}
