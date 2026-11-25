import 'package:equatable/equatable.dart';

/// A bucket and folder pair for a storage upload.
class StorageTarget extends Equatable {
  const StorageTarget({required this.bucket, required this.folder});

  final String bucket;
  final String folder;

  @override
  List<Object?> get props => [bucket, folder];
}
