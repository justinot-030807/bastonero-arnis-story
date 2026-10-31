class StoryEvent {
  final String id;
  final String title;
  final String speaker;
  final String speakerRole;
  final List<String> dialogues;
  final int triggerMonth; // 0 if milestone-based
  final int triggerYear; // 0 if any year
  final String triggerCondition; // 'start', 'division_warning', 'lorenzo_rival', 'low_grades', etc.
  final int rewardPesos;
  final double rewardAcademics;
  final double rewardPower;
  final double rewardTechnique;
  bool isTriggered;

  StoryEvent({
    required this.id,
    required this.title,
    required this.speaker,
    required this.speakerRole,
    required this.dialogues,
    this.triggerMonth = 0,
    this.triggerYear = 0,
    required this.triggerCondition,
    this.rewardPesos = 0,
    this.rewardAcademics = 0.0,
    this.rewardPower = 0.0,
    this.rewardTechnique = 0.0,
    this.isTriggered = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'speaker': speaker,
        'speakerRole': speakerRole,
        'dialogues': dialogues,
        'triggerMonth': triggerMonth,
        'triggerYear': triggerYear,
        'triggerCondition': triggerCondition,
        'rewardPesos': rewardPesos,
        'rewardAcademics': rewardAcademics,
        'rewardPower': rewardPower,
        'rewardTechnique': rewardTechnique,
        'isTriggered': isTriggered,
      };

  factory StoryEvent.fromJson(Map<String, dynamic> json) => StoryEvent(
        id: json['id'] as String,
        title: json['title'] as String,
        speaker: json['speaker'] as String,
        speakerRole: json['speakerRole'] as String,
        dialogues: (json['dialogues'] as List<dynamic>).map((e) => e.toString()).toList(),
        triggerMonth: json['triggerMonth'] as int? ?? 0,
        triggerYear: json['triggerYear'] as int? ?? 0,
        triggerCondition: json['triggerCondition'] as String,
        rewardPesos: json['rewardPesos'] as int? ?? 0,
        rewardAcademics: (json['rewardAcademics'] as num?)?.toDouble() ?? 0.0,
        rewardPower: (json['rewardPower'] as num?)?.toDouble() ?? 0.0,
        rewardTechnique: (json['rewardTechnique'] as num?)?.toDouble() ?? 0.0,
        isTriggered: json['isTriggered'] as bool? ?? false,
      );

  static List<StoryEvent> generateDefaultStoryEvents() {
    return [
      StoryEvent(
        id: 'intro_coach',
        title: 'Ang Simula ng Bastonero',
        speaker: 'Coach Mang Kanor',
        speakerRole: 'Veteran Barangay Arnisador & Coach',
        triggerCondition: 'start',
        dialogues: [
          'Kamusta, bata! Hawakan mo ang rattan baston na ito nang maayos.',
          'Hindi basta palo ang Arnis. May ritmo, may respeto, at higit sa lahat — diskarte!',
          'Ngayong Grade 5 ka na, tuturuan kita rito sa ating backyard gym.',
          'Bantayan mo ang iyong grado sa eskwela! Kapag bumagsak ka sa 80, bawal ka sa Palaro.',
          'Magsimula tayo sa Gulong Dummy. Sanayin mo ang iyong pulso at salag!',
        ],
        rewardPesos: 200,
        rewardPower: 2.0,
        rewardTechnique: 2.0,
      ),
      StoryEvent(
        id: 'bully_challenge',
        title: 'Hamon ni Berto Batuta',
        speaker: 'Berto Batuta',
        speakerRole: 'Purok Bully & Street Fighter',
        triggerCondition: 'month_2',
        triggerMonth: 2,
        dialogues: [
          'Hahaha! Akala mo ba arnisador ka na dahil may baston ka?',
          'Pang-sayaw lang yang tinuturo sa iyo ni Mang Kanor! Sa kanto, bahi at bakal ang usapan.',
          'Kung matapang ka, pumunta ka sa Inter-Purok Bakbakan. Tignan natin kung hindi ka umiyak!',
        ],
        rewardPesos: 100,
      ),
      StoryEvent(
        id: 'principal_warning',
        title: 'Banta ni Principal Santos',
        speaker: 'Principal Santos',
        speakerRole: 'School Principal',
        triggerCondition: 'month_8',
        triggerMonth: 8,
        dialogues: [
          'Makinig kayo, Coach Kanor at Arnis Varsity!',
          'Maliit lang ang budget ng eskwelahan. Kung hindi kayo mag-uuwi ng medalya sa darating na Division Meet sa Nobyembre...',
          'Ibubuwag ko ang Arnis Club at ililipat ang pondo sa Drum and Lyre Corps!',
          'Siguraduhin ninyong pumapasa ang bata sa mga pagsusulit. Walang drop-out na atleta dito!',
        ],
        rewardAcademics: 2.0,
      ),
      StoryEvent(
        id: 'lorenzo_encounter',
        title: 'Ang Hambog na si Lorenzo Dela Cruz',
        speaker: 'Lorenzo Dela Cruz',
        speakerRole: 'Private Academy Ace',
        triggerCondition: 'division_won',
        dialogues: [
          'So you are the public school champion everyone is talking about?',
          'How quaint. You train with discarded jeepney tires while my family imports custom Kamagong sticks.',
          'See you at Regionals. Make sure your battered rattan stick doesn\'t splinter on my first swing.',
        ],
        rewardPesos: 500,
        rewardTechnique: 3.0,
      ),
      StoryEvent(
        id: 'academic_probation',
        title: 'Babala sa Grado!',
        speaker: 'Guro Maria',
        speakerRole: 'Class Adviser',
        triggerCondition: 'grade_warning',
        dialogues: [
          'Bastos ang baston kapag walang laman ang ulo!',
          'Bumaba ang iyong marka sa ilalim ng 80! Suspindido ka muna sa school varsity tournaments.',
          'Pumunta ka sa Study Desk sa ilalim ng Mangga at magbasa ng libro bago ka magsanay muli!',
        ],
      ),
    ];
  }
}
