let currentEditor = 'items';
let currentEntries = {};
let currentEditEntry = null;

// ════════════════════════════════════════════════════════════
// INITIALIZE
// ════════════════════════════════════════════════════════════

window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'openEditor') {
        openEditor(data.type);
    } else if (data.action === 'openQuickAdd') {
        openQuickAdd(data.type, data.name, data.label, data.data);
    }
});

// Close on ESC
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeEditor();
        closeModal();
        closeImportModal();
    }
});

// ════════════════════════════════════════════════════════════
// EDITOR FUNCTIONS
// ════════════════════════════════════════════════════════════

function openEditor(type) {
    currentEditor = type || 'items';
    $('#editor-panel').removeClass('hidden');
    switchEditor(currentEditor);
}

function closeEditor() {
    $('#editor-panel').addClass('hidden');
    $.post('https://cm-core/closeEditor', JSON.stringify({}));
}

function switchEditor(type) {
    currentEditor = type;
    
    // Update nav
    $('.nav-btn').removeClass('active');
    $(`.nav-btn:contains("${capitalize(type)}")`).addClass('active');
    
    // Update content
    $('.editor-section').removeClass('active');
    $(`#${type}-editor`).addClass('active');
    
    // Load data
    loadEntries(type);
}

// ════════════════════════════════════════════════════════════
// LOAD ENTRIES
// ════════════════════════════════════════════════════════════

function loadEntries(type) {
    const callbacks = {
        'items': 'getItems',
        'vehicles': 'getVehicles',
        'jobs': 'getJobs',
        'gangs': 'getGangs'
    };
    
    $.post(`https://cm-core/${callbacks[type]}`, JSON.stringify({}), function(data) {
        if (!data) {
            showNotification('Failed to load ' + type, 'error');
            return;
        }
        
        currentEntries = data;
        renderEntries(type, data);
    });
}

function renderEntries(type, entries) {
    const container = $(`#${type}-grid`);
    container.empty();
    
    if (!entries || Object.keys(entries).length === 0) {
        container.html(`<p style="color: #a0a0b0; text-align: center; grid-column: 1/-1;">No ${type} found. Click "Add New" to create one.</p>`);
        return;
    }
    
    for (const [key, entry] of Object.entries(entries)) {
        const card = createEntryCard(type, key, entry);
        container.append(card);
    }
}

function createEntryCard(type, key, entry) {
    let imageUrl = 'nui://cm-images/misc/placeholder.png';
    let title = key;
    let details = '';
    
    if (type === 'items') {
        imageUrl = `nui://cm-images/items/${entry.image || key + '.png'}`;
        title = entry.label || key;
        details = `
            <p><strong>Name:</strong> ${entry.name}</p>
            <p><strong>Weight:</strong> ${entry.weight}g</p>
            <p><strong>Type:</strong> ${entry.type}</p>
            <span class="badge">${entry.useable ? 'Useable' : 'Item'}</span>
            ${entry.unique ? '<span class="badge">Unique</span>' : ''}
        `;
    } else if (type === 'vehicles') {
        imageUrl = `nui://cm-images/vehicles/${entry.image || key + '.png'}`;
        title = entry.name || key;
        details = `
            <p><strong>Model:</strong> ${entry.model}</p>
            <p><strong>Brand:</strong> ${entry.brand || 'Unknown'}</p>
            <p><strong>Price:</strong> $${formatMoney(entry.price || 0)}</p>
            <p><strong>Category:</strong> ${entry.category}</p>
            <span class="badge">${entry.shop || 'PDM'}</span>
        `;
    } else if (type === 'jobs') {
        imageUrl = `nui://cm-images/jobs/${key}.png`;
        title = entry.label || key;
        const gradeCount = Object.keys(entry.grades || {}).length;
        details = `
            <p><strong>Job:</strong> ${key}</p>
            <p><strong>Grades:</strong> ${gradeCount}</p>
            <p><strong>Default Duty:</strong> ${entry.defaultDuty ? 'Yes' : 'No'}</p>
        `;
    } else if (type === 'gangs') {
        imageUrl = `nui://cm-images/gangs/${key}.png`;
        title = entry.label || key;
        const gradeCount = Object.keys(entry.grades || {}).length;
        details = `
            <p><strong>Gang:</strong> ${key}</p>
            <p><strong>Grades:</strong> ${gradeCount}</p>
        `;
    }
    
    return $(`
        <div class="entry-card">
            <img src="${imageUrl}" class="entry-card-image" onerror="this.src='nui://cm-images/misc/placeholder.png'">
            <h3>${title}</h3>
            ${details}
            <div class="entry-card-actions">
                <button class="btn btn-primary" onclick="editEntry('${type}', '${key}')">Edit</button>
                ${type === 'vehicles' ? `<button class="btn btn-info" onclick="previewVehicle('${key}')">Preview</button>` : ''}
                ${key !== 'unemployed' && key !== 'none' ? `<button class="btn btn-danger" onclick="deleteEntry('${type}', '${key}')">Delete</button>` : ''}
            </div>
        </div>
    `);
}

// ════════════════════════════════════════════════════════════
// FILTER ENTRIES
// ════════════════════════════════════════════════════════════

function filterEntries() {
    const search = $('#search-input').val().toLowerCase();
    
    if (!search) {
        renderEntries(currentEditor, currentEntries);
        return;
    }
    
    const filtered = {};
    
    for (const [key, entry] of Object.entries(currentEntries)) {
        const searchText = JSON.stringify(entry).toLowerCase();
        if (searchText.includes(search) || key.toLowerCase().includes(search)) {
            filtered[key] = entry;
        }
    }
    
    renderEntries(currentEditor, filtered);
}

// ════════════════════════════════════════════════════════════
// ADD/EDIT/DELETE ENTRY
// ════════════════════════════════════════════════════════════

function showAddDialog() {
    currentEditEntry = null;
    $('#modal-title').text(`Add New ${capitalize(currentEditor.slice(0, -1))}`);
    generateForm(currentEditor, null);
    $('#edit-modal').removeClass('hidden');
}

function editEntry(type, key) {
    currentEditEntry = key;
    const entry = currentEntries[key];
    $('#modal-title').text(`Edit ${capitalize(type.slice(0, -1))}`);
    generateForm(type, entry);
    $('#edit-modal').removeClass('hidden');
}

function deleteEntry(type, key) {
    if (!confirm(`Are you sure you want to delete this ${type.slice(0, -1)}?`)) {
        return;
    }
    
    const callbacks = {
        'items': 'deleteItem',
        'vehicles': 'deleteVehicle',
        'jobs': 'deleteJob',
        'gangs': 'deleteGang'
    };
    
    const dataKey = type === 'items' ? 'name' : type === 'vehicles' ? 'model' : 'name';
    
    $.post(`https://cm-core/${callbacks[type]}`, JSON.stringify({[dataKey]: key}), function(result) {
        if (result.success) {
            loadEntries(type);
        }
    });
}

function saveEntry() {
    const formData = getFormData();
    
    if (!validateForm(formData)) {
        showNotification('Please fill in all required fields', 'error');
        return;
    }
    
    const callbacks = {
        'items': currentEditEntry ? 'updateItem' : 'addItem',
        'vehicles': currentEditEntry ? 'updateVehicle' : 'addVehicle',
        'jobs': currentEditEntry ? 'updateJob' : 'addJob',
        'gangs': currentEditEntry ? 'updateGang' : 'addGang'
    };
    
    const callback = callbacks[currentEditor];
    
    let postData;
    if (currentEditEntry) {
        const key = currentEditor === 'items' ? 'name' : currentEditor === 'vehicles' ? 'model' : 'name';
        postData = {
            [key]: currentEditEntry,
            [currentEditor.slice(0, -1)]: formData
        };
    } else {
        postData = formData;
    }
    
    $.post(`https://cm-core/${callback}`, JSON.stringify(postData), function(result) {
        if (result.success) {
            closeModal();
            loadEntries(currentEditor);
        }
    });
}

// ════════════════════════════════════════════════════════════
// FORM GENERATION
// ════════════════════════════════════════════════════════════

function generateForm(type, data) {
    const forms = {
        'items': generateItemForm,
        'vehicles': generateVehicleForm,
        'jobs': generateJobForm,
        'gangs': generateGangForm
    };
    
    const formHtml = forms[type](data);
    $('#modal-form').html(formHtml);
}

function generateItemForm(data) {
    return `
        <div class="form-group">
            <label>Spawn Name *</label>
            <input type="text" id="item-name" value="${data?.name || ''}" ${data ? 'disabled' : ''} required>
        </div>
        
        <div class="form-group">
            <label>Display Name *</label>
            <input type="text" id="item-label" value="${data?.label || ''}" required>
        </div>
        
        <div class="form-group">
            <label>Description</label>
            <textarea id="item-description">${data?.description || ''}</textarea>
        </div>
        
        <div class="form-group">
            <label>Weight (grams) *</label>
            <input type="number" id="item-weight" value="${data?.weight || 0}" required>
        </div>
        
        <div class="form-group">
            <label>Type *</label>
            <select id="item-type">
                <option value="item" ${data?.type === 'item' ? 'selected' : ''}>Item</option>
                <option value="weapon" ${data?.type === 'weapon' ? 'selected' : ''}>Weapon</option>
                <option value="food" ${data?.type === 'food' ? 'selected' : ''}>Food</option>
                <option value="drink" ${data?.type === 'drink' ? 'selected' : ''}>Drink</option>
            </select>
        </div>
        
        <div class="form-group">
            <label>Image (filename in cm-images/items/)</label>
            <input type="text" id="item-image" value="${data?.image || ''}" placeholder="item_name.png">
        </div>
        
        <div class="form-group checkbox-group">
            <input type="checkbox" id="item-useable" ${data?.useable ? 'checked' : ''}>
            <label>Useable</label>
        </div>
        
        <div class="form-group checkbox-group">
            <input type="checkbox" id="item-unique" ${data?.unique ? 'checked' : ''}>
            <label>Unique (one per slot)</label>
        </div>
        
        <div class="form-group checkbox-group">
            <input type="checkbox" id="item-shouldClose" ${data?.shouldClose !== false ? 'checked' : ''}>
            <label>Should close inventory on use</label>
        </div>
    `;
}

function generateVehicleForm(data) {
    return `
        <div class="form-group">
            <label>Model (spawn name) *</label>
            <input type="text" id="vehicle-model" value="${data?.model || ''}" ${data ? 'disabled' : ''} required>
        </div>
        
        <div class="form-group">
            <label>Display Name *</label>
            <input type="text" id="vehicle-name" value="${data?.name || ''}" required>
        </div>
        
        <div class="form-group">
            <label>Brand</label>
            <input type="text" id="vehicle-brand" value="${data?.brand || ''}" placeholder="e.g. Truffade">
        </div>
        
        <div class="form-group">
            <label>Price *</label>
            <input type="number" id="vehicle-price" value="${data?.price || 0}" required>
        </div>
        
        <div class="form-group">
            <label>Category *</label>
            <select id="vehicle-category">
                <option value="compacts" ${data?.category === 'compacts' ? 'selected' : ''}>Compacts</option>
                <option value="sedans" ${data?.category === 'sedans' ? 'selected' : ''}>Sedans</option>
                <option value="suvs" ${data?.category === 'suvs' ? 'selected' : ''}>SUVs</option>
                <option value="coupes" ${data?.category === 'coupes' ? 'selected' : ''}>Coupes</option>
                <option value="muscle" ${data?.category === 'muscle' ? 'selected' : ''}>Muscle</option>
                <option value="sports" ${data?.category === 'sports' ? 'selected' : ''}>Sports</option>
                <option value="super" ${data?.category === 'super' ? 'selected' : ''}>Super</option>
                <option value="motorcycles" ${data?.category === 'motorcycles' ? 'selected' : ''}>Motorcycles</option>
                <option value="offroad" ${data?.category === 'offroad' ? 'selected' : ''}>Off-road</option>
                <option value="vans" ${data?.category === 'vans' ? 'selected' : ''}>Vans</option>
            </select>
        </div>
        
        <div class="form-group">
            <label>Shop *</label>
            <select id="vehicle-shop">
                <option value="pdm" ${data?.shop === 'pdm' ? 'selected' : ''}>Premium Deluxe Motorsport</option>
                <option value="luxury" ${data?.shop === 'luxury' ? 'selected' : ''}>Luxury Autos</option>
                <option value="boats" ${data?.shop === 'boats' ? 'selected' : ''}>Boat Shop</option>
                <option value="air" ${data?.shop === 'air' ? 'selected' : ''}>Aircraft Shop</option>
            </select>
        </div>
        
        <div class="form-group">
            <label>Stock (-1 = unlimited)</label>
            <input type="number" id="vehicle-stock" value="${data?.stock ?? -1}">
        </div>
        
        <div class="form-group">
            <label>Image (filename in cm-images/vehicles/)</label>
            <input type="text" id="vehicle-image" value="${data?.image || ''}" placeholder="vehicle_model.png">
        </div>
    `;
}

function generateJobForm(data) {
    let gradesHtml = '';
    if (data?.grades) {
        for (const [grade, info] of Object.entries(data.grades)) {
            gradesHtml += `
                <div class="grade-entry">
                    <h4>Grade ${grade}</h4>
                    <input type="text" class="grade-name" data-grade="${grade}" value="${info.name}" placeholder="Grade Name">
                    <input type="number" class="grade-payment" data-grade="${grade}" value="${info.payment || 0}" placeholder="Payment">
                </div>
            `;
        }
    } else {
        gradesHtml = `
            <div class="grade-entry">
                <h4>Grade 0</h4>
                <input type="text" class="grade-name" data-grade="0" value="Employee" placeholder="Grade Name">
                <input type="number" class="grade-payment" data-grade="0" value="50" placeholder="Payment">
            </div>
        `;
    }
    
    return `
        <div class="form-group">
            <label>Job Name (internal) *</label>
            <input type="text" id="job-name" value="${data?.name || ''}" ${data ? 'disabled' : ''} required>
        </div>
        
        <div class="form-group">
            <label>Display Name *</label>
            <input type="text" id="job-label" value="${data?.label || ''}" required>
        </div>
        
        <div class="form-group checkbox-group">
            <input type="checkbox" id="job-defaultDuty" ${data?.defaultDuty ? 'checked' : ''}>
            <label>On Duty by Default</label>
        </div>
        
        <div class="form-group">
            <label>Grades</label>
            <div id="grades-container">
                ${gradesHtml}
            </div>
            <button type="button" class="btn btn-primary" onclick="addGrade()">Add Grade</button>
        </div>
    `;
}

function generateGangForm(data) {
    let gradesHtml = '';
    if (data?.grades) {
        for (const [grade, info] of Object.entries(data.grades)) {
            gradesHtml += `
                <div class="grade-entry">
                    <h4>Grade ${grade}</h4>
                    <input type="text" class="grade-name" data-grade="${grade}" value="${info.name}" placeholder="Grade Name">
                    <input type="number" class="grade-payment" data-grade="${grade}" value="${info.payment || 0}" placeholder="Payment">
                </div>
            `;
        }
    } else {
        gradesHtml = `
            <div class="grade-entry">
                <h4>Grade 0</h4>
                <input type="text" class="grade-name" data-grade="0" value="Member" placeholder="Grade Name">
                <input type="number" class="grade-payment" data-grade="0" value="25" placeholder="Payment">
            </div>
        `;
    }
    
    return `
        <div class="form-group">
            <label>Gang Name (internal) *</label>
            <input type="text" id="gang-name" value="${data?.name || ''}" ${data ? 'disabled' : ''} required>
        </div>
        
        <div class="form-group">
            <label>Display Name *</label>
            <input type="text" id="gang-label" value="${data?.label || ''}" required>
        </div>
        
        <div class="form-group">
            <label>Grades</label>
            <div id="grades-container">
                ${gradesHtml}
            </div>
            <button type="button" class="btn btn-primary" onclick="addGrade()">Add Grade</button>
        </div>
    `;
}

function addGrade() {
    const container = $('#grades-container');
    const gradeCount = container.find('.grade-entry').length;
    
    container.append(`
        <div class="grade-entry">
            <h4>Grade ${gradeCount}</h4>
            <input type="text" class="grade-name" data-grade="${gradeCount}" value="" placeholder="Grade Name">
            <input type="number" class="grade-payment" data-grade="${gradeCount}" value="0" placeholder="Payment">
            <button type="button" class="btn btn-danger btn-sm" onclick="$(this).parent().remove()">Remove</button>
        </div>
    `);
}

// ════════════════════════════════════════════════════════════
// GET FORM DATA
// ════════════════════════════════════════════════════════════

function getFormData() {
    const type = currentEditor;
    
    if (type === 'items') {
        return {
            name: $('#item-name').val(),
            label: $('#item-label').val(),
            description: $('#item-description').val(),
            weight: parseInt($('#item-weight').val()) || 0,
            type: $('#item-type').val(),
            image: $('#item-image').val() || ($('#item-name').val() + '.png'),
            useable: $('#item-useable').is(':checked'),
            unique: $('#item-unique').is(':checked'),
            shouldClose: $('#item-shouldClose').is(':checked'),
            combinable: null
        };
    } else if (type === 'vehicles') {
        return {
            model: $('#vehicle-model').val(),
            name: $('#vehicle-name').val(),
            brand: $('#vehicle-brand').val(),
            price: parseInt($('#vehicle-price').val()) || 0,
            category: $('#vehicle-category').val(),
            shop: $('#vehicle-shop').val(),
            stock: parseInt($('#vehicle-stock').val()) || -1,
            image: $('#vehicle-image').val() || ($('#vehicle-model').val() + '.png')
        };
    } else if (type === 'jobs') {
        const grades = {};
        $('.grade-entry').each(function() {
            const grade = $(this).find('.grade-name').data('grade');
            grades[grade] = {
                name: $(this).find('.grade-name').val(),
                payment: parseInt($(this).find('.grade-payment').val()) || 0
            };
        });
        
        return {
            name: $('#job-name').val(),
            label: $('#job-label').val(),
            defaultDuty: $('#job-defaultDuty').is(':checked'),
            grades: grades
        };
    } else if (type === 'gangs') {
        const grades = {};
        $('.grade-entry').each(function() {
            const grade = $(this).find('.grade-name').data('grade');
            grades[grade] = {
                name: $(this).find('.grade-name').val(),
                payment: parseInt($(this).find('.grade-payment').val()) || 0
            };
        });
        
        return {
            name: $('#gang-name').val(),
            label: $('#gang-label').val(),
            grades: grades
        };
    }
}

function validateForm(data) {
    if (currentEditor === 'items') {
        return data.name && data.label;
    } else if (currentEditor === 'vehicles') {
        return data.model && data.name;
    } else if (currentEditor === 'jobs' || currentEditor === 'gangs') {
        return data.name && data.label && Object.keys(data.grades).length > 0;
    }
    return false;
}

// ════════════════════════════════════════════════════════════
// QUICK ADD
// ════════════════════════════════════════════════════════════

function openQuickAdd(type, name, label, data) {
    currentEditor = type + 's';
    currentEditEntry = null;
    
    $('#editor-panel').removeClass('hidden');
    switchEditor(currentEditor);
    
    setTimeout(() => {
        $('#modal-title').text(`Quick Add ${capitalize(type)}`);
        generateForm(currentEditor, data || {name: name, label: label});
        
        // Pre-fill quick add data
        if (type === 'item') {
            $('#item-name').val(name || '');
            $('#item-label').val(label || '');
        } else if (type === 'vehicle' && data) {
            $('#vehicle-model').val(data.model || '');
            $('#vehicle-name').val(data.name || '');
            $('#vehicle-brand').val(data.brand || '');
            $('#vehicle-category').val(data.category || 'sedans');
        }
        
        $('#edit-modal').removeClass('hidden');
    }, 500);
}

// ════════════════════════════════════════════════════════════
// PREVIEW VEHICLE
// ════════════════════════════════════════════════════════════

function previewVehicle(model) {
    $.post('https://cm-core/previewVehicle', JSON.stringify({model: model}));
}

// ════════════════════════════════════════════════════════════
// IMPORT/EXPORT
// ════════════════════════════════════════════════════════════

function showImportDialog() {
    $('#import-modal').removeClass('hidden');
}

function closeImportModal() {
    $('#import-modal').addClass('hidden');
    $('#import-data').val('');
}

function importFromQBCore() {
    const data = $('#import-data').val();
    
    if (!data) {
        showNotification('Please paste QBCore config data', 'error');
        return;
    }
    
    try {
        const parsed = JSON.parse(data);
        
        $.post('https://cm-core/importFromQBCore', JSON.stringify({
            type: capitalize(currentEditor),
            data: parsed
        }), function(result) {
            if (result.success) {
                closeImportModal();
                loadEntries(currentEditor);
            }
        });
    } catch (e) {
        showNotification('Invalid JSON format', 'error');
    }
}

function importFromJSON() {
    const data = $('#import-data').val();
    
    if (!data) {
        showNotification('Please paste JSON data', 'error');
        return;
    }
    
    try {
        const parsed = JSON.parse(data);
        currentEntries = parsed;
        renderEntries(currentEditor, parsed);
        closeImportModal();
        showNotification('Data imported (not saved yet)', 'success');
    } catch (e) {
        showNotification('Invalid JSON format', 'error');
    }
}

function importFromCSV() {
    showNotification('CSV import coming soon', 'info');
}

function exportConfig() {
    const dataStr = JSON.stringify(currentEntries, null, 2);
    
    // Copy to clipboard
    navigator.clipboard.writeText(dataStr).then(() => {
        showNotification('Configuration copied to clipboard', 'success');
    }).catch(() => {
        showNotification('Failed to copy to clipboard', 'error');
    });
}

function processImport() {
    importFromJSON();
}

// ════════════════════════════════════════════════════════════
// MODAL FUNCTIONS
// ════════════════════════════════════════════════════════════

function closeModal() {
    $('#edit-modal').addClass('hidden');
    currentEditEntry = null;
}

// ════════════════════════════════════════════════════════════
// UTILITY FUNCTIONS
// ════════════════════════════════════════════════════════════

function capitalize(str) {
    return str.charAt(0).toUpperCase() + str.slice(1);
}

function formatMoney(num) {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function showNotification(message, type) {
    console.log(`[${type.toUpperCase()}] ${message}`);
}