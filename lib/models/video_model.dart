class VideoModel {
  final String name;
  final String logoUrl;
  final String streamUrl;
  final String groupTitle;

  VideoModel({
    required this.name,
    required this.logoUrl,
    required this.streamUrl,
    required this.groupTitle,
  });

  // Factory constructor to create an instance from a map
  factory VideoModel.fromMap(Map<String, dynamic> map) {
    return VideoModel(
      name: map['name'],
      logoUrl: map['logoUrl'],
      streamUrl: map['streamUrl'],
      groupTitle: map['groupTitle'],
    );
  }

  // Method to convert the object to a map (for sending in API requests, if needed)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'logoUrl': logoUrl,
      'streamUrl': streamUrl,
      'groupTitle': groupTitle,
    };
  }
}
