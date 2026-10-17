import React, { useEffect, useRef, useCallback } from 'react';
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
  ReactFlowProvider,
  NodeChange,
  applyNodeChanges,
  EdgeChange,
  applyEdgeChanges
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

  const [nodes, setNodes] = useNodesState<Node>([]);
  const [edges, setEdges] = useEdgesState<Edge>([]);
  const draggedPositions = useRef<Record<string, { x: number; y: number }>>({});

  // Notify parent of reactFlow instance
  useEffect(() => {
    if (onEngineReady) onEngineReady(reactFlow);
  }, [reactFlow, onEngineReady]);

  // Synchronize graph nodes and edges whenever store state changes, preserving dragged positions
  useEffect(() => {
    const list: Node[] = [];

    // Helper to get position (dragged position if user moved it, otherwise default)
    const getPos = (id: string, defaultPos: { x: number; y: number }) => {
      return draggedPositions.current[id] || defaultPos;
    };

    // 1. Center Focal Person Node (Home Hub)
    list.push({
      id: 'person-hub',
      type: 'personNode',
      position: getPos('person-hub', { x: 0, y: 220 }),
      draggable: true,
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
        position: getPos('settings-node', { x: -350, y: 80 }),
        draggable: true,
        data: { isPinned: state.openNodes['settings-node'].isPinned }
      });
    }

    if (state.openNodes['notifications-node']) {
      list.push({
        id: 'notifications-node',
        type: 'notificationsNode',
        position: getPos('notifications-node', { x: -380, y: 260 }),
        draggable: true,
        data: { isPinned: state.openNodes['notifications-node'].isPinned }
      });
    }

    if (state.openNodes['network-node']) {
      list.push({
        id: 'network-node',
        type: 'networkNode',
        position: getPos('network-node', { x: -360, y: 460 }),
        draggable: true,
        data: { isPinned: state.openNodes['network-node'].isPinned }
      });
    }

    // 3. Right Blooming Nodes (Work & Discovery)
    if (state.openNodes['explore-node']) {
      list.push({
        id: 'explore-node',
        type: 'exploreNode',
        position: getPos('explore-node', { x: 330, y: 60 }),
        draggable: true,
        data: { isPinned: state.openNodes['explore-node'].isPinned }
      });
    }

    // 4. Surrounding Project Cards in Explore / Hub Mode
    const otherProjects = state.projects.filter(p => p.id !== state.activeProjectId);
    otherProjects.forEach((p, idx) => {
      const cardId = `card-${p.id}`;
      list.push({
        id: cardId,
        type: 'projectCardNode',
        position: getPos(cardId, { x: 330, y: 240 + idx * 240 }),
        draggable: true,
        data: { project: p, isCurrentActive: false }
      });
    });

    // 5. Active Project Story Nodes (Horizontal Left-to-Right Graph)
    const activeProject = state.projects.find(p => p.id === state.activeProjectId);
    if (activeProject && activeProject.nodes.length > 0) {
      activeProject.nodes.forEach((sn) => {
        const defaultPosX = 700 + (sn.position?.x || sn.stepNumber * 260);
        const defaultPosY = sn.position?.y || 200;

        list.push({
          id: sn.id,
          type: 'storyStepNode',
          position: getPos(sn.id, { x: defaultPosX, y: defaultPosY }),
          draggable: true,
          data: {
            node: sn,
            isActiveStep: sn.stepNumber === state.activeStepIndex,
            isSelected: sn.id === state.selectedNodeId
          }
        });
      });
    }

    // Construct dynamic graph edges
    const edgeList: Edge[] = [];

    if (state.openNodes['settings-node']) {
      edgeList.push({
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
      edgeList.push({
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
      edgeList.push({
        id: 'edge-hub-network',
        source: 'person-hub',
        target: 'network-node',
        sourceHandle: 'left-source',
        targetHandle: 'network-source',
        type: 'animatedStoryEdge',
        data: { label: 'network' }
      });
    }

    if (state.openNodes['explore-node']) {
      edgeList.push({
        id: 'edge-hub-explore',
        source: 'person-hub',
        target: 'explore-node',
        sourceHandle: 'right-source',
        targetHandle: 'explore-target',
        type: 'animatedStoryEdge',
        data: { label: 'explore' }
      });
    }

    if (activeProject && activeProject.nodes.length > 0) {
      const firstNode = activeProject.nodes[0];
      edgeList.push({
        id: 'edge-hub-story',
        source: 'person-hub',
        target: firstNode.id,
        sourceHandle: 'right-source',
        targetHandle: 'step-target',
        type: 'animatedStoryEdge',
        data: { label: 'active story' }
      });

      activeProject.connections.forEach((conn) => {
        edgeList.push({
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

    setNodes(list);
    setEdges(edgeList);
  }, [state, setNodes, setEdges]);

  // Handle node position changes during user dragging
  const handleNodesChange = useCallback(
    (changes: NodeChange[]) => {
      changes.forEach((change) => {
        if (change.type === 'position' && change.position) {
          draggedPositions.current[change.id] = change.position;
        }
      });
      setNodes((nds) => applyNodeChanges(changes, nds));
    },
    [setNodes]
  );

  const handleEdgesChange = useCallback(
    (changes: EdgeChange[]) => {
      setEdges((eds) => applyEdgeChanges(changes, eds));
    },
    [setEdges]
  );

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
      branchStore.openModal('privateBranch');
    }
  }, []);

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
        onNodesChange={handleNodesChange}
        onEdgesChange={handleEdgesChange}
        onPaneClick={handlePaneClick}
        nodesDraggable={true}
        nodesConnectable={false}
        elementsSelectable={true}
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
