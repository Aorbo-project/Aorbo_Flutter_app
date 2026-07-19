/// Pulls the 11-character video ID out of any common YouTube URL shape:
/// youtube.com/watch?v=ID, youtu.be/ID, youtube.com/shorts/ID,
/// youtube.com/embed/ID (with or without extra query params).
String? extractYoutubeVideoId(String url) {
  if (url.isEmpty) return null;

  final patterns = [
    RegExp(r'(?:youtube\.com/watch\?v=|youtube\.com/live/)([a-zA-Z0-9_-]{11})'),
    RegExp(r'youtu\.be/([a-zA-Z0-9_-]{11})'),
    RegExp(r'youtube\.com/shorts/([a-zA-Z0-9_-]{11})'),
    RegExp(r'youtube\.com/embed/([a-zA-Z0-9_-]{11})'),
  ];

  for (final pattern in patterns) {
    final match = pattern.firstMatch(url);
    if (match != null) return match.group(1);
  }
  return null;
}

/// A `/shorts/` URL is always vertical (9:16). Everything else — a normal
/// `/watch` upload — defaults to landscape (16:9) since YouTube's IFrame
/// player has no way to auto-detect a regular upload's true orientation.
bool isYoutubeShortsUrl(String url) => url.contains('youtube.com/shorts/');

/// Every public YouTube video serves a default thumbnail at this
/// predictable address — no separate admin-uploaded cover image is needed
/// for the shelf preview. `hqdefault` (480x360) is used because, unlike
/// `maxresdefault`, it's guaranteed to exist for every video regardless of
/// upload resolution/age.
String? youtubeThumbnailUrl(String videoUrl) {
  final videoId = extractYoutubeVideoId(videoUrl);
  if (videoId == null) return null;
  return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
}
