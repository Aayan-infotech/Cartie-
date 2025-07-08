import 'dart:io';

import 'package:cartie/core/api_services/call_helper.dart';
import 'package:cartie/core/theme/app_theme.dart';
import 'package:cartie/core/utills/app_colors.dart';
import 'package:cartie/core/utills/branded_primary_button.dart';
import 'package:cartie/core/utills/branded_text_filed.dart';
import 'package:cartie/core/utills/constant.dart';
import 'package:cartie/core/utills/mobile_number_field.dart';
import 'package:cartie/core/utills/shared_pref_util.dart';
import 'package:cartie/features/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:http_parser/http_parser.dart';

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
  bool isChange = false;

  @override
  void initState() {
    super.initState();
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    _nameController = TextEditingController(text: userViewModel.user.name);
    _emailController = TextEditingController(text: userViewModel.user.email);
    final fullNumber = userViewModel.user.mobile ?? '';
    final phoneWithoutCountryCode =
        fullNumber.startsWith('+1') ? fullNumber.substring(2) : fullNumber;
    _phoneController = TextEditingController(text: phoneWithoutCountryCode);
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

  Future<void> _uploadProfilePicture(
      BuildContext context, File imageFile) async {
    try {
      final String userId = SharedPrefUtil.getValue(userIdPref, "") as String;
      final String accessToken =
          SharedPrefUtil.getValue(accessTokenPref, "") as String;
      final String url = '${CallHelper.baseUrl}api/users/profileImage/$userId';

      print("url: $url");

      Dio dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $accessToken';

      final fileName = imageFile.path.split('/').last;
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      final mediaType = MediaType.parse(mimeType);

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: mediaType,
        ),
      });

      print("Uploading image: $fileName");

      final response = await dio.put(
        url,
        data: formData, // ✅ must be whole FormData
      );

      print("Response data: ${response.data}");
      print("Status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final userProvider = Provider.of<UserViewModel>(context, listen: false);
        await userProvider.getUserProfile(accessToken, userId);
        AppTheme.showSuccessDialog(
            context, "Profile image updated successfully!",
            onConfirm: () async {});
      } else {
        AppTheme.showErrorDialog(context, "Failed to upload image",
            onConfirm: () {});
      }
    } catch (e) {
      AppTheme.showErrorDialog(context, "Error: ${e.toString()}",
          onConfirm: () {});
    }
  }

  void _changeProfilePicture() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      // Upload to server
      await _uploadProfilePicture(context, _profileImage!);
    }
  }

  void _saveProfile() async {
    final userProvider = Provider.of<UserViewModel>(context, listen: false);
    final updatedName = _nameController.text.trim();
    final updatedAddress = _addressController.text.trim();

    final response =
        await userProvider.updateProfile(updatedName, updatedAddress);

    if (response.success) {
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
      AppTheme.showErrorDialog(context, response.message, onConfirm: () {});
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
        title: Text("Profile Information", style: theme.textTheme.displayLarge),
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
                                  : (userProvider.user.image != null
                                      ? NetworkImage(userProvider.user.image)
                                          as ImageProvider
                                      : null),
                              child: (_profileImage == null &&
                                      userProvider.user.image == null)
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
                      onChanged: (value) {
                        setState(() {
                          isChange = true;
                        });
                      },
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
                      initialCountryCode: 'US',
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
                      isEnabled: !userProvider.isLoading && isChange,
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
