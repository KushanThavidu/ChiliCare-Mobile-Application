import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class Message {
  final String text;
  final bool isUserMessage;
  final DateTime timestamp;
  final MessageType type;
  final List<String>? suggestions;

  Message(
    this.text,
    this.isUserMessage, {
    this.type = MessageType.text,
    this.suggestions,
  }) : timestamp = DateTime.now();
}

enum MessageType { text, welcome, tips, warning, success }

class ModernChatbotScreen extends StatefulWidget {
  const ModernChatbotScreen({Key? key}) : super(key: key);

  @override
  _ModernChatbotScreenState createState() => _ModernChatbotScreenState();
}

class _ModernChatbotScreenState extends State<ModernChatbotScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  final FocusNode _focusNode = FocusNode();

  late AnimationController _fadeController;
  late AnimationController _typingController;
  late AnimationController _floatingController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _typingAnimation;
  late Animation<double> _floatingAnimation;

  bool _isTyping = false;
  bool _isOnline = true;
  List<String> _quickReplies = [];

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _typingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _typingController, curve: Curves.easeInOut),
    );

    _floatingAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _floatingController.repeat(reverse: true);
    _fadeController.forward();

    _initializeChat();
  }

  void _initializeChat() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _addBotMessage(
        '🌶️ Welcome to ChiliCare AI Assistant!\n\nI\'m here to help you grow the perfect chili plants. I can assist with:\n\n• Disease & pest identification\n• Growing tips & care guides\n• Watering & fertilizing schedules\n• Harvesting advice\n• Troubleshooting problems',
        type: MessageType.welcome,
        suggestions: [
          '🌱 Growing Basics',
          '💧 Watering Guide',
          '🐛 Pest Control',
          '📋 Care Calendar'
        ]);
  }

  void _addBotMessage(String text,
      {MessageType type = MessageType.text, List<String>? suggestions}) {
    setState(() {
      _messages.add(Message(text, false, type: type, suggestions: suggestions));
      _quickReplies = suggestions ?? [];
    });
    _scrollToBottom();
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(Message(text.trim(), true));
      _controller.clear();
      _isTyping = true;
      _quickReplies.clear();
    });

    _typingController.repeat();
    _scrollToBottom();

    // Simulate bot thinking with variable delay
    int delay = 1000 + (text.length * 30).clamp(0, 2000);
    Future.delayed(Duration(milliseconds: delay), () {
      _getBotResponse(text.toLowerCase().trim());
    });
  }

  void _getBotResponse(String text) {
    String response = '';
    MessageType messageType = MessageType.text;
    List<String>? suggestions;

    // Advanced pattern matching with context awareness
    text = text.toLowerCase();

    // Greetings & Interaction
    if (_matchesAny(
        text, ['hello', 'hi', 'hey', 'good morning', 'good evening'])) {
      response =
          'Hello there! 👋 I\'m ChiliBot, your dedicated plant care companion. Ready to help you grow amazing chilies! What would you like to explore today?';
      suggestions = [
        '🌱 Start Growing',
        '🔍 Diagnose Problem',
        '📚 Learn More',
        '🗓️ Care Schedule'
      ];
    } else if (_matchesAny(text, ['how are you', 'what\'s up'])) {
      response =
          'I\'m doing fantastic! 🌟 Always excited to help fellow chili enthusiasts. Your plants are lucky to have someone who cares! How are your green friends doing?';
      suggestions = [
        'They\'re great!',
        'Having issues',
        'Just started',
        'Need advice'
      ];
    } else if (_matchesAny(text, ['bye', 'goodbye', 'see you', 'thanks bye'])) {
      response =
          'Happy growing! 🌶️ Remember to check on your plants daily. Feel free to come back anytime for more advice. May your harvest be bountiful! 🌱✨';
    }

    // Getting Started & Beginner Guide
    else if (_matchesAny(text, [
      'beginner',
      'start growing',
      'how to grow',
      'new to growing',
      'first time'
    ])) {
      response = '🌱 **BEGINNER\'S COMPLETE GUIDE**\n\n'
          '**STEP 1: Choose Your Variety**\n'
          '• Easy: Bell peppers, Jalapeños\n'
          '• Medium: Serranos, Thai chilies\n'
          '• Advanced: Ghost peppers, Reapers\n\n'
          '**STEP 2: Perfect Location**\n'
          '• 6-8 hours direct sunlight\n'
          '• Protected from strong winds\n'
          '• Good air circulation\n\n'
          '**STEP 3: Soil Preparation**\n'
          '• Well-draining potting mix\n'
          '• pH 6.0-7.0\n'
          '• Rich in organic matter';
      suggestions = [
        '🌶️ Variety Guide',
        '🏠 Indoor Growing',
        '📍 Location Tips',
        '🌿 Soil Mix Recipe'
      ];
    } else if (_matchesAny(
        text, ['variety', 'types', 'which chili', 'recommend variety'])) {
      response = '🌶️ **CHILI VARIETY GUIDE**\n\n'
          '**FOR BEGINNERS:**\n'
          '• Bell Pepper (0 SHU) - Sweet & mild\n'
          '• Banana Pepper (100-500 SHU)\n'
          '• Jalapeño (2,500-8,000 SHU)\n\n'
          '**INTERMEDIATE:**\n'
          '• Serrano (10K-25K SHU)\n'
          '• Thai Chili (50K-100K SHU)\n'
          '• Cayenne (30K-50K SHU)\n\n'
          '**ADVANCED:**\n'
          '• Habanero (100K-350K SHU)\n'
          '• Ghost Pepper (1M+ SHU)\n'
          '• Carolina Reaper (2.2M SHU)';
      suggestions = [
        '🌡️ Heat Levels',
        '🌱 Easy Varieties',
        '🔥 Super Hot',
        '📊 Compare Varieties'
      ];
    }

    // Planting & Seeds
    else if (_matchesAny(text, ['seed', 'planting', 'germination', 'sowing'])) {
      response = '🌱 **SEED STARTING SUCCESS**\n\n'
          '**Germination Setup:**\n'
          '• Temperature: 26-29°C (80-85°F)\n'
          '• Humidity: 70-80%\n'
          '• Use seed starting mix\n'
          '• Keep consistently moist\n\n'
          '**Timeline:**\n'
          '• Germination: 7-21 days\n'
          '• First true leaves: 2-4 weeks\n'
          '• Transplant ready: 6-8 weeks\n\n'
          '**Pro Tips:**\n'
          '• Soak seeds 12-24 hours\n'
          '• Use heat mat for consistency\n'
          '• Label everything!';
      suggestions = [
        '🌡️ Heat Mat Tips',
        '💧 Watering Seeds',
        '📅 Timing Guide',
        '🌿 Transplanting'
      ];
    } else if (_matchesAny(
        text, ['when to plant', 'planting time', 'best time'])) {
      response = '📅 **PERFECT TIMING GUIDE**\n\n'
          '**Climate-Based Planting:**\n'
          '• Tropical: Year-round possible\n'
          '• Temperate: After last frost\n'
          '• Indoor: Anytime with grow lights\n\n'
          '**Sri Lankan Calendar:**\n'
          '• Yala Season: April-September\n'
          '• Maha Season: October-March\n'
          '• Best: Start of monsoon\n\n'
          '**Indoor Starting:**\n'
          '• Start seeds 8-10 weeks before transplant\n'
          '• Use grow lights for consistent growth';
      messageType = MessageType.tips;
      suggestions = [
        '🌍 Climate Guide',
        '🏠 Indoor Timing',
        '📱 Set Reminder',
        '🌧️ Weather Tips'
      ];
    }

    // Soil & Growing Medium
    else if (_matchesAny(
        text, ['soil', 'potting mix', 'growing medium', 'compost'])) {
      response = '🌿 **PERFECT SOIL RECIPE**\n\n'
          '**Premium Mix (DIY):**\n'
          '• 40% Quality potting soil\n'
          '• 30% Compost\n'
          '• 20% Perlite/vermiculite\n'
          '• 10% Worm castings\n\n'
          '**Essential Properties:**\n'
          '• pH: 6.0-7.0\n'
          '• Well-draining\n'
          '• Rich in organic matter\n'
          '• Loose, airy texture\n\n'
          '**Budget Alternative:**\n'
          '• 60% Regular potting soil\n'
          '• 30% Compost\n'
          '• 10% Sand/perlite';
      suggestions = [
        '🧪 pH Testing',
        '💰 Budget Mix',
        '🪱 Worm Castings',
        '🏪 Store Bought'
      ];
    } else if (_matchesAny(text, ['ph', 'acidity', 'alkaline', 'ph level'])) {
      response = '🧪 **pH MANAGEMENT GUIDE**\n\n'
          '**Ideal Range: 6.0-7.0**\n\n'
          '**Too Acidic (below 6.0):**\n'
          '• Add: Lime, wood ash\n'
          '• Symptoms: Yellow leaves, poor growth\n\n'
          '**Too Alkaline (above 7.0):**\n'
          '• Add: Sulfur, peat moss\n'
          '• Symptoms: Iron deficiency, yellow veins\n\n'
          '**Testing:**\n'
          '• Digital pH meter (most accurate)\n'
          '• pH strips (budget option)\n'
          '• Test monthly';
      messageType = MessageType.warning;
      suggestions = [
        '📏 How to Test',
        '⬇️ Lower pH',
        '⬆️ Raise pH',
        '🛒 pH Products'
      ];
    }

    // Watering & Irrigation
    else if (_matchesAny(
        text, ['water', 'watering', 'irrigation', 'how much water'])) {
      response = '💧 **COMPLETE WATERING GUIDE**\n\n'
          '**The Golden Rules:**\n'
          '• Deep, infrequent watering\n'
          '• Water at soil level\n'
          '• Morning is best time\n'
          '• Check soil moisture first\n\n'
          '**Frequency Guide:**\n'
          '• Seedlings: Daily light misting\n'
          '• Young plants: Every 2-3 days\n'
          '• Mature plants: 2-4 times/week\n'
          '• Containers: More frequent\n\n'
          '**Finger Test:**\n'
          '• Stick finger 2 inches deep\n'
          '• If dry → water needed\n'
          '• If moist → wait';
      suggestions = [
        '⏰ Watering Schedule',
        '🏺 Container Tips',
        '☔ Rainwater Use',
        '🌡️ Climate Adjust'
      ];
    } else if (_matchesAny(
        text, ['overwatering', 'too much water', 'drowning plants'])) {
      response = '⚠️ **OVERWATERING EMERGENCY**\n\n'
          '**Warning Signs:**\n'
          '• Yellow, mushy leaves\n'
          '• Fungal growth\n'
          '• Root rot smell\n'
          '• Stunted growth\n\n'
          '**Immediate Action:**\n'
          '1. Stop watering immediately\n'
          '2. Improve drainage\n'
          '3. Remove affected leaves\n'
          '4. Check roots for rot\n\n'
          '**Prevention:**\n'
          '• Use finger test\n'
          '• Ensure drainage holes\n'
          '• Use well-draining soil';
      messageType = MessageType.warning;
      suggestions = [
        '🚨 Save My Plant',
        '🕳️ Drainage Tips',
        '🌿 Root Check',
        '💊 Treatment'
      ];
    } else if (_matchesAny(text, ['underwatering', 'dry soil', 'wilting'])) {
      response = '🏜️ **UNDERWATERING RECOVERY**\n\n'
          '**Warning Signs:**\n'
          '• Wilted, droopy leaves\n'
          '• Dry, cracked soil\n'
          '• Slow growth\n'
          '• Leaf drop\n\n'
          '**Recovery Steps:**\n'
          '1. Water slowly and deeply\n'
          '2. Add mulch to retain moisture\n'
          '3. Increase watering frequency\n'
          '4. Check drainage isn\'t TOO good\n\n'
          '**Prevention:**\n'
          '• Set watering reminders\n'
          '• Use moisture meters\n'
          '• Mulch around plants';
      messageType = MessageType.tips;
      suggestions = [
        '💧 Deep Watering',
        '⏰ Set Reminders',
        '🌾 Mulching Tips',
        '📱 Apps Help'
      ];
    }

    // Fertilizer & Nutrition
    else if (_matchesAny(text, ['fertilizer', 'nutrients', 'feeding', 'npk'])) {
      response = '🌿 **COMPLETE NUTRITION GUIDE**\n\n'
          '**Growth Stages:**\n'
          '• Seedling: Balanced (10-10-10)\n'
          '• Vegetative: High N (20-10-10)\n'
          '• Flowering: High P (10-20-10)\n'
          '• Fruiting: High K (10-10-20)\n\n'
          '**Feeding Schedule:**\n'
          '• Weekly: Diluted liquid fertilizer\n'
          '• Bi-weekly: Granular slow-release\n'
          '• Monthly: Compost top-dressing\n\n'
          '**Organic Options:**\n'
          '• Compost tea\n'
          '• Worm casting liquid\n'
          '• Fish emulsion\n'
          '• Banana peel water';
      suggestions = [
        '🌱 Organic Recipe',
        '📊 NPK Guide',
        '⏰ Feed Schedule',
        '💡 DIY Fertilizer'
      ];
    } else if (_matchesAny(text,
        ['organic fertilizer', 'natural fertilizer', 'homemade fertilizer'])) {
      response = '🌱 **ORGANIC FERTILIZER RECIPES**\n\n'
          '**Compost Tea:**\n'
          '• 1 cup compost + 1 gallon water\n'
          '• Steep 24-48 hours\n'
          '• Strain and dilute 1:10\n\n'
          '**Banana Peel Fertilizer:**\n'
          '• Chop 3-4 peels\n'
          '• Soak in 1L water for 48 hours\n'
          '• Use as potassium booster\n\n'
          '**Eggshell Calcium:**\n'
          '• Crush clean eggshells\n'
          '• Mix into soil\n'
          '• Prevents blossom end rot\n\n'
          '**Coffee Ground Mix:**\n'
          '• Mix used grounds with compost\n'
          '• Adds nitrogen and improves texture';
      messageType = MessageType.success;
      suggestions = [
        '🍌 Banana Recipe',
        '🥚 Calcium Boost',
        '☕ Coffee Grounds',
        '🍃 Compost Tea'
      ];
    }

    // Disease & Pest Management
    else if (_matchesAny(
        text, ['disease', 'sick plant', 'plant problem', 'unhealthy'])) {
      response = '🔍 **DISEASE IDENTIFICATION**\n\n'
          '**Common Diseases:**\n'
          '• **Leaf Spot:** Brown/black circles on leaves\n'
          '• **Powdery Mildew:** White powdery coating\n'
          '• **Blossom End Rot:** Dark spots on fruit bottom\n'
          '• **Wilt:** Sudden drooping despite moist soil\n\n'
          '**Immediate Actions:**\n'
          '1. Isolate affected plants\n'
          '2. Remove infected parts\n'
          '3. Improve air circulation\n'
          '4. Adjust watering schedule\n\n'
          '**Use our Disease Detection feature for accurate diagnosis!**';
      messageType = MessageType.warning;
      suggestions = [
        '📱 Use AI Detection',
        '🍃 Leaf Spot Help',
        '⚪ Mildew Treatment',
        '🎯 Specific Disease'
      ];
    } else if (_matchesAny(
        text, ['pest', 'insect', 'bug', 'aphid', 'spider mite'])) {
      response = '🐛 **PEST CONTROL ARSENAL**\n\n'
          '**Common Pests & Solutions:**\n\n'
          '**Aphids (Green/Black bugs):**\n'
          '• Spray with water\n'
          '• Neem oil treatment\n'
          '• Introduce ladybugs\n\n'
          '**Spider Mites (Tiny red dots):**\n'
          '• Increase humidity\n'
          '• Insecticidal soap\n'
          '• Predatory mites\n\n'
          '**Whiteflies (Small white flies):**\n'
          '• Yellow sticky traps\n'
          '• Neem oil spray\n'
          '• Reflective mulch\n\n'
          '**Thrips (Tiny yellow/black):**\n'
          '• Blue sticky traps\n'
          '• Beneficial predators';
      suggestions = [
        '🌿 Neem Oil Recipe',
        '🕷️ Mite Control',
        '🟡 Sticky Traps',
        '🐞 Beneficial Insects'
      ];
    } else if (_matchesAny(
        text, ['neem oil', 'natural pesticide', 'organic pest control'])) {
      response = '🌿 **NEEM OIL MASTER GUIDE**\n\n'
          '**Perfect Recipe:**\n'
          '• 2 tablespoons neem oil\n'
          '• 1 tablespoon mild dish soap\n'
          '• 1 gallon warm water\n'
          '• Mix thoroughly\n\n'
          '**Application Tips:**\n'
          '• Spray in evening/early morning\n'
          '• Cover all surfaces (top & bottom of leaves)\n'
          '• Apply every 3-7 days\n'
          '• Don\'t spray in direct sunlight\n\n'
          '**What it Controls:**\n'
          '• Aphids, spider mites, whiteflies\n'
          '• Powdery mildew\n'
          '• Thrips, scale insects';
      messageType = MessageType.success;
      suggestions = [
        '🍽️ Dish Soap Safe?',
        '⏰ Application Time',
        '🌡️ Weather Matters',
        '🔄 How Often'
      ];
    }

    // Plant Growth & Development
    else if (_matchesAny(
        text, ['flowering', 'bloom', 'flower', 'no flowers'])) {
      response = '🌸 **FLOWERING SUCCESS GUIDE**\n\n'
          '**Triggering Flowers:**\n'
          '• 12+ hour light periods\n'
          '• Reduce nitrogen fertilizer\n'
          '• Increase phosphorus\n'
          '• Maintain 21-29°C temperature\n\n'
          '**No Flowers? Check:**\n'
          '• Too much nitrogen (leafy growth)\n'
          '• Insufficient light\n'
          '• Temperature stress\n'
          '• Plant too young (wait 8-12 weeks)\n\n'
          '**Flower Drop Causes:**\n'
          '• Temperature extremes\n'
          '• Irregular watering\n'
          '• Low humidity\n'
          '• Stress';
      suggestions = [
        '🌡️ Temperature Tips',
        '💡 Light Requirements',
        '💧 Humidity Help',
        '🌿 Fertilizer Adjust'
      ];
    } else if (_matchesAny(
        text, ['fruit', 'pepper', 'harvest', 'when to pick'])) {
      response = '🌶️ **HARVESTING MASTERY**\n\n'
          '**Perfect Timing:**\n'
          '• **Green Stage:** Firm, full size\n'
          '• **Colored Stage:** Full color development\n'
          '• **Hot Peppers:** Wait for color change\n'
          '• **Sweet Peppers:** Can pick green or colored\n\n'
          '**Harvesting Technique:**\n'
          '• Use clean, sharp scissors\n'
          '• Cut stem, don\'t pull\n'
          '• Leave small stem on pepper\n'
          '• Harvest in morning\n\n'
          '**Frequency:**\n'
          '• Check daily during season\n'
          '• Regular picking encourages more fruit\n'
          '• Don\'t let overripe fruit stay on plant';
      messageType = MessageType.success;
      suggestions = [
        '🌈 Ripeness Guide',
        '✂️ Proper Cutting',
        '📦 Storage Tips',
        '🔄 Encourage More'
      ];
    }

    // Environmental Conditions
    else if (_matchesAny(text, ['temperature', 'heat', 'cold', 'weather'])) {
      response = '🌡️ **TEMPERATURE MANAGEMENT**\n\n'
          '**Ideal Ranges:**\n'
          '• **Germination:** 26-29°C (80-85°F)\n'
          '• **Growing:** 21-29°C (70-85°F)\n'
          '• **Flowering:** 18-32°C (65-90°F)\n'
          '• **Minimum:** Above 15°C (60°F)\n\n'
          '**Heat Stress (Above 35°C):**\n'
          '• Provide afternoon shade\n'
          '• Increase watering\n'
          '• Use shade cloth (30-50%)\n'
          '• Mist around plants\n\n'
          '**Cold Protection (Below 15°C):**\n'
          '• Move containers indoors\n'
          '• Use row covers\n'
          '• Mulch heavily\n'
          '• Water before cold nights';
      suggestions = [
        '🌡️ Monitor Temp',
        '☀️ Heat Protection',
        '🧊 Cold Shield',
        '📱 Weather Alerts'
      ];
    } else if (_matchesAny(text, ['humidity', 'dry air', 'humid'])) {
      response = '💨 **HUMIDITY CONTROL**\n\n'
          '**Ideal Range: 50-70%**\n\n'
          '**Too Dry (Below 40%):**\n'
          '• Use humidity trays\n'
          '• Group plants together\n'
          '• Mist air (not leaves)\n'
          '• Indoor humidifier\n\n'
          '**Too Humid (Above 80%):**\n'
          '• Improve air circulation\n'
          '• Space plants apart\n'
          '• Use fans\n'
          '• Reduce watering frequency\n\n'
          '**Indoor Solutions:**\n'
          '• Pebble trays with water\n'
          '• Humidifier/dehumidifier\n'
          '• Proper ventilation';
      suggestions = [
        '💧 Humidity Tray DIY',
        '🌬️ Air Flow Tips',
        '🏠 Indoor Control',
        '📏 Measure Humidity'
      ];
    }

    // Advanced Topics
    else if (_matchesAny(
        text, ['pruning', 'topping', 'trim', 'cutting back'])) {
      response = '✂️ **PRUNING FOR SUCCESS**\n\n'
          '**Early Season (First 6 weeks):**\n'
          '• Remove first flower buds\n'
          '• Pinch growing tips to encourage branching\n'
          '• Remove lower leaves touching soil\n\n'
          '**Mid Season:**\n'
          '• Remove suckers (shoots between main stem and branches)\n'
          '• Trim overcrowded branches\n'
          '• Remove diseased/damaged parts\n\n'
          '**Late Season:**\n'
          '• Top plants 4-6 weeks before first frost\n'
          '• Remove new flowers to redirect energy\n'
          '• Prune for air circulation';
      suggestions = [
        '🌱 Early Pruning',
        '✋ Remove Suckers',
        '🍂 End Season',
        '🔧 Pruning Tools'
      ];
    } else if (_matchesAny(text,
        ['companion planting', 'what to plant with', 'plant neighbors'])) {
      response = '🤝 **COMPANION PLANTING GUIDE**\n\n'
          '**EXCELLENT Companions:**\n'
          '• **Basil:** Improves flavor, repels pests\n'
          '• **Tomatoes:** Similar needs, mutual benefits\n'
          '• **Oregano:** Natural pest deterrent\n'
          '• **Marigolds:** Repel nematodes\n\n'
          '**GOOD Companions:**\n'
          '• Parsley, cilantro, thyme\n'
          '• Onions, garlic, chives\n'
          '• Lettuce, spinach (different heights)\n\n'
          '**AVOID Planting With:**\n'
          '• Fennel (allelopathic)\n'
          '• Beans (different nutrient needs)\n'
          '• Brassicas (cabbage family)';
      messageType = MessageType.tips;
      suggestions = [
        '🌿 Herb Partners',
        '🧄 Allium Benefits',
        '🌻 Flower Friends',
        '❌ Plants to Avoid'
      ];
    }

    // Container & Indoor Growing
    else if (_matchesAny(
        text, ['container', 'pot', 'indoor growing', 'grow lights'])) {
      response = '🏺 **CONTAINER GROWING EXPERT**\n\n'
          '**Container Requirements:**\n'
          '• **Minimum Size:** 5-gallon (20L)\n'
          '• **Drainage:** Multiple holes essential\n'
          '• **Material:** Fabric pots ideal\n'
          '• **Depth:** At least 12 inches\n\n'
          '**Indoor Setup:**\n'
          '• **LED Grow Lights:** Full spectrum\n'
          '• **Light Duration:** 14-16 hours/day\n'
          '• **Distance:** 12-24 inches from plants\n'
          '• **Air Circulation:** Small fan essential\n\n'
          '**Container Care:**\n'
          '• Water more frequently\n'
          '• Feed every 2 weeks\n'
          '• Monitor drainage\n'
          '• Rotate pots weekly';
      suggestions = [
        '💡 LED Lights',
        '🏺 Pot Sizing',
        '🌬️ Ventilation',
        '💧 Container Watering'
      ];
    }

    // Problem Solving & Troubleshooting
    else if (_matchesAny(
        text, ['yellow leaves', 'yellowing', 'leaves turning yellow'])) {
      response = '🟡 **YELLOW LEAVES DIAGNOSIS**\n\n'
          '**Bottom Leaves Yellow (Normal):**\n'
          '• Natural aging process\n'
          '• Remove gently\n'
          '• Continue normal care\n\n'
          '**Multiple Leaves Yellow:**\n'
          '• **Overwatering:** Most common cause\n'
          '• **Nitrogen Deficiency:** Feed with balanced fertilizer\n'
          '• **Root Problems:** Check for root rot\n'
          '• **Light Stress:** Too much or too little\n\n'
          '**Quick Fixes:**\n'
          '1. Check soil moisture\n'
          '2. Adjust watering schedule\n'
          '3. Apply balanced fertilizer\n'
          '4. Improve drainage if needed';
      messageType = MessageType.warning;
      suggestions = [
        '💧 Check Watering',
        '🌿 Fertilizer Fix',
        '🕳️ Drainage Help',
        '📸 Photo Diagnosis'
      ];
    } else if (_matchesAny(text, ['not growing', 'slow growth', 'stunted'])) {
      response = '🐌 **SLOW GROWTH SOLUTIONS**\n\n'
          '**Common Causes:**\n'
          '• **Insufficient Light:** Need 6+ hours direct sun\n'
          '• **Poor Nutrition:** Lacks essential nutrients\n'
          '• **Root Bound:** Needs larger container\n'
          '• **Temperature Stress:** Too hot/cold\n'
          '• **Watering Issues:** Over or under watering\n\n'
          '**Growth Boosters:**\n'
          '1. Move to sunnier location\n'
          '2. Apply balanced fertilizer\n'
          '3. Check root system\n'
          '4. Maintain consistent watering\n'
          '5. Ensure proper temperature\n\n'
          '**Expected Growth:**\n'
          '• Seedling to transplant: 6-8 weeks\n'
          '• First flowers: 8-12 weeks\n'
          '• First harvest: 12-16 weeks';
      suggestions = [
        '☀️ Light Solutions',
        '🌿 Nutrition Boost',
        '🏺 Repot Guide',
        '🌡️ Temperature Check'
      ];
    } else if (_matchesAny(
        text, ['dropping leaves', 'leaf drop', 'losing leaves'])) {
      response = '🍃 **LEAF DROP EMERGENCY**\n\n'
          '**Sudden Leaf Drop:**\n'
          '• **Shock:** Recent transplant/move\n'
          '• **Watering Stress:** Too much or too little\n'
          '• **Temperature Shock:** Sudden change\n'
          '• **Pest/Disease:** Check for signs\n\n'
          '**Gradual Leaf Drop:**\n'
          '• **Natural:** Lower leaves age out\n'
          '• **Light Deficiency:** Move to brighter spot\n'
          '• **Nutrient Deficiency:** Feed the plant\n\n'
          '**Recovery Plan:**\n'
          '1. Stabilize environment\n'
          '2. Check soil moisture\n'
          '3. Remove dropped leaves\n'
          '4. Reduce stress factors\n'
          '5. Be patient - recovery takes time';
      messageType = MessageType.warning;
      suggestions = [
        '🚨 Quick Fix',
        '🌡️ Stabilize Temp',
        '💧 Water Check',
        '🕰️ Recovery Time'
      ];
    }

    // Advanced Care Topics
    else if (_matchesAny(
        text, ['pollination', 'hand pollinate', 'no fruit setting'])) {
      response = '🐝 **POLLINATION MASTERY**\n\n'
          '**Natural Pollination:**\n'
          '• Wind and insects usually sufficient\n'
          '• Plant flowers to attract pollinators\n'
          '• Avoid pesticides during flowering\n\n'
          '**Hand Pollination (Indoor/No bees):**\n'
          '1. Use small paintbrush or cotton swab\n'
          '2. Transfer pollen from stamen to pistil\n'
          '3. Do this mid-morning\n'
          '4. Gently brush each flower\n\n'
          '**Signs of Success:**\n'
          '• Flowers stay attached\n'
          '• Small fruit begins forming\n'
          '• Fruit continues to grow\n\n'
          '**Flower Drop Causes:**\n'
          '• Temperature stress\n'
          '• Poor pollination\n'
          '• Nutrient imbalance';
      suggestions = [
        '🖌️ Hand Pollination',
        '🌺 Attract Pollinators',
        '🌡️ Temperature Tips',
        '🍯 Bee-Friendly Plants'
      ];
    } else if (_matchesAny(
        text, ['seed saving', 'collect seeds', 'save seeds'])) {
      response = '🌰 **SEED SAVING MASTERCLASS**\n\n'
          '**Selection Criteria:**\n'
          '• Choose healthiest plants\n'
          '• Best flavor/heat level\n'
          '• Disease-free specimens\n'
          '• True-to-type varieties\n\n'
          '**Harvesting Process:**\n'
          '1. Let peppers fully ripen on plant\n'
          '2. Choose overripe peppers\n'
          '3. Extract seeds carefully\n'
          '4. Remove all flesh\n\n'
          '**Drying & Storage:**\n'
          '• Air dry for 1-2 weeks\n'
          '• Store in paper envelopes\n'
          '• Label with variety and date\n'
          '• Keep cool, dry, dark\n'
          '• Viability: 2-4 years';
      messageType = MessageType.success;
      suggestions = [
        '🔄 Cross-Pollination',
        '📦 Storage Methods',
        '🏷️ Labeling Tips',
        '⏰ Viability Test'
      ];
    }

    // Seasonal Care
    else if (_matchesAny(
        text, ['winter care', 'cold season', 'overwintering'])) {
      response = '❄️ **WINTER SURVIVAL GUIDE**\n\n'
          '**Container Plants:**\n'
          '• Move indoors before frost\n'
          '• Place near bright window\n'
          '• Reduce watering frequency\n'
          '• Stop fertilizing\n\n'
          '**Ground Plants (Warm Climates):**\n'
          '• Heavy mulching\n'
          '• Protect from wind\n'
          '• Prune back 1/3\n'
          '• Reduce watering\n\n'
          '**Indoor Conditions:**\n'
          '• Temperature: 15-18°C minimum\n'
          '• Light: South-facing window or grow lights\n'
          '• Humidity: Use humidity trays\n'
          '• Watch for pests';
      suggestions = [
        '🏠 Indoor Setup',
        '🧣 Plant Protection',
        '💡 Winter Lighting',
        '🌡️ Temperature Control'
      ];
    } else if (_matchesAny(
        text, ['summer care', 'hot weather', 'heat protection'])) {
      response = '☀️ **SUMMER SUCCESS STRATEGY**\n\n'
          '**Heat Management:**\n'
          '• Afternoon shade (30-50% shade cloth)\n'
          '• Increase watering frequency\n'
          '• Deep mulching\n'
          '• Mist around plants (not leaves)\n\n'
          '**Peak Growth Period:**\n'
          '• Feed every 2 weeks\n'
          '• Harvest regularly\n'
          '• Watch for pests\n'
          '• Support heavy branches\n\n'
          '**Stress Signs:**\n'
          '• Wilting despite moist soil\n'
          '• Flower/fruit drop\n'
          '• Leaf scorch\n'
          '• Stunted growth';
      messageType = MessageType.tips;
      suggestions = [
        '🌡️ Heat Stress',
        '💧 Summer Watering',
        '🌿 Shade Solutions',
        '🍂 Mulching Guide'
      ];
    }

    // Storage & Preservation
    else if (_matchesAny(
        text, ['storage', 'preserve', 'keep fresh', 'storing peppers'])) {
      response = '📦 **PEPPER PRESERVATION GUIDE**\n\n'
          '**Fresh Storage:**\n'
          '• Refrigerator: 1-2 weeks\n'
          '• Room temperature: 2-3 days\n'
          '• Don\'t wash until ready to use\n'
          '• Store in perforated bags\n\n'
          '**Long-term Methods:**\n'
          '• **Freezing:** Whole or chopped, blanch first\n'
          '• **Drying:** Air dry or dehydrator\n'
          '• **Pickling:** In vinegar solution\n'
          '• **Fermentation:** Hot sauce base\n\n'
          '**Drying Process:**\n'
          '1. Thread through stems\n'
          '2. Hang in dry, airy place\n'
          '3. Takes 3-4 weeks\n'
          '4. Store in airtight containers';
      suggestions = [
        '🧊 Freezing Tips',
        '☀️ Drying Methods',
        '🥒 Pickling Recipe',
        '🌶️ Hot Sauce Making'
      ];
    }

    // Default responses with context
    else {
      List<String> defaultResponses = [
        '🤔 I\'d love to help you with that! Could you be more specific? I\'m expert in:\n\n• 🌱 Growing & planting advice\n• 💧 Watering & feeding guidance\n• 🐛 Pest & disease management\n• 🌶️ Harvesting & storage tips\n• 🔧 Troubleshooting plant problems',
        '🌶️ That\'s an interesting question! I\'m your chili growing specialist. Try asking about:\n\n• Specific growing problems\n• Disease identification\n• Fertilizer recommendations\n• Pest control methods\n• Variety selection\n\nOr use our AI Disease Detection feature! 📱',
        '🌿 I\'m here to help you grow amazing chilies! Could you tell me more about what you\'re looking for? I can help with:\n\n• Step-by-step growing guides\n• Problem diagnosis\n• Care schedules\n• Organic solutions\n• Indoor growing tips'
      ];

      response =
          defaultResponses[math.Random().nextInt(defaultResponses.length)];
      suggestions = [
        '🌱 Growing Help',
        '🔍 Diagnose Problem',
        '📚 Care Guide',
        '🤖 AI Detection'
      ];
    }

    setState(() {
      _isTyping = false;
      _typingController.stop();
    });

    _addBotMessage(response, type: messageType, suggestions: suggestions);
  }

  bool _matchesAny(String text, List<String> patterns) {
    return patterns.any((pattern) => text.contains(pattern));
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleQuickReply(String reply) {
    _handleSubmitted(reply);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _typingController.dispose();
    _floatingController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          if (_quickReplies.isNotEmpty) _buildQuickReplies(),
          if (_isTyping) _buildTypingIndicator(),
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatingAnimation.value),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF4CAF50).withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.smart_toy_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ChiliCare AI Assistant',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isOnline ? Colors.green : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isOnline ? 'Online • Ready to help' : 'Offline',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh_rounded, color: Color(0xFF2E7D32)),
          onPressed: () {
            setState(() {
              _messages.clear();
              _quickReplies.clear();
            });
            _initializeChat();
          },
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          return _buildMessage(message, index);
        },
      ),
    );
  }

  Widget _buildMessage(Message message, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUserMessage
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUserMessage) _buildBotAvatar(),
          if (!message.isUserMessage) const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUserMessage
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                _buildMessageBubble(message),
                if (!message.isUserMessage && message.suggestions != null)
                  _buildSuggestionChips(message.suggestions!),
              ],
            ),
          ),
          if (message.isUserMessage) const SizedBox(width: 12),
          if (message.isUserMessage) _buildUserAvatar(),
        ],
      ),
    );
  }

  Widget _buildBotAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(
        Icons.eco_rounded,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2196F3).withOpacity(0.3),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(
        Icons.person_rounded,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    Color bubbleColor;
    Color textColor;
    List<Color> gradientColors;

    if (message.isUserMessage) {
      gradientColors = [Color(0xFF2196F3), Color(0xFF1976D2)];
      textColor = Colors.white;
    } else {
      switch (message.type) {
        case MessageType.welcome:
          gradientColors = [Color(0xFF4CAF50), Color(0xFF2E7D32)];
          textColor = Colors.white;
          break;
        case MessageType.warning:
          gradientColors = [Color(0xFFFF9800), Color(0xFFF57C00)];
          textColor = Colors.white;
          break;
        case MessageType.success:
          gradientColors = [Color(0xFF4CAF50), Color(0xFF388E3C)];
          textColor = Colors.white;
          break;
        case MessageType.tips:
          gradientColors = [Color(0xFF9C27B0), Color(0xFF7B1FA2)];
          textColor = Colors.white;
          break;
        default:
          gradientColors = [Colors.white, Colors.grey[50]!];
          textColor = Color(0xFF333333);
      }
    }

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.text,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          if (!message.isUserMessage)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _formatTime(message.timestamp),
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChips(List<String> suggestions) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: suggestions.map((suggestion) {
          return GestureDetector(
            onTap: () => _handleQuickReply(suggestion),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Color(0xFF4CAF50).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                suggestion,
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickReplies() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _quickReplies.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _handleQuickReply(_quickReplies[index]),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF4CAF50).withOpacity(0.3),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _quickReplies[index],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildBotAvatar(),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
                const SizedBox(width: 8),
                Text(
                  'Assistant is thinking...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return AnimatedBuilder(
      animation: _typingController,
      builder: (context, child) {
        final animationValue = _typingController.value;
        final dotAnimation = (animationValue + (index * 0.2)) % 1.0;
        final scale = 0.5 + (math.sin(dotAnimation * math.pi * 2) * 0.5);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF4CAF50),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Ask about your chili plants...',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[400]),
                            onPressed: () {
                              _controller.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF333333),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: _handleSubmitted,
                  onChanged: (text) {
                    setState(() {});
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                if (_controller.text.trim().isNotEmpty) {
                  _handleSubmitted(_controller.text);
                  HapticFeedback.lightImpact();
                }
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: _controller.text.trim().isNotEmpty
                      ? LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                        )
                      : LinearGradient(
                          colors: [Colors.grey[300]!, Colors.grey[400]!],
                        ),
                  shape: BoxShape.circle,
                  boxShadow: _controller.text.trim().isNotEmpty
                      ? [
                          BoxShadow(
                            color: Color(0xFF4CAF50).withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}
