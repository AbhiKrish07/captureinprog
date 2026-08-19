import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/constants.dart';
import '../../../models/capture.dart';
import '../../../providers/capture_provider.dart';
import '../../../widgets/capture_card.dart';
import '../../../widgets/search_bar.dart';
import '../../../widgets/shared/loading_indicator.dart';
import '../../../widgets/bottom_sheet_capture_input.dart';

class BoardScreen extends ConsumerWidget {
  const BoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capturesAsync = ref.watch(captureListNotifierProvider);
    final currentQuery = ref.watch(currentSearchQueryProvider);
    final searchResultsAsync = ref.watch(searchResultsProvider);


    // Show search results if query is active, otherwise show all captures
    final displayAsync = currentQuery.isEmpty ? capturesAsync : searchResultsAsync;

    return Scaffold(
      body: CustomScrollView(
        cacheExtent: 2000.0,
        slivers: [
          // APP BAR WITH SEARCH
          SliverAppBar(
            pinned: true,
            backgroundColor: kBackgroundDark,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Capture',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              centerTitle: true,
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(60),
              child: Padding(
                padding: EdgeInsets.all(kSpacingM),
                child: SearchBarWidget(
                  onChanged: (query) {
                    ref.read(currentSearchQueryProvider.notifier).set(query);
                  },
                  hintText: 'Find anything...',
                ),
              ),
            ),
          ),

          // CONTENT
          displayAsync.when(
            loading: () => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CaptureLoadingIndicator()
                        .animate()
                        .fadeIn(duration: kDurationNormal),
                    SizedBox(height: kSpacingM),
                    Text('Finding your memories...')
                        .animate()
                        .fadeIn(duration: kDurationNormal),
                  ],
                ),
              ),
            ),
            error: (err, st) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: kErrorRed),
                    SizedBox(height: kSpacingM),
                    Text('Error: $err'),
                    SizedBox(height: kSpacingM),
                    ElevatedButton(
                      onPressed: () => ref.read(captureListNotifierProvider.notifier).refresh(),
                      child: Text('Retry'),
                    ),
                  ],
                ).animate().shake(hz: 4, curve: Curves.easeInOut),
              ),
            ),
            data: (captures) => captures.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 64, color: kTextSecondary),
                          SizedBox(height: kSpacingL),
                          Text(
                            currentQuery.isEmpty
                                ? 'No captures yet'
                                : 'No results for "$currentQuery"',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          SizedBox(height: kSpacingS),
                          Text(
                            'Start capturing to build your memory',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: EdgeInsets.all(kSpacingM),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 0.85,
                        mainAxisSpacing: kSpacingM,
                        crossAxisSpacing: kSpacingM,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final capture = captures[index];
                          return CaptureCard(
                            capture: capture,
                            onTap: () => _openCapture(context, capture),
                            onDelete: () => _deleteCapture(ref, capture.id),
                          )
                              .animate()
                              .fadeIn(
                                duration: kDurationNormal,
                                delay: Duration(milliseconds: index * 50),
                              )
                              .scale(
                                begin: Offset(0.95, 0.95),
                                delay: Duration(milliseconds: index * 50),
                              );
                        },
                        childCount: captures.length,
                      ),
                    ),
                  ),
          ),
        ],
      ),

      // FLOATING ACTION BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCaptureBottomSheet(context),
        backgroundColor: kAccentOrange,
        child: Icon(Icons.add, color: kBackgroundDark),
      ).animate().scale(begin: Offset.zero),
    );
  }

  void _openCapture(BuildContext context, Capture capture) {
  }

  void _deleteCapture(WidgetRef ref, String captureId) {
    ref.read(captureListNotifierProvider.notifier).deleteCapture(captureId);
  }
}
