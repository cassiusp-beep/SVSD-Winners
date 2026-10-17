import { useState, useEffect } from 'react';
import { User, Project, NotificationItem, Branch, Chapter, StoryNode, Gap, Credit } from '../types';
import { SEED_USERS, SEED_PROJECTS, SEED_NOTIFICATIONS } from '../data/seedData';

const STORAGE_KEY = 'svsd_branch_state_v2';

export interface BranchState {
  currentUserId: string;
  activeProjectId: string | null;
  activeStepIndex: number;
  isPlayingStory: boolean;
  aiEnabled: boolean;
  viewMode: 'hub' | 'story';
  isProfileDocked: boolean;
  helpDrawerOpen: boolean;
  storyTimelineOpen: boolean;
  lastSavedAt: string;
  openNodes: Record<string, { isPinned: boolean; direction: 'left' | 'right' }>;
  savedProjectIds: string[];
  selectedNodeId: string | null;
  hoveredDropTargetId: string | null;
  activeRadialMenu: boolean;
  // Legacy compatibility for any lingering modal components
  activeModal: string | null;
  radialMenu: { isOpen: boolean; x: number; y: number } | null;
  mobileSheetOpen: boolean;
  projects: Project[];
  notifications: NotificationItem[];
}

const defaultState: BranchState = {
  currentUserId: 'elena',
  activeProjectId: 'haptic-weave',
  activeStepIndex: 1,
  isPlayingStory: false,
  aiEnabled: false,
  viewMode: 'hub',
  isProfileDocked: false,
  helpDrawerOpen: false,
  storyTimelineOpen: false,
  lastSavedAt: 'Saved just now',
  openNodes: {
    'hw-q1': { isPinned: true, direction: 'right' }
  },
  savedProjectIds: ['haptic-weave'],
  selectedNodeId: 'hw-q1',
  hoveredDropTargetId: null,
  activeRadialMenu: true,
  activeModal: null,
  radialMenu: null,
  mobileSheetOpen: false,
  projects: SEED_PROJECTS,
  notifications: SEED_NOTIFICATIONS
};

type Listener = () => void;
let state: BranchState = loadState();
const listeners = new Set<Listener>();

function loadState(): BranchState {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (raw) {
      const parsed = JSON.parse(raw);
      return { ...defaultState, ...parsed };
    }
  } catch (e) {
    console.warn('Failed to load local state, using seed defaults:', e);
  }
  return defaultState;
}

function persistState() {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify({
      currentUserId: state.currentUserId,
      activeProjectId: state.activeProjectId,
      activeStepIndex: state.activeStepIndex,
      aiEnabled: state.aiEnabled,
      viewMode: state.viewMode,
      isProfileDocked: state.isProfileDocked,
      savedProjectIds: state.savedProjectIds,
      projects: state.projects,
      notifications: state.notifications
    }));
  } catch (e) {
    console.warn('Failed to save to localStorage:', e);
  }
}

function notify() {
  persistState();
  listeners.forEach(fn => fn());
}

export const branchStore = {
  getState: () => state,
  
  subscribe: (listener: Listener) => {
    listeners.add(listener);
    return () => {
      listeners.delete(listener);
    };
  },

  setCurrentUser: (userId: string) => {
    state = { ...state, currentUserId: userId };
    notify();
  },

  setViewMode: (viewMode: 'hub' | 'story') => {
    state = {
      ...state,
      viewMode,
      isProfileDocked: viewMode === 'story'
    };
    notify();
  },

  dockProfile: (docked: boolean) => {
    state = { ...state, isProfileDocked: docked };
    notify();
  },

  setActiveProject: (projectId: string | null) => {
    state = { 
      ...state, 
      activeProjectId: projectId, 
      activeStepIndex: 1, 
      isPlayingStory: false,
      selectedNodeId: projectId ? `${projectId}-q1` : null
    };
    notify();
  },

  setActiveStepIndex: (stepIndex: number) => {
    const project = state.projects.find(p => p.id === state.activeProjectId);
    const targetNode = project?.nodes.find(n => n.stepNumber === stepIndex);
    state = { 
      ...state, 
      activeStepIndex: stepIndex,
      selectedNodeId: targetNode ? targetNode.id : state.selectedNodeId
    };
    notify();
  },

  setSelectedNodeId: (nodeId: string | null) => {
    const project = state.projects.find(p => p.id === state.activeProjectId);
    const targetNode = project?.nodes.find(n => n.id === nodeId);
    state = { 
      ...state, 
      selectedNodeId: nodeId,
      activeStepIndex: targetNode?.stepNumber ?? state.activeStepIndex
    };
    notify();
  },

  toggleStoryPlay: () => {
    state = { ...state, isPlayingStory: !state.isPlayingStory };
    notify();
  },

  toggleAi: () => {
    state = { ...state, aiEnabled: !state.aiEnabled };
    notify();
  },

  toggleHelpDrawer: () => {
    state = { ...state, helpDrawerOpen: !state.helpDrawerOpen };
    notify();
  },

  toggleStoryTimeline: () => {
    state = { ...state, storyTimelineOpen: !state.storyTimelineOpen };
    notify();
  },

  toggleRadialMenu: (open?: boolean) => {
    state = { ...state, activeRadialMenu: open !== undefined ? open : !state.activeRadialMenu };
    notify();
  },

  setHoveredDropTarget: (id: string | null) => {
    if (state.hoveredDropTargetId !== id) {
      state = { ...state, hoveredDropTargetId: id };
      notify();
    }
  },

  nextStoryStep: () => {
    const project = state.projects.find(p => p.id === state.activeProjectId);
    if (!project) return;
    const maxSteps = project.nodes.length;
    const next = state.activeStepIndex >= maxSteps ? 1 : state.activeStepIndex + 1;
    branchStore.setActiveStepIndex(next);
  },

  prevStoryStep: () => {
    const project = state.projects.find(p => p.id === state.activeProjectId);
    if (!project) return;
    const maxSteps = project.nodes.length;
    const prev = state.activeStepIndex <= 1 ? maxSteps : state.activeStepIndex - 1;
    branchStore.setActiveStepIndex(prev);
  },

  openNode: (nodeId: string, direction: 'left' | 'right') => {
    state = {
      ...state,
      openNodes: {
        ...state.openNodes,
        [nodeId]: { isPinned: false, direction }
      }
    };
    notify();
  },

  closeNode: (nodeId: string) => {
    const updated = { ...state.openNodes };
    delete updated[nodeId];
    state = { ...state, openNodes: updated };
    notify();
  },

  togglePinNode: (nodeId: string) => {
    const current = state.openNodes[nodeId];
    if (current) {
      state = {
        ...state,
        openNodes: {
          ...state.openNodes,
          [nodeId]: { ...current, isPinned: !current.isPinned }
        }
      };
      notify();
    }
  },

  toggleSaveProject: (projectId: string) => {
    const isSaved = state.savedProjectIds.includes(projectId);
    state = {
      ...state,
      savedProjectIds: isSaved
        ? state.savedProjectIds.filter(id => id !== projectId)
        : [...state.savedProjectIds, projectId],
      lastSavedAt: 'Saved just now'
    };
    notify();
  },

  postOpenInvite: (projectId: string, gapTitle: string, need: string, discipline: string) => {
    const targetProject = state.projects.find(p => p.id === projectId);
    if (!targetProject) return;

    const newGapId = `gap-${Date.now()}`;
    const newGapNode: StoryNode = {
      id: `node-${newGapId}`,
      projectId,
      type: 'gap',
      title: gapTitle,
      authorId: state.currentUserId,
      authorName: SEED_USERS[state.currentUserId]?.name || 'You',
      authorDiscipline: SEED_USERS[state.currentUserId]?.discipline || 'Designer',
      timestamp: 'Just now',
      stepNumber: targetProject.nodes.length + 1,
      gapNeed: need,
      gapStatus: 'open',
      position: { x: 1200 + targetProject.nodes.length * 60, y: 180 }
    };

    const newGapItem: Gap = {
      id: newGapId,
      projectId,
      title: gapTitle,
      need,
      disciplineTarget: discipline,
      status: 'open',
      sourceNodeId: newGapNode.id
    };

    const newNotification: NotificationItem = {
      id: `notif-${Date.now()}`,
      actorId: state.currentUserId,
      actorName: SEED_USERS[state.currentUserId]?.name || 'You',
      actorAvatar: SEED_USERS[state.currentUserId]?.avatar || '',
      actorDiscipline: SEED_USERS[state.currentUserId]?.discipline || '',
      action: 'posted_invite',
      projectId,
      projectTitle: targetProject.title,
      message: `Open invite posted: "${gapTitle}" for ${discipline}`,
      timestamp: 'Just now',
      read: false
    };

    const updatedProjects = state.projects.map(p => {
      if (p.id === projectId) {
        return {
          ...p,
          gaps: [...p.gaps, newGapItem],
          nodes: [...p.nodes, newGapNode]
        };
      }
      return p;
    });

    state = {
      ...state,
      projects: updatedProjects,
      notifications: [newNotification, ...state.notifications],
      selectedNodeId: newGapNode.id,
      lastSavedAt: 'Saved just now'
    };
    notify();
  },

  genesisProjectFromDrop: (title: string, droppedType: string) => {
    const newProjectId = `project-${Date.now()}`;
    const newProject: Project = {
      id: newProjectId,
      creatorId: state.currentUserId,
      creatorName: SEED_USERS[state.currentUserId]?.name || 'Elena Rostova',
      creatorAvatar: SEED_USERS[state.currentUserId]?.avatar || '',
      creatorDiscipline: SEED_USERS[state.currentUserId]?.discipline || 'MDes Student',
      title: title || 'New Exploratory Branch',
      startingQuestion: `Started by dragging in ${droppedType}. Exploring through living nodes.`,
      status: 'shared',
      heroMedia: 'https://images.unsplash.com/photo-1558655146-d09347e92766?auto=format&fit=crop&w=1200&q=80',
      lastActive: 'Just now',
      nodes: [
        {
          id: `${newProjectId}-q1`,
          projectId: newProjectId,
          type: 'starting_question',
          title: `How might we explore ${title.toLowerCase()}?`,
          authorId: state.currentUserId,
          authorName: SEED_USERS[state.currentUserId]?.name || 'Elena Rostova',
          authorDiscipline: SEED_USERS[state.currentUserId]?.discipline || 'MDes Student',
          timestamp: 'Just now',
          stepNumber: 1,
          question: `Exploring genesis from ${droppedType}`,
          position: { x: 100, y: 150 }
        },
        {
          id: `${newProjectId}-gap1`,
          projectId: newProjectId,
          type: 'gap',
          title: 'Unresolved technical constraint',
          authorId: state.currentUserId,
          authorName: SEED_USERS[state.currentUserId]?.name || 'Elena Rostova',
          authorDiscipline: SEED_USERS[state.currentUserId]?.discipline || 'MDes Student',
          timestamp: 'Just now',
          stepNumber: 2,
          gapNeed: 'Looking for a collaborator experienced in real-time execution.',
          gapStatus: 'open',
          position: { x: 420, y: 150 }
        }
      ],
      connections: [
        {
          id: `conn-${newProjectId}-1`,
          fromId: `${newProjectId}-q1`,
          toId: `${newProjectId}-gap1`,
          type: 'led_to',
          label: 'genesis gap',
          dialogueSnippet: 'Elena: "Initial genesis experiment requires real-time bridge."'
        }
      ],
      branches: [],
      gaps: [
        {
          id: `gap-${newProjectId}-1`,
          projectId: newProjectId,
          title: 'Unresolved technical constraint',
          need: 'Looking for a collaborator experienced in real-time execution.',
          disciplineTarget: 'Engineering / DSP',
          status: 'open',
          sourceNodeId: `${newProjectId}-gap1`
        }
      ],
      credits: [
        {
          userId: state.currentUserId,
          name: SEED_USERS[state.currentUserId]?.name || 'Elena Rostova',
          discipline: SEED_USERS[state.currentUserId]?.discipline || 'MDes Student',
          role: 'Genesis Creator',
          timestamp: 'Just now'
        }
      ]
    };

    state = {
      ...state,
      projects: [newProject, ...state.projects],
      activeProjectId: newProjectId,
      viewMode: 'story',
      isProfileDocked: true,
      lastSavedAt: 'Saved just now'
    };
    notify();
  },

  createPrivateBranch: (
    originProjectId: string,
    originNodeId: string,
    title: string,
    skill: string,
    intent: string
  ) => {
    const currentUser = SEED_USERS[state.currentUserId] || SEED_USERS.elena;
    const targetProject = state.projects.find(p => p.id === originProjectId);
    if (!targetProject) return;

    const branchId = `branch-${Date.now()}`;
    const newBranch: Branch = {
      id: branchId,
      originProjectId,
      originNodeId,
      title,
      contributorId: currentUser.id,
      contributorName: currentUser.name,
      contributorDiscipline: currentUser.discipline,
      isPrivate: false,
      chapters: [
        {
          id: `chapter-${branchId}-1`,
          branchId,
          chapterNumber: 1,
          title,
          authorId: currentUser.id,
          authorName: currentUser.name,
          authorDiscipline: currentUser.discipline,
          date: 'Just now',
          turningPoint: intent,
          sourceNodeId: originNodeId,
          artifacts: []
        }
      ],
      credits: [
        {
          userId: currentUser.id,
          name: currentUser.name,
          discipline: currentUser.discipline,
          role: skill,
          timestamp: 'Just now'
        }
      ],
      createdAt: 'Just now'
    };

    const newChapterNode: StoryNode = {
      id: `node-${branchId}`,
      projectId: originProjectId,
      type: 'chapter',
      title: `${title} (${skill})`,
      authorId: currentUser.id,
      authorName: currentUser.name,
      authorDiscipline: currentUser.discipline,
      timestamp: 'Just now',
      stepNumber: targetProject.nodes.length + 1,
      hypothesis: intent,
      isTurningPoint: true,
      turningPointNote: `Branched from gap by ${currentUser.name}`,
      position: { x: 900, y: 350 }
    };

    const newConnection = {
      id: `conn-${originNodeId}-${newChapterNode.id}`,
      fromId: originNodeId,
      toId: newChapterNode.id,
      type: 'branched_from' as const,
      label: `branched by ${currentUser.name}`,
      dialogueSnippet: `${currentUser.name}: "Explored ${intent} through ${skill}."`,
      aiRelevance: `Branch expands original project scope into ${currentUser.discipline}.`
    };

    const quietNotification: NotificationItem = {
      id: `notif-${Date.now()}`,
      actorId: currentUser.id,
      actorName: currentUser.name,
      actorAvatar: currentUser.avatar,
      actorDiscipline: currentUser.discipline,
      action: 'added_chapter',
      projectId: originProjectId,
      projectTitle: targetProject.title,
      branchId,
      message: `${currentUser.name} branched your work and added a chapter: "${title}" (quiet notification, zero gatekeeping).`,
      timestamp: 'Just now',
      read: false
    };

    const updatedProjects = state.projects.map(p => {
      if (p.id === originProjectId) {
        return {
          ...p,
          branches: [...p.branches, newBranch],
          nodes: [...p.nodes, newChapterNode],
          connections: [...p.connections, newConnection],
          credits: [
            ...p.credits,
            {
              userId: currentUser.id,
              name: currentUser.name,
              discipline: currentUser.discipline,
              role: skill,
              timestamp: 'Just now'
            }
          ]
        };
      }
      return p;
    });

    state = {
      ...state,
      projects: updatedProjects,
      notifications: [quietNotification, ...state.notifications],
      selectedNodeId: newChapterNode.id,
      lastSavedAt: 'Saved just now'
    };
    notify();
  },

  // Legacy method compatibility for any unmigrated components
  openModal: (_modal: any) => {},
  closeModal: () => {},
  closeRadialMenu: () => {},
  openRadialMenu: (_x: number, _y: number) => {},
  toggleMobileSheet: (_open?: boolean) => {},
  keepPrivateBranch: (originProjectId: string, originNodeId: string, title: string, intent: string, skill: string) => {
    branchStore.createPrivateBranch(originProjectId, originNodeId, title, skill, intent);
  },

  markNotificationRead: (id: string) => {
    state = {
      ...state,
      notifications: state.notifications.map(n => n.id === id ? { ...n, read: true } : n)
    };
    notify();
  },

  resetToSeed: () => {
    localStorage.removeItem(STORAGE_KEY);
    state = defaultState;
    notify();
  }
};

export function useBranchStore(): BranchState {
  const [snapshot, setSnapshot] = useState<BranchState>(branchStore.getState);

  useEffect(() => {
    const unsubscribe = branchStore.subscribe(() => {
      setSnapshot(branchStore.getState());
    });
    return unsubscribe;
  }, []);

  return snapshot;
}
