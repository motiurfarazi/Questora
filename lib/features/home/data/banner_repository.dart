import 'package:supabase_flutter/supabase_flutter.dart';

class BannerItem {
  final String id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final String? actionUrl;
  final int order;

  const BannerItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    this.actionUrl,
    required this.order,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      imageUrl: json['image_url'] as String,
      actionUrl: json['action_url'] as String?,
      order: json['order_index'] as int? ?? 0,
    );
  }
}

class BannerRepository {
  final SupabaseClient _supabase;
  BannerRepository(this._supabase);

  Future<List<BannerItem>> getActiveBanners() async {
    final response = await _supabase
        .from('banners')
        .select()
        .eq('is_active', true)
        .order('order_index', ascending: true);
    return response.map((json) => BannerItem.fromJson(json)).toList();
  }
}
