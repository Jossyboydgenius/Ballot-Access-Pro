class FormValidators {
  static String? isNameValid(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    // Split the name and trim whitespace
    final nameParts = value.trim().split(' ').where((part) => part.isNotEmpty).toList();

    if (nameParts.length < 2) {
      return 'Please provide both first name and last name';
    }

    if (nameParts.length > 2) {
      return 'Only first name and last name are required';
    }

    // Check if each part contains only letters
    final nameRegex = RegExp(r'^[a-zA-Z]+$');
    if (!nameParts.every((part) => nameRegex.hasMatch(part))) {
      return 'Names should contain only letters';
    }

    return null;
  }

  static String? validateEmail(String? email) {
    if (email!.isEmpty) return "Email address is required";

    if (!RegExp(r'^[\w-/.]+@([\w-]+\.)+[\w-]{2,4}').hasMatch(email)) {
      return "Please enter a valid email";
    }

    return null;
  }

  static String? validatePassword(String? password) {
    if (password!.isEmpty) return "Password is required";
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~%]).{8,}$';
    RegExp regex = RegExp(pattern);

    if (!regex.hasMatch(password)) {
      return '''Password must be at least 8 characters,\ninclude an uppercase letter, number and symbol.''';
    }

    return null;
  }

  static String? checkIfPasswordSame(String? password, String? val,
      [String? title]) {
    if (password != val) {
      return '${title ?? "Passwords"} do not match';
    }
    return null;
  }

  static String? validatePassCode(String? val) {
    if (val == null || val.length < 6 || val.length > 6) {
      return 'Passcode must be at 6 digits';
    }

    return null;
  }

  static String? isProjectNameValid(String? value) {
    if (value == null) {
      return 'Name cannot be empty';
    }

    if (value.length < 2) {
      return "Name must be at least 2 characters";
    }

    return null;
  }

  static String? isDescriptionValid(String? value) {
    if (value == null) {
      return 'Description cannot be empty';
    }

    value = value.trim();

    if (value.length < 10) {
      return 'Description must be at least 10 characters';
    }

    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    // Basic phone number validation - can be adjusted based on your needs
    if (!RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return 'Gender is required';
    }
    final lowercaseGender = value.toLowerCase();
    if (lowercaseGender != 'male' && lowercaseGender != 'female') {
      return 'Please select either male or female';
    }
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    if (value.trim().length < 5) {
      return 'Please enter a valid address';
    }
    return null;
  }
} 
