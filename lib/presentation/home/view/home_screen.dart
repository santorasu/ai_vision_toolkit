import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constansts/color_manger.dart';
import '../../../core/resource/app_strings.dart';
import '../../../core/route/route_name.dart';

class _ToolItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  final Color color;
  final Color bgColor;

  const _ToolItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.color,
    required this.bgColor,
  });
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const List<_ToolItem> _tools = [
    _ToolItem(
      icon: Icons.text_fields_rounded,
      title: AppString.textRecognition,
      subtitle: AppString.textRecognitionDesc,
      route: RouteName.textRecognitionRoute,
      color: Color(0xFF3D5AFE),
      bgColor: Color(0xFFEEF1FF),
    ),
    _ToolItem(
      icon: Icons.face_retouching_natural,
      title: AppString.faceDetection,
      subtitle: AppString.faceDetectionDesc,
      route: RouteName.faceDetectionRoute,
      color: Color(0xFFE91E63),
      bgColor: Color(0xFFFCE4EC),
    ),
    _ToolItem(
      icon: Icons.qr_code_scanner_rounded,
      title: AppString.barcodeScanner,
      subtitle: AppString.barcodeScannerDesc,
      route: RouteName.barcodeScannerRoute,
      color: Color(0xFF00897B),
      bgColor: Color(0xFFE0F2F1),
    ),
    _ToolItem(
      icon: Icons.label_rounded,
      title: AppString.imageLabeling,
      subtitle: AppString.imageLabelingDesc,
      route: RouteName.imageLabelingRoute,
      color: Color(0xFFFF6D00),
      bgColor: Color(0xFFFFF3E0),
    ),
    _ToolItem(
      icon: Icons.accessibility_new_rounded,
      title: AppString.poseDetection,
      subtitle: AppString.poseDetectionDesc,
      route: RouteName.poseDetectionRoute,
      color: Color(0xFF6200EA),
      bgColor: Color(0xFFEDE7F6),
    ),
    _ToolItem(
      icon: Icons.document_scanner_rounded,
      title: AppString.documentScanner,
      subtitle: AppString.documentScannerDesc,
      route: RouteName.documentScannerRoute,
      color: Color(0xFF0097A7),
      bgColor: Color(0xFFE0F7FA),
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeaderBanner(context),
                const SizedBox(height: 24),
                Text(
                  'AI Tools',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
                const SizedBox(height: 16),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildToolCard(context, _tools[index]),
                childCount: _tools.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120.h,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          AppString.dashboard,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00136B), Color(0xFF1A237E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildHeaderBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00136B), Color(0xFF3949AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ColorManager.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🤖 On-Device AI',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppString.dashboardSubtitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '6 AI Tools Available',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, _ToolItem tool) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, tool.route),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E1E2E)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: tool.color.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: tool.color.withValues(alpha: 0.15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: tool.bgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(tool.icon, color: tool.color, size: 26),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tool.title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : const Color(0xFF1A1A2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tool.subtitle,
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
