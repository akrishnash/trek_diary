class DiaryImage {
  final String url;
  final String caption;

  const DiaryImage({required this.url, this.caption = ''});

  DiaryImage copyWith({String? url, String? caption}) =>
      DiaryImage(url: url ?? this.url, caption: caption ?? this.caption);

  factory DiaryImage.fromJson(Map<String, dynamic> j) => DiaryImage(
    url:     j['url'] as String? ?? '',
    caption: j['caption'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {'url': url, 'caption': caption};
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
    'text': text,
    'images': images.map((i) => i.toJson()).toList(),
  };

  bool get isEmpty => text.isEmpty && images.isEmpty;
}
