import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/scan_history_model.dart';
import '../../../data/repositories/scan_history_repository.dart';

class HistoryState {
  final List<ScanHistoryModel> items;
  final String query;

  const HistoryState({this.items = const [], this.query = ''});

  HistoryState copyWith({List<ScanHistoryModel>? items, String? query}) {
    return HistoryState(items: items ?? this.items, query: query ?? this.query);
  }
}

class HistoryNotifier extends Notifier<HistoryState> {
  final _repo = ScanHistoryRepository();

  @override
  HistoryState build() {
    return HistoryState(items: _repo.getAll());
  }

  void search(String query) {
    state = state.copyWith(items: _repo.search(query), query: query);
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    state = state.copyWith(items: _repo.search(state.query));
  }

  Future<void> clearAll() async {
    await _repo.clearAll();
    state = const HistoryState();
  }

  Future<void> save(String type, String result) async {
    await _repo.add(type: type, result: result);
    refresh();
  }

  void refresh() {
    state = state.copyWith(items: _repo.search(state.query));
  }
}

final historyProvider = NotifierProvider<HistoryNotifier, HistoryState>(
  HistoryNotifier.new,
);
