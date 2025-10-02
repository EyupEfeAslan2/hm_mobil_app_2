// lib/data/content_data.dart

/// Content data organized by level, class, and profession
///
/// Structure:
/// - For 9th-10th grades: contentData[level][class]
/// - For 11th-12th grades with profession: contentData['level-class-profession']
const Map<String, dynamic> contentData = {
  // Lise 9. Sınıf - Genel
  'Lise': {
    '9. Sınıf': [
      'Doğal Sayılar ve Tam Sayılar',
      'Rasyonel Sayılar',
      'Kümeler',
      'Mantık',
      'Atom Yapısı ve Periyodik Sistem',
      'Kimyasal Türler Arası Etkileşimler',
      'Maddenin Halleri',
      'Hareket ve Kuvvet',
      'Enerji',
      'Isı ve Sıcaklık',
      'Hücre Biyolojisi ve Organizasyon',
      'Canlıların Sınıflandırılması',
      'Mitoz ve Mayoz Bölünme',
    ],
    '10. Sınıf': [
      'Fonksiyonlar ve Grafikler',
      'Polinomlar',
      'İkinci Dereceden Denklemler',
      'Trigonometri',
      'Asit-Baz Teorileri',
      'Kimyasal Tepkimeler',
      'Karışımlar',
      'Elektrik ve Manyetizma',
      'Basınç',
      'Dalgalar',
      'Solunum ve Dolaşım Sistemleri',
      'Destek ve Hareket Sistemi',
      'Sinir Sistemi',
    ],
  },

  // Lise 11. Sınıf - Sayısal
  'Lise-11. Sınıf-sayisal': [
    'Türev ve Uygulamaları',
    'İntegral Hesabı Giriş',
    'Diziler ve Seriler',
    'Limit ve Süreklilik',
    'Organik Kimya Temelleri',
    'Hidrokarbon Bileşikleri',
    'Fonksiyonel Gruplar',
    'İzomerlik',
    'Dalgalar ve Optik',
    'Modern Fizik Giriş',
    'Elektrik Devreleri',
    'Manyetik Alan',
    'Sindirim ve Boşaltım Sistemleri',
    'Duyu Organları',
    'İç Salgı Bezleri',
  ],

  // Lise 11. Sınıf - Sözel
  'Lise-11. Sınıf-sozel': [
    'Türk Edebiyatı - Tanzimat Dönemi',
    'Türk Edebiyatı - Servet-i Fünun',
    'Divan Edebiyatı',
    'Halk Edebiyatı',
    'Osmanlı Tarihi - Kuruluş Dönemi',
    'Osmanlı Tarihi - Yükselme Dönemi',
    'Osmanlı Tarihi - Duraklama Dönemi',
    'Türkiye Coğrafyası - Fiziki Coğrafya',
    'Türkiye Coğrafyası - Beşeri Coğrafya',
    'İnsan Hakları ve Özgürlükler',
  ],

  // Lise 11. Sınıf - Eşit Ağırlık
  'Lise-11. Sınıf-esit_agirlik': [
    'Türev ve Uygulamaları',
    'Olasılık',
    'İstatistik',
    'Türk Edebiyatı - Tanzimat Dönemi',
    'Türk Edebiyatı - Servet-i Fünun',
    'Osmanlı Tarihi - Yükselme Dönemi',
    'Türkiye Coğrafyası - Fiziki Coğrafya',
    'Türkiye Coğrafyası - Beşeri Coğrafya',
    'Organik Kimya Temelleri',
    'Dalgalar ve Optik',
  ],

  // Lise 12. Sınıf - Sayısal
  'Lise-12. Sınıf-sayisal': [
    'İntegral ve Uygulamaları',
    'Diferansiyel Denklemler Giriş',
    'Analitik Geometri',
    'Karmaşık Sayılar',
    'Kimyasal Denge ve Termodinamik',
    'Elektrokimya',
    'Nükleer Kimya',
    'Modern Fizik ve Atom Modelleri',
    'Kuantum Fiziği Giriş',
    'Elektromanyetik İndüksiyon',
    'Genetik ve Biyoteknoloji',
    'Ekoloji ve Çevre',
    'Evrim',
  ],

  // Lise 12. Sınıf - Sözel
  'Lise-12. Sınıf-sozel': [
    'Türk Edebiyatı - Milli Edebiyat',
    'Türk Edebiyatı - Cumhuriyet Dönemi',
    'Dünya Edebiyatı',
    'Osmanlı Tarihi - Dağılma Dönemi',
    'Türkiye Cumhuriyeti Tarihi',
    'Atatürk İlkeleri ve İnkılap Tarihi',
    'Dünya Tarihi - Sanayi Devrimi',
    'Dünya Tarihi - Dünya Savaşları',
    'Beşeri Coğrafya - Nüfus',
    'Beşeri Coğrafya - Yerleşme',
    'Ekonomik Coğrafya',
  ],

  // Lise 12. Sınıf - Eşit Ağırlık
  'Lise-12. Sınıf-esit_agirlik': [
    'İntegral ve Uygulamaları',
    'Olasılık ve İstatistik',
    'Analitik Geometri',
    'Türk Edebiyatı - Milli Edebiyat',
    'Türk Edebiyatı - Cumhuriyet Dönemi',
    'Türkiye Cumhuriyeti Tarihi',
    'Atatürk İlkeleri ve İnkılap Tarihi',
    'Beşeri Coğrafya - Nüfus',
    'Ekonomik Coğrafya',
    'Kimyasal Denge',
  ],
};
