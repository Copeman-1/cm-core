let currentPlayers = [];
let currentPlayerSource = null;

// ════════════════════════════════════════════════════════════
// INITIALIZE
// ════════════════════════════════════════════════════════════

window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'openAdminPanel') {
        openPanel();
    }
});

// Close panel on ESC
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closePanel();
        closeModal();
    }
});

// ════════════════════════════════════════════════════════════
// PANEL FUNCTIONS
// ════════════════════════════════════════════════════════════

function openPanel() {
    $('#admin-panel').removeClass('hidden');
    loadPlayers();
    loadServerStats();
}

function closePanel() {
    $('#admin-panel').addClass('hidden');
    $.post('https://cm-core/closeAdminPanel', JSON.stringify({}));
}

function switchTab(tab) {
    // Update nav buttons
    $('.nav-btn').removeClass('active');
    $(event.target).addClass('active');
    
    // Update tab content
    $('.tab-content').removeClass('active');
    $(`#${tab}-tab`).addClass('active');
    
    // Load data for tab
    if (tab === 'players') {
        loadPlayers();
    } else if (tab === 'bans') {
        loadBans();
    } else if (tab === 'logs') {
        loadLogs();
    } else if (tab === 'server') {
        loadServerStats();
    }
}

// ════════════════════════════════════════════════════════════
// PLAYERS TAB
// ════════════════════════════════════════════════════════════

function loadPlayers() {
    $.post('https://cm-core/getOnlinePlayers', JSON.stringify({}), function(players) {
        currentPlayers = players;
        renderPlayers(players);
    });
}

function renderPlayers(players) {
    const container = $('#players-list');
    container.empty();
    
    if (players.length === 0) {
        container.html('<p style="color: #a0a0b0; text-align: center;">No players online</p>');
        return;
    }
    
    players.forEach(player => {
        const card = $(`
            <div class="player-card" onclick="openPlayerModal(${player.source})">
                <h3>${player.name}</h3>
                <p><strong>ID:</strong> ${player.source}</p>
                <p><strong>Citizen ID:</strong> ${player.citizenid}</p>
                <p><strong>Job:</strong> ${player.job.label} (${player.job.grade})</p>
                <p><strong>Cash:</strong> $${formatMoney(player.money.cash)}</p>
                <p><strong>Bank:</strong> $${formatMoney(player.money.bank)}</p>
                <span class="badge">${player.job.name}</span>
            </div>
        `);
        
        container.append(card);
    });
}

function filterPlayers() {
    const search = $('#player-search').val().toLowerCase();
    
    const filtered = currentPlayers.filter(player => {
        return player.name.toLowerCase().includes(search) ||
               player.citizenid.toLowerCase().includes(search) ||
               player.source.toString().includes(search);
    });
    
    renderPlayers(filtered);
}

// ════════════════════════════════════════════════════════════
// PLAYER MODAL
// ════════════════════════════════════════════════════════════

function openPlayerModal(source) {
    currentPlayerSource = source;
    
    $.post('https://cm-core/getPlayerDetails', JSON.stringify({source: source}), function(data) {
        if (!data) {
            showNotification('Player not found', 'error');
            return;
        }
        
        const player = data.playerData;
        const warnings = data.warnings;
        
        $('#modal-player-name').text(player.name);
        
        let warningsHtml = '';
        if (warnings && warnings.length > 0) {
            warningsHtml = '<div style="margin-top: 15px;"><h4 style="color: #ef4444;">Warnings:</h4>';
            warnings.forEach(warn => {
                warningsHtml += `
                    <div style="background: #1e1e2e; padding: 10px; margin: 5px 0; border-radius: 5px;">
                        <p style="margin: 3px 0;"><strong>Reason:</strong> ${warn.reason}</p>
                        <p style="margin: 3px 0;"><strong>By:</strong> ${warn.warnedby}</p>
                        <p style="margin: 3px 0;"><strong>Date:</strong> ${formatDate(warn.created_at)}</p>
                    </div>
                `;
            });
            warningsHtml += '</div>';
        }
        
        $('#player-info').html(`
            <p><strong>Name:</strong> ${player.name}</p>
            <p><strong>Server ID:</strong> ${player.source}</p>
            <p><strong>Citizen ID:</strong> ${player.citizenid}</p>
            <p><strong>License:</strong> ${player.license}</p>
            <p><strong>Job:</strong> ${player.job.label} - ${player.job.gradeLabel} (Grade ${player.job.grade})</p>
            <p><strong>Gang:</strong> ${player.gang.label}</p>
            <p><strong>Cash:</strong> $${formatMoney(player.money.cash)}</p>
            <p><strong>Bank:</strong> $${formatMoney(player.money.bank)}</p>
            <p><strong>Ping:</strong> ${data.ping}ms</p>
            ${warningsHtml}
        `);
        
        $('#player-modal').removeClass('hidden');
    });
}

function closeModal() {
    $('#player-modal').addClass('hidden');
    currentPlayerSource = null;
}

// ════════════════════════════════════════════════════════════
// PLAYER ACTIONS
// ════════════════════════════════════════════════════════════

function teleportToPlayer() {
    if (!currentPlayerSource) return;
    
    $.post('https://cm-core/teleportToPlayer', JSON.stringify({source: currentPlayerSource}), function() {
        showNotification('Teleported to player', 'success');
        closeModal();
    });
}

function bringPlayer() {
    if (!currentPlayerSource) return;
    
    $.post('https://cm-core/bringPlayer', JSON.stringify({source: currentPlayerSource}), function() {
        showNotification('Player brought to you', 'success');
    });
}

function spectatePlayer() {
    if (!currentPlayerSource) return;
    
    $.post('https://cm-core/spectatePlayer', JSON.stringify({source: currentPlayerSource}), function() {
        closeModal();
        closePanel();
    });
}

function freezePlayer() {
    if (!currentPlayerSource) return;
    
    $.post('https://cm-core/freezePlayer', JSON.stringify({source: currentPlayerSource}), function() {
        showNotification('Player frozen', 'success');
    });
}

function revivePlayer() {
    if (!currentPlayerSource) return;
    
    $.post('https://cm-core/revivePlayer', JSON.stringify({source: currentPlayerSource}), function() {
        showNotification('Player revived', 'success');
    });
}

function healPlayer() {
    if (!currentPlayerSource) return;
    
    $.post('https://cm-core/healPlayer', JSON.stringify({source: currentPlayerSource}), function() {
        showNotification('Player healed', 'success');
    });
}

function showWarnDialog() {
    if (!currentPlayerSource) return;
    
    const reason = prompt('Enter warning reason:');
    if (!reason) return;
    
    $.post('https://cm-core/warnPlayer', JSON.stringify({
        source: currentPlayerSource,
        reason: reason
    }), function(success) {
        if (success) {
            showNotification('Player warned', 'success');
            openPlayerModal(currentPlayerSource); // Reload player data
        } else {
            showNotification('Failed to warn player', 'error');
        }
    });
}

function showKickDialog() {
    if (!currentPlayerSource) return;
    
    const reason = prompt('Enter kick reason:');
    if (!reason) return;
    
    if (!confirm('Are you sure you want to kick this player?')) return;
    
    $.post('https://cm-core/kickPlayer', JSON.stringify({
        source: currentPlayerSource,
        reason: reason
    }), function(success) {
        if (success) {
            showNotification('Player kicked', 'success');
            closeModal();
            loadPlayers();
        } else {
            showNotification('Failed to kick player', 'error');
        }
    });
}

function showBanDialog() {
    if (!currentPlayerSource) return;
    
    const duration = prompt('Enter ban duration in days (-1 for permanent):');
    if (duration === null) return;
    
    const durationNum = parseInt(duration);
    if (isNaN(durationNum)) {
        showNotification('Invalid duration', 'error');
        return;
    }
    
    const reason = prompt('Enter ban reason:');
    if (!reason) return;
    
    if (!confirm(`Are you sure you want to ban this player for ${durationNum === -1 ? 'permanent' : durationNum + ' days'}?`)) return;
    
    $.post('https://cm-core/banPlayer', JSON.stringify({
        source: currentPlayerSource,
        duration: durationNum,
        reason: reason
    }), function(success) {
        if (success) {
            showNotification('Player banned', 'success');
            closeModal();
            loadPlayers();
        } else {
            showNotification('Failed to ban player', 'error');
        }
    });
}

// ════════════════════════════════════════════════════════════
// BANS TAB
// ════════════════════════════════════════════════════════════

function loadBans() {
    $.post('https://cm-core/getBans', JSON.stringify({}), function(bans) {
        renderBans(bans);
    });
}

function renderBans(bans) {
    const container = $('#bans-list');
    container.empty();
    
    if (bans.length === 0) {
        container.html('<p style="color: #a0a0b0; text-align: center;">No bans found</p>');
        return;
    }
    
    bans.forEach(ban => {
        const timeLeft = ban.expire === -1 ? 'Permanent' : formatTimeLeft(ban.expire);
        const expired = ban.expire !== -1 && ban.expire < Date.now() / 1000;
        
        const item = $(`
            <div class="ban-item" style="${expired ? 'opacity: 0.5;' : ''}">
                <h4>${ban.name}</h4>
                <p><strong>License:</strong> ${ban.license}</p>
                <p><strong>Reason:</strong> ${ban.reason}</p>
                <p><strong>Banned By:</strong> ${ban.bannedby}</p>
                <p><strong>Time Left:</strong> ${timeLeft}</p>
                <p><strong>Date:</strong> ${formatDate(ban.created_at)}</p>
                ${!expired ? `<button onclick="unbanPlayer('${ban.license}')">Unban</button>` : '<p style="color: #ef4444;">Expired</p>'}
            </div>
        `);
        
        container.append(item);
    });
}

function unbanPlayer(license) {
    if (!confirm('Are you sure you want to unban this player?')) return;
    
    $.post('https://cm-core/unbanPlayer', JSON.stringify({license: license}), function(success) {
        if (success) {
            showNotification('Player unbanned', 'success');
            loadBans();
        } else {
            showNotification('Failed to unban player', 'error');
        }
    });
}

// ════════════════════════════════════════════════════════════
// LOGS TAB
// ════════════════════════════════════════════════════════════

function loadLogs() {
    $.post('https://cm-core/getAdminLogs', JSON.stringify({limit: 100}), function(logs) {
        renderLogs(logs);
    });
}

function renderLogs(logs) {
    const container = $('#logs-list');
    container.empty();
    
    if (logs.length === 0) {
        container.html('<p style="color: #a0a0b0; text-align: center;">No logs found</p>');
        return;
    }
    
    logs.forEach(log => {
        let details = '';
        try {
            const detailsObj = JSON.parse(log.details);
            details = Object.entries(detailsObj).map(([key, value]) => `${key}: ${value}`).join(', ');
        } catch (e) {
            details = log.details;
        }
        
        const color = getActionColor(log.action);
        
        const item = $(`
            <div class="log-item" style="border-left-color: ${color};">
                <h4>${log.action.toUpperCase()}</h4>
                <p><strong>Admin:</strong> ${log.admin_name} (${log.admin_license})</p>
                ${log.target_name ? `<p><strong>Target:</strong> ${log.target_name} (${log.target_license})</p>` : ''}
                ${details ? `<p><strong>Details:</strong> ${details}</p>` : ''}
                <p><strong>Date:</strong> ${formatDate(log.created_at)}</p>
            </div>
        `);
        
        container.append(item);
    });
}

function getActionColor(action) {
    const colors = {
        'ban': '#ef4444',
        'unban': '#10b981',
        'kick': '#f59e0b',
        'warn': '#f59e0b',
        'teleport': '#3b82f6',
        'revive': '#10b981',
        'heal': '#10b981',
        'givemoney': '#8b5cf6',
        'giveitem': '#8b5cf6',
        'setjob': '#06b6d4',
        'announce': '#3b82f6'
    };
    
    return colors[action] || '#3b82f6';
}

// ════════════════════════════════════════════════════════════
// SERVER TAB
// ════════════════════════════════════════════════════════════

function loadServerStats() {
    $.post('https://cm-core/getServerStats', JSON.stringify({}), function(stats) {
        if (!stats) return;
        
        const uptime = formatUptime(stats.uptime);
        
        $('#server-stats').html(`
            <div class="stat-card">
                <h3>Players Online</h3>
                <div class="stat-value">${stats.players} / ${stats.maxPlayers}</div>
            </div>
            
            <div class="stat-card">
                <h3>Server Uptime</h3>
                <div class="stat-value" style="font-size: 20px;">${uptime}</div>
            </div>
            
            <div class="stat-card">
                <h3>Cache Entries</h3>
                <div class="stat-value">${stats.cache.entries}</div>
            </div>
            
            <div class="stat-card">
                <h3>Framework Version</h3>
                <div class="stat-value" style="font-size: 20px;">${stats.version}</div>
            </div>
        `);
    });
}

// ════════════════════════════════════════════════════════════
// UTILITY FUNCTIONS
// ════════════════════════════════════════════════════════════

function formatMoney(amount) {
    return amount.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function formatDate(timestamp) {
    const date = new Date(timestamp);
    return date.toLocaleString();
}

function formatTimeLeft(expire) {
    const now = Math.floor(Date.now() / 1000);
    const diff = expire - now;
    
    if (diff <= 0) return 'Expired';
    
    const days = Math.floor(diff / 86400);
    const hours = Math.floor((diff % 86400) / 3600);
    const minutes = Math.floor((diff % 3600) / 60);
    
    if (days > 0) {
        return `${days}d ${hours}h ${minutes}m`;
    } else if (hours > 0) {
        return `${hours}h ${minutes}m`;
    } else {
        return `${minutes}m`;
    }
}

function formatUptime(seconds) {
    const days = Math.floor(seconds / 86400);
    const hours = Math.floor((seconds % 86400) / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    
    if (days > 0) {
        return `${days}d ${hours}h ${minutes}m`;
    } else if (hours > 0) {
        return `${hours}h ${minutes}m`;
    } else {
        return `${minutes}m`;
    }
}

function showNotification(message, type) {
    // This would integrate with your notification system
    console.log(`[${type.toUpperCase()}] ${message}`);
}

// ════════════════════════════════════════════════════════════
// AUTO-REFRESH
// ════════════════════════════════════════════════════════════

// Auto-refresh players list every 5 seconds when tab is active
setInterval(function() {
    if ($('#players-tab').hasClass('active') && !$('#admin-panel').hasClass('hidden')) {
        loadPlayers();
    }
}, 5000);

// Auto-refresh server stats every 10 seconds when tab is active
setInterval(function() {
    if ($('#server-tab').hasClass('active') && !$('#admin-panel').hasClass('hidden')) {
        loadServerStats();
    }
}, 10000);