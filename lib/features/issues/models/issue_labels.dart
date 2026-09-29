import '../../../l10n/app_localizations.dart';
import 'issue.dart';

/// Translated names for issue categories, shared by the issue cards and the
/// Report an issue form.
extension IssueCategoryLabel on IssueCategory {
  String label(AppLocalizations l10n) => switch (this) {
    IssueCategory.wages => l10n.categoryWages,
    IssueCategory.permit => l10n.categoryPermit,
    IssueCategory.housing => l10n.categoryHousing,
    IssueCategory.documents => l10n.categoryDocuments,
    IssueCategory.safety => l10n.categorySafety,
    IssueCategory.other => l10n.categoryOther,
  };
}
