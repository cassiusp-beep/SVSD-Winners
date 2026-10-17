import React, { memo } from 'react';
import { Handle, Position } from '@xyflow/react';
import { branchStore } from '../../../store/branchStore';
import { Bell, Pin, PinOff, X, GitBranch, Sparkles } from 'lucide-react';

interface NotificationsNodeProps {
  id: string;
  data: {
    isPinned?: boolean;
  };
}

export const NotificationsNode = memo(({ id, data }: NotificationsNodeProps) => {
  const isPinned = data.isPinned;
  const state = branchStore.getState();
  const notifications = state.notifications;

  const handleOpenBranch = (projectId: string) => {
    branchStore.setActiveProject(projectId);
  };

  return (
    <div
      className="branch-card"
      style={{
        width: 320,
        padding: '16px',
        backgroundColor: '#FFFFFF',
        borderColor: 'var(--color-border)',
        boxShadow: 'var(--shadow-floating)'
      }}
    >
      <Handle type="source" position={Position.Right} id="notif-source" style={{ background: '#767D73' }} />

      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '12px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <Bell size={16} color="var(--color-ink)" />
          <h4 style={{ fontFamily: 'var(--font-display)', fontSize: '14px', fontWeight: 600 }}>
            Quiet Notifications
          </h4>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
          <button
            onClick={() => branchStore.togglePinNode(id)}
            style={{ background: 'none', border: 'none', cursor: 'pointer', padding: '4px', color: isPinned ? 'var(--color-ink)' : 'var(--color-ink-muted)' }}
            title={isPinned ? 'Unpin' : 'Pin'}
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

      <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', maxHeight: '280px', overflowY: 'auto' }}>
        {notifications.length === 0 ? (
          <p style={{ fontSize: '12px', color: 'var(--color-ink-muted)', padding: '16px 0', textAlign: 'center' }}>
            No new activity. Work continues calmly.
          </p>
        ) : (
          notifications.map((notif) => (
            <div
              key={notif.id}
              onClick={() => handleOpenBranch(notif.projectId)}
              style={{
                padding: '10px 12px',
                backgroundColor: notif.read ? 'transparent' : 'var(--color-surface-subtle)',
                borderRadius: 'var(--radius-control)',
                cursor: 'pointer',
                border: '1px solid var(--color-border-subtle)',
                fontSize: '12px'
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '4px' }}>
                <img
                  src={notif.actorAvatar}
                  alt={notif.actorName}
                  style={{ width: 22, height: 22, borderRadius: 'var(--radius-pill)', objectFit: 'cover' }}
                />
                <span style={{ fontWeight: 600, color: 'var(--color-ink)' }}>{notif.actorName}</span>
                <span style={{ fontSize: '10px', color: 'var(--color-ink-muted)', marginLeft: 'auto' }}>{notif.timestamp}</span>
              </div>
              <p style={{ color: 'var(--color-ink)', lineHeight: 1.35 }}>{notif.message}</p>
              <div style={{ marginTop: '6px', display: 'flex', alignItems: 'center', gap: '4px', color: 'var(--color-positive-ink)', fontSize: '11px' }}>
                <GitBranch size={11} />
                <span>Credited beside your project (no approval needed)</span>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
});

NotificationsNode.displayName = 'NotificationsNode';
