class Helpers {
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  static String formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}…';
  }

  static String readingProgressText(int currentPage, int totalPages) {
    if (totalPages <= 0) return '0%';
    final percent = ((currentPage / totalPages) * 100).round();
    return '$percent%';
  }

  static double readingProgressValue(int currentPage, int totalPages) {
    if (totalPages <= 0) return 0.0;
    return currentPage / totalPages;
  }
}
