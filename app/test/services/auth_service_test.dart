import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ngo_volunteer_app/services/auth_service.dart';
import 'auth_service_test.mocks.dart';

@GenerateMocks([FirebaseAuth, UserCredential, User])
void main() {
  group('AuthService Tests', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late AuthService authService;
    late MockUserCredential mockUserCredential;
    late MockUser mockUser;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockUserCredential = MockUserCredential();
      mockUser = MockUser();
      
      authService = AuthService(auth: mockFirebaseAuth);
    });

    test('login with email and password returns UserCredential on success', () async {
      when(mockFirebaseAuth.signInWithEmailAndPassword(
              email: 'test@example.com', password: 'password123'))
          .thenAnswer((_) async => mockUserCredential);

      final result = await authService.login(
          email: 'test@example.com', password: 'password123');

      expect(result, mockUserCredential);
      verify(mockFirebaseAuth.signInWithEmailAndPassword(
              email: 'test@example.com', password: 'password123'))
          .called(1);
    });

    test('login throws exception on failure', () async {
      when(mockFirebaseAuth.signInWithEmailAndPassword(
              email: 'test@example.com', password: 'wrong'))
          .thenThrow(FirebaseAuthException(code: 'wrong-password'));

      expect(
        () => authService.login(email: 'test@example.com', password: 'wrong'),
        throwsA(isA<String>()), 
      );
    });

    test('register with email and password returns UserCredential on success', () async {
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'new@example.com', password: 'password123'))
          .thenAnswer((_) async => mockUserCredential);

      final result = await authService.register(
          email: 'new@example.com', password: 'password123');

      expect(result, mockUserCredential);
      verify(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'new@example.com', password: 'password123'))
          .called(1);
    });
  });
}
