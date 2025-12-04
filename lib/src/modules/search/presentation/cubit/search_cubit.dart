import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/search_repository.dart'; // Import enum SearchType
import 'package:social_app/src/modules/search/domain/usecases/search_usecase.dart'; // Import UseCase mới
import 'package:social_app/src/modules/search/presentation/cubit/search_state.dart';

@injectable
class SearchCubit extends Cubit<SearchState> {
  final SearchUseCase _searchUseCase; // Sử dụng class SearchUseCase mới
  Timer? _debounce;

  String _currentQuery = '';
  SearchType _currentType = SearchType.all;

  SearchCubit(this._searchUseCase) : super(const SearchState.initial());

  // Sự kiện khi người dùng gõ text
  void onSearchChanged(String query) {
    _currentQuery = query;
    _triggerSearch();
  }

  // Sự kiện khi người dùng chuyển Tab (All / Posts / Users)
  void onTypeChanged(int tabIndex) {
    switch (tabIndex) {
      case 0:
        _currentType = SearchType.all;
        break;
      case 1:
        _currentType = SearchType.posts;
        break;
      case 2:
        _currentType = SearchType.users;
        break;
    }
    // Nếu đang có từ khóa tìm kiếm, thực hiện tìm lại ngay với Type mới
    if (_currentQuery.isNotEmpty) {
       if (_debounce?.isActive ?? false) _debounce!.cancel();
       _executeSearch(_currentQuery, _currentType);
    }
  }

  void _triggerSearch() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (_currentQuery.trim().isEmpty) {
      emit(const SearchState.initial());
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _executeSearch(_currentQuery, _currentType);
    });
  }

  Future<void> _executeSearch(String query, SearchType type) async {
    emit(const SearchState.loading());
    
    final result = await _searchUseCase(query, type);
    
    result.fold(
      (failure) => emit(SearchState.failure(failure.message ?? 'Đã có lỗi xảy ra')),
      // Đảm bảo SearchState.success nhận tham số là SearchResult
      (data) => emit(SearchState.success(data)), 
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}