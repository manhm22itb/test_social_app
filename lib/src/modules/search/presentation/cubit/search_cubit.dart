import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:social_app/src/modules/newpost/domain/entities/post_entity.dart';
import 'package:social_app/src/modules/newpost/domain/usecase/toggle_like_usecase.dart'; // Import UseCase thả tim
import 'package:social_app/src/modules/search/domain/usecases/search_usecase.dart';
import '../../domain/repositories/search_repository.dart';
import 'package:social_app/src/modules/search/presentation/cubit/search_state.dart';

@injectable
class SearchCubit extends Cubit<SearchState> {
  final SearchUseCase _searchUseCase;
  final ToggleLikeUseCase _toggleLikeUseCase; // Inject thêm usecase này
  Timer? _debounce;

  String _currentQuery = '';
  SearchType _currentType = SearchType.all;

  SearchCubit(
    this._searchUseCase,
    this._toggleLikeUseCase, 
  ) : super(const SearchState.initial());

  // ... (Giữ nguyên các hàm onSearchChanged, onTypeChanged, _triggerSearch) ...
  
  void onSearchChanged(String query) {
    _currentQuery = query;
    _triggerSearch();
  }

  void onTypeChanged(int tabIndex) {
    switch (tabIndex) {
      case 0: _currentType = SearchType.all; break;
      case 1: _currentType = SearchType.posts; break;
      case 2: _currentType = SearchType.users; break;
    }
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
      (failure) => emit(SearchState.failure(failure.message ?? 'Error')),
      (data) => emit(SearchState.success(data)),
    );
  }

  // --- THÊM HÀM NÀY: Xử lý thả tim ---
  Future<void> toggleLike(PostEntity post) async {
    // Chỉ xử lý khi đang ở state Success (có dữ liệu)
    state.maybeWhen(
      success: (currentResult) async {
        // 1. Cập nhật UI ngay lập tức (Optimistic Update)
        final updatedPosts = currentResult.posts.map((p) {
          if (p.id == post.id) {
            final isLiked = !p.isLiked;
            return p.copyWith(
              isLiked: isLiked,
              likeCount: isLiked ? p.likeCount + 1 : (p.likeCount > 0 ? p.likeCount - 1 : 0),
            );
          }
          return p;
        }).toList();

        // Emit state mới với danh sách đã update
        emit(SearchState.success(currentResult.copyWith(posts: updatedPosts)));

        // 2. Gọi API ngầm bên dưới
        final result = await _toggleLikeUseCase(post.id);
        
        // 3. Nếu API lỗi, revert lại state cũ (nếu muốn chặt chẽ)
        // result.fold((l) {
        //     // Revert logic here if needed
        //     print("❌ Toggle like failed: ${l.message}");
        // }, (r) => null);
      },
      orElse: () {},
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}