import 'package:campus_manager/models/deleted_suggestion_model.dart';
import 'package:campus_manager/models/suggestion_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SuggestionService {
  Future<void> storeSuggestion(SuggestionModel suggestion) async {
  CollectionReference suggestions =
      FirebaseFirestore.instance.collection('suggestions');

  if (suggestion.id != null) {
    // Use the provided ID
    await suggestions.doc(suggestion.id).set(suggestion.toMap());
  } else {
    // Add with auto-generated ID
    await suggestions.add(suggestion.toMap());
  }
}

  Stream<List<SuggestionModel>> getSuggestionsStream() {
    return FirebaseFirestore.instance
        .collection('suggestions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return SuggestionModel.fromMap(doc.data(), id: doc.id);
            }).toList());
  }

  /// Store a deleted announcement
  Future<void> storeDeletedSuggestion(DeletedSuggestionModel model) async {
    await FirebaseFirestore.instance
        .collection('deleted_suggestions')
        .doc(model.suggestionId)
        .set(model.toMap());
  }

  /// Get a deleted announcement by its announcementId
  Future<DeletedSuggestionModel?> getDeletedSuggestion(
      String suggestionId) async {
    final doc = await FirebaseFirestore.instance
        .collection('deleted_suggestions')
        .doc(suggestionId)
        .get();

    if (doc.exists && doc.data() != null) {
      return DeletedSuggestionModel.fromMap(doc.data()!);
    }
    return null;
  }
}
