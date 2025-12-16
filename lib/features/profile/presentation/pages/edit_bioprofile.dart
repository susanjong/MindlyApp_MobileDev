import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import 'package:notesapp/core/utils/permission_helper.dart';

class EditAccountInformationScreen extends StatefulWidget {
  const EditAccountInformationScreen({super.key});

  @override
  State<EditAccountInformationScreen> createState() => _EditAccountInformationScreenState();
}

class _EditAccountInformationScreenState extends State<EditAccountInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _bioController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool _isLoadingData = true;
  File? _imageFile;
  String? _currentImageUrl;
  String _userEmail = '';
  bool _photoChanged = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await AuthService.getUserData();

      if (userData != null) {
        setState(() {
          _fullNameController.text = userData['displayName'] ?? '';
          _bioController.text = userData['bio'] ?? '';
          _currentImageUrl = userData['photoURL'];
          _userEmail = userData['email'] ?? '';
          _isLoadingData = false;
        });

        debugPrint('📥 User data loaded:');
        debugPrint('  - Name: ${_fullNameController.text}');
        debugPrint('  - Bio: ${_bioController.text}');
        debugPrint('  - Photo: ${_currentImageUrl != null ? "Has photo" : "No photo"}');
      } else {
        final displayName = AuthService.getUserDisplayName();
        final email = AuthService.getCurrentUserEmail();
        final photoURL = AuthService.getUserPhotoURL();

        setState(() {
          _fullNameController.text = displayName ?? '';
          _bioController.text = '';
          _currentImageUrl = photoURL;
          _userEmail = email ?? '';
          _isLoadingData = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingData = false;
      });
      debugPrint('❌ Error loading user data: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      bool hasPermission = false;

      if (source == ImageSource.camera) {
        hasPermission = await PermissionHelper.requestCameraPermission(context);
      } else {
        hasPermission = await PermissionHelper.requestGalleryPermission(context);
      }

      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Permission denied. Please enable it in settings.',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _photoChanged = true;
        });

        debugPrint('✅ Image selected: ${pickedFile.path}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                source == ImageSource.camera
                    ? 'Photo captured successfully!'
                    : 'Image selected successfully!',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to pick image: ${e.toString()}',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('❌ Error picking image: $e');
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Choose Profile Photo',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5784EB).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: Color(0xFF5784EB),
                    ),
                  ),
                  title: Text(
                    'Choose from Gallery',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  title: Text(
                    'Take a Photo',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                if (_currentImageUrl != null || _imageFile != null)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                    title: Text(
                      'Remove Photo',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _imageFile = null;
                        _currentImageUrl = null;
                        _photoChanged = true;
                      });

                      debugPrint('🗑️ Photo removed');

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Photo removed. Click Save to apply changes.',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: Colors.orange,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ✅ Convert image to Base64 string with compression
  Future<String?> _convertImageToBase64() async {
    if (_imageFile == null) return null;

    try {
      debugPrint('📸 Converting image to Base64...');
      final bytes = await _imageFile!.readAsBytes();
      final base64String = base64Encode(bytes);
      final fullBase64 = 'data:image/jpeg;base64,$base64String';

      final sizeInKB = (fullBase64.length * 0.75) / 1024;
      debugPrint('📏 Image size: ${sizeInKB.toStringAsFixed(2)} KB');

      if (sizeInKB > 900) {
        throw Exception('Image too large (${sizeInKB.toStringAsFixed(0)} KB). Please choose a smaller image.');
      }

      debugPrint('✅ Image converted successfully');
      return fullBase64;
    } catch (e) {
      debugPrint('❌ Error converting image to base64: $e');
      rethrow;
    }
  }

  /// ✅ Save profile with proper Firebase sync
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fullNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Full name cannot be empty',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('💾 Starting profile save...');
      debugPrint('  - Name: ${_fullNameController.text.trim()}');
      debugPrint('  - Bio: ${_bioController.text.trim()}');
      debugPrint('  - Photo changed: $_photoChanged');

      String? photoData;

      // ✅ Handle photo changes
      if (_photoChanged) {
        if (_imageFile != null) {
          // User selected a new image
          debugPrint('🖼️ Processing new image...');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Processing image...',
                      style: GoogleFonts.poppins(),
                    ),
                  ],
                ),
                duration: const Duration(seconds: 30),
                backgroundColor: const Color(0xFF5784EB),
              ),
            );
          }

          photoData = await _convertImageToBase64();
          if (photoData == null) {
            throw Exception('Failed to process image');
          }
          debugPrint('✅ New image processed');
        } else {
          // User removed photo - set to empty string untuk dihapus
          photoData = '';
          debugPrint('🗑️ Photo will be removed');
        }
      } else {
        // Photo not changed - keep existing
        photoData = _currentImageUrl;
        debugPrint('📌 Photo not changed, keeping existing');
      }

      // ✅ Update profile in Firebase
      debugPrint('📤 Updating Firebase...');
      await AuthService.updateUserProfile(
        displayName: _fullNameController.text.trim(),
        bio: _bioController.text.trim(),
        photoURL: photoData?.isEmpty == true ? '' : photoData,
      );

      debugPrint('✅ Firebase updated successfully');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).clearSnackBars();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profile updated successfully!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        // ✅ Return true to trigger refresh in profile page
        Navigator.pop(context, true);
        debugPrint('🔙 Returned to profile page with refresh trigger');
      }
    } catch (e) {
      debugPrint('❌ Error saving profile: $e');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).clearSnackBars();

        String errorMessage = 'Failed to update profile: ${e.toString()}';
        if (e.toString().contains('too large')) {
          errorMessage = 'Image is too large. Please choose a smaller image or reduce quality.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double inputWidth = screenWidth > 600 ? 400 : 340;
    final double buttonWidth = screenWidth > 600 ? 400 : 340;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          padding: const EdgeInsets.only(left: 16),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Account Information',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            height: 1,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoadingData
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 49),

                // Profile Picture with Edit Button
                Stack(
                  children: [
                    GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF5784EB),
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: _buildProfileImage(),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF5784EB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 17),

                Text(
                  _fullNameController.text.isEmpty
                      ? 'User'
                      : _fullNameController.text,
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  _userEmail,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF6A6E76),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1,
                  ),
                ),

                const SizedBox(height: 44),

                // Full Name Input
                Center(
                  child: Container(
                    width: inputWidth,
                    height: 40,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFFFFCFC),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 1, color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: TextFormField(
                      controller: _fullNameController,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        height: 1,
                      ),
                      decoration: InputDecoration(
                        hintText: "What's your full name?",
                        hintStyle: GoogleFonts.poppins(
                          color: const Color(0xFF6A6E76),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 14,
                        ),
                        isDense: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Full name cannot be empty';
                        }
                        return null;
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Bio Input
                Center(
                  child: Container(
                    width: inputWidth,
                    height: 40,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFFFFCFC),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 1, color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: TextFormField(
                      controller: _bioController,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        height: 1,
                      ),
                      decoration: InputDecoration(
                        hintText: "Edit bio in here.....",
                        hintStyle: GoogleFonts.poppins(
                          color: const Color(0xFF6A6E76),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 14,
                        ),
                        isDense: true,
                        suffixIcon: const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.edit_outlined,
                            color: Colors.black,
                            size: 15,
                          ),
                        ),
                        suffixIconConstraints: const BoxConstraints(
                          minWidth: 30,
                          minHeight: 40,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 80),

                // Save Button
                Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : PrimaryButton(
                    label: 'Save',
                    onPressed: _saveProfile,
                    enabled: !_isLoading,
                    showArrow: true,
                    width: buttonWidth,
                    height: 38,
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ Build profile image with proper preview
  Widget _buildProfileImage() {
    // Priority: Local file > Current Base64/URL > Default avatar
    if (_imageFile != null) {
      debugPrint('🖼️ Displaying local file');
      return Image.file(
        _imageFile!,
        fit: BoxFit.cover,
      );
    }

    if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      if (_currentImageUrl!.startsWith('data:image')) {
        debugPrint('🖼️ Displaying Base64 image');
        try {
          final base64String = _currentImageUrl!.split(',')[1];
          final bytes = base64Decode(base64String);
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('❌ Error displaying Base64: $error');
              return _buildDefaultAvatar();
            },
          );
        } catch (e) {
          debugPrint('❌ Error decoding base64 image: $e');
          return _buildDefaultAvatar();
        }
      }

      debugPrint('🖼️ Displaying network image');
      return Image.network(
        _currentImageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ Error loading network image: $error');
          return _buildDefaultAvatar();
        },
      );
    }

    debugPrint('🖼️ Displaying default avatar');
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: const Color(0xFF4CAF50),
      child: Center(
        child: Text(
          _fullNameController.text.isNotEmpty
              ? _fullNameController.text[0].toUpperCase()
              : 'U',
          style: GoogleFonts.poppins(
            fontSize: 40,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}