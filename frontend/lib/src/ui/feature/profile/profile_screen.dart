import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/helpers/constants.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_event.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_state.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is ProfileLoaded) {
              final user = state.user;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    _topBarSection(context),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.padding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _avatarSection(user.fullname),
                          SizedBox(height: AppSizes.spacingMedium),
                          _nameUserSection(user.fullname),
                          _activeStatusSection(),
                          SizedBox(height: AppSizes.spacingSmall),
                          Divider(color: AppColors.textSecondary),
                          SizedBox(height: AppSizes.spacingSmall),
                          if (user.bio.isNotEmpty) ...[
                            _bioSection(user.bio),
                            SizedBox(height: AppSizes.spacingMedium),
                          ],
                          _informationUserSection(user.email, user.dob),
                          SizedBox(height: AppSizes.spacingLarge),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is AuthFailure) {
              return Center(child: Text('Error: ${state.error}'));
            }
            context.read<AuthBloc>().add(GetUserProfileEvent());
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Padding _topBarSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              context.push('/edit-profile');
            },
            child: Text(
              "Edit",
              style: TextStyle(
                fontSize: AppSizes.fontSizeBody,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Center _avatarSection(String fullname) {
    return Center(
      child: CircleAvatar(
        radius: 50,
        backgroundColor: AppColors.primaryColor,
        child: Text(
          fullname.isNotEmpty ? fullname[0].toUpperCase() : 'U',
          style: TextStyle(
            fontSize: AppSizes.fontSizeTitle,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  Center _nameUserSection(String fullname) {
    return Center(
      child: Text(
        fullname.isEmpty ? 'Unknown User' : fullname, // Xử lý fullname rỗng
        style: TextStyle(
          fontSize: AppSizes.fontSizeTitle,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Center _activeStatusSection() {
    const isOnline = true;
    return Center(
      child: Text(
        isOnline ? "Online" : "Offline",
        style: TextStyle(
          fontSize: AppSizes.fontSizeBody,
          color: isOnline ? Colors.green : AppColors.textSecondary,
        ),
      ),
    );
  }

  Column _bioSection(String bio) {
    return Column(
      children: [
        Center(
          child: Text(
            "Bio",
            style: TextStyle(
              fontSize: AppSizes.fontSizeBody,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        SizedBox(height: AppSizes.spacingSmall),
        Center(
          child: Text(
            textAlign: TextAlign.center,
            bio,
            style: TextStyle(
              fontSize: AppSizes.fontSizeBody,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Column _informationUserSection(String email, DateTime? dob) {
    final dateFormatter = DateFormat('dd/MM/yyyy');
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Email",
              style: TextStyle(
                fontSize: AppSizes.fontSizeBody,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              email.isEmpty ? 'No email' : email, // Xử lý email rỗng
              style: TextStyle(
                fontSize: AppSizes.fontSizeBody,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        if (dob != null) ...[
          SizedBox(height: AppSizes.spacingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Dob",
                style: TextStyle(
                  fontSize: AppSizes.fontSizeBody,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                dateFormatter.format(dob),
                style: TextStyle(
                  fontSize: AppSizes.fontSizeBody,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}