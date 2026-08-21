import '../../../core/errors/app_error.dart';
import '../../../core/network/pagination.dart';
import '../../../core/utils/result.dart';
import '../../../shared/models/community.dart';
import '../../sample/sample_content.dart';
import '../domain/community_repository.dart';

/// Development-only repository. See `features/sample/sample_content.dart`.
class SampleCommunityRepository implements CommunityRepository {
  const SampleCommunityRepository();

  @override
  Future<Result<Paginated<Community>>> discover({
    PageRequest page = const PageRequest(),
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return Success<Paginated<Community>>(
      Paginated<Community>(items: SampleContent.communities()),
    );
  }

  @override
  Future<Result<Community>> communityBySlug(String slug) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    for (final community in SampleContent.communities()) {
      if (community.slug == slug) return Success<Community>(community);
    }
    return const Failure<Community>(
      NotFoundError(debugMessage: 'no sample community with that slug'),
    );
  }
}
