class FortuneCategory {
  final String id;
  final String name;
  final String japaneseTitle;
  final String description;
  final String iconPath;
  final int stars;

  FortuneCategory({
    required this.id,
    required this.name,
    required this.japaneseTitle,
    required this.description,
    required this.iconPath,
    required this.stars,
  });
}

final List<FortuneCategory> fortuneCategories = [
  FortuneCategory(
    id: 'card-reading',
    name: 'Card Reading',
    japaneseTitle: 'カードリーディング',
    description: '過去・現在・未来の流れを読み解き、あなたの運命を導きます。',
    iconPath: 'assets/images/icon_card.png',
    stars: 3,
  ),
  FortuneCategory(
    id: 'astrology',
    name: 'Astrology',
    japaneseTitle: '占星術',
    description: '星の動きからあなたの運命と可能性を紐解きます。',
    iconPath: 'assets/images/icon_astrology.png',
    stars: 4,
  ),
  FortuneCategory(
    id: 'spiritual',
    name: 'Spiritual',
    japaneseTitle: 'スピリチュアル',
    description: '目に見えない世界からのメッセージをお届けします。',
    iconPath: 'assets/images/icon_spiritual.png',
    stars: 5,
  ),
  FortuneCategory(
    id: 'numerology',
    name: 'Numerology',
    japaneseTitle: '数秘術',
    description: '数字に宿る神秘的な力を通じてあなたの運命を紐解きます。',
    iconPath: 'assets/images/icon_numbers.png',
    stars: 3,
  ),
  FortuneCategory(
    id: 'dream',
    name: 'Dream Reading',
    japaneseTitle: '夢占い',
    description: '夢に込められたメッセージを解読し、あなたの無意識を探ります。',
    iconPath: 'assets/images/icon_dream.png',
    stars: 4,
  ),
];
