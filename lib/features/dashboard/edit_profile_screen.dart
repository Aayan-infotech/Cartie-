import 'dart:io';
import 'package:cartie/core/api_services/server_calls/auth_api.dart';
import 'package:cartie/core/theme/app_theme.dart';
import 'package:cartie/core/utills/constant.dart';
import 'package:cartie/core/utills/mobile_number_field.dart';
import 'package:cartie/core/utills/shared_pref_util.dart';
import 'package:cartie/core/utills/user_context_data.dart';
import 'package:cartie/features/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cartie/core/utills/app_colors.dart';
import 'package:cartie/core/utills/branded_primary_button.dart';
import 'package:cartie/core/utills/branded_text_filed.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  File? _profileImage;

  @override
  void initState() {
    super.initState();
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    _nameController = TextEditingController(text: userViewModel.user.name);
    _emailController = TextEditingController(text: userViewModel.user.email);
    _phoneController = TextEditingController(text: userViewModel.user.mobile);
    _addressController =
        TextEditingController(text: userViewModel.user.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _changeProfilePicture() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  void _saveProfile() async {
    final userProvider = Provider.of<UserViewModel>(context, listen: false);
    final updatedName = _nameController.text.trim();
    final updatedAddress = _addressController.text.trim();

    final provider = Provider.of<UserViewModel>(context, listen: false);
    final response = await provider.updateProfile(updatedName, updatedAddress);

    // Close loading indicator

    if (response.success) {
      // Update userProvider (optional if userViewModel fetches data from backend again)

      AppTheme.showSuccessDialog(context, "Profile updated successfully!",
          onConfirm: () async {
        userProvider.user.name = updatedName;
        userProvider.user.address = updatedAddress;

        String userId = SharedPrefUtil.getValue(userIdPref, "") as String;
        String accessToken =
            SharedPrefUtil.getValue(accessTokenPref, "") as String;

        await userProvider.getUserProfile(accessToken, userId);
      });
    } else {
      AppTheme.showErrorDialog(context, response.message,
          onConfirm: () async {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text("Profile Information"),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: theme.appBarTheme.elevation,
        iconTheme: theme.iconTheme,
        titleTextStyle: theme.textTheme.displayLarge,
      ),
      body: Consumer<UserViewModel>(
        builder: (context, userProvider, child) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: colorScheme.primary, width: 3),
                            ),
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.grey.withOpacity(0.2),
                              backgroundImage: _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : null,
                              child: _profileImage == null
                                  ? Icon(Icons.person,
                                      size: 60, color: colorScheme.onPrimary)
                                  : null,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: _changeProfilePicture,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt,
                                    size: 20, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    BrandedTextField(
                      controller: _nameController,
                      labelText: "Name",
                      isEnabled: true,
                      prefix: Icon(Icons.person_outline,
                          color: theme.textTheme.bodyLarge?.color),
                    ),
                    const SizedBox(height: 20),
                    BrandedTextField(
                      controller: _emailController,
                      labelText: "Email",
                      keyboardType: TextInputType.emailAddress,
                      isEnabled: false,
                      prefix: Icon(Icons.email_outlined,
                          color: theme.textTheme.bodyLarge?.color),
                    ),
                    const SizedBox(height: 20),
                    CustomPhoneTextField(
                      initialCountryCode: 'IN',
                      labelText: 'Phone Number',
                      isEnabled: false,
                      controller: _phoneController,
                      onChanged: (phone) {
                        _phoneController.text = phone.completeNumber;
                      },
                    ),
                    const SizedBox(height: 20),
                    BrandedTextField(
                      controller: _addressController,
                      labelText: "Address",
                      maxLines: 3,
                      isEnabled: false,
                      prefix: Icon(Icons.location_on_outlined,
                          color: theme.textTheme.bodyLarge?.color),
                    ),
                    const SizedBox(height: 32),
                    BrandedPrimaryButton(
                      isEnabled: !userProvider.isLoading,
                      name: "Save Changes",
                      onPressed: _saveProfile,
                    ),
                  ],
                ),
              ),
              if (userProvider.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
