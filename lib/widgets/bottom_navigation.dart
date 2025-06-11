// lib/widgets/bottom_navigation.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppColors {
  static const Color darkNavy = Color(0xFF0D1321);
  static const Color navy = Color(0xFF1D2D44);
  static const Color blueGray = Color(0xFF3E5C76);
  static const Color lightBlue = Color(0xFF748CAB);
  static const Color cream = Color(0xFFF0EDD8);
}

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavigation({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.darkNavy.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.blueGray,
        unselectedItemColor: AppColors.lightBlue.withOpacity(0.6),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
        elevation: 0,
        onTap: (index) => _onItemTapped(context, index),
        items: [
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.dashboard_outlined, Icons.dashboard, 0),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.schedule_outlined, Icons.schedule, 1),
            label: 'Recordatorios',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.work_outline, Icons.work, 2),
            label: 'Proyectos',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.notifications_outlined, Icons.notifications, 3),
            label: 'Notificaciones',
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData outlinedIcon, IconData filledIcon, int index) {
    final isSelected = currentIndex == index;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.blueGray.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        isSelected ? filledIcon : outlinedIcon,
        size: 24,
      ),
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    if (currentIndex == index) return; // No navegar si ya estamos en la misma página
    
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/recordatorios');
        break;
      case 2:
        context.go('/proyectos');
        break;
      case 3:
        context.go('/notificaciones');
        break;
    }
  }
}