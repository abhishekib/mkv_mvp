class Channel {
  final String name;
  final String url;
  final String logo;
  final String group;
  final String tvgId;

  Channel({
    required this.name,
    required this.url,
    required this.logo,
    required this.group,
    required this.tvgId,
  });

  factory Channel.fromM3U8Line(String extinf, String url) {
    // Parse EXTINF line: #EXTINF:-1 tvg-id="" tvg-name="F1| F1 TV FHD" tvg-logo="..." group-title="...",Channel Name
    final nameMatch = RegExp(r'tvg-name="([^"]*)"').firstMatch(extinf);
    final logoMatch = RegExp(r'tvg-logo="([^"]*)"').firstMatch(extinf);
    final groupMatch = RegExp(r'group-title="([^"]*)"').firstMatch(extinf);
    final tvgIdMatch = RegExp(r'tvg-id="([^"]*)"').firstMatch(extinf);

    final splitLine = extinf.split(',');
    final channelName = splitLine.length > 1 ? splitLine.last.trim() : '';

    return Channel(
      name: nameMatch?.group(1) ?? channelName,
      url: url.trim(),
      logo: logoMatch?.group(1) ?? '',
      group: groupMatch?.group(1) ?? '',
      tvgId: tvgIdMatch?.group(1) ?? '',
    );
  }
}
