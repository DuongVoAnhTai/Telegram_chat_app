import 'package:flutter/material.dart';
import 'package:frontend/core/helpers/constants.dart';

// Định nghĩa một lớp User đơn giản để lưu thông tin (sẽ mở rộng khi có backend)
class User {
  final String name;
  final String initial; // Ký tự đầu để hiển thị trong CircleAvatar

  User({required this.name, required this.initial});
}

class ListChatScreen extends StatelessWidget {
  // Danh sách user mặc định
  final List<User> users = [
    User(name: "User 1", initial: "U1"),
    User(name: "User 2", initial: "U2"),
    User(name: "User 3", initial: "U3"),
    User(name: "User 4", initial: "U4"),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Thanh search
        Padding(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search users...",
              prefixIcon: Icon(Icons.search, color: AppColors.primaryColor),
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        // Danh sách user
        Expanded(
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryColor,
                  child: Text(
                    user.initial,
                    style: TextStyle(color: AppColors.white),
                  ),
                ),
                title: Text(
                  user.name,
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                onTap: () {
                  // Logic khi click vào user (để trống, sẽ thêm sau)
                  print("Clicked ${user.name}");
                },
              );
            },
          ),
        ),
      ],
    );
  }
}