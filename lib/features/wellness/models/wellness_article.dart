class WellnessArticle {
  final int id;
  final int articleId;
  final String title;
  final String category;
  final String author;
  final String source;
  final String content;
  final String body;
  final String description;
  final String imageUrl;
  final String image;
  final String assetImagePath;
  final String meta;
  final String date;
  final String createdAt;
  final String updatedAt;

  const WellnessArticle({
    required this.id,
    required this.articleId,
    required this.title,
    required this.category,
    required this.author,
    required this.source,
    required this.content,
    required this.body,
    required this.description,
    required this.imageUrl,
    required this.image,
    required this.assetImagePath,
    required this.meta,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WellnessArticle.fromJson(Map<String, dynamic> json) {
    final parsedId = _asInt(
      json['ArticleId'] ??
          json['articleId'] ??
          json['article_id'] ??
          json['id'] ??
          json['Id'],
    );

    final parsedTitle = _asString(
      json['Title'] ??
          json['title'] ??
          json['ArticleTitle'] ??
          json['articleTitle'] ??
          json['article_title'] ??
          json['ArticleName'] ??
          json['articleName'] ??
          json['article_name'],
    );

    final parsedCategory = _asString(
      json['Category'] ??
          json['category'] ??
          json['ArticleCategory'] ??
          json['articleCategory'] ??
          json['article_category'] ??
          json['Type'] ??
          json['type'],
    );

    final parsedAuthor = _asString(json['Author'] ?? json['author']);

    final parsedSource = _asString(
      json['Source'] ?? json['source'] ?? json['Author'] ?? json['author'],
    );

    final parsedContent = _asString(
      json['Content'] ??
          json['content'] ??
          json['ArticleContent'] ??
          json['articleContent'] ??
          json['article_content'] ??
          json['Body'] ??
          json['body'] ??
          json['Description'] ??
          json['description'],
    );

    final parsedDescription = _asString(
      json['Description'] ??
          json['description'] ??
          json['Summary'] ??
          json['summary'] ??
          parsedContent,
    );

    final parsedImage = _asString(
      json['ImageUrl'] ??
          json['imageUrl'] ??
          json['image_url'] ??
          json['Image'] ??
          json['image'] ??
          json['Photo'] ??
          json['photo'] ??
          json['Thumbnail'] ??
          json['thumbnail'],
    );

    final parsedAssetImagePath = _asString(
      json['AssetImagePath'] ??
          json['assetImagePath'] ??
          json['asset_image_path'] ??
          json['AssetImage'] ??
          json['assetImage'] ??
          json['asset_image'] ??
          json['ImageAsset'] ??
          json['imageAsset'] ??
          json['image_asset'],
    );

    final parsedDate = _asString(
      json['Date'] ??
          json['date'] ??
          json['Created_at'] ??
          json['CreatedAt'] ??
          json['created_at'] ??
          json['createdAt'] ??
          json['PublishedAt'] ??
          json['published_at'],
    );

    final parsedMeta = _asString(
      json['Meta'] ??
          json['meta'] ??
          json['SubTitle'] ??
          json['subtitle'] ??
          json['Subtext'] ??
          json['subtext'],
    );

    return WellnessArticle(
      id: parsedId,
      articleId: parsedId,
      title: parsedTitle,
      category: parsedCategory,
      author: parsedAuthor,
      source: parsedSource,
      content: parsedContent,
      body: parsedContent,
      description: parsedDescription,
      imageUrl: parsedImage,
      image: parsedImage,
      assetImagePath: parsedAssetImagePath,
      meta: parsedMeta.isEmpty
          ? _buildMeta(parsedCategory, parsedSource, parsedDate)
          : parsedMeta,
      date: parsedDate,
      createdAt: _asString(
        json['Created_at'] ??
            json['CreatedAt'] ??
            json['created_at'] ??
            json['createdAt'],
      ),
      updatedAt: _asString(
        json['Updated_at'] ??
            json['UpdatedAt'] ??
            json['updated_at'] ??
            json['updatedAt'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ArticleId': articleId,
      'id': id,
      'Title': title,
      'Category': category,
      'Author': author,
      'Source': source,
      'Content': content,
      'Body': body,
      'Description': description,
      'ImageUrl': imageUrl,
      'Image': image,
      'AssetImagePath': assetImagePath,
      'Meta': meta,
      'Date': date,
      'Created_at': createdAt,
      'Updated_at': updatedAt,
    };
  }

  static String _buildMeta(String category, String source, String date) {
    final parts = <String>[];

    if (category.trim().isNotEmpty) {
      parts.add(category.trim());
    }

    if (source.trim().isNotEmpty) {
      parts.add(source.trim());
    }

    if (date.trim().isNotEmpty) {
      parts.add(date.trim());
    }

    return parts.join(' • ');
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.round() ?? 0;
    }
    return 0;
  }

  static String _asString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }
}
