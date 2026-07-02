library;

class ExternalLinkModel {
  const ExternalLinkModel({
    required this.url,
    required this.label,
  });

  factory ExternalLinkModel.fromJson(Map<String, dynamic> json) {
    return ExternalLinkModel(
      url: json['url'] as String? ?? '',
      label: json['label'] as String? ?? '',
    );
  }

  final String url;
  final String label;

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'label': label,
    };
  }
}
