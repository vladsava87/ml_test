import 'package:ml_test/domain/enums/e_image_type.dart';
import 'package:ml_test/infrastructure/business/controllers/home_controller.dart';
import 'package:ml_test/infrastructure/constants/app_navigation_args.dart';
import 'package:ml_test/infrastructure/constants/app_strings.dart';
import 'package:ml_test/infrastructure/router.dart';
import 'package:ml_test/domain/interfaces/services/i_app_permissions_service.dart';
import 'package:ml_test/presentation/widgets/paginated_list_view.dart';
import 'package:ml_test/presentation/widgets/thumbnail_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.appTitle.tr),
        elevation: 1,
        shadowColor: Colors.deepPurpleAccent.shade100,
        scrolledUnderElevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: AppStrings.switchLanguage.tr,
            onPressed: () => controller.toggleLanguage(),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(
          () => PaginatedListView(
            context: context,
            items: controller.files,
            totalItems: controller.totalFiles.value,
            isLoading: controller.isLoading.value,
            currentPage: controller.currentPage,
            pageItems: controller.pageSize,
            onLoadMore: (nextPage, pageSize, filter, context) async {
              await controller.loadMore(nextPage, pageSize);
            },
            onRefresh: controller.loadRecent,
            cardTemplate: (context, item) {
              return Slidable(
                closeOnScroll: true,
                endActionPane: ActionPane(
                  extentRatio: 0.2,
                  closeThreshold: 0.05,
                  openThreshold: 0.05,
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) => controller.deleteFile(item.id),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: AppStrings.delete.tr,
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () => controller.openHistoryForFile(item),
                  child: ListTile(
                    key: ValueKey(item.id),
                    leading: ThumbnailImageWidget(item: item),
                    title: Text(
                      item.type == EImageType.person
                          ? AppStrings.faceProcessed.tr
                          : AppStrings.documentScan.tr,
                    ),
                    subtitle: Text(
                      DateFormat.yMMMd().format(item.createdAt.toLocal()),
                    ),
                  ),
                ),
              );
            },
            emptyTemplate: (context) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8.0,
              children: [
                Text(AppStrings.noFilesProcessedYet.tr),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 4,
                  children: [
                    Text(AppStrings.tapThe.tr),
                    const Icon(Icons.camera_alt, color: Colors.deepPurple),
                    Text(AppStrings.buttonToAddSome.tr),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showImagePickerAsync(context),
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  Future<void> _showImagePickerAsync(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(AppStrings.takeAPicture.tr),
                onTap: () async {
                  _cameraPermissionFlow(context);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(AppStrings.chooseFromImageGallery.tr),
                onTap: () {
                  controller.pickMultiImage().then((files) {
                    if (files != null && files.isNotEmpty) {
                      if (files.length == 1) {
                        Get.toNamed(
                          AppRouter.fileProcess,
                          arguments: AppNavigationArgs.fileProcess(
                            file: files.first,
                          ),
                        );
                      } else {
                        Get.toNamed(
                          AppRouter.batchProcess,
                          arguments: AppNavigationArgs.batchProcess(
                            files: files,
                          ),
                        );
                      }
                    }
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool?> _showPermissionRationale(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppStrings.cameraAccessNeeded.tr),
          content: Text(AppStrings.cameraPermissionRationale.tr),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppStrings.notNow.tr),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppStrings.allow.tr),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cameraPermissionFlow(BuildContext context) async {
    final permissionsService = Get.find<IAppPermissionsService>();
    final status = await permissionsService.checkCameraPermission();

    if (status.isGranted) {
      await Get.toNamed(AppRouter.camera);
      return;
    }

    if (status.isPermanentlyDenied) {
      openAppSettings();
      return;
    }

    if (context.mounted) {
      final proceed = await _showPermissionRationale(context);
      if (proceed == true) {
        final granted = await permissionsService.requestCameraPermission();
        if (granted) {
          await Get.toNamed(AppRouter.camera);
        }
      }
    }
  }
}
