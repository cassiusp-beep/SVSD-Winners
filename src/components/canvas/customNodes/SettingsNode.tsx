import React, { memo } from 'react';
import { Handle, Position } from '@xyflow/react';
import { branchStore } from '../../../store/branchStore';
import { Pin, PinOff, X, Sliders, Shield, RefreshCw } from 'lucide-react';

interface SettingsNodeProps {
  id: string;
  data: {
    isPinned?: boolean;
  };
}

export const SettingsNode = memo(({ id, data }: SettingsNodeProps) => {
  const isPinned = data.isPinned;

  return (
    <div
      className="branch-card"
      style={{
        width: 280,
        padding: '16px',
        backgroundColor: '#FFFFFF',
        borderColor: 'var(--color-border)',
        boxShadow: 'var(--shadow-floating)'
      }}
    >
      <Handle type="source" position={Position.Right} id="settings-source" style={{ background: '#767D73' }} />

      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '12px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <Sliders size={16} color="var(--color-ink)" />
          <h4 style={{ fontFamily: 'var(--font-display)', fontSize: '14px', fontWeight: 600 }}>
            Settings & Privacy
          </h4>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
          <button
            onClick={() => branchStore.togglePinNode(id)}
            style={{ background: 'none', border: 'none', cursor: 'pointer', padding: '4px', color: isPinned ? 'var(--color-ink)' : 'var(--color-ink-muted)' }}
            title={isPinned ? 'Unpin node' : 'Pin node (prevents auto-fade)'}
          >
            {isPinned ? <Pin size={14} fill="var(--color-ink)" /> : <PinOff size={14} />}
          </button>
          <button
            onClick={() => branchStore.closeNode(id)}
            style={{ background: 'none', border: 'none', cursor: 'pointer', padding: '4px', color: 'var(--color-ink-muted)' }}
            title="Close"
          >
            <X size={14} />
          </button>
        </div>
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: '10px', fontSize: '12px' }}>
        <div style={{ padding: '8px 10px', backgroundColor: 'var(--color-surface-subtle)', borderRadius: 'var(--radius-control)' }}>
          <span style={{ fontWeight: 600 }}>Authorship Privacy</span>
          <p style={{ color: 'var(--color-ink-muted)', marginTop: '2px' }}>
            Draft branches are always private until kept. Original projects are never touched.
          </p>
        </div>

        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '6px 0' }}>
          <span>Optional AI Layer</span>
          <button
            onClick={() => branchStore.toggleAi()}
            className="branch-chip"
            style={{
              backgroundColor: branchStore.getState().aiEnabled ? 'var(--color-ai-tint)' : 'var(--color-surface-subtle)',
              color: 'var(--color-ink)',
              border: '1px solid var(--color-border)',
              cursor: 'pointer'
            }}
          >
            {branchStore.getState().aiEnabled ? 'AI Enabled' : 'AI Off'}
          </button>
        </div>

        <button
          onClick={() => branchStore.resetToSeed()}
          className="branch-btn branch-btn-secondary"
          style={{ width: '100%', fontSize: '11px', marginTop: '4px' }}
        >
          <RefreshCw size={12} />
          <span>Reset Demo to Clean Seed</span>
        </button>
      </div>
    </div>
  );
});

SettingsNode.displayName = 'SettingsNode';
