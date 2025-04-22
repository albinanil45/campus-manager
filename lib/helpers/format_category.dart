import 'package:campus_manager/models/suggestion_model.dart';

class FormatCategory {
  static String formatCategoryName(SuggestionCategories category) {
    return category
        .toString()
        .split('.')
        .last
        .replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
        .replaceFirstMapped(RegExp(r'^\w'), (match) => match.group(0)!.toUpperCase())
        .trim();
  }
}