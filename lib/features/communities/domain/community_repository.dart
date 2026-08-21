import '../../../core/network/pagination.dart';
import '../../../core/utils/result.dart';
import '../../../shared/models/community.dart';

/// Community reads for discovery and the community detail screen.
///
/// Joining is deliberately absent: it is a server action with approval rules,
/// counters and audit logging behind it, and a mobile write path should be
/// designed with the backend rather than guessed at here.
abstract interface class CommunityRepository {
  Future<Result<Paginated<Community>>> discover({PageRequest page});

  Future<Result<Community>> communityBySlug(String slug);
}
