class Channel {
  final String id;
  final String name;
  final String logo;
  final String groupTitle;
  final String url;
  final String? tvgId;
  final String? country;
  final String? language;

  Channel({
    required this.id,
    required this.name,
    required this.logo,
    required this.groupTitle,
    required this.url,
    this.tvgId,
    this.country,
    this.language,
  });

  factory Channel.fromM3uLine(String extinfLine, String urlLine) {
    final nameRegExp = RegExp(r'tvg-name="([^"]*)"');
    final logoRegExp = RegExp(r'tvg-logo="([^"]*)"');
    final groupRegExp = RegExp(r'group-title="([^"]*)"');
    final tvgIdRegExp = RegExp(r'tvg-id="([^"]*)"');
    final countryRegExp = RegExp(r'tvg-country="([^"]*)"');
    final languageRegExp = RegExp(r'tvg-language="([^"]*)"');
    final idRegExp = RegExp(r'#EXTINF:-1.*,(.*)');

    return Channel(
      id: urlLine.split('/').last,
      name: nameRegExp.firstMatch(extinfLine)?.group(1) ??
          idRegExp.firstMatch(extinfLine)?.group(1) ??
          'Unknown',
      logo: logoRegExp.firstMatch(extinfLine)?.group(1) ?? '',
      groupTitle: groupRegExp.firstMatch(extinfLine)?.group(1) ?? 'Others',
      url: urlLine,
      tvgId: tvgIdRegExp.firstMatch(extinfLine)?.group(1),
      country: countryRegExp.firstMatch(extinfLine)?.group(1),
      language: languageRegExp.firstMatch(extinfLine)?.group(1),
    );
  }
}
