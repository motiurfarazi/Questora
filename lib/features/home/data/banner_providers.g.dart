// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bannerRepository)
final bannerRepositoryProvider = BannerRepositoryProvider._();

final class BannerRepositoryProvider
    extends
        $FunctionalProvider<
          BannerRepository,
          BannerRepository,
          BannerRepository
        >
    with $Provider<BannerRepository> {
  BannerRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bannerRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bannerRepositoryHash();

  @$internal
  @override
  $ProviderElement<BannerRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BannerRepository create(Ref ref) {
    return bannerRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BannerRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BannerRepository>(value),
    );
  }
}

String _$bannerRepositoryHash() => r'c3d9ddcab46b9850c26c01cd74c2d9cdbd4ecfe5';

@ProviderFor(activeBanners)
final activeBannersProvider = ActiveBannersProvider._();

final class ActiveBannersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BannerItem>>,
          List<BannerItem>,
          FutureOr<List<BannerItem>>
        >
    with $FutureModifier<List<BannerItem>>, $FutureProvider<List<BannerItem>> {
  ActiveBannersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeBannersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeBannersHash();

  @$internal
  @override
  $FutureProviderElement<List<BannerItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BannerItem>> create(Ref ref) {
    return activeBanners(ref);
  }
}

String _$activeBannersHash() => r'be4b670ae0e17a86ebaa654dd3d3de7847a5b868';
