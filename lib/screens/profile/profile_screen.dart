import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(); // Always required
  final _newPasswordController = TextEditingController(); // Optional

  bool _isEditing = false;
  bool _isLoading = false;

  // Avatar related
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploadingAvatar = false;
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      _nameController.text = authProvider.user!.name;
      _emailController.text = authProvider.user!.email;

      // Fetch latest avatar data
      await authProvider.fetchUserAvatar();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Current password is always required for any changes
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Current password is required to save any changes'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate new password if provided
    if (_newPasswordController.text.isNotEmpty &&
        _newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New password must be at least 6 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password:
            _passwordController.text, // Current password (always required)
        newPassword: _newPasswordController.text.isNotEmpty
            ? _newPasswordController.text
            : null, // Optional new password
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        setState(() {
          _isEditing = false;
        });

        // Clear password fields after successful update
        _passwordController.clear();
        _newPasswordController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Failed to update profile. Please check your password.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
    });

    // Reload original user data
    _loadUserData();

    // Clear password fields
    _passwordController.clear();
    _newPasswordController.clear();
  }

  // Avatar Methods
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );

      if (pickedFile != null) {
        print('Picked file: ${pickedFile.name}, MIME: ${pickedFile.mimeType}');
        await _uploadAvatarFromXFile(pickedFile);
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );

      if (pickedFile != null) {
        print('Captured photo: ${pickedFile.name}, MIME: ${pickedFile.mimeType}');
        await _uploadAvatarFromXFile(pickedFile);
      }
    } catch (e) {
      print('Error taking photo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking photo: $e')),
      );
    }
  }

  Future<void> _uploadAvatarFromXFile(XFile xFile) async {
    setState(() {
      _isUploadingAvatar = true;
    });

    try {
      // Get file information
      final String fileName = xFile.name.toLowerCase();
      String? mimeType = xFile.mimeType;
      
      print('File details:');
      print('- File name: $fileName');
      print('- Original MIME type: $mimeType');
      
      // Validate image type - check both MIME type and file extension
      bool isValidImage = false;
      String finalMimeType = '';
      
      // Check MIME type first
      if (mimeType != null && mimeType.startsWith('image/')) {
        const allowedMimeTypes = [
          'image/jpeg',
          'image/jpg', 
          'image/png',
          'image/webp'
        ];
        if (allowedMimeTypes.contains(mimeType)) {
          isValidImage = true;
          finalMimeType = mimeType;
        }
      }
      
      // If MIME type check failed, try file extension as fallback
      if (!isValidImage) {
        if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) {
          isValidImage = true;
          finalMimeType = 'image/jpeg';
        } else if (fileName.endsWith('.png')) {
          isValidImage = true;
          finalMimeType = 'image/png';
        } else if (fileName.endsWith('.webp')) {
          isValidImage = true;
          finalMimeType = 'image/webp';
        }
      }
      
      if (!isValidImage) {
        throw Exception('Only JPEG, PNG, and WebP images are allowed!');
      }

      final bytes = await xFile.readAsBytes();
      
      // Validate file size (optional - limit to 5MB)
      if (bytes.length > 5 * 1024 * 1024) {
        throw Exception('Image size must be less than 5MB');
      }

      // Create a proper filename with correct extension based on final MIME type
      String extension;
      switch (finalMimeType) {
        case 'image/jpeg':
        case 'image/jpg':
          extension = '.jpg';
          break;
        case 'image/png':
          extension = '.png';
          break;
        case 'image/webp':
          extension = '.webp';
          break;
        default:
          extension = '.jpg'; // fallback
      }

      // Generate a unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newFileName = 'avatar_$timestamp$extension';

      print('Uploading avatar:');
      print('- Final MIME Type: $finalMimeType');
      print('- New File Name: $newFileName');
      print('- File Size: ${bytes.length} bytes');

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success =
          await authProvider.uploadAvatarBytes(bytes, newFileName, finalMimeType);

      setState(() {
        _isUploadingAvatar = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update avatar')),
        );
      }
    } catch (e) {
      setState(() {
        _isUploadingAvatar = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading avatar: $e')),
      );
    }
  }

  Future<void> _deleteAvatar() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Avatar'),
          content: const Text('Are you sure you want to delete your avatar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final success = await authProvider.deleteAvatar();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar deleted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete avatar')),
        );
      }
    }
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Select Avatar Image',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Supported formats: JPEG, PNG, WebP\nMax size: 1000x1000 pixels',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _takePhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage();
                },
              ),
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  if (authProvider.user?.avatar != null) {
                    return ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: const Text('Delete Avatar',
                          style: TextStyle(color: Colors.red)),
                      onTap: () {
                        Navigator.of(context).pop();
                        _deleteAvatar();
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatarSection(AuthProvider authProvider) {
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: _showAvatarOptions,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!, width: 2),
              ),
              child: ClipOval(
                child: _isUploadingAvatar
                    ? const Center(child: CircularProgressIndicator())
                    : authProvider.user?.avatar != null
                        ? CachedNetworkImage(
                            imageUrl: authProvider.getAvatarUrl()!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                          ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              await authProvider.fetchUserAvatar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile refreshed')),
              );
            },
          ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.user == null) {
            return const Center(
              child: Text('No user data available'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Picture Section
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildAvatarSection(authProvider),
                      const SizedBox(height: 16),
                      Text(
                        authProvider.user!.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        authProvider.user!.email,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (authProvider.isAdmin)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Admin',
                            style: TextStyle(
                              color: Colors.orange[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Profile Form
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            enabled: _isEditing,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: const Icon(Icons.person),
                              border: _isEditing
                                  ? const OutlineInputBorder()
                                  : InputBorder.none,
                              filled: !_isEditing,
                              fillColor: _isEditing ? null : Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            enabled: _isEditing, // Now email can be edited
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(Icons.email),
                              border: _isEditing
                                  ? const OutlineInputBorder()
                                  : InputBorder.none,
                              filled: !_isEditing,
                              fillColor: _isEditing ? null : Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          if (_isEditing) ...[
                            const Text(
                              'Security Verification',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '⚠️ Current password is required to save any changes',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Current Password *',
                                prefixIcon:
                                    Icon(Icons.lock_outline, color: Colors.red),
                                border: OutlineInputBorder(),
                                hintText: 'Enter your current password',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Current password is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Change Password (Optional)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _newPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'New Password (Optional)',
                                prefixIcon: Icon(Icons.lock),
                                border: OutlineInputBorder(),
                                hintText:
                                    'Leave empty to keep current password',
                              ),
                            ),
                          ],
                          if (_isEditing) ...[
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _cancelEdit,
                                    child: const Text('Cancel'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _saveProfile,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'Save Changes',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Quick Actions
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      ListTile(
                        leading:
                            const Icon(Icons.receipt_long, color: Colors.blue),
                        title: const Text('My Orders'),
                        subtitle: const Text('View your order history'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => Navigator.pushNamed(context, '/orders'),
                      ),
                      const Divider(height: 1),
                      if (authProvider.isAdmin)
                        ListTile(
                          leading: const Icon(Icons.admin_panel_settings,
                              color: Colors.orange),
                          title: const Text('Admin Dashboard'),
                          subtitle: const Text('Manage users and orders'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () => Navigator.pushNamed(context, '/admin'),
                        ),
                      if (authProvider.isAdmin) const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text('Logout'),
                        subtitle: const Text('Sign out of your account'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _showLogoutDialog(context, authProvider),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                authProvider.logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child:
                  const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
