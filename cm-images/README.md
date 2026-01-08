# CM-Images

Centralized image storage for CM-Core framework resources.

## 📁 Directory Structure

- **items/** - Item images for inventory systems (512x512 recommended)
- **vehicles/** - Vehicle thumbnail images (800x600 recommended)
- **jobs/** - Job badge/icon images (256x256 recommended)
- **gangs/** - Gang logo images (256x256 recommended)
- **weapons/** - Weapon images (512x512 recommended)
- **clothing/** - Clothing preview images (512x512 recommended)
- **misc/** - Miscellaneous images

## 🖼️ Image Guidelines

### Format
- **Preferred**: PNG with transparency
- **Alternative**: WebP for smaller file sizes, JPG for photos
- **Avoid**: GIF (use PNG for static images)

### Size Recommendations
- **Items/Weapons**: 512x512px (max 200KB each)
- **Vehicles**: 800x600px or 16:9 ratio
- **Jobs/Gangs**: 256x256px
- **Clothing**: 512x512px

### Naming Convention
- Use lowercase
- Use underscores instead of spaces
- Match spawn names for items/weapons/vehicles
- Examples:
  - `weapon_pistol.png`
  - `water_bottle.png`
  - `adder.png`
  - `police_badge.png`

## 🔧 Usage

### In CM-Core Resources
```lua
-- Get image path
local itemImage = 'nui://cm-images/items/water_bottle.png'
local vehicleImage = 'nui://cm-images/vehicles/adder.png'
local jobIcon = 'nui://cm-images/jobs/police.png'
```

### In HTML/NUI
```html
<img src="nui://cm-images/items/sandwich.png" alt="Sandwich">
```

### In CSS
```css
.item-icon {
    background-image: url('nui://cm-images/items/water.png');
}
```

## ➕ Adding New Images

1. Add your image to the appropriate folder
2. Ensure it follows naming conventions
3. Run `refresh` or `ensure cm-images` in server console
4. No server restart required!

## 🎨 Placeholder Image

If an image is missing, use:
```
nui://cm-images/misc/placeholder.png
```

## 📦 Optimization Tips

- Compress images before adding (use tools like TinyPNG)
- Use WebP format for smaller file sizes
- Batch resize images to recommended dimensions
- Remove metadata from images

## 🔄 Hot Reload

To reload images without restarting:
```
refresh
ensure cm-images
```

Or simply:
```
restart cm-images
```