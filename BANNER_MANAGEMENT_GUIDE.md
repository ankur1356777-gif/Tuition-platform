# Banner Management System - Admin Guide

## Overview
The banner management system allows administrators to create, edit, and manage promotional banners that appear on the mobile app's landing page.

## Accessing Banner Management

1. **Login to Admin Panel**: Navigate to `https://submissions.lucknows.shop/login`
2. **Navigate to Banners**: Click on "Banners" in the admin sidebar menu
3. **URL**: Direct access at `https://submissions.lucknows.shop/admin/banners`

## Features

### 1. View All Banners
- See all banners in a table format
- View banner image thumbnails
- Check status (Active/Inactive)
- See display order
- Quick actions (Edit, Delete, Toggle Status)

### 2. Create New Banner

**Steps:**
1. Click "Add New Banner" button
2. Fill in the form:
   - **Image** (Required): Upload banner image
     - Recommended size: 1200x400px (3:1 ratio)
     - Max file size: 2MB
     - Formats: JPEG, PNG, JPG, GIF
   
   - **Title** (Optional): Descriptive title for internal reference
   
   - **Link URL** (Optional): URL to open when banner is clicked
     - Example: `https://example.com/promotion`
   
   - **Type** (Required):
     - `Home Slider`: Appears in the main carousel
     - `Promotion`: Special promotional banner
   
   - **Display Order** (Required): Number (0, 1, 2, etc.)
     - Lower numbers appear first
     - Use this to control banner sequence
   
   - **Active**: Check to make banner visible in app

3. Click "Create Banner"

### 3. Edit Banner

**Steps:**
1. Click the edit icon (pencil) next to any banner
2. Modify any fields
3. Optionally upload a new image (leave empty to keep current)
4. Click "Update Banner"

### 4. Delete Banner

**Steps:**
1. Click the delete icon (trash) next to any banner
2. Confirm deletion
3. Banner and its image will be permanently removed

### 5. Toggle Banner Status

**Quick Method:**
- Click the "Active" or "Inactive" button in the status column
- Banner status will toggle immediately
- Active banners appear in the app
- Inactive banners are hidden

## Best Practices

### Image Guidelines
- **Aspect Ratio**: Use 3:1 (e.g., 1200x400, 1500x500)
- **Quality**: High-resolution images for clarity
- **File Size**: Keep under 2MB for fast loading
- **Content**: Clear, readable text if any
- **Mobile-Friendly**: Test how it looks on small screens

### Organization
- **Ordering**: Use sequential numbers (0, 1, 2, 3...)
- **Naming**: Use descriptive titles for easy management
- **Active Status**: Only activate banners you want visible
- **Cleanup**: Delete old/unused banners regularly

### Performance
- **Limit Count**: Keep 3-5 active banners for best performance
- **Optimize Images**: Compress images before upload
- **Test**: Check app after adding/updating banners

## Technical Details

### Database Table: `banners`
- `id`: Auto-increment ID
- `image_url`: Path to uploaded image
- `title`: Optional banner title
- `link`: Optional click-through URL
- `type`: Banner type (home_slider, promo)
- `order`: Display order (integer)
- `is_active`: Active status (boolean)
- `created_at`, `updated_at`: Timestamps

### Storage
- Images are stored in: `storage/app/public/banners/`
- Accessible via: `https://submissions.lucknows.shop/storage/banners/filename.jpg`

### API Endpoint
- Public endpoint: `GET /api/public/landing`
- Returns active banners ordered by `order` field
- Used by mobile app to fetch banner data

## Troubleshooting

### Banner Not Showing in App
1. Check if banner is marked as "Active"
2. Verify image uploaded successfully
3. Check display order (lower numbers first)
4. Refresh app or clear app cache

### Image Upload Failed
1. Check file size (must be under 2MB)
2. Verify file format (JPEG, PNG, JPG, GIF only)
3. Ensure stable internet connection
4. Try compressing image and re-upload

### Banner Order Not Working
1. Use whole numbers (0, 1, 2, not 1.5)
2. Ensure no duplicate order numbers
3. Refresh the page after saving

## Support
For technical issues or questions, contact your system administrator.
