import { User, Project, NotificationItem } from '../types';

/**
 * SEED DATA [PLACEHOLDER]
 * Minimal, realistic maker data for UC Berkeley MDes, EECS, and Stanford CCRMA.
 * Strictly no lorem ipsum. All items tagged [PLACEHOLDER].
 */
export const SEED_USERS: Record<string, User> = {
  elena: {
    id: 'elena',
    name: 'Elena Rostova',
    handle: '@elena_craft',
    discipline: 'Physical & Industrial Design',
    institution: 'UC Berkeley MDes [PLACEHOLDER]',
    avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=256&q=80',
    exploring: ['Smart textiles', 'Haptic feedback', 'Non-visual interfaces'],
    skills: ['Weaving', 'SolidWorks', 'Soft Prototyping', 'User Research'],
    bio: '[PLACEHOLDER] Exploring how tactile surfaces can replace glass screens for storytelling and ambient communication.'
  },
  marcus: {
    id: 'marcus',
    name: 'Marcus Chen',
    handle: '@marcus_makes',
    discipline: 'Creative Technologist / EECS',
    institution: 'UC Berkeley EECS [PLACEHOLDER]',
    avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=256&q=80',
    exploring: ['WebAudio synthesis', 'Micro-actuators', 'ESP32 firmware'],
    skills: ['DSP', 'Embedded C++', 'Web Audio API', 'Circuit Design'],
    bio: '[PLACEHOLDER] Coding between physical sensors and generative sound synthesis.'
  },
  amina: {
    id: 'amina',
    name: 'Amina Diallo',
    handle: '@amina_sound',
    discipline: 'Acoustic & Sound Design',
    institution: 'Stanford CCRMA [PLACEHOLDER]',
    avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=256&q=80',
    exploring: ['Spatial audio', 'Binaural storytelling', 'Psychoacoustics'],
    skills: ['Max/MSP', 'Ableton', 'Field Recording', 'Acoustic Ecology'],
    bio: '[PLACEHOLDER] Designing intimate audio environments that ground narrative memory in space.'
  },
  lucas: {
    id: 'lucas',
    name: 'Lucas Zhao',
    handle: '@lucas_arch',
    discipline: 'Computational Architecture',
    institution: 'UC Berkeley CED [PLACEHOLDER]',
    avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=256&q=80',
    exploring: ['Kinetic origami', 'Acoustic origami', 'Parametric folding'],
    skills: ['Rhino/Grasshopper', 'CNC Milling', 'Laser Cutting'],
    bio: '[PLACEHOLDER] Creating responsive acoustic surfaces from folding paper and composite fabrics.'
  }
};

export const SEED_PROJECTS: Project[] = [
  {
    id: 'haptic-weave',
    creatorId: 'elena',
    creatorName: 'Elena Rostova',
    creatorAvatar: SEED_USERS.elena.avatar,
    creatorDiscipline: 'Physical & Industrial Design',
    title: 'Haptic Weave: Tactile Storytelling [PLACEHOLDER]',
    startingQuestion: '[PLACEHOLDER] Can woven electronic textiles convey emotional narrative beats through micro-actuators without a visual screen?',
    status: 'stuck',
    heroMedia: 'https://images.unsplash.com/photo-1584992236310-6edddc08acff?auto=format&fit=crop&w=1200&q=80',
    lastActive: '2 hours ago',
    isFavorite: true,
    credits: [
      { userId: 'elena', name: 'Elena Rostova', discipline: 'Industrial Design', role: 'Original Creator', timestamp: 'Oct 14, 2026' },
      { userId: 'marcus', name: 'Marcus Chen', discipline: 'Creative Tech', role: 'Frequency Synthesis Contributor', timestamp: 'Oct 16, 2026' }
    ],
    nodes: [
      {
        id: 'hw-q1',
        projectId: 'haptic-weave',
        type: 'starting_question',
        title: 'Starting Question',
        authorId: 'elena',
        authorName: 'Elena Rostova',
        authorDiscipline: 'Industrial Design',
        timestamp: 'Oct 14, 2026',
        stepNumber: 1,
        question: 'Can woven electronic textiles convey emotional narrative beats through micro-actuators without a visual screen?',
        position: { x: 50, y: 180 },
        artifacts: [
          {
            id: 'art-q1',
            type: 'sketch',
            title: 'Initial Loom Pattern Concept',
            url: 'https://images.unsplash.com/photo-1544816155-12df9643f363?auto=format&fit=crop&w=800&q=80',
            caption: 'Pencil on gridded paper: mapping tactile intensity zones to fingers 1 through 4.'
          }
        ]
      },
      {
        id: 'hw-s1',
        projectId: 'haptic-weave',
        type: 'source',
        title: 'Tactile Aesthetics Benchmarks',
        authorId: 'elena',
        authorName: 'Elena Rostova',
        authorDiscipline: 'Industrial Design',
        timestamp: 'Oct 14, 2026',
        stepNumber: 2,
        sources: [
          {
            id: 'src-1',
            title: 'Tactile Graphics & Narrative Spatialization',
            author: 'Challis & Edwards, 2021',
            note: 'Shows that fingertip tactile resolution requires at least 4mm spacing between vibrational nodes to prevent sensation masking.'
          },
          {
            id: 'src-2',
            title: 'Conductive Yarn Tensile Resistance Under Tension',
            author: 'MIT Media Lab Tangible Media Group',
            note: 'Silver-coated nylon maintains 1.2 ohms/cm up to 15% elongation before signal degradation.'
          }
        ],
        position: { x: 340, y: 100 },
        artifacts: [
          {
            id: 'art-s1',
            type: 'image',
            title: 'Loom Wire Spacing Diagram',
            url: 'https://images.unsplash.com/photo-1607344645866-009c320c5ab8?auto=format&fit=crop&w=800&q=80',
            caption: 'Measuring conductor pitch: 4.8mm separation meets Challis perceptual threshold.'
          }
        ]
      },
      {
        id: 'hw-e1',
        projectId: 'haptic-weave',
        type: 'experiment',
        title: 'Piezoelectric Ceramic Discs',
        authorId: 'elena',
        authorName: 'Elena Rostova',
        authorDiscipline: 'Industrial Design',
        timestamp: 'Oct 15, 2026',
        stepNumber: 3,
        experimentStatus: 'active',
        hypothesis: 'Ultra-thin piezo discs (0.2mm) woven between jacquard layers will give sharp transient clicks for punctuation.',
        outcome: 'Clicks are distinct (18ms rise time), but lack variable low-frequency resonance needed for sustained mood.',
        position: { x: 640, y: 100 },
        artifacts: [
          {
            id: 'art-e1',
            type: 'image',
            title: 'Woven Piezo Array Test Bed',
            url: 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?auto=format&fit=crop&w=800&q=80',
            caption: 'Oscilloscope trace confirms sharp 18ms impulse, but low frequencies fall off below 120Hz.'
          }
        ]
      },
      {
        id: 'hw-e2',
        projectId: 'haptic-weave',
        type: 'experiment',
        title: 'Nichrome Thermal Pulse Grid',
        authorId: 'elena',
        authorName: 'Elena Rostova',
        authorDiscipline: 'Industrial Design',
        timestamp: 'Oct 15, 2026',
        stepNumber: 4,
        experimentStatus: 'abandoned',
        isTurningPoint: true,
        turningPointNote: 'Abandoned dead end: 3.2s thermal lag made synchronizing with speech impossible.',
        hypothesis: 'Subtle warmth pulses could represent emotional intimacy or tension in the story.',
        outcome: 'Thermal inertia created 3.2-second rise/fall latency. Felt sluggish, and power draw drained battery in 14 minutes.',
        position: { x: 640, y: 340 },
        artifacts: [
          {
            id: 'art-e2',
            type: 'image',
            title: 'Thermal Camera Heat Retention',
            url: 'https://images.unsplash.com/photo-1509228468518-180dd4864904?auto=format&fit=crop&w=800&q=80',
            caption: 'FLIR capture: residual heat bled into neighboring threads for over 8 seconds. Dead end.'
          }
        ]
      },
      {
        id: 'hw-d1',
        projectId: 'haptic-weave',
        type: 'decision',
        title: 'Decision: Pivot to Tuned LRAs',
        authorId: 'elena',
        authorName: 'Elena Rostova',
        authorDiscipline: 'Industrial Design',
        timestamp: 'Oct 16, 2026',
        stepNumber: 5,
        decisionRationale: 'Eliminate all thermal actuators. Use Linear Resonant Actuators (LRAs) tuned to 175Hz and 235Hz to deliver immediate, tactile texture while keeping battery life above 6 hours.',
        chosenOver: ['Peltier thermal junctions (too bulky)', 'Rotary eccentric motors (slow spin-up lag)'],
        isTurningPoint: true,
        turningPointNote: 'Decided on dual-frequency LRAs to balance instant responsiveness with battery feasibility.',
        position: { x: 940, y: 180 },
        artifacts: [
          {
            id: 'art-d1',
            type: 'image',
            title: 'LRA Micro-Enclosure Housing',
            url: 'https://images.unsplash.com/photo-1581092335397-9583fe92d232?auto=format&fit=crop&w=800&q=80',
            caption: '3D printed silicone damping boots for 8mm LRA motors; 12ms response time verified.'
          }
        ]
      },
      {
        id: 'hw-gap1',
        projectId: 'haptic-weave',
        type: 'gap',
        title: 'Open Gap: Audio-to-Haptic DSP',
        authorId: 'elena',
        authorName: 'Elena Rostova',
        authorDiscipline: 'Industrial Design',
        timestamp: 'Oct 16, 2026',
        stepNumber: 6,
        gapNeed: 'Need someone in Mechatronics or Audio DSP to map voice pitch/cadence into dual-frequency LRA drive curves so audio stories vibrate dynamically.',
        gapStatus: 'open',
        position: { x: 1240, y: 180 },
        artifacts: [
          {
            id: 'art-gap1',
            type: 'sketch',
            title: 'Desired Frequency Split Diagram',
            url: 'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=800&q=80',
            caption: 'Hand-drawn flow: Voice audio stream -> FFT filter -> 175Hz LRA (vowels) & 235Hz LRA (consonants).'
          }
        ]
      },
      {
        id: 'hw-ch1',
        projectId: 'haptic-weave',
        type: 'chapter',
        title: 'Chapter 2: WebAudio Frequency Bridge',
        authorId: 'marcus',
        authorName: 'Marcus Chen',
        authorDiscipline: 'Creative Technologist',
        timestamp: 'Oct 16, 2026',
        stepNumber: 7,
        decisionRationale: 'Marcus branched from Elena’s gap and built a WebAudio browser synthesizer that translates speech syllables into PWM actuator signals in real time.',
        position: { x: 1240, y: 380 },
        artifacts: [
          {
            id: 'art-ch1',
            type: 'code',
            title: 'WebAudio FFT Actuator Node',
            url: 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&w=800&q=80',
            caption: 'JavaScript AudioWorklet node extracting phoneme envelopes with under 8ms latency.'
          }
        ]
      }
    ],
    connections: [
      {
        id: 'conn-1-2',
        fromId: 'hw-q1',
        toId: 'hw-s1',
        type: 'informed',
        label: 'informed by',
        dialogueSnippet: 'Elena: "Looking into tactile perceptual limits before winding the first spool."',
        aiRelevance: 'Perceptual papers by Challis established the minimum 4mm resolution needed to answer the starting question.'
      },
      {
        id: 'conn-2-3',
        fromId: 'hw-s1',
        toId: 'hw-e1',
        type: 'led_to',
        label: 'led to test',
        dialogueSnippet: 'Elena: "Piezo discs were the first physical test to see if 4.8mm pitch was achievable on a loom."',
        aiRelevance: 'Challis recommendations directly shaped the physical geometry of this ceramic piezo experiment.'
      },
      {
        id: 'conn-1-4',
        fromId: 'hw-q1',
        toId: 'hw-e2',
        type: 'led_to',
        label: 'tested thermal path',
        dialogueSnippet: 'Elena: "I wondered if warmth felt more human than vibrations."',
        aiRelevance: 'Explored an alternative sensory modality (thermoception) to convey emotion without mechanical buzz.'
      },
      {
        id: 'conn-4-5',
        fromId: 'hw-e2',
        toId: 'hw-d1',
        type: 'led_to',
        label: 'forced pivot',
        dialogueSnippet: 'Elena: "The 3.2-second thermal lag was a dealbreaker; speech moves at 150ms per syllable."',
        aiRelevance: 'Thermal failure forced an explicit design pivot away from heat to frequency-tuned mechanical actuators.'
      },
      {
        id: 'conn-3-5',
        fromId: 'hw-e1',
        toId: 'hw-d1',
        type: 'informed',
        label: 'combined with',
        dialogueSnippet: 'Elena: "Piezo clicks worked, but adding resonant LRAs provides both click and texture."',
        aiRelevance: 'Piezo transient response proved that tactile clicks need an accompanying resonant body to feel organic.'
      },
      {
        id: 'conn-5-6',
        fromId: 'hw-d1',
        toId: 'hw-gap1',
        type: 'led_to',
        label: 'revealed gap',
        dialogueSnippet: 'Elena: "Hardware is ready, but I need an audio/DSP collaborator to write the frequency mapping."',
        aiRelevance: 'Selecting dual-frequency LRAs opened a technical gap requiring software frequency synthesis.'
      },
      {
        id: 'conn-6-7',
        fromId: 'hw-gap1',
        toId: 'hw-ch1',
        type: 'branched_from',
        label: 'branched & filled by Marcus',
        dialogueSnippet: 'Marcus: "Saw Elena\'s open gap in the feed and prototyped a browser-based AudioWorklet mapper."',
        aiRelevance: 'Marcus branched Elena\'s open gap, writing the missing DSP translation layer to complete the storytelling arc.'
      }
    ],
    branches: [
      {
        id: 'branch-marcus-dsp',
        originProjectId: 'haptic-weave',
        originNodeId: 'hw-gap1',
        title: 'WebAudio Realtime Actuator Modulator',
        contributorId: 'marcus',
        contributorName: 'Marcus Chen',
        contributorDiscipline: 'Creative Technologist',
        createdAt: 'Oct 16, 2026',
        isPrivate: false,
        credits: [
          { userId: 'elena', name: 'Elena Rostova', discipline: 'Industrial Design', role: 'Original Loom & Actuator Hardware', timestamp: 'Oct 14, 2026' },
          { userId: 'marcus', name: 'Marcus Chen', discipline: 'Creative Tech', role: 'Realtime AudioWorklet DSP', timestamp: 'Oct 16, 2026' }
        ],
        chapters: [
          {
            id: 'ch-marcus-1',
            branchId: 'branch-marcus-dsp',
            chapterNumber: 2,
            title: 'AudioWorklet Realtime DSP',
            authorId: 'marcus',
            authorName: 'Marcus Chen',
            authorDiscipline: 'Creative Technologist',
            date: 'Oct 16, 2026',
            turningPoint: 'Mapped 175Hz to vowel formants and 235Hz to fricative consonants, achieving 8ms tactile sync.',
            sourceNodeId: 'hw-gap1',
            artifacts: [
              {
                id: 'art-m-code',
                type: 'code',
                title: 'DSP Worklet Audio Pipeline',
                url: 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&w=800&q=80',
                caption: 'WebAudio Worklet splitting incoming speech into LRA control streams.'
              }
            ]
          }
        ]
      }
    ],
    gaps: [
      {
        id: 'gap-dsp',
        projectId: 'haptic-weave',
        title: 'Audio-to-Haptic DSP Synthesis',
        need: 'Need an audio programmer to translate spoken narrative streams into dual-frequency actuator PWM signals.',
        disciplineTarget: 'Creative Tech / Audio DSP',
        status: 'open',
        sourceNodeId: 'hw-gap1'
      }
    ]
  },
  {
    id: 'bioluminescent-algae',
    creatorId: 'amina',
    creatorName: 'Amina Diallo',
    creatorAvatar: SEED_USERS.amina.avatar,
    creatorDiscipline: 'Acoustic & Sound Design',
    title: 'Bioluminescent Algae Companion [PLACEHOLDER]',
    startingQuestion: '[PLACEHOLDER] How can living dinoflagellates translate ambient room acoustics into rhythmic glowing bioluminescence?',
    status: 'shared',
    heroMedia: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=1200&q=80',
    lastActive: '5 hours ago',
    credits: [
      { userId: 'amina', name: 'Amina Diallo', discipline: 'Sound Design', role: 'Original Acoustic Rig', timestamp: 'Oct 12, 2026' }
    ],
    nodes: [],
    connections: [],
    branches: [],
    gaps: [
      {
        id: 'gap-algae-pump',
        projectId: 'bioluminescent-algae',
        title: 'Peristaltic Micro-Fluidic Shear Valve [PLACEHOLDER]',
        need: '[PLACEHOLDER] Need mechanical engineer to design silent shear flow chamber so sound pulses agitate dinoflagellates gently.',
        disciplineTarget: 'Mechatronics / Bio-Engineering',
        status: 'open',
        sourceNodeId: 'bio-q1'
      }
    ]
  },
  {
    id: 'kinetic-origami',
    creatorId: 'lucas',
    creatorName: 'Lucas Zhao',
    creatorAvatar: SEED_USERS.lucas.avatar,
    creatorDiscipline: 'Computational Architecture',
    title: 'Kinetic Origami Acoustic Baffles [PLACEHOLDER]',
    startingQuestion: '[PLACEHOLDER] Can origami tessellations dynamically fold to reshape room reverberation time based on occupancy?',
    status: 'shared',
    heroMedia: 'https://images.unsplash.com/photo-1513694203232-719a280e022f?auto=format&fit=crop&w=1200&q=80',
    lastActive: '1 day ago',
    credits: [
      { userId: 'lucas', name: 'Lucas Zhao', discipline: 'Architecture', role: 'Parametric Geometry', timestamp: 'Oct 11, 2026' }
    ],
    nodes: [],
    connections: [],
    branches: [],
    gaps: []
  }
];

export const SEED_NOTIFICATIONS: NotificationItem[] = [
  {
    id: 'notif-1',
    actorId: 'marcus',
    actorName: 'Marcus Chen',
    actorAvatar: SEED_USERS.marcus.avatar,
    actorDiscipline: 'Creative Technologist',
    action: 'added_chapter',
    projectId: 'haptic-weave',
    projectTitle: 'Haptic Weave: Tactile Storytelling',
    branchId: 'branch-marcus-dsp',
    message: 'Marcus Chen added Chapter 2: WebAudio Realtime DSP beside your project.',
    timestamp: '2 hours ago',
    read: false
  },
  {
    id: 'notif-2',
    actorId: 'amina',
    actorName: 'Amina Diallo',
    actorAvatar: SEED_USERS.amina.avatar,
    actorDiscipline: 'Acoustic Design',
    action: 'branched',
    projectId: 'haptic-weave',
    projectTitle: 'Haptic Weave: Tactile Storytelling',
    message: 'Amina started a private branch exploring binaural acoustic companion tracks.',
    timestamp: 'Yesterday',
    read: true
  }
];
