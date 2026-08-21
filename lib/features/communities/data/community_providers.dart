import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/network/pagination.dart';
import '../../../shared/models/community.dart';
import '../domain/community_repository.dart';
import 'pending_community_repository.dart';
import 'sample_community_repository.dart';

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return ref.watch(appConfigProvider).useSampleContent
      ? const SampleCommunityRepository()
      : const PendingCommunityRepository();
});

final discoverCommunitiesProvider =
    FutureProvider<Paginated<Community>>((ref) async {
  final result = await ref.watch(communityRepositoryProvider).discover();
  return result.fold(
    onSuccess: (page) => page,
    onFailure: (error) => throw error,
  );
});

final communityBySlugProvider = FutureProvider.family<Community, String>(
  (ref, slug) async {
    final result =
        await ref.watch(communityRepositoryProvider).communityBySlug(slug);
    return result.fold(
      onSuccess: (community) => community,
      onFailure: (error) => throw error,
    );
  },
);
