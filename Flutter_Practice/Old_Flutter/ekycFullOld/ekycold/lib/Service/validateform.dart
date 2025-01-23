String? validationNotNull(String? value, String validateContent) {
  if (value == null || value.isEmpty) {
    return 'Please enter the $validateContent';
  }
  return null;
}
