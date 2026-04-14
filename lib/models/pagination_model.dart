

class PaginationModel<T>{
  T data;
  bool isLoading;
  bool isPaginationCompleted;
  int page;
  String error;

  PaginationModel({
    required this.data,
    required this.isLoading,
    required this.isPaginationCompleted,
    required this.page,
    required this.error
  });
}