import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/event/event_entity.dart';
import 'package:real_amis/presentation/event/providers/event_provider.dart';

final allEventsNotifierProvider =
    StateNotifierProvider<AllEventsNotifier, AsyncValue<List<EventEntity>>>(
      (ref) => AllEventsNotifier(ref),
    );

class AllEventsNotifier extends StateNotifier<AsyncValue<List<EventEntity>>> {
  final Ref ref;

  AllEventsNotifier(this.ref) : super(const AsyncLoading()) {
    fetchAllEvents();
  }

  Future<void> fetchAllEvents() async {
    state = const AsyncLoading();
    final res = await ref.read(getAllEventsProvider)(NoParams());
    state = res.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (events) => AsyncData(events),
    );
  }
}
