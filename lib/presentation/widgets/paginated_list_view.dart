import 'package:ml_test/infrastructure/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaginatedListView<T, F> extends StatelessWidget {
  final BuildContext context;
  final List<T>? items;
  final int totalItems;
  final bool isLoading;
  final int currentPage;
  final int pageItems;
  final F? filter;
  final Future<void> Function(
    int nextPage,
    int pageSize,
    F? filter,
    BuildContext context,
  )
  onLoadMore;
  final Future<void> Function() onRefresh;
  final Widget Function(BuildContext, T) cardTemplate;
  final Widget Function(BuildContext) emptyTemplate;
  final bool? hasSeparator;

  const PaginatedListView({
    super.key,
    required this.context,
    required this.items,
    required this.pageItems,
    required this.totalItems,
    required this.isLoading,
    required this.currentPage,
    required this.onLoadMore,
    required this.onRefresh,
    required this.cardTemplate,
    required this.emptyTemplate,
    this.hasSeparator = false,
    this.filter,
  });

  @override
  Widget build(BuildContext context) {
    if ((items == null || items!.isEmpty) && isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              Text(AppStrings.loadingItems.tr),
              CircularProgressIndicator(color: Colors.accents[3].shade700),
            ],
          ),
        ),
      );
    }

    if (items == null || items!.isEmpty) {
      return emptyTemplate(context);
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: onRefresh,
        backgroundColor: Colors.accents[3].shade700,
        color: Colors.white,
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent &&
                !isLoading &&
                items!.length < totalItems) {
              onLoadMore(currentPage + 1, pageItems, filter, context);
            }
            return false;
          },
          child: hasSeparator == true
              ? ListView.separated(
                  separatorBuilder: (context, index) =>
                      Divider(color: Colors.grey[300]),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: items!.length < totalItems
                      ? items!.length + 1
                      : items!.length,
                  itemBuilder: (context, index) {
                    if (index == items!.length) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(
                            color: Colors.accents[3].shade700,
                          ),
                        ),
                      );
                    }
                    return cardTemplate(context, items![index]);
                  },
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: items!.length < totalItems
                      ? items!.length + 1
                      : items!.length,
                  itemBuilder: (context, index) {
                    if (index == items!.length) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(
                            color: Colors.accents[3].shade700,
                          ),
                        ),
                      );
                    }
                    return cardTemplate(context, items![index]);
                  },
                ),
        ),
      ),
    );
  }
}
