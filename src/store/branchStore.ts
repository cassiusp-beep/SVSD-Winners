import { useState, useEffect } from 'react';
import { User, Project, NotificationItem, Branch, Chapter, StoryNode } from '../types';
import { SEED_USERS, SEED_PROJECTS, SEED_NOTIFICATIONS } from '../data/seedData';

const STORAGE_KEY = 'svsd_branch_state_v1';

export interface BranchState {
  currentUserId: string;
  activeProjectId: string | null;
  activeStepIndex: number;
  isPlayingStory: boolean;
  aiEnabled: boolean;
  openNodes: Record<string, { isPinned: boolean; direction: 'left' | 'right' }>;
  savedProjectIds: string[];
  activeModal: 'findYourPlace' | 'privateBranch' | 'help' | 'save' | 'notifications' | 'settings' | 'network' | 'tinder' | null;
  selectedNodeId: string | null;
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
  openNodes: {
    'hw-q1': { isPinned: true, direction: 'right' }
  },
  savedProjectIds: ['haptic-weave'],
  activeModal: null,
  selectedNodeId: 'hw-q1',
  radialMenu: null,
  mobileSheetOpen: false,
  projects: SEED_PROJECTS,
  notifications: SEED_NOTIFICATIONS
};

// Simple reactive store with listener subscriptions
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

  closeUnpinnedNodes: () => {
    const remaining: Record<string, { isPinned: boolean; direction: 'left' | 'right' }> = {};
    Object.entries(state.openNodes).forEach(([id, val]) => {
      if (val.isPinned) remaining[id] = val;
    });
    state = { ...state, openNodes: remaining, radialMenu: null };
    notify();
  },

  openModal: (modal: BranchState['activeModal']) => {
    state = { ...state, activeModal: modal, radialMenu: null };
    notify();
  },

  closeModal: () => {
    state = { ...state, activeModal: null };
    notify();
  },

  openRadialMenu: (x: number, y: number) => {
    state = { ...state, radialMenu: { isOpen: true, x, y } };
    notify();
  },

  closeRadialMenu: () => {
    state = { ...state, radialMenu: null };
    notify();
  },

  toggleMobileSheet: (open?: boolean) => {
    state = { ...state, mobileSheetOpen: open !== undefined ? open : !state.mobileSheetOpen };
    notify();
  },

  toggleSaveProject: (projectId: string) => {
    const isSaved = state.savedProjectIds.includes(projectId);
    state = {
      ...state,
      savedProjectIds: isSaved
        ? state.savedProjectIds.filter(id => id !== projectId)
        : [...state.savedProjectIds, projectId]
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
          status: 'stuck' as const,
          nodes: [...p.nodes, newGapNode],
          gaps: [
            ...p.gaps,
            {
              id: newGapId,
              projectId,
              title: gapTitle,
              need,
              disciplineTarget: discipline,
              status: 'open' as const,
              sourceNodeId: newGapNode.id
            }
          ]
        };
      }
      return p;
    });

    state = {
      ...state,
      projects: updatedProjects,
      notifications: [newNotification, ...state.notifications],
      activeModal: null
    };
    notify();
  },

  keepPrivateBranch: (originProjectId: string, originNodeId: string, title: string, intent: string, skill: string) => {
    const targetProject = state.projects.find(p => p.id === originProjectId);
    if (!targetProject) return;

    const currentUser = SEED_USERS[state.currentUserId] || SEED_USERS.elena;
    const branchId = `branch-${Date.now()}`;
    const chapterId = `ch-${Date.now()}`;

    const newChapter: Chapter = {
      id: chapterId,
      branchId,
      chapterNumber: targetProject.nodes.length + 1,
      title,
      authorId: currentUser.id,
      authorName: currentUser.name,
      authorDiscipline: currentUser.discipline,
      date: 'Just now',
      turningPoint: intent,
      sourceNodeId: originNodeId,
      artifacts: [
        {
          id: `art-${Date.now()}`,
          type: 'code',
          title: `${title} Implementation Draft`,
          url: 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&w=800&q=80',
          caption: `${skill} contribution: ${intent}`
        }
      ]
    };

    const newBranch: Branch = {
      id: branchId,
      originProjectId,
      originNodeId,
      title,
      contributorId: currentUser.id,
      contributorName: currentUser.name,
      contributorDiscipline: currentUser.discipline,
      createdAt: 'Just now',
      isPrivate: false,
      credits: [
        ...targetProject.credits,
        {
          userId: currentUser.id,
          name: currentUser.name,
          discipline: currentUser.discipline,
          role: skill,
          timestamp: 'Just now'
        }
      ],
      chapters: [newChapter]
    };

    const newChapterNode: StoryNode = {
      id: `node-${chapterId}`,
      projectId: originProjectId,
      type: 'chapter',
      title: `Chapter: ${title}`,
      authorId: currentUser.id,
      authorName: currentUser.name,
      authorDiscipline: currentUser.discipline,
      timestamp: 'Just now',
      stepNumber: targetProject.nodes.length + 1,
      decisionRationale: intent,
      position: { x: 1240, y: 380 + targetProject.branches.length * 160 },
      artifacts: newChapter.artifacts
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

    // Quiet notification for original creator with ZERO gatekeeping!
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
      activeModal: null,
      selectedNodeId: newChapterNode.id
    };
    notify();
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

// React hook for consuming branch store
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
