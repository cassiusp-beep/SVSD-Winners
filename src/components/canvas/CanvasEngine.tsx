import React, { useEffect, useRef, useCallback } from 'react';
import {
  ReactFlow,
  Background,
  useNodesState,
  useEdgesState,
  Node,
  Edge,
  useReactFlow,
  ReactFlowProvider,
  NodeChange,
  applyNodeChanges
} from '@xyflow/react';
import '@xyflow/react/dist/style.css';

import { useBranchStore, branchStore } from '../../store/branchStore';
import { PersonHubNode } from './customNodes/PersonHubNode';
import { ProjectStoryNode } from './customNodes/ProjectStoryNode';
import { GapNode } from './customNodes/GapNode';
import { BranchNode } from './customNodes/BranchNode';
import { SourceNode } from './customNodes/SourceNode';
import { PeerNode } from './customNodes/PeerNode';
import { DialogueEdge } from './customEdges/DialogueEdge';
import { HotCornersHUD } from './HotCornersHUD';

const nodeTypes = {
  personHubNode: PersonHubNode,
  projectStoryNode: ProjectStoryNode,
  gapNode: GapNode,
  branchNode: BranchNode,
  sourceNode: SourceNode,
  peerNode: PeerNode
};

const edgeTypes = {
  dialogueEdge: DialogueEdge
};

const CanvasInner: React.FC = () => {
  const state = useBranchStore();
  const reactFlow = useReactFlow();

  const [nodes, setNodes] = useNodesState<Node>([]);
  const [edges, setEdges] = useEdgesState<Edge>([]);
  const draggedPositions = useRef<Record<string, { x: number; y: number }>>({});

  // Center camera on hub
  const handleCenterHub = useCallback(() => {
    reactFlow.setCenter(0, 0, { zoom: window.innerWidth < 768 ? 0.8 : 1, duration: 600 });
  }, [reactFlow]);

  // Center camera on specific story step
  const handleCenterStoryStep = useCallback((stepIndex: number) => {
    const targetX = (stepIndex - 1) * 320;
    reactFlow.setCenter(targetX, 0, { zoom: 0.95, duration: 500 });
  }, [reactFlow]);

  // Synchronize graph nodes and edges based on viewMode and store state
  useEffect(() => {
    const list: Node[] = [];
    const edgeList: Edge[] = [];

    const getPos = (id: string, defaultPos: { x: number; y: number }) => {
      return draggedPositions.current[id] || defaultPos;
    };

    if (state.viewMode === 'hub') {
      // 1. Central Profile Hub
      list.push({
        id: 'person-hub',
        type: 'personHubNode',
        position: getPos('person-hub', { x: 0, y: 0 }),
        draggable: true,
        data: {
          userId: state.currentUserId,
          isGuest: state.currentUserId === 'guest',
          isDocked: false
        }
      });

      // 2. Surrounding Project Hero Card: Haptic Weave (Elena)
      list.push({
        id: 'project-haptic-weave',
        type: 'projectStoryNode',
        position: getPos('project-haptic-weave', { x: 230, y: -50 }),
        draggable: true,
        data: {
          project: {
            id: 'haptic-weave',
            title: 'Haptic Weave',
            tagline: 'Can woven electronic textiles convey emotion through micro-actuators without screens?',
            creatorName: 'Elena Rostova',
            openGapsCount: 1,
            branchesCount: 1
          }
        }
      });

      // 3. Validation Source Node: Tactile Aesthetics
      list.push({
        id: 'source-tactile',
        type: 'sourceNode',
        position: getPos('source-tactile', { x: 650, y: -230 }),
        draggable: true,
        data: {
          source: {
            id: 'src-1',
            title: 'Tactile Aesthetics',
            author: 'Challis & Edwards (4.8mm pitch)',
            stepLabel: 'SOURCE • STEP 2'
          }
        }
      });

      // 4. Open Gap Node: Audio-to-Haptic DSP (Breathing Amber Glow)
      list.push({
        id: 'gap-audio-dsp',
        type: 'gapNode',
        position: getPos('gap-audio-dsp', { x: 740, y: 50 }),
        draggable: true,
        data: {
          gap: {
            id: 'hw-gap1',
            title: 'Audio-to-Haptic DSP',
            need: 'Need voice pitch mapped to dual-frequency 175Hz / 235Hz LRA actuators.',
            disciplineTarget: 'Mechatronics / Audio',
            projectId: 'haptic-weave'
          }
        }
      });

      // 5. Branch Node: Marcus Chen AudioWorklet DSP Bridge
      list.push({
        id: 'branch-marcus-dsp',
        type: 'branchNode',
        position: getPos('branch-marcus-dsp', { x: 280, y: 380 }),
        draggable: true,
        data: {
          branch: {
            id: 'branch-1',
            title: 'AudioWorklet DSP Bridge',
            creatorName: 'Marcus Chen',
            intent: 'Branched from Elena\'s gap. Synthesizes formant filters into PWM signals in browser.',
            date: 'Oct 16',
            accentColor: '#2563EB'
          }
        }
      });

      // 6. Peer Node: Amina Diallo
      list.push({
        id: 'peer-amina',
        type: 'peerNode',
        position: getPos('peer-amina', { x: -380, y: -130 }),
        draggable: true,
        data: {
          peer: {
            id: 'amina-diallo',
            name: 'Amina Diallo',
            institution: 'CCRMA',
            title: 'Bioluminescent Algae',
            description: 'Translating room acoustics into dinoflagellate glowing shear flow.',
            accentColor: '#FF7A6B'
          }
        }
      });

      // 7. Peer Node: Lucas Zhao
      list.push({
        id: 'peer-lucas',
        type: 'peerNode',
        position: getPos('peer-lucas', { x: -360, y: 170 }),
        draggable: true,
        data: {
          peer: {
            id: 'lucas-zhao',
            name: 'Lucas Zhao',
            institution: 'CED',
            title: 'Origami Acoustic Baffles',
            description: 'Parametric tessellations that fold to adjust room reverberation time.',
            accentColor: '#A98BFF'
          }
        }
      });

      // Edges with Live Dialogue Snippets (Saturated Whiteboard Markers)
      edgeList.push({
        id: 'edge-hub-project',
        source: 'person-hub',
        target: 'project-haptic-weave',
        sourceHandle: 'right-source',
        targetHandle: 'project-target',
        type: 'dialogueEdge',
        data: {
          label: 'active project',
          makerColor: '#0D8F5B'
        }
      });

      edgeList.push({
        id: 'edge-project-source',
        source: 'project-haptic-weave',
        target: 'source-tactile',
        sourceHandle: 'project-source',
        targetHandle: 'source-target',
        type: 'dialogueEdge',
        data: {
          label: 'validated by',
          makerColor: '#0D8F5B'
        }
      });

      edgeList.push({
        id: 'edge-project-gap',
        source: 'project-haptic-weave',
        target: 'gap-audio-dsp',
        sourceHandle: 'project-source',
        targetHandle: 'gap-target',
        type: 'dialogueEdge',
        data: {
          label: 'unfilled need',
          dialogueSnippet: 'Elena: "Need DSP to map voice pitch into LRA pulses."',
          makerColor: '#FF9F0A'
        }
      });

      edgeList.push({
        id: 'edge-gap-branch',
        source: 'gap-audio-dsp',
        target: 'branch-marcus-dsp',
        sourceHandle: 'gap-bottom',
        targetHandle: 'branch-target',
        type: 'dialogueEdge',
        data: {
          label: 'branched response',
          dialogueSnippet: 'Marcus: "AudioWorklet splits speech syllables at <8ms."',
          makerColor: '#E23D28',
          type: 'branched_from'
        }
      });

      edgeList.push({
        id: 'edge-hub-amina',
        source: 'person-hub',
        target: 'peer-amina',
        sourceHandle: 'left-source',
        targetHandle: 'peer-source',
        type: 'dialogueEdge',
        data: {
          label: 'peer collaboration',
          makerColor: '#0D8F5B'
        }
      });

      edgeList.push({
        id: 'edge-hub-lucas',
        source: 'person-hub',
        target: 'peer-lucas',
        sourceHandle: 'left-source',
        targetHandle: 'peer-source',
        type: 'dialogueEdge',
        data: {
          label: 'studio critique',
          makerColor: '#0D8F5B'
        }
      });
    } else {
      // 'story' mode: Profile docks top-left, horizontal chapter lineage
      list.push({
        id: 'person-hub',
        type: 'personHubNode',
        position: getPos('person-hub', { x: -450, y: -200 }),
        draggable: true,
        data: {
          userId: state.currentUserId,
          isGuest: state.currentUserId === 'guest',
          isDocked: true
        }
      });

      // Linear project lineage
      const activeProject = state.projects.find(p => p.id === state.activeProjectId) || state.projects[0];
      activeProject.nodes.forEach((sn, idx) => {
        const posX = idx * 300;
        const isGap = sn.type === 'gap';

        if (isGap) {
          list.push({
            id: sn.id,
            type: 'gapNode',
            position: getPos(sn.id, { x: posX, y: 50 }),
            draggable: true,
            data: {
              gap: {
                id: sn.id,
                title: sn.title,
                need: sn.gapNeed || 'Collaborator needed.',
                disciplineTarget: sn.authorDiscipline,
                projectId: activeProject.id
              }
            }
          });
        } else if (sn.type === 'source') {
          list.push({
            id: sn.id,
            type: 'sourceNode',
            position: getPos(sn.id, { x: posX, y: -90 }),
            draggable: true,
            data: {
              source: {
                id: sn.id,
                title: sn.title,
                author: sn.authorName,
                stepLabel: `SOURCE • STEP ${sn.stepNumber}`
              }
            }
          });
        } else {
          list.push({
            id: sn.id,
            type: 'projectStoryNode',
            position: getPos(sn.id, { x: posX, y: 0 }),
            draggable: true,
            data: {
              project: {
                id: sn.id,
                title: sn.title,
                tagline: sn.hypothesis || sn.question || 'Exploring story step.',
                creatorName: sn.authorName,
                openGapsCount: 0,
                branchesCount: 0
              }
            }
          });
        }

        if (idx > 0) {
          const prevNode = activeProject.nodes[idx - 1];
          edgeList.push({
            id: `story-edge-${prevNode.id}-${sn.id}`,
            source: prevNode.id,
            target: sn.id,
            type: 'dialogueEdge',
            data: {
              label: `step ${sn.stepNumber}`,
              dialogueSnippet: idx === 3 ? 'Elena: "Need DSP to map voice pitch into LRA pulses."' : undefined,
              makerColor: '#4FD8F0'
            }
          });
        }
      });
    }

    setNodes(list);
    setEdges(edgeList);
  }, [state, setNodes, setEdges]);

  // Handle position changes and proximity morphing detection
  const handleNodesChange = useCallback(
    (changes: NodeChange[]) => {
      changes.forEach((change) => {
        if (change.type === 'position' && change.position) {
          draggedPositions.current[change.id] = change.position;

          // Proximity detection for morph behavior (Section 3.5)
          const draggedPos = change.position;
          let nearestTarget: string | null = null;
          let minDistance = 90;

          nodes.forEach((n) => {
            if (n.id !== change.id) {
              const dx = (draggedPositions.current[n.id]?.x || n.position.x) - draggedPos.x;
              const dy = (draggedPositions.current[n.id]?.y || n.position.y) - draggedPos.y;
              const dist = Math.sqrt(dx * dx + dy * dy);
              if (dist < minDistance) {
                nearestTarget = n.id;
              }
            }
          });

          branchStore.setHoveredDropTarget(nearestTarget);
        }
      });
      setNodes((nds) => applyNodeChanges(changes, nds));
    },
    [nodes, setNodes]
  );

  // HTML5 Drag and drop handler for canvas ingestion (Section 3.6)
  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'copy';
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    branchStore.setHoveredDropTarget(null);

    // If external files dropped
    if (e.dataTransfer.files && e.dataTransfer.files.length > 0) {
      const file = e.dataTransfer.files[0];
      branchStore.genesisProjectFromDrop(file.name.replace(/\.[^/.]+$/, ''), 'Imported File / 3D Model');
    } else {
      branchStore.genesisProjectFromDrop('Tactile Waveform Study', 'Dropped Sensor Artifact');
    }
  };

  const isMobile = typeof window !== 'undefined' && window.innerWidth < 768;

  return (
    <div
      onDragOver={handleDragOver}
      onDrop={handleDrop}
      style={{
        width: '100vw',
        height: '100vh',
        backgroundColor: '#FAF9F5',
        position: 'relative',
        overflow: 'hidden'
      }}
    >
      <ReactFlow
        nodes={nodes}
        edges={edges}
        nodeTypes={nodeTypes}
        edgeTypes={edgeTypes}
        onNodesChange={handleNodesChange}
        defaultViewport={{
          x: isMobile ? 195 : window.innerWidth / 2 - 110,
          y: isMobile ? 390 : window.innerHeight / 2 - 30,
          zoom: isMobile ? 0.55 : 0.82
        }}
        minZoom={0.35}
        maxZoom={2.0}
        panOnDrag={true}
        zoomOnScroll={true}
        zoomOnPinch={true}
        preventScrolling={true}
        proOptions={{ hideAttribution: true }}
      >
        <Background color="#E5E0D5" gap={24} size={1.5} />
      </ReactFlow>

      {/* 4 Quiet Hot Corners Frame */}
      <HotCornersHUD
        onCenterHub={handleCenterHub}
        onCenterStoryStep={handleCenterStoryStep}
      />
    </div>
  );
};

export const CanvasEngine: React.FC = () => {
  return (
    <ReactFlowProvider>
      <CanvasInner />
    </ReactFlowProvider>
  );
};
