import 'package:flutter/material.dart';
import 'package:yango_faso/passenger/manage_profil.dart';
import 'package:yango_faso/passenger/passenger_profil_page.dart';



class UserProfileAndManagementPage extends StatefulWidget {
  @override
  _UserProfileAndManagementPageState createState() => _UserProfileAndManagementPageState();
}

class _UserProfileAndManagementPageState extends State<UserProfileAndManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Profil'),
            Tab(text: 'Gestion de Profil'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          UserProfilePage(),
          ProfileManagementPage(),
        ],
      ),
    );
  }
}
