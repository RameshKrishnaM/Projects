import 'package:flutter/material.dart';
import 'package:novo/screens/MutualFundsScreens/MututalFundsPage.dart';
import 'package:novo/widgets/NOVO%20Widgets/customLoadingAni.dart';
import 'package:provider/provider.dart';

import '../../Provider/provider.dart';
import '../../widgets/MF Widgets/mfAlertWidgets/mfactiveStatus.dart';

class MFactiveScreen extends StatefulWidget {
  const MFactiveScreen({super.key});

  @override
  State<MFactiveScreen> createState() => _MFactiveScreenState();
}

class _MFactiveScreenState extends State<MFactiveScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getActiveStatus();
  }

  Future<void> getActiveStatus() async {
    await Provider.of<NavigationProvider>(context, listen: false)
        .getMfCheckActivateAPI(context);
    setState(() {
      _isLoading = false; // Loading complete, set state to rebuild with data
    });
  }

  Widget mfActiveStatus(NavigationProvider value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showRiskDisclosureDialog(context, value);
    });
    return Container(
      color: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, value, child) {
        // Show loading widget if data is still being fetched
        if (_isLoading) {
          return LoadingProgress();
        }

        bool shouldShowAlert = (value.mfCheckActive['status'] == 'W' ||
                value.mfCheckActive['status'] == 'R' ||
                value.mfCheckActive['status'] == 'E') &&
            value.mfCheckActive['mfSoftLiveKey'] == 'Y';

        return shouldShowAlert ? mfActiveStatus(value) : MfMainScreen();
      },
    );
  }
}
