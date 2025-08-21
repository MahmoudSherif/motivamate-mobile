import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class Quote {
  final String text;
  final String author;
  final bool isArabic;
  
  Quote({
    required this.text,
    required this.author,
    required this.isArabic,
  });
}

class QuotesProvider with ChangeNotifier {
  Timer? _timer;
  int _currentQuoteIndex = 0;
  
  final List<Quote> _quotes = [
    // English quotes
    Quote(
      text: "The future belongs to those who believe in the beauty of their dreams.",
      author: "Eleanor Roosevelt",
      isArabic: false,
    ),
    Quote(
      text: "Success is not final, failure is not fatal: it is the courage to continue that counts.",
      author: "Winston Churchill",
      isArabic: false,
    ),
    Quote(
      text: "The only way to do great work is to love what you do.",
      author: "Steve Jobs",
      isArabic: false,
    ),
    Quote(
      text: "Innovation distinguishes between a leader and a follower.",
      author: "Steve Jobs",
      isArabic: false,
    ),
    Quote(
      text: "The journey of a thousand miles begins with one step.",
      author: "Lao Tzu",
      isArabic: false,
    ),
    Quote(
      text: "Your limitation—it's only your imagination.",
      author: "Unknown",
      isArabic: false,
    ),
    Quote(
      text: "Push yourself, because no one else is going to do it for you.",
      author: "Unknown",
      isArabic: false,
    ),
    Quote(
      text: "Great things never come from comfort zones.",
      author: "Unknown",
      isArabic: false,
    ),
    Quote(
      text: "Dream it. Wish it. Do it.",
      author: "Unknown",
      isArabic: false,
    ),
    Quote(
      text: "Don't wait for opportunity. Create it.",
      author: "Unknown",
      isArabic: false,
    ),
    
    // Arabic quotes
    Quote(
      text: "من جدّ وجد، ومن زرع حصد",
      author: "مثل عربي",
      isArabic: true,
    ),
    Quote(
      text: "العلم نور والجهل ظلام",
      author: "مثل عربي",
      isArabic: true,
    ),
    Quote(
      text: "اطلبوا العلم من المهد إلى اللحد",
      author: "الحديث الشريف",
      isArabic: true,
    ),
    Quote(
      text: "الصبر مفتاح الفرج",
      author: "مثل عربي",
      isArabic: true,
    ),
    Quote(
      text: "لا تؤجل عمل اليوم إلى الغد",
      author: "مثل عربي",
      isArabic: true,
    ),
    Quote(
      text: "من صبر ظفر",
      author: "مثل عربي",
      isArabic: true,
    ),
    Quote(
      text: "العقل السليم في الجسم السليم",
      author: "مثل عربي",
      isArabic: true,
    ),
    Quote(
      text: "الوقت كالذهب إن لم تقطعه قطعك",
      author: "مثل عربي",
      isArabic: true,
    ),
    Quote(
      text: "النجاح يحتاج إلى تسعة أشهر مثل الولادة",
      author: "مثل عربي",
      isArabic: true,
    ),
    Quote(
      text: "خير الناس أنفعهم للناس",
      author: "الحديث الشريف",
      isArabic: true,
    ),
    Quote(
      text: "إنما الأعمال بالنيات",
      author: "الحديث الشريف",
      isArabic: true,
    ),
    Quote(
      text: "من طلب العلا سهر الليالي",
      author: "مثل عربي",
      isArabic: true,
    ),
    Quote(
      text: "الطريق إلى المجد لا يمر عبر الراحة",
      author: "مثل عربي",
      isArabic: true,
    ),
    Quote(
      text: "ما أصعب أن تحلم وأنت نائم، وما أجمل أن تحلم وأنت مستيقظ",
      author: "مثل عربي",
      isArabic: true,
    ),
    Quote(
      text: "الهمة العالية تصنع المعجزات",
      author: "مثل عربي",
      isArabic: true,
    ),
  ];
  
  Quote get currentQuote => _quotes[_currentQuoteIndex];
  
  QuotesProvider() {
    _startTimer();
    _shuffleQuotes();
  }
  
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _nextQuote();
    });
  }
  
  void _nextQuote() {
    _currentQuoteIndex = (_currentQuoteIndex + 1) % _quotes.length;
    notifyListeners();
  }
  
  void _shuffleQuotes() {
    _quotes.shuffle(Random());
  }
  
  void pauseTimer() {
    _timer?.cancel();
  }
  
  void resumeTimer() {
    if (_timer?.isActive != true) {
      _startTimer();
    }
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}