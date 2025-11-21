enum ContentType {
  text('0'),
  yt('1'),
  pdf('2');

  const ContentType(this.value);

  final String value;

  static ContentType fromString(String? value) {
    return ContentType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ContentType.text,
    );
  }
}

class Comprehension {
  const Comprehension({
    required this.isPlayed,
    required this.id,
    required this.languageId,
    required this.title,
    required this.detail,
    required this.status,
    required this.noOfQue,
    required this.contentType,
    required this.contentData,
  });

  Comprehension.fromJson(Map<String, dynamic> json)
    : isPlayed = (json['is_play'] as String? ?? '1') == '1',
      id = json['id'] as String,
      languageId = json['language_id'] as String,
      title = json['title'] as String,
      detail = json['detail'] as String,
      status = json['status'] as String,
      noOfQue = json['no_of_que'] as String,
      contentType = ContentType.fromString(json['content_type'] as String?),
      contentData = json['content_data'] as String? ?? '';

  Comprehension.empty()
    : isPlayed = true,
      id = '',
      languageId = '',
      title = '',
      detail = '',
      status = '',
      noOfQue = '',
      contentType = ContentType.text,
      contentData = '';

  final String id;
  final String languageId;
  final String title;
  final String detail;
  final String status;
  final String noOfQue;
  final bool isPlayed;
  final ContentType contentType;
  final String contentData;
}
