part of 'route_import_part.dart';

class AppRouter {
  static Route<dynamic> getRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case RouteName.splashRoute:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case RouteName.bottomNavRoute:
        return MaterialPageRoute(builder: (_) => const BottomNavBarScreen());

      // AI Feature Routes
      case RouteName.textRecognitionRoute:
        return MaterialPageRoute(builder: (_) => const TextRecognitionScreen());
      case RouteName.faceDetectionRoute:
        return MaterialPageRoute(builder: (_) => const FaceDetectionScreen());
      case RouteName.barcodeScannerRoute:
        return MaterialPageRoute(builder: (_) => const BarcodeScannerScreen());
      case RouteName.imageLabelingRoute:
        return MaterialPageRoute(builder: (_) => const ImageLabelingScreen());
      case RouteName.poseDetectionRoute:
        return MaterialPageRoute(builder: (_) => const PoseDetectionScreen());
      case RouteName.documentScannerRoute:
        return MaterialPageRoute(builder: (_) => const DocumentScannerScreen());
      case RouteName.colorDetectionRoute:
        return MaterialPageRoute(builder: (_) => const ColorDetectionScreen());
      case RouteName.objectDetectionRoute:
        return MaterialPageRoute(builder: (_) => const ObjectDetectionScreen());
      case RouteName.cameraRoute:
        return MaterialPageRoute(builder: (_) => const CameraScreen());
      case RouteName.historyRoute:
        return MaterialPageRoute(builder: (_) => const HistoryScreen());
      case RouteName.settingsRoute:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      default:
        return unDefineRoute();
    }
  }

  static Route<dynamic> unDefineRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text(AppString.noRoute)),
        body: const Center(child: Text(AppString.noRoute)),
      ),
    );
  }
}
