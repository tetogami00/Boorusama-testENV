// Project imports:
import 'package:boorusama/core/feats/notes/notes.dart';

abstract interface class NoteRepository {
  Future<List<Note>> getNotes(int postId);
  Future<void> createNote({
    required int postId,
    required int x,
    required int y,
    required int width,
    required int height,
    required String body,
  });
}

class NoteRepositoryBuilder implements NoteRepository {
  const NoteRepositoryBuilder({
    required this.fetch,
    required this.create,
  });

  final Future<List<Note>> Function(int postId) fetch;
  final Future<void> Function(
    int postId,
    int x,
    int y,
    int width,
    int height,
    String body,
  ) create;

  @override
  Future<List<Note>> getNotes(int postId) => fetch(postId);

  @override
  Future<void> createNote(
          {required int postId,
          required int x,
          required int y,
          required int width,
          required int height,
          required String body}) =>
      create(
        postId,
        x,
        y,
        width,
        height,
        body,
      );
}

class EmptyNoteRepository implements NoteRepository {
  const EmptyNoteRepository();

  @override
  Future<List<Note>> getNotes(int postId) async => [];

  @override
  Future<void> createNote({
    required int postId,
    required int x,
    required int y,
    required int width,
    required int height,
    required String body,
  }) async {}
}
