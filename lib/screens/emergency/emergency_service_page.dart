import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/location/location_bloc.dart';
import '../../theme/colors.dart';

class EmergencyServicePage extends StatefulWidget {
  const EmergencyServicePage({super.key});

  @override
  State<EmergencyServicePage> createState() => _EmergencyServicePageState();
}

class _EmergencyServicePageState extends State<EmergencyServicePage>
    with TickerProviderStateMixin {
  bool _isAlertSent = false;
  bool _isSendingAlert = false;
  late AnimationController _pulseController;
  late AnimationController _successController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    _successController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _successController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Emergency Services',
          style: TextStyle(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.error,
        iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Emergency Alert Status
              if (_isAlertSent)
                _buildAlertSentCard()
              else
                _buildEmergencyCard(),

              const SizedBox(height: 24),

              // Current Location Card
              _buildLocationCard(),

              const SizedBox(height: 24),

              // Emergency Services List
              _buildEmergencyServicesList(),

              const SizedBox(height: 24),

              // Emergency Contacts
              _buildEmergencyContactsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.emergency, size: 64, color: AppColors.textOnPrimary),
          const SizedBox(height: 16),
          const Text(
            'Emergency Alert',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textOnPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Press the button below to alert emergency services',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.textOnPrimary),
          ),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: GestureDetector(
                  onTap: _isSendingAlert ? null : _sendEmergencyAlert,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: _isSendingAlert
                          ? AppColors.mutedText
                          : AppColors.textOnPrimary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textOnPrimary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: _isSendingAlert
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.error,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.emergency,
                            size: 48,
                            color: AppColors.error,
                          ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            _isSendingAlert ? 'Sending Alert...' : 'EMERGENCY',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textOnPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertSentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 2),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (value * 0.2),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.textOnPrimary.withOpacity(0.2),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 48,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Alert Sent Successfully!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textOnPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Emergency services have been notified of your location',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.textOnPrimary),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.textOnPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Ambulance dispatched',
                      style: TextStyle(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.textOnPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Police notified',
                      style: TextStyle(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.textOnPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Emergency contacts alerted',
                      style: TextStyle(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'ETA: 5-8 minutes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textOnPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.neutral,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkText.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Current Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (state is LocationLoaded) ...[
                Text(
                  state.address,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Lat: ${state.latitude.toStringAsFixed(6)}, Lng: ${state.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.lightText,
                  ),
                ),
              ] else ...[
                const Text(
                  'Getting your location...',
                  style: TextStyle(fontSize: 16, color: AppColors.lightText),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmergencyServicesList() {
    final services = [
      {
        'title': 'Ambulance',
        'subtitle': 'Medical Emergency',
        'icon': Icons.local_hospital,
        'color': AppColors.error,
        'status': _isAlertSent ? 'Dispatched' : 'Available',
      },
      {
        'title': 'Police',
        'subtitle': 'Emergency Response',
        'icon': Icons.local_police,
        'color': Colors.blue,
        'status': _isAlertSent ? 'Notified' : 'Available',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Emergency Services',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 16),
        ...services.map(
          (service) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.neutral,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (service['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    service['icon'] as IconData,
                    color: service['color'] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['title'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                      ),
                      Text(
                        service['subtitle'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.lightText,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _isAlertSent
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    service['status'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _isAlertSent
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyContactsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkText.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emergency Hotlines',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16),
          _buildContactRow('Police', '100', Icons.local_police),
          _buildContactRow('Fire', '101', Icons.local_fire_department),
          _buildContactRow('Ambulance', '102', Icons.local_hospital),
          _buildContactRow('Disaster Management', '108', Icons.warning),
        ],
      ),
    );
  }

  Widget _buildContactRow(String service, String number, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              service,
              style: const TextStyle(fontSize: 16, color: AppColors.darkText),
            ),
          ),
          Text(
            number,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendEmergencyAlert() async {
    setState(() {
      _isSendingAlert = true;
    });

    // Simulate sending alert
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isSendingAlert = false;
      _isAlertSent = true;
    });

    _pulseController.stop();
  }
}
