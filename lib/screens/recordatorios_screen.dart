// lib/screens/recordatorios_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/recordatorios/recordatorios_bloc.dart';
import '../bloc/recordatorios/recordatorios_state.dart';
import '../bloc/recordatorios/recordatorios_event.dart';
import '../widgets/recordatorio_card.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/crear_recordatorio_dialog.dart';
import '../models/recordatorio.dart';

class AppColors {
  static const Color darkNavy = Color(0xFF0D1321);
  static const Color navy = Color(0xFF1D2D44);
  static const Color blueGray = Color(0xFF3E5C76);
  static const Color lightBlue = Color(0xFF748CAB);
  static const Color cream = Color(0xFFF0EDD8);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
}

class RecordatoriosScreen extends StatefulWidget {
  const RecordatoriosScreen({Key? key}) : super(key: key);

  @override
  State<RecordatoriosScreen> createState() => _RecordatoriosScreenState();
}

class _RecordatoriosScreenState extends State<RecordatoriosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: Row(
          children: [
            Icon(Icons.schedule, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            const Text('Recordatorios'),
          ],
        ),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppColors.cream,
          indicatorWeight: 3,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.list, size: 18),
                  const SizedBox(width: 6),
                  const Text('Todos'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning_amber, size: 18),
                  const SizedBox(width: 6),
                  const Text('Urgentes'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.today, size: 18),
                  const SizedBox(width: 6),
                  const Text('Hoy'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                context.read<RecordatoriosBloc>().add(const RefrescarRecordatorios('1'));
              },
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.cream,
      body: BlocBuilder<RecordatoriosBloc, RecordatoriosState>(
        builder: (context, state) {
          if (state is RecordatoriosLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.blueGray),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando recordatorios...',
                    style: TextStyle(color: AppColors.navy),
                  ),
                ],
              ),
            );
          }
          
          if (state is RecordatoriosError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.error_outline, 
                                size: 64, 
                                color: AppColors.error),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Error al cargar recordatorios',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.navy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.navy.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<RecordatoriosBloc>().add(const CargarRecordatorios('1'));
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueGray,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          if (state is RecordatoriosLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                // Todos los recordatorios
                _buildRecordatoriosList(
                  state.recordatorios.cast<Recordatorio>(), 
                  'No hay recordatorios',
                  Icons.list_alt,
                  AppColors.blueGray,
                ),
                
                // Recordatorios urgentes
                _buildRecordatoriosList(
                  state.recordatoriosUrgentes.cast<Recordatorio>(), 
                  'No hay recordatorios urgentes',
                  Icons.warning_amber,
                  AppColors.error,
                ),
                
                // Recordatorios de hoy
                _buildRecordatoriosList(
                  state.recordatoriosHoy.cast<Recordatorio>(), 
                  'No hay recordatorios para hoy',
                  Icons.today,
                  AppColors.info,
                ),
              ],
            );
          }
          
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.schedule, 
                              size: 64, 
                              color: AppColors.lightBlue),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Inicia para ver tus recordatorios',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.navy,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarCrearRecordatorio(context),
        backgroundColor: AppColors.lightBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
        elevation: 4,
      ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 1),
    );
  }

  Widget _buildRecordatoriosList(
    List<Recordatorio> recordatorios, 
    String emptyMessage,
    IconData emptyIcon,
    Color emptyColor,
  ) {
    if (recordatorios.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: emptyColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(emptyIcon, 
                          size: 64, 
                          color: emptyColor),
              ),
              const SizedBox(height: 24),
              Text(
                emptyMessage,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Crea un nuevo recordatorio tocando el botón +',
                style: TextStyle(color: AppColors.navy.withOpacity(0.7)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.blueGray,
      onRefresh: () async {
        context.read<RecordatoriosBloc>().add(const RefrescarRecordatorios('1'));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: recordatorios.length + 1, // +1 para el header de estadísticas
        itemBuilder: (context, index) {
          if (index == 0) {
            // Header con estadísticas
            return Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkNavy.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: emptyColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(emptyIcon, color: emptyColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${recordatorios.length} recordatorios',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.navy,
                          ),
                        ),
                        Text(
                          _getSubtitleForTab(),
                          style: TextStyle(
                            color: AppColors.navy.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          
          final recordatorio = recordatorios[index - 1];
          return RecordatorioCard(
            recordatorio: recordatorio,
            esUrgente: recordatorio.esUrgente,
          );
        },
      ),
    );
  }

  String _getSubtitleForTab() {
    switch (_tabController.index) {
      case 0:
        return 'Gestiona todos tus recordatorios';
      case 1:
        return 'Requieren atención inmediata';
      case 2:
        return 'Programados para hoy';
      default:
        return '';
    }
  }

  void _mostrarCrearRecordatorio(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CrearRecordatorioDialog(),
    );
  }
}