import 'package:flutter/material.dart';
import '../../services/connectivity_service.dart';
import '../../config/app_colors.dart';

class NoInternetWrapper extends StatefulWidget {
  final Widget child;

  const NoInternetWrapper({super.key, required this.child});

  @override
  State<NoInternetWrapper> createState() => _NoInternetWrapperState();
}

class _NoInternetWrapperState extends State<NoInternetWrapper> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
    _connectivityService.connectionStream.listen((isConnected) {
      if (mounted) {
        setState(() {
          _hasInternet = isConnected;
        });
      }
    });
  }

  Future<void> _checkInitialConnection() async {
    final isConnected = await _connectivityService.checkConnection();
    if (mounted) {
      setState(() {
        _hasInternet = isConnected;
      });
    }
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: widget.child),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _hasInternet ? 0 : 40,
          width: double.infinity,
          color: AppColors.error,
          alignment: Alignment.center,
          child: const Text(
            'No Internet Connection',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
