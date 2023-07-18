String capitalize(String input) {
  if (input.isEmpty) {
    return '';
  }
  final List<String> words = input.split(' ');
  final capitalizedWords = words.map((word) {
    if (word.isEmpty) {
      return '';
    }
    final firstLetter = word[0].toUpperCase();
    final remainingLetters = word.substring(1).toLowerCase();
    return '$firstLetter$remainingLetters';
  });
  return capitalizedWords.join(' ');
}