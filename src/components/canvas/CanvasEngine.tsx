import React, { useMemo, useCallback } from 'react';
import {
  ReactFlow,
  Background,
  Controls,
  MiniMap,
  useNodesState,
  useEdgesState,
  Node,
  Edge,
  useReactFlow,
  ReactFlowProvider
} from '@xyflow/react';
import '@xyflow/react/dist/style.css';

import { useBranchStore, branchStore } from '../../store/branchStore';
import { PersonNode } from './customNodes/PersonNode';
import { StoryStepNode } from './customNodes/StoryStepNode';
import { ProjectCardNode } from './customNodes/ProjectCardNode';
import { SettingsNode } from './customNodes/SettingsNode';
import { NotificationsNode } from './customNodes/NotificationsNode';
import { NetworkNode } from './customNodes/NetworkNode';
import { ExploreNode } from './customNodes/ExploreNode';
import { AnimatedStoryEdge } from './customEdges/AnimatedStoryEdge';

const nodeTypes = {
  personNode: PersonNode,
  storyStepNode: StoryStepNode,
  projectCardNode: ProjectCardNode,
  settingsNode: SettingsNode,
  notificationsNode: NotificationsNode,
  networkNode: NetworkNode,
  exploreNode: ExploreNode
};

const edgeTypes = {
  animatedStoryEdge: AnimatedStoryEdge
};

const InnerCanvas: React.FC<{ onEngineReady?: (flow: any) => void }> = ({ onEngineReady }) => {
  const state = useBranchStore();
  const reactFlow = useReactFlow();

  // Call onEngineReady callback
  React.useEffect(() => {
    if (onEngineReady) onEngineReady(reactFlow);
  }, [reactFlow, onEngineReady]);

  // Construct dynamic graph nodes based on current state & open bloomed nodes
  const nodes = useMemo<Node[]>(() => {
    const list: Node[] = [];

    // 1. Center Focal Person Node (Home Hub)
    list.push({
      id: 'person-hub',
      type: 'personNode',
      position: { x: 0, y: 220 },
      data: {
        userId: state.currentUserId,
        isGuest: state.currentUserId === 'guest'
      }
    });

    // 2. Left Blooming Nodes (Personal & Network)
    if (state.openNodes['settings-node']) {
      list.push({
        id: 'settings-node',
        type: 'settingsNode',
        position: { x: -350, y: 80 },
        data: { isPinned: state.openNodes['settings-node'].isPinned }
      });
    }

    if (state.openNodes['notifications-node']) {
      list.push({
        id: 'notifications-node',
        type: 'notificationsNode',
        position: { x: -380, y: 260 },
        data: { isPinned: state.openNodes['notifications-node'].isPinned }
      });
    }

    if (state.openNodes['network-node']) {
      list.push({
        id: 'network-node',
        type: 'networkNode',
        position: { x: -360, y: 460 },
        data: { isPinned: state.openNodes['network-node'].isPinned }
      });
    }

    // 3. Right Blooming Nodes (Work & Discovery)
    if (state.openNodes['explore-node']) {
      list.push({
        id: 'explore-node',
        type: 'exploreNode',
        position: { x: 330, y: 60 },
        data: { isPinned: state.openNodes['explore-node'].isPinned }
      });
    }

    // 4. Surrounding Project Cards in Explore / Hub Mode
    const otherProjects = state.projects.filter(p => p.id !== state.activeProjectId);
    otherProjects.forEach((p, idx) => {
      list.push({
        id: `card-${p.id}`,
        type: 'projectCardNode',
        position: { x: 330, y: 240 + idx * 240 },
        data: { project: p, isCurrentActive: false }
      });
    });

    // 5. Active Project Story Nodes (Horizontal Left-to-Right Graph)
    const activeProject = state.projects.find(p => p.id === state.activeProjectId);
    if (activeProject && activeProject.nodes.length > 0) {
      activeProject.nodes.forEach((sn) => {
        const posX = 700 + (sn.position?.x || sn.stepNumber * 260);
        const posY = sn.position?.y || 200;

        list.push({
          id: sn.id,
          type: 'storyStepNode',
          position: { x: posX, y: posY },
          data: {
            node: sn,
            isActiveStep: sn.stepNumber === state.activeStepIndex,
            isSelected: sn.id === state.selectedNodeId
          }
        });
      });
    }

    return list;
  }, [state]);

  // Construct dynamic graph edges
  const edges = useMemo<Edge[]>(() => {
    const list: Edge[] = [];

    // Edges from Person Hub to left nodes
    if (state.openNodes['settings-node']) {
      list.push({
        id: 'edge-hub-settings',
        source: 'person-hub',
        target: 'settings-node',
        sourceHandle: 'left-source',
        targetHandle: 'settings-source',
        type: 'animatedStoryEdge',
        data: { label: 'settings' }
      });
    }

    if (state.openNodes['notifications-node']) {
      list.push({
        id: 'edge-hub-notif',
        source: 'person-hub',
        target: 'notifications-node',
        sourceHandle: 'left-source',
        targetHandle: 'notif-source',
        type: 'animatedStoryEdge',
        data: { label: 'alerts' }
      });
    }

    if (state.openNodes['network-node']) {
      list.push({
        id: 'edge-hub-network',
        source: 'person-hub',
        target: 'network-node',
        sourceHandle: 'left-source',
        targetHandle: 'network-source',
        type: 'animatedStoryEdge',
        data: { label: 'network' }
      });
    }

    // Edges from Person Hub to right nodes
    if (state.openNodes['explore-node']) {
      list.push({
        id: 'edge-hub-explore',
        source: 'person-hub',
        target: 'explore-node',
        sourceHandle: 'right-source',
        targetHandle: 'explore-target',
        type: 'animatedStoryEdge',
        data: { label: 'explore' }
      });
    }

    // Edge from Person Hub to active project story origin
    const activeProject = state.projects.find(p => p.id === state.activeProjectId);
    if (activeProject && activeProject.nodes.length > 0) {
      const firstNode = activeProject.nodes[0];
      list.push({
        id: 'edge-hub-story',
        source: 'person-hub',
        target: firstNode.id,
        sourceHandle: 'right-source',
        targetHandle: 'step-target',
        type: 'animatedStoryEdge',
        data: { label: 'active story' }
      });

      // Internal story connections
      activeProject.connections.forEach((conn) => {
        list.push({
          id: conn.id,
          source: conn.fromId,
          target: conn.toId,
          sourceHandle: 'step-source',
          targetHandle: 'step-target',
          type: 'animatedStoryEdge',
          data: {
            label: conn.label,
            type: conn.type,
            dialogueSnippet: conn.dialogueSnippet,
            aiRelevance: conn.aiRelevance
          }
        });
      });
    }

    return list;
  }, [state]);

  // Handle clicking empty canvas space to fold unpinned nodes
  const handlePaneClick = useCallback(() => {
    branchStore.closeUnpinnedNodes();
  }, []);

  // Handle desktop file drag and drop onto canvas
  const handleDragOver = useCallback((e: React.DragEvent) => {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'copy';
  }, []);

  const handleDrop = useCallback((e: React.DragEvent) => {
    e.preventDefault();
    const files = e.dataTransfer.files;
    if (files && files.length > 0) {
      const file = files[0];
      const position = reactFlow.screenToFlowPosition({
        x: e.clientX,
        y: e.clientY
      });

      // Automatically launch private draft with dropped file context!
      branchStore.openModal('privateBranch');
    }
  }, [reactFlow]);

  return (
    <div
      style={{ width: '100%', height: '100%', position: 'relative' }}
      onDragOver={handleDragOver}
      onDrop={handleDrop}
    >
      <ReactFlow
        nodes={nodes}
        edges={edges}
        nodeTypes={nodeTypes}
        edgeTypes={edgeTypes}
        onPaneClick={handlePaneClick}
        fitView
        fitViewOptions={{ padding: 0.25 }}
        minZoom={0.35}
        maxZoom={1.75}
        defaultViewport={{ x: 100, y: 100, zoom: 0.85 }}
      >
        <Background color="#D2D6CF" gap={28} size={1} />
        <Controls showInteractive={false} position="bottom-right" style={{ marginBottom: 120, marginRight: 16 }} />
        <MiniMap
          nodeColor={(n) => {
            if (n.type === 'personNode') return '#202420';
            if (n.type === 'storyStepNode') return '#F4E7A3';
            return '#D8E8F0';
          }}
          maskColor="rgba(243, 243, 240, 0.7)"
          style={{ marginBottom: 180, marginRight: 16, borderRadius: 'var(--radius-card)', border: '1px solid var(--color-border)' }}
        />
      </ReactFlow>
    </div>
  );
};

export const CanvasEngine: React.FC<{ onEngineReady?: (flow: any) => void }> = (props) => {
  return (
    <ReactFlowProvider>
      <InnerCanvas {...props} />
    </ReactFlowProvider>
  );
};
