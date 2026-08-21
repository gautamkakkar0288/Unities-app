import '../../../core/errors/app_error.dart';
import '../../../core/network/api_paths.dart';
import '../../../core/network/pagination.dart';
import '../../../core/utils/result.dart';
import '../../../shared/models/community.dart';
import '../domain/community_repository.dart';

/// Awaiting a communities endpoint. See [PendingEventRepository] for the
/// reasoning behind failing honestly instead of inventing a route.
class PendingCommunityRepository implements CommunityRepository {
  const PendingCommunityRepository();

  static const AppError _missing = MissingBackendCapabilityError(
    capability: MissingCapabilities.communitiesList,
    detail: MissingCapabilities.communitiesDetail,
  );

  @override
  Future<Result<Paginated<Community>>> discover({
    PageRequest page = const PageRequest(),
  }) async =>
      const Failure<Paginated<Community>>(_missing);

  @override
  Future<Result<Community>> communityBySlug(String slug) async =>
      const Failure<Community>(_missing);
}
