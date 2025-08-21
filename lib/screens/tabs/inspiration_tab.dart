import 'package:flutter/material.dart';
import '../../widgets/space_background.dart';
import '../../theme/app_theme.dart';

class HistoricalCharacter {
  final String name;
  final String title;
  final String description;
  final String achievement;
  final String quote;
  final String imageAsset;
  final Color themeColor;

  HistoricalCharacter({
    required this.name,
    required this.title,
    required this.description,
    required this.achievement,
    required this.quote,
    required this.imageAsset,
    required this.themeColor,
  });
}

class InspirationTab extends StatefulWidget {
  const InspirationTab({super.key});

  @override
  State<InspirationTab> createState() => _InspirationTabState();
}

class _InspirationTabState extends State<InspirationTab> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<HistoricalCharacter> _characters = [
    HistoricalCharacter(
      name: 'Albert Einstein',
      title: 'Theoretical Physicist',
      description: 'German-born theoretical physicist who developed the theory of relativity, one of the two pillars of modern physics.',
      achievement: 'Theory of Relativity, Nobel Prize in Physics',
      quote: 'Imagination is more important than knowledge.',
      imageAsset: '👨‍🔬', // Using emoji as placeholder
      themeColor: Colors.blue,
    ),
    HistoricalCharacter(
      name: 'Marie Curie',
      title: 'Physicist and Chemist',
      description: 'Polish-French physicist and chemist who conducted pioneering research on radioactivity.',
      achievement: 'First woman to win Nobel Prize, only person to win Nobel Prizes in two different sciences',
      quote: 'Nothing in life is to be feared, it is only to be understood.',
      imageAsset: '👩‍🔬',
      themeColor: Colors.purple,
    ),
    HistoricalCharacter(
      name: 'Leonardo da Vinci',
      title: 'Renaissance Polymath',
      description: 'Italian Renaissance polymath who was active as a painter, draughtsman, engineer, scientist, theorist, sculptor and architect.',
      achievement: 'Mona Lisa, The Last Supper, numerous inventions and scientific discoveries',
      quote: 'Learning never exhausts the mind.',
      imageAsset: '🎨',
      themeColor: Colors.orange,
    ),
    HistoricalCharacter(
      name: 'Ibn Khaldun',
      title: 'Historian and Sociologist',
      description: 'Arab historiographer who is often viewed as one of the forerunners of modern historiography, sociology, and economics.',
      achievement: 'Father of modern historiography and sociology',
      quote: 'Knowledge comes only after practice.',
      imageAsset: '📚',
      themeColor: Colors.green,
    ),
    HistoricalCharacter(
      name: 'Nikola Tesla',
      title: 'Inventor and Engineer',
      description: 'Serbian-American inventor, electrical engineer, mechanical engineer, and futurist best known for his contributions to the design of the modern alternating current electricity supply system.',
      achievement: 'AC electrical system, wireless technology, over 300 patents',
      quote: 'The present is theirs; the future, for which I really worked, is mine.',
      imageAsset: '⚡',
      themeColor: Colors.cyan,
    ),
    HistoricalCharacter(
      name: 'Ibn Sina (Avicenna)',
      title: 'Physician and Philosopher',
      description: 'Persian polymath who is regarded as one of the most significant physicians, astronomers, thinkers and writers of the Islamic Golden Age.',
      achievement: 'The Canon of Medicine, contributions to philosophy and science',
      quote: 'The knowledge of anything, since all things have causes, is not acquired or complete unless it is known by its causes.',
      imageAsset: '🏥',
      themeColor: Colors.teal,
    ),
    HistoricalCharacter(
      name: 'Thomas Edison',
      title: 'Inventor and Businessman',
      description: 'American inventor and businessman who has been described as America\'s greatest inventor.',
      achievement: 'Light bulb, phonograph, motion picture camera, over 1000 patents',
      quote: 'Genius is one percent inspiration, ninety-nine percent perspiration.',
      imageAsset: '💡',
      themeColor: Colors.amber,
    ),
    HistoricalCharacter(
      name: 'Al-Khwarizmi',
      title: 'Mathematician and Astronomer',
      description: 'Persian mathematician, astronomer and geographer during the Abbasid Caliphate, a scholar in the House of Wisdom in Baghdad.',
      achievement: 'Father of Algebra, introduced Hindu-Arabic numeral system to the Western world',
      quote: 'That fondness for science, that affability and condescension which God shows to the learned, that promptitude with which he protects and supports them in the elucidation of obscurities and in the removal of difficulties.',
      imageAsset: '🔢',
      themeColor: Colors.indigo,
    ),
    HistoricalCharacter(
      name: 'Mahatma Gandhi',
      title: 'Political and Spiritual Leader',
      description: 'Indian lawyer, anti-colonial nationalist and political ethicist who employed nonviolent resistance to lead the successful campaign for India\'s independence from British rule.',
      achievement: 'Led India to independence through non-violent civil disobedience',
      quote: 'Be the change that you wish to see in the world.',
      imageAsset: '🕊️',
      themeColor: Colors.brown,
    ),
    HistoricalCharacter(
      name: 'Steve Jobs',
      title: 'Technology Entrepreneur',
      description: 'American business magnate, industrial designer, investor, and media proprietor who was the co-founder, chairman, and CEO of Apple Inc.',
      achievement: 'Co-founded Apple, revolutionized personal computing, smartphones, and digital publishing',
      quote: 'Innovation distinguishes between a leader and a follower.',
      imageAsset: '📱',
      themeColor: Colors.grey,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // Header
          GlassContainer(
            child: Row(
              children: [
                const Icon(
                  Icons.auto_stories,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Historical Inspirations',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Learn from the greatest minds in history',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Character Cards
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: _characters.length,
              itemBuilder: (context, index) {
                return _buildCharacterCard(_characters[index]);
              },
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Page Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _characters.length,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index
                      ? AppColors.primary
                      : AppColors.textSecondary.withOpacity(0.3),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Navigation Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _currentIndex > 0
                      ? () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.glassPrimary,
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.glassBorder),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _currentIndex < _characters.length - 1
                      ? () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterCard(HistoricalCharacter character) {
    return SingleChildScrollView(
      child: GlassContainer(
        child: Column(
          children: [
            // Character Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    character.themeColor.withOpacity(0.2),
                    character.themeColor.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppBorderRadius.lg),
                  topRight: Radius.circular(AppBorderRadius.lg),
                ),
              ),
              child: Column(
                children: [
                  // Character Image/Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: character.themeColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: character.themeColor,
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        character.imageAsset,
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  // Name
                  Text(
                    character.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: AppSpacing.xs),
                  
                  // Title
                  Text(
                    character.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: character.themeColor,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Description
            _buildSection(
              'About',
              character.description,
              Icons.person,
              character.themeColor,
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Achievement
            _buildSection(
              'Known For',
              character.achievement,
              Icons.emoji_events,
              character.themeColor,
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Quote
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: character.themeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                border: Border.all(
                  color: character.themeColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.format_quote,
                        color: character.themeColor,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Inspiring Quote',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '"${character.quote}"',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontStyle: FontStyle.italic,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '— ${character.name}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: character.themeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Motivation Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.accent.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb,
                        color: AppColors.accent,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'What We Can Learn',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _getMotivationalText(character),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
            height: 1.5,
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  String _getMotivationalText(HistoricalCharacter character) {
    switch (character.name) {
      case 'Albert Einstein':
        return 'Einstein teaches us that curiosity and imagination are more powerful than mere knowledge. His approach to problem-solving involved thinking outside conventional boundaries and questioning fundamental assumptions. Apply this to your studies by asking "why" and "what if" questions, and don\'t be afraid to explore unconventional solutions.';
      
      case 'Marie Curie':
        return 'Marie Curie\'s perseverance in the face of gender discrimination and scientific challenges shows us that determination can overcome any obstacle. She reminds us that understanding conquers fear, and that continuous learning and research lead to breakthrough discoveries. Face your challenges with curiosity rather than fear.';
      
      case 'Leonardo da Vinci':
        return 'Da Vinci exemplifies the power of interdisciplinary learning. He didn\'t limit himself to one field but explored art, science, engineering, and anatomy. This teaches us that knowledge from different areas can enhance and inform each other. Don\'t be afraid to explore diverse interests and find connections between them.';
      
      case 'Ibn Khaldun':
        return 'Ibn Khaldun pioneered the scientific approach to history and sociology. His work teaches us the importance of systematic observation and analysis. Apply this by developing critical thinking skills, gathering evidence before forming conclusions, and understanding the interconnectedness of different phenomena.';
      
      case 'Nikola Tesla':
        return 'Tesla\'s visionary thinking and dedication to innovation remind us that the future belongs to those who dare to dream and work toward those dreams. His persistence despite numerous failures teaches us that setbacks are stepping stones to success. Stay focused on your long-term vision while working diligently in the present.';
      
      case 'Ibn Sina (Avicenna)':
        return 'Avicenna\'s comprehensive approach to knowledge, combining medicine, philosophy, and science, shows us the value of holistic learning. His emphasis on understanding causes teaches us to dig deeper and seek root understanding rather than surface-level knowledge. Always ask not just "what" but "why" and "how."';
      
      case 'Thomas Edison':
        return 'Edison\'s famous quote about genius being 1% inspiration and 99% perspiration emphasizes the crucial role of hard work and persistence. His numerous failures before each success teach us that failure is part of the learning process. Embrace effort, learn from failures, and keep iterating toward your goals.';
      
      case 'Al-Khwarizmi':
        return 'Al-Khwarizmi\'s systematic approach to mathematics laid the foundation for algebra and modern computational thinking. His work teaches us the power of creating systematic methods and processes. Apply this by developing structured approaches to problem-solving and breaking complex challenges into manageable steps.';
      
      case 'Mahatma Gandhi':
        return 'Gandhi\'s philosophy of being the change you wish to see reminds us that personal transformation is the foundation of broader change. His commitment to non-violence and truth teaches us that principles matter more than shortcuts. Lead by example and stay true to your values even when it\'s difficult.';
      
      case 'Steve Jobs':
        return 'Jobs\' focus on innovation and user experience teaches us to think differently and challenge the status quo. His attention to detail and pursuit of perfection remind us that excellence requires going beyond "good enough." Always strive to create something meaningful and don\'t settle for mediocrity.';
      
      default:
        return 'Every great person in history teaches us that extraordinary achievements come from ordinary people who refuse to give up on their dreams and consistently work toward their goals.';
    }
  }
}