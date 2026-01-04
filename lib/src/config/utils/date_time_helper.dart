class DateTimeHelper {
  /// Formats a DateTime into a human-readable "time ago" string
  /// Example: "2h ago", "3d ago", "5mo ago", "1y ago"
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  /// Converts a local date string (DD/MM/YYYY) to ISO date format (YYYY-MM-DD)
  /// For logging meals and activities to the backend
  ///
  /// Strategy: Convert to ISO date format without time component
  /// The backend expects just the date in YYYY-MM-DD format
  ///
  /// Example: "05/01/2026" -> "2026-01-05"
  static String convertLocalDateToISODate(String localDate) {
    // Parse the date string DD/MM/YYYY
    final parts = localDate.split('/');
    if (parts.length != 3) {
      throw FormatException('Invalid date format. Expected DD/MM/YYYY');
    }

    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);

    // Return as ISO date format (YYYY-MM-DD)
    return '${year.toString()}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  /// Gets current time as UTC ISO string
  /// For logging activities with current timestamp
  static String getCurrentUTC() {
    final now = DateTime.now().toUtc();
    return now.toIso8601String();
  }
}
