import 'package:flutter/material.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text('User Management')),
      body: Center(
        child: Text('Manage Users Here', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
