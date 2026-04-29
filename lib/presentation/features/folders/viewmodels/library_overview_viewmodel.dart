import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/content_providers.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/clock.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../domain/enums/content_sort_mode.dart';
import '../../../../domain/value_objects/content_queries.dart';
import '../models/library_folder.dart';

part 'library_overview_viewmodel.g.dart';

@immutable
class LibraryOverviewGreeting {
  const LibraryOverviewGreeting({
    required this.salutation,
    required this.userName,
  });

  final String salutation;
  final String userName;
}

@immutable
class LibraryOverviewState {
  const LibraryOverviewState({
    required this.greeting,
    required this.dueToday,
    required this.folders,
  });

  final LibraryOverviewGreeting greeting;
  final int dueToday;
  final List<LibraryFolder> folders;

  bool get isEmpty => folders.isEmpty;
}

@riverpod
class LibraryToolbarState extends _$LibraryToolbarState {
  @override
  ContentQuery build() => const ContentQuery();

  void setSearchTerm(String value) {
    final next = StringUtils.trimmed(value);
    if (next == state.searchTerm) {
      return;
    }
    state = ContentQuery(searchTerm: next, sortMode: state.sortMode);
  }

  void setSortMode(ContentSortMode sortMode) {
    if (sortMode == state.sortMode) {
      return;
    }
    state = ContentQuery(searchTerm: state.searchTerm, sortMode: sortMode);
  }
}

@Riverpod(keepAlive: true)
Future<LibraryOverviewState> libraryOverviewQuery(Ref ref) async {
  final query = ref.watch(libraryToolbarStateProvider);
  final useCase = ref.watch(watchLibraryOverviewUseCaseProvider);
  final clock = ref.watch(clockProvider);
  ref.watch(contentDataRevisionProvider);

  final data = await useCase.execute(query);
  return LibraryOverviewState(
    greeting: _buildGreeting(clock),
    dueToday: data.dueTodayCount,
    folders: data.folders
        .map(
          (item) => LibraryFolder(
            id: item.folder.id,
            name: item.folder.name,
            icon: Icons.folder_outlined,
            deckCount: item.deckCount,
            itemCount: item.itemCount,
            dueCardCount: item.dueCardCount,
            newCardCount: item.newCardCount,
            masteryPercent: item.masteryPercent,
          ),
        )
        .toList(growable: false),
  );
}

@riverpod
class LibraryOverviewActionController
    extends _$LibraryOverviewActionController {
  @override
  FutureOr<void> build() {}

  Future<bool> createFolder(String name) async {
    // guard:retry-reviewed
    state = const AsyncLoading<void>();
    final result = await ref.read(createFolderUseCaseProvider).createRoot(name);
    if (!ref.mounted) {
      return false;
    }
    final failure = result.failureOrNull;
    if (failure != null) {
      state = AsyncError<void>(failure, StackTrace.current);
      return false;
    }
    state = const AsyncData<void>(null);
    return true;
  }
}

LibraryOverviewGreeting _buildGreeting(Clock clock) {
  final localNow = clock.nowUtc().toLocal();
  final salutation = switch (localNow.hour) {
    >= 5 && < 12 => 'Good morning',
    >= 12 && < 18 => 'Good afternoon',
    _ => 'Good evening',
  };

  return LibraryOverviewGreeting(salutation: salutation, userName: 'Learner');
}

AppFailure? libraryOverviewActionError(AsyncValue<void> actionState) =>
    actionState.whenOrNull(
      error: (error, _) => error is AppFailure ? error : null,
    );
