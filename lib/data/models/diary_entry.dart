class DiaryImage {
  final String url;
  final String localPath;
  final String caption;

  const DiaryImage({
    this.url       = '',
    this.localPath = '',
    this.caption   = '',
  });

  bool get hasContent => url.isNotEmpty || localPath.isNotEmpty;
  String get displayPath => localPath.isNotEmpty ? localPath : url;

  DiaryImage copyWith({String? url, String? localPath, String? caption}) =>
      DiaryImage(
        url:       url       ?? this.url,
        localPath: localPath ?? this.localPath,
        caption:   caption   ?? this.caption,
      );

  factory DiaryImage.fromJson(Map<String, dynamic> j) => DiaryImage(
    url:       j['url']       as String? ?? '',
    localPath: j['localPath'] as String? ?? '',
    caption:   j['caption']   as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'url':       url,
    'localPath': localPath,
    'caption':   caption,
  };
}

class DiaryEntry {
  final String text;
  final List<DiaryImage> images;

  const DiaryEntry({this.text = '', this.images = const []});

  DiaryEntry copyWith({String? text, List<DiaryImage>? images}) =>
      DiaryEntry(text: text ?? this.text, images: images ?? this.images);

  factory DiaryEntry.fromJson(Map<String, dynamic> j) => DiaryEntry(
    text:   j['text'] as String? ?? '',
    images: (j['images'] as List? ?? [])
        .map((i) => DiaryImage.fromJson(i as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'text':   text,
    'images': images.map((i) => i.toJson()).toList(),
  };

  bool get isEmpty => text.isEmpty && images.isEmpty;
}
