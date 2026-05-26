class DailyFactEntity {
  final int year;
  final String text;
  final String? imageUrl;
  final String? pageTitle;
  final String? pageExtract;
  final String? wikipediaUrl;

  const DailyFactEntity({
    required this.year,
    required this.text,
    this.imageUrl,
    this.pageTitle,
    this.pageExtract,
    this.wikipediaUrl,
  });

  String get era {
    if (year >= 1922 && year <= 1991) return 'СССР';
    if (year >= 1721 && year <= 1917) return 'Российская империя';
    if (year >= 1918 && year <= 1922) return 'Гражданская война';
    if (year >= 1992) return 'Современная Россия';
    return 'Россия';
  }
}
