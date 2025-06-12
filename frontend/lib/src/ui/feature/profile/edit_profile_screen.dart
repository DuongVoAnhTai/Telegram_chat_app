


import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/helpers/constants.dart';
import 'package:frontend/core/services/cloudinary.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_event.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_state.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String? _profilePicUrl;
  DateTime? _selectedDob;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(GetUserProfileEvent());
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _isUploading = true;
      });
      try {
        final imageFile = File(pickedFile.path);
        final uploadedUrl = await CloudinaryHelper.uploadImage(imageFile);
        setState(() {
          _profilePicUrl = uploadedUrl;
          _isUploading = false;
        });
      } catch (e) {
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDob) {
      final localDate = DateTime(picked.year, picked.month, picked.day + 1);
      setState(() {
        _selectedDob = localDate;
        _dobController.text = "${localDate.day - 1}/${localDate.month}/${localDate.year}";
      });
    }
  }

  void _saveProfile() {
    context.read<AuthBloc>().add(UpdateProfileEvent(
      fullname: _usernameController.text.isNotEmpty ? _usernameController.text : null,
      bio: _bioController.text.isNotEmpty ? _bioController.text : null,
      dob: _selectedDob,
      profilePic: _profilePicUrl,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          _usernameController.text = state.user.fullname ?? '';
          _bioController.text = state.user.bio ?? '';
          _profilePicUrl = state.user.profilePic.isNotEmpty ? state.user.profilePic : null;
          if (state.user.dob != null) {
            _selectedDob = state.user.dob;
            _dobController.text =
                "${_selectedDob!.day}/${_selectedDob!.month}/${_selectedDob!.year}";
          } else {
            _selectedDob = null;
            _dobController.clear();
          }
        } else if (state is ProfileUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          context.pop();
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: _buildAppBar(context),
          body: state is AuthLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfilePhotoSection(),
                      _buildUsernameSection(),
                      SizedBox(height: AppSizes.spacingMedium),
                      _buildBioSection(),
                      SizedBox(height: AppSizes.spacingMedium),
                      _buildDateOfBirthSection(context),
                      SizedBox(height: AppSizes.spacingSmall),
                    ],
                  ),
                ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      elevation: 0,
      leadingWidth: 90,
      leading: _buildCancelButton(context),
      actions: [_buildDoneButton()],
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () => context.pop(),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
      ),
      child: Text(
        "Cancel",
        style: TextStyle(
            fontSize: AppSizes.fontSizeBody, color: AppColors.primaryColor),
      ),
    );
  }

  Widget _buildDoneButton() {
    return TextButton(
      onPressed: _saveProfile,
      child: Text(
        "Done",
        style: TextStyle(
            fontSize: AppSizes.fontSizeBody, color: AppColors.primaryColor),
      ),
    );
  }

  Widget _buildProfilePhotoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingMedium),
      child: Center(
        child: Column(
          children: [
            GestureDetector(
              onTap: _isUploading ? null : _pickAndUploadImage,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                    backgroundImage: _profilePicUrl != null
                        ? NetworkImage(_profilePicUrl!)
                        : null,
                    child: _profilePicUrl == null && !_isUploading
                        ? Icon(Icons.camera_alt,
                            size: 40, color: AppColors.primaryColor)
                        : null,
                  ),
                  if (_isUploading)
                    CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                    ),
                ],
              ),
            ),
            Text(
              "Set New Photo",
              style: TextStyle(
                  fontSize: AppSizes.fontSizeBody,
                  color: AppColors.primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsernameSection() {
    return _buildTextFieldSection(
      "Username",
      _usernameController,
      "Enter your name and add an optional profile photo.",
    );
  }

  Widget _buildBioSection() {
    return _buildTextFieldSection(
      "Bio",
      _bioController,
      "You can add a few lines about yourself.",
      maxLines: 3,
    );
  }

  Widget _buildDateOfBirthSection(BuildContext context) {
    return _buildReadOnlyTextField(
      "Date of Birth",
      _dobController,
      "Only your contacts can see your birthday.",
      onTap: () => _selectDate(context),
    );
  }

  Widget _buildTextFieldSection(
      String hint, TextEditingController controller, String helperText,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.white,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                borderSide: BorderSide(color: AppColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                borderSide: BorderSide(color: AppColors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                borderSide: BorderSide(color: AppColors.primaryColor),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: AppSizes.paddingOnly),
            child: Text(
              helperText,
              style: TextStyle(
                  fontSize: AppSizes.fontSizeSubBody,
                  color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyTextField(
      String hint, TextEditingController controller, String helperText,
      {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            readOnly: true,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.white,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                borderSide: BorderSide(color: AppColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                borderSide: BorderSide(color: AppColors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                borderSide: BorderSide(color: AppColors.primaryColor),
              ),
              suffixIcon:
                  Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primaryColor),
            ),
            onTap: onTap,
          ),
          Padding(
            padding: EdgeInsets.only(left: AppSizes.paddingOnly),
            child: Text(
              helperText,
              style: TextStyle(
                  fontSize: AppSizes.fontSizeSubBody,
                  color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}