extension StringCasingExtension on String {
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ')
        .map((str) => str.isNotEmpty ? '${str[0].toUpperCase()}${str.substring(1)}' : '')
        .join(' ');
  }
}
