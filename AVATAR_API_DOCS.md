# Avatar Upload and Management API Documentation

## Overview
This API provides complete avatar management functionality for user profiles, including upload, retrieval, and deletion of user avatars.

## Features
- ✅ Avatar upload with file validation
- ✅ Get current user's avatar
- ✅ Get any user's avatar by ID
- ✅ Delete user's avatar
- ✅ Automatic old avatar cleanup
- ✅ File type validation (JPEG, PNG, GIF, WebP)
- ✅ File size limits (5MB max)
- ✅ Secure file storage

## API Endpoints

### 1. Upload Avatar
**POST** `/api/v1/users/avatar`

**Authentication:** Required (JWT Token)

**Content-Type:** `multipart/form-data`

**Request Body:**
- `avatar` (file): Image file (JPEG, PNG, GIF, WebP, max 5MB)

**Response Success (200):**
```json
{
    "status": "success",
    "data": {
        "message": "Avatar uploaded successfully",
        "avatar": "1640001564164-profile.jpg",
        "avatarUrl": "/api/v1/avatars/1640001564164-profile.jpg",
        "user": {
            "name": "John Doe",
            "email": "john@example.com",
            "avatar": "1640001564164-profile.jpg"
        }
    }
}
```

**Error Responses:**
- `400`: No file provided or invalid file type
- `401`: Unauthorized (invalid token)
- `404`: User not found
- `413`: File too large
- `500`: Server error

### 2. Get Current User's Avatar
**GET** `/api/v1/users/avatar`

**Authentication:** Required (JWT Token)

**Response Success (200):**
```json
{
    "status": "success",
    "data": {
        "avatar": "1640001564164-profile.jpg",
        "avatarUrl": "/api/v1/avatars/1640001564164-profile.jpg",
        "user": {
            "name": "John Doe",
            "email": "john@example.com"
        }
    }
}
```

**Error Responses:**
- `401`: Unauthorized
- `404`: User not found or no avatar exists

### 3. Get User Avatar by ID (Public)
**GET** `/api/v1/users/avatar/:userId`

**Authentication:** Not required

**Parameters:**
- `userId`: MongoDB ObjectId of the user

**Response Success (200):**
```json
{
    "status": "success",
    "data": {
        "avatar": "1640001564164-profile.jpg",
        "avatarUrl": "/api/v1/avatars/1640001564164-profile.jpg",
        "userName": "John Doe"
    }
}
```

### 4. Delete Avatar
**DELETE** `/api/v1/users/avatar`

**Authentication:** Required (JWT Token)

**Response Success (200):**
```json
{
    "status": "success",
    "data": {
        "message": "Avatar deleted successfully",
        "user": {
            "name": "John Doe",
            "email": "john@example.com",
            "avatar": null
        }
    }
}
```

### 5. Access Avatar Files (Static)
**GET** `/api/v1/avatars/:filename`

**Authentication:** Not required

**Description:** Direct access to avatar image files

**Example:** `http://localhost:3000/api/v1/avatars/1640001564164-profile.jpg`

## File Upload Specifications

### Supported File Types
- JPEG (.jpg, .jpeg)
- PNG (.png)
- GIF (.gif)
- WebP (.webp)

### File Size Limits
- Maximum file size: 5MB
- Recommended dimensions: 300x300px to 1000x1000px

### File Storage
- Avatars are stored in: `./Mvc/avatars/`
- Files are renamed with timestamp prefix to avoid conflicts
- Old avatars are automatically deleted when new ones are uploaded

## Frontend Integration Examples

### HTML Form
```html
<form enctype="multipart/form-data">
    <input type="file" name="avatar" accept="image/*" required>
    <button type="submit">Upload Avatar</button>
</form>
```

### JavaScript/Fetch API
```javascript
async function uploadAvatar(file, token) {
    const formData = new FormData();
    formData.append('avatar', file);
    
    const response = await fetch('/api/v1/users/avatar', {
        method: 'POST',
        headers: {
            'Authorization': `Bearer ${token}`
        },
        body: formData
    });
    
    return response.json();
}
```

### React Example
```javascript
import React, { useState } from 'react';

function AvatarUpload({ token }) {
    const [file, setFile] = useState(null);
    const [avatarUrl, setAvatarUrl] = useState('');
    
    const handleUpload = async (e) => {
        e.preventDefault();
        if (!file) return;
        
        const formData = new FormData();
        formData.append('avatar', file);
        
        try {
            const response = await fetch('/api/v1/users/avatar', {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${token}`
                },
                body: formData
            });
            
            const result = await response.json();
            if (result.status === 'success') {
                setAvatarUrl(result.data.avatarUrl);
            }
        } catch (error) {
            console.error('Upload failed:', error);
        }
    };
    
    return (
        <div>
            <form onSubmit={handleUpload}>
                <input 
                    type="file" 
                    accept="image/*"
                    onChange={(e) => setFile(e.target.files[0])}
                />
                <button type="submit">Upload Avatar</button>
            </form>
            
            {avatarUrl && (
                <img 
                    src={`http://localhost:3000${avatarUrl}`} 
                    alt="Avatar" 
                    style={{width: '100px', height: '100px', borderRadius: '50%'}}
                />
            )}
        </div>
    );
}
```

## Security Considerations

1. **File Type Validation**: Only image files are allowed
2. **File Size Limits**: 5MB maximum to prevent abuse
3. **Authentication**: Upload, get, and delete require valid JWT tokens
4. **File Path Security**: Files are stored with safe naming conventions
5. **Error Handling**: Uploaded files are cleaned up on errors

## Error Handling

All endpoints return standardized error responses:

```json
{
    "status": "fail" | "error",
    "data": {
        "message": "Error description"
    }
}
```

Common error scenarios are handled gracefully:
- Invalid file types
- Missing files
- File size exceeded
- User not found
- Authentication failures
- File system errors

## Testing

Use the provided `avatar-test.js` file for testing the avatar functionality. Remember to:

1. Start the server: `npm test` or `npm start`
2. Create a user account and get a JWT token
3. Use a valid image file for testing
4. Test all endpoints in sequence

## Database Schema

The avatar field is added to the User model:

```javascript
{
    name: String,
    email: String,
    password: String,
    userType: ObjectId,
    googleId: String,
    avatar: String  // Filename of the avatar image
}
```

## Folder Structure

```
Mvc/
├── avatars/              # Avatar storage directory
├── Controllers/
│   ├── usercontroller.js # Avatar upload logic
│   └── multers.js       # File upload configuration
├── models/
│   └── usermodel.js     # User schema with avatar field
└── routs/
    └── userrouts.js     # Avatar routes
```
