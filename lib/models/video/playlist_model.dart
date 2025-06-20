class Channel {
  final String id;
  final String name;
  final String logo;
  final String groupTitle;
  final String url;

  Channel({
    required this.id,
    required this.name,
    required this.logo,
    required this.groupTitle,
    required this.url,
  });

  factory Channel.fromM3uLine(String extinfLine, String urlLine) {
    final nameRegExp = RegExp(r'tvg-name="([^"]*)"');
    final logoRegExp = RegExp(r'tvg-logo="([^"]*)"');
    final groupRegExp = RegExp(r'group-title="([^"]*)"');
    final idRegExp = RegExp(r'#EXTINF:-1.*,(.*)');

    return Channel(
      id: urlLine.split('/').last,
      name: nameRegExp.firstMatch(extinfLine)?.group(1) ??
          idRegExp.firstMatch(extinfLine)?.group(1) ??
          'Unknown',
      logo: logoRegExp.firstMatch(extinfLine)?.group(1) ?? '',
      groupTitle: groupRegExp.firstMatch(extinfLine)?.group(1) ?? 'Others',
      url: urlLine,
    );
  }
}

class Playlist {
  final List<Channel> channels;

  Playlist(this.channels);

  factory Playlist.parseM3u(String m3uContent) {
    final lines = m3uContent.split('\n');
    final channels = <Channel>[];

    for (int i = 0; i < lines.length - 1; i++) {
      if (lines[i].startsWith('#EXTINF:')) {
        final urlLine = lines[i + 1].trim();
        if (urlLine.isNotEmpty && !urlLine.startsWith('#')) {
          channels.add(Channel.fromM3uLine(lines[i], urlLine));
        }
      }
    }

    return Playlist(channels);
  }
}
