/**
 * Branch Core Data Types
 * Exact vocabulary mapped from conceptual-model.md, interaction-model.md, and features.md
 */

export interface User {
  id: string;
  name: string;
  handle: string;
  discipline: string;
  institution: string;
  avatar: string;
  exploring: string[];
  skills: string[];
  bio?: string;
}

export interface Credit {
  userId: string;
  name: string;
  discipline: string;
  role: string;
  timestamp: string;
}

export interface Artifact {
  id: string;
  type: 'image' | 'audio' | 'sketch' | 'code' | '3d';
  title: string;
  url: string;
  caption: string;
  metadata?: string;
}

export interface Source {
  id: string;
  title: string;
  author: string;
  url?: string;
  note: string;
}

export type StoryNodeType = 
  | 'starting_question'
  | 'source'
  | 'experiment'
  | 'decision'
  | 'gap'
  | 'chapter';

export interface StoryNode {
  id: string;
  projectId: string;
  type: StoryNodeType;
  title: string;
  authorId: string;
  authorName: string;
  authorDiscipline: string;
  timestamp: string;
  stepNumber: number; // For Follow Its Story sequence (1 of 7, etc.)
  
  // Specific node contents
  question?: string;
  sources?: Source[];
  hypothesis?: string;
  outcome?: string;
  decisionRationale?: string;
  chosenOver?: string[];
  experimentStatus?: 'active' | 'abandoned' | 'revived';
  gapNeed?: string;
  gapStatus?: 'open' | 'claimed' | 'filled';
  artifacts?: Artifact[];
  
  // Turning point indicator for storytelling
  isTurningPoint?: boolean;
  turningPointNote?: string;
  
  // Canvas placement hints
  position?: { x: number; y: number };
}

export interface NodeConnection {
  id: string;
  fromId: string;
  toId: string;
  type: 'led_to' | 'informed' | 'branched_from' | 'revived_from';
  label?: string;
  dialogueSnippet?: string; // Live dialogue snippet on hover/motion
  aiRelevance?: string;     // AI layer explaining connection relevance between A and B
}

export interface Gap {
  id: string;
  projectId: string;
  title: string;
  need: string;
  disciplineTarget: string;
  status: 'open' | 'claimed' | 'filled';
  inviteId?: string;
  sourceNodeId: string;
}

export interface Invite {
  id: string;
  projectId: string;
  gapId: string;
  creatorId: string;
  creatorName: string;
  projectTitle: string;
  prompt: string;
  targetDiscipline: string;
  createdAt: string;
  status: 'open' | 'responded';
}

export interface Chapter {
  id: string;
  branchId: string;
  chapterNumber: number;
  title: string;
  authorId: string;
  authorName: string;
  authorDiscipline: string;
  date: string;
  turningPoint: string;
  sourceNodeId: string;
  artifacts: Artifact[];
}

export interface Contribution {
  id: string;
  branchId: string;
  contributorId: string;
  status: 'private' | 'kept' | 'discarded';
  intent: string;
  skillOffered: string;
}

export interface Branch {
  id: string;
  originProjectId: string;
  originNodeId: string;
  title: string;
  contributorId: string;
  contributorName: string;
  contributorDiscipline: string;
  credits: Credit[];
  isPrivate: boolean;
  chapters: Chapter[];
  createdAt: string;
}

export interface NotificationItem {
  id: string;
  actorId: string;
  actorName: string;
  actorAvatar: string;
  actorDiscipline: string;
  action: 'branched' | 'added_chapter' | 'posted_invite' | 'responded_invite';
  projectId: string;
  projectTitle: string;
  branchId?: string;
  message: string;
  timestamp: string;
  read: boolean;
}

export interface Project {
  id: string;
  creatorId: string;
  creatorName: string;
  creatorAvatar: string;
  creatorDiscipline: string;
  title: string;
  startingQuestion: string;
  status: 'draft' | 'shared' | 'stuck' | 'revived';
  heroMedia: string;
  nodes: StoryNode[];
  connections: NodeConnection[];
  branches: Branch[];
  gaps: Gap[];
  credits: Credit[];
  lastActive: string;
  isFavorite?: boolean;
}

// Canvas & Interaction state
export type CanvasViewMode = 'hub' | 'story' | 'explore' | 'wander';

export interface TransientNodeState {
  nodeId: string;
  isPinned: boolean;
  bloomedFromId?: string;
  direction: 'left' | 'right';
}
