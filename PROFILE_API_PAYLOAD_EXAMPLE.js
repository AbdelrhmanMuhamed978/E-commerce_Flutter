// Example payload that will be sent to the backend
// When user edits profile with the following form data:

// Name: "abdelrhman"
// Email: "abdo@abdo.com"  
// Current Password: "0123456789" (always required)
// New Password: "" (empty = no password change)

const examplePayload1 = {
    "name": "abdelrhman",
    "email": "abdo@abdo.com",
    "password": "0123456789",  // Current password (always required)
    "newPassword": ""          // Empty string = keep current password
};

// If user wants to change password:
// Name: "abdelrhman"
// Email: "abdo@abdo.com"
// Current Password: "0123456789" 
// New Password: "newpassword123"

const examplePayload2 = {
    "name": "abdelrhman",
    "email": "abdo@abdo.com",
    "password": "0123456789",    // Current password (always required)
    "newPassword": "newpassword123" // New password to set
};

/* 
API Endpoint: PATCH /users/profile
Headers: {
  "Content-Type": "application/json",
  "Authorization": "Bearer <jwt_token>"
}

Security Rules:
1. Current password is ALWAYS required for ANY change
2. Cannot save without entering current password
3. Can change name, email, or password
4. New password is optional (empty string = no change)
5. If newPassword is provided, it must be at least 6 characters
*/
