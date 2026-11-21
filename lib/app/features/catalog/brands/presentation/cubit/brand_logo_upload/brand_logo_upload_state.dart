import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';

sealed class BrandLogoUploadState extends Equatable {
  const BrandLogoUploadState();
  @override
  List<Object?> get props => [];
}

final class BrandLogoIdle extends BrandLogoUploadState {
  const BrandLogoIdle();
}

final class BrandLogoUploading extends BrandLogoUploadState {
  const BrandLogoUploading();
}

/// [url] is the public URL to store in `brands.logo`.
final class BrandLogoUploaded extends BrandLogoUploadState {
  const BrandLogoUploaded(this.url);
  final String url;
  @override
  List<Object?> get props => [url];
}

final class BrandLogoUploadFailed extends BrandLogoUploadState {
  const BrandLogoUploadFailed(this.messageKey);
  final AppKey messageKey;
  @override
  List<Object?> get props => [messageKey];
}
