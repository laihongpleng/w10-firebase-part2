import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../model/songs/song.dart';
import '../../dtos/song_dto.dart';
import 'song_repository.dart';

class SongRepositoryFirebase extends SongRepository {
    final String baseUrl =
      'laihong-first-practice-default-rtdb.asia-southeast1.firebasedatabase.app';

  final Uri songsUri = Uri.https(
    'laihong-first-practice-default-rtdb.asia-southeast1.firebasedatabase.app',
    '/songs.json',
  );
  
  List<Song>? _cachedSongs;
  void clearCache() {
    _cachedSongs = null;
  }
  @override
  Future<List<Song>> fetchSongs({bool forceFetch = false}) async {
    if (!forceFetch && _cachedSongs != null) {
      return _cachedSongs!;
    }
    final http.Response response = await http.get(songsUri);

    if (response.statusCode == 200) {
      // 1 - Send the retrieved list of songs
      Map<String, dynamic> songJson = json.decode(response.body);

      List<Song> result = [];
      for (final entry in songJson.entries) {
        result.add(SongDto.fromJson(entry.key, entry.value));
      }
      
      _cachedSongs = result;
      return result;
    } else {
      // 2- Throw expcetion if any issue
      throw Exception('Failed to load posts');
    }
  }

  @override
  Future<Song?> fetchSongById(String id) async {}

  Future<void> likeSong(String songId) async {
    final uri = Uri.https(baseUrl, '/songs/$songId/like.json');

    final songs = await fetchSongs();
    final song = songs.firstWhere((s) => s.id == songId);

    final newLikes = song.like + 1;

    final response = await http.put(uri, body: jsonEncode(newLikes));
    
    if (response.statusCode != 200) {
      throw Exception("Failed to like song");
    }
    clearCache();
  }
}


