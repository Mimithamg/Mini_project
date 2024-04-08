class SignUpWithEmailAndPasswordFailure {
  final String message; 

  const SignUpWithEmailAndPasswordFailure([this.message = "An unknown error occurred"]);

  factory SignUpWithEmailAndPasswordFailure.code(String code) {
    switch(code) {
      case 'weak-password':
        return const SignUpWithEmailAndPasswordFailure('Please enter a stronger password.');
      case 'invalid-email':
        return const SignUpWithEmailAndPasswordFailure('Email is not valid.');
      case 'email-already-in-use':
        return const SignUpWithEmailAndPasswordFailure('Account already exists.');
      case 'operation-not-allowed':
        return const SignUpWithEmailAndPasswordFailure('Operation is not allowed.');
      case 'user-disabled':
        return const SignUpWithEmailAndPasswordFailure('This user has been disabled. Please contact support for help.');
      default:
        return const SignUpWithEmailAndPasswordFailure();
    }
  }
}
