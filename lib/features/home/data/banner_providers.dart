import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'banner_repository.dart';

part 'banner_providers.g.dart';

@riverpod
BannerRepository bannerRepository(Ref ref) {
  return BannerRepository(Supabase.instance.client);
}

@riverpod
Future<List<BannerItem>> activeBanners(Ref ref) async {
  final repo = ref.read(bannerRepositoryProvider);
  return repo.getActiveBanners();
}
