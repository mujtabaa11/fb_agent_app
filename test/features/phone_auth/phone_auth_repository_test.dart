/// Tests for phone authentication methods on [FirebaseAuthRepository].
///
/// Reuses the same mockito [MockFirebaseAuth] / [MockUser] pattern as the
/// existing auth_repository_test.dart but focuses exclusively on
/// [verifyPhoneNumber] and [signInWithPhoneCredential].
///
/// Key challenge: [FirebaseAuth.verifyPhoneNumber] is callback-based.
/// We use mockito's [any] matcher on named parameters and invoke the
/// callbacks manually via the [Invocation] to simulate codeSent,
/// verificationFailed, etc.
library;

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:template_app/core/data/result.dart';
import 'package:template_app/core/errors/app_exceptions.dart';
import 'package:template_app/features/auth/models/auth_user.dart';
import 'package:template_app/features/auth/repositories/auth_repository.dart';

@GenerateMocks([
  fb.FirebaseAuth,
  fb.UserCredential,
  fb.User,
])
import 'phone_auth_repository_test.mocks.dart';

// FirebaseAuthException has a @protected constructor.
class TestFirebaseAuthException extends fb.FirebaseAuthException {
  TestFirebaseAuthException({
    required super.code,
    super.message,
  });
}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockUserCredential mockCredential;
  late MockUser mockUser;
  late FirebaseAuthRepository repo;

  void stubMockUser({
    String uid = 'phone-uid',
    String email = '',
    bool emailVerified = false,
    String? phoneNumber = '+1234567890',
  }) {
    when(mockUser.uid).thenReturn(uid);
    when(mockUser.email).thenReturn(email);
    when(mockUser.emailVerified).thenReturn(emailVerified);
    when(mockUser.displayName).thenReturn(null);
    when(mockUser.phoneNumber).thenReturn(phoneNumber);
    when(mockCredential.user).thenReturn(mockUser);
  }

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockCredential = MockUserCredential();
    mockUser = MockUser();

    stubMockUser();

    repo = FirebaseAuthRepository(firebaseAuth: mockAuth);
  });

  // ---------------------------------------------------------------------------
  // verifyPhoneNumber
  // ---------------------------------------------------------------------------

  group('verifyPhoneNumber', () {
    test('codeSent callback returns Success with verificationId', () async {
      when(mockAuth.verifyPhoneNumber(
        phoneNumber: anyNamed('phoneNumber'),
        verificationCompleted: anyNamed('verificationCompleted'),
        verificationFailed: anyNamed('verificationFailed'),
        codeSent: anyNamed('codeSent'),
        codeAutoRetrievalTimeout: anyNamed('codeAutoRetrievalTimeout'),
      )).thenAnswer((invocation) async {
        final codeSent = invocation.namedArguments[#codeSent]
            as void Function(String, int?);
        codeSent('test-verification-id', null);
      });

      final result = await repo.verifyPhoneNumber('+1234567890');

      expect(result, isA<Success<String>>());
      expect((result as Success<String>).value, 'test-verification-id');
    });

    test('verificationFailed with invalid-phone-number returns Failure with AuthException',
        () async {
      when(mockAuth.verifyPhoneNumber(
        phoneNumber: anyNamed('phoneNumber'),
        verificationCompleted: anyNamed('verificationCompleted'),
        verificationFailed: anyNamed('verificationFailed'),
        codeSent: anyNamed('codeSent'),
        codeAutoRetrievalTimeout: anyNamed('codeAutoRetrievalTimeout'),
      )).thenAnswer((invocation) async {
        final verificationFailed = invocation
                .namedArguments[#verificationFailed]
            as void Function(fb.FirebaseAuthException);
        verificationFailed(TestFirebaseAuthException(
          code: 'invalid-phone-number',
          message: 'The phone number is invalid.',
        ));
      });

      final result = await repo.verifyPhoneNumber('+invalid');

      expect(result, isA<Failure<String>>());
      final failure = result as Failure<String>;
      expect(failure.exception, isA<AuthException>());
      expect(
        (failure.exception as AuthException).code,
        'invalid-phone-number',
      );
    });

    test('verificationFailed with too-many-requests returns Failure with AuthException',
        () async {
      when(mockAuth.verifyPhoneNumber(
        phoneNumber: anyNamed('phoneNumber'),
        verificationCompleted: anyNamed('verificationCompleted'),
        verificationFailed: anyNamed('verificationFailed'),
        codeSent: anyNamed('codeSent'),
        codeAutoRetrievalTimeout: anyNamed('codeAutoRetrievalTimeout'),
      )).thenAnswer((invocation) async {
        final verificationFailed = invocation
                .namedArguments[#verificationFailed]
            as void Function(fb.FirebaseAuthException);
        verificationFailed(TestFirebaseAuthException(
          code: 'too-many-requests',
          message: 'Too many requests.',
        ));
      });

      final result = await repo.verifyPhoneNumber('+1234567890');

      expect(result, isA<Failure<String>>());
      final failure = result as Failure<String>;
      expect(failure.exception, isA<AuthException>());
      expect(
        (failure.exception as AuthException).code,
        'too-many-requests',
      );
    });

    test('verificationFailed with network-request-failed returns Failure with NetworkException',
        () async {
      when(mockAuth.verifyPhoneNumber(
        phoneNumber: anyNamed('phoneNumber'),
        verificationCompleted: anyNamed('verificationCompleted'),
        verificationFailed: anyNamed('verificationFailed'),
        codeSent: anyNamed('codeSent'),
        codeAutoRetrievalTimeout: anyNamed('codeAutoRetrievalTimeout'),
      )).thenAnswer((invocation) async {
        final verificationFailed = invocation
                .namedArguments[#verificationFailed]
            as void Function(fb.FirebaseAuthException);
        verificationFailed(TestFirebaseAuthException(
          code: 'network-request-failed',
        ));
      });

      final result = await repo.verifyPhoneNumber('+1234567890');

      expect(result, isA<Failure<String>>());
      expect((result as Failure).exception, isA<NetworkException>());
    });

    test('verificationCompleted (Android auto-verify) returns Success with auto-verified sentinel',
        () async {
      when(mockAuth.signInWithCredential(any))
          .thenAnswer((_) async => mockCredential);

      when(mockAuth.verifyPhoneNumber(
        phoneNumber: anyNamed('phoneNumber'),
        verificationCompleted: anyNamed('verificationCompleted'),
        verificationFailed: anyNamed('verificationFailed'),
        codeSent: anyNamed('codeSent'),
        codeAutoRetrievalTimeout: anyNamed('codeAutoRetrievalTimeout'),
      )).thenAnswer((invocation) async {
        final verificationCompleted = invocation
                .namedArguments[#verificationCompleted]
            as void Function(fb.PhoneAuthCredential);
        verificationCompleted(
          fb.PhoneAuthProvider.credential(
            verificationId: 'auto-id',
            smsCode: '123456',
          ),
        );
      });

      final result = await repo.verifyPhoneNumber('+1234567890');

      expect(result, isA<Success<String>>());
      expect((result as Success<String>).value, 'auto-verified');
    });

    test('generic exception thrown by verifyPhoneNumber returns Failure with NetworkException',
        () async {
      when(mockAuth.verifyPhoneNumber(
        phoneNumber: anyNamed('phoneNumber'),
        verificationCompleted: anyNamed('verificationCompleted'),
        verificationFailed: anyNamed('verificationFailed'),
        codeSent: anyNamed('codeSent'),
        codeAutoRetrievalTimeout: anyNamed('codeAutoRetrievalTimeout'),
      )).thenThrow(Exception('platform error'));

      final result = await repo.verifyPhoneNumber('+1234567890');

      expect(result, isA<Failure<String>>());
      expect((result as Failure).exception, isA<NetworkException>());
    });
  });

  // ---------------------------------------------------------------------------
  // signInWithPhoneCredential
  // ---------------------------------------------------------------------------

  group('signInWithPhoneCredential', () {
    test('success returns Success<AuthUser> with phone number', () async {
      when(mockAuth.signInWithCredential(any))
          .thenAnswer((_) async => mockCredential);

      final result =
          await repo.signInWithPhoneCredential('verification-id', '123456');

      expect(result, isA<Success<AuthUser>>());
      final user = (result as Success<AuthUser>).value;
      expect(user.uid, 'phone-uid');
      expect(user.phoneNumber, '+1234567890');
      expect(user.email, '');
    });

    test('invalid-verification-code returns Failure with AuthException',
        () async {
      when(mockAuth.signInWithCredential(any)).thenThrow(
        TestFirebaseAuthException(
          code: 'invalid-verification-code',
          message: 'The verification code is invalid.',
        ),
      );

      final result =
          await repo.signInWithPhoneCredential('verification-id', '000000');

      expect(result, isA<Failure<AuthUser>>());
      final failure = result as Failure<AuthUser>;
      expect(failure.exception, isA<AuthException>());
      expect(
        (failure.exception as AuthException).code,
        'invalid-verification-code',
      );
    });

    test('network-request-failed returns Failure with NetworkException',
        () async {
      when(mockAuth.signInWithCredential(any)).thenThrow(
        TestFirebaseAuthException(code: 'network-request-failed'),
      );

      final result =
          await repo.signInWithPhoneCredential('verification-id', '123456');

      expect(result, isA<Failure<AuthUser>>());
      expect((result as Failure).exception, isA<NetworkException>());
    });

    test('generic exception returns Failure with NetworkException', () async {
      when(mockAuth.signInWithCredential(any))
          .thenThrow(Exception('unexpected'));

      final result =
          await repo.signInWithPhoneCredential('verification-id', '123456');

      expect(result, isA<Failure<AuthUser>>());
      expect((result as Failure).exception, isA<NetworkException>());
    });
  });
}
