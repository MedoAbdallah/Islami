class DuaCard {
  final String title;

  const DuaCard({
    required this.title,
  });
}

final List<DuaCard> duas = [
  // Morning & Evening
  DuaCard(title: 'دعاء الصباح'),
  DuaCard(title: 'دعاء المساء'),

  // Daily & Situational
  DuaCard(title: 'دعاء الخروج من المنزل'),
  DuaCard(title: 'دعاء دخول المنزل'),
  DuaCard(title: 'دعاء السفر'),
  DuaCard(title: 'دعاء ركوب الدابة'),

  // Emotional & Hardship
  DuaCard(title: 'دعاء الهم والحزن'),
  DuaCard(title: 'دعاء الكرب'),
  DuaCard(title: 'دعاء الخوف'),

  // Health & Provision
  DuaCard(title: 'دعاء الشفاء'),
  DuaCard(title: 'دعاء الرزق'),
  DuaCard(title: 'دعاء قضاء الدين'),

  // Family
  DuaCard(title: 'دعاء الوالدين'),
  DuaCard(title: 'دعاء الأبناء'),
  DuaCard(title: 'دعاء الزوجين'),

  // Worship related
  DuaCard(title: 'دعاء دخول المسجد'),
  DuaCard(title: 'دعاء الخروج من المسجد'),
  DuaCard(title: 'دعاء الاستفتاح'),
  DuaCard(title: 'دعاء القنوت'),
  DuaCard(title: 'دعاء ختم القرآن'),

  // Other common ones
  DuaCard(title: 'دعاء الاستخارة'),
  DuaCard(title: 'دعاء الرقية الشرعية'),
  DuaCard(title: 'دعاء النوم'),
  DuaCard(title: 'دعاء الاستيقاظ'),
  DuaCard(title: 'دعاء الطعام'),
  DuaCard(title: 'دعاء اللباس'),
];