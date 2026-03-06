# Phone Authentication

SMS-based phone authentication gated by a Firebase Remote Config feature flag (`phone_auth_enabled`). Users enter a phone number with a country code picker, receive an SMS verification code, and enter a 6-digit OTP to sign in. The feature is disabled by default and requires Firebase Blaze plan for SMS delivery.

## Enabling Phone Auth

Phone authentication is controlled by the `phone_auth_enabled` Remote Config flag. When `false` (default), the phone sign-in button is hidden from the login screen.

To enable:

1. In the **Firebase Console** → **Remote Config**, create a `phone_auth_enabled` parameter and set it to `true`
2. Click **Publish changes**
3. Restart the app — the phone sign-in button appears on the login screen

The default value is registered in `lib/core/constants/remote_config_defaults.dart`:

```dart
static const Map<String, dynamic> defaults = {
  'phone_auth_enabled': false,
};
```

No code changes are needed to toggle the feature — only the Remote Config value.

## Firebase Console Setup

1. **Enable Phone sign-in method** — go to **Firebase Console** → **Authentication** → **Sign-in method** → enable **Phone**
2. **Add test phone numbers** (recommended for development) — in the Phone provider settings, add test phone numbers with fixed verification codes. This avoids SMS charges and rate limits during development
3. **Enable App Check enforcement** (optional) — if App Check is enforced for Authentication, ensure debug tokens are registered for all development devices

## Firebase Plan Requirement

Phone authentication requires the **Firebase Blaze (pay-as-you-go) plan**. The Spark (free) plan does not support SMS delivery.

SMS costs vary by country. As of 2026, Firebase charges per SMS sent (verification) and per SMS received (auto-verification on Android). Check the [Firebase pricing page](https://firebase.google.com/pricing) for current rates.

### Cost Mitigation

- Use **test phone numbers** in the Firebase Console during development — these do not send real SMS messages
- Set **rate limits** in Firebase Console → Authentication → Settings to prevent abuse
- Consider adding a **CAPTCHA** or rate-limiting layer before calling `verifyPhoneNumber` in production

## Country Code List

The country code picker uses a curated list defined in `lib/features/phone_auth/models/country_code.dart`. The default list includes 20 countries (UAE, US, UK, Saudi Arabia, Egypt, India, Germany, France, Italy, Spain, Canada, Australia, Pakistan, Bangladesh, Indonesia, Turkey, Brazil, Mexico, Japan, South Korea).

### Adding a Country

Add an entry to the `CountryCode.all` list:

```dart
CountryCode(name: 'Nigeria', dialCode: '+234', flag: '🇳🇬', code: 'NG'),
```

### Default Country

The phone input screen auto-selects the country matching the device locale. If no match is found, it falls back to the first entry in the list (UAE). To change the fallback, reorder the `all` list or modify `_defaultCountryFromLocale()` in `phone_input_screen.dart`.

## How to Disable Completely

To remove phone authentication from your project:

1. Remove the `phone_auth_enabled` entry from `RemoteConfigDefaults.defaults`
2. Remove the phone sign-in button block from `login_screen.dart` (the `if (ref.watch(...).getBool('phone_auth_enabled'))` block)
3. Remove the `/phone-input` and `/otp` routes from `lib/routing/router.dart`
4. Remove `'/phone-input'` and `'/otp'` from the `isAuthRoute` check in the router redirect function
5. Optionally delete `lib/features/phone_auth/` entirely

## Router Guard Behavior

Phone-authenticated users bypass the email verification gate. The router redirect function checks:

```dart
final needsVerification = user.email.isNotEmpty &&
    _authRepository.currentSignInProvider == 'password' &&
    !user.emailVerified;
```

Phone auth users have an empty email string and a provider of `'phone'`, so `needsVerification` is always `false` — they proceed directly to `/home` after sign-in.

The `/phone-input` and `/otp` routes are included in the `isAuthRoute` set, so they are treated like `/login` and `/signup` — unauthenticated users can access them, and authenticated users are redirected away from them to `/home`.

## Android Auto-Verification

On Android, Firebase can automatically verify the phone number without user interaction if:

1. The device has Google Play Services
2. The SMS is received on the same device
3. The SMS format matches Firebase's expected pattern

When auto-verification succeeds:

1. The `verificationCompleted` callback fires with a `PhoneAuthCredential`
2. The repository automatically calls `signInWithCredential(credential)`
3. `verifyPhoneNumber()` returns `'auto-verified'` as the verification ID
4. The phone input screen detects this sentinel value and skips OTP navigation — the auth state change triggers the router to navigate to `/home`

Auto-verification is Android-only. On iOS, users always enter the OTP manually.

## Limitations

- **No account linking** — if a phone number is already associated with another account, sign-in fails with a `credential-already-in-use` error. Account linking/migration is not implemented.
- **No phone number change** — there is no UI to update a phone-authenticated user's phone number after sign-in. This would require re-verification with the new number.
- **SMS delivery** — SMS delivery is subject to carrier restrictions, country-specific regulations, and Firebase rate limits. Some countries may have higher failure rates.
- **Rate limiting** — Firebase enforces per-IP and per-phone-number rate limits on SMS sends. The `too-many-requests` error is surfaced to the user with a localized message.
- **No reCAPTCHA fallback on iOS** — Firebase may require reCAPTCHA verification on iOS in some cases (e.g. when APNs is not configured). The current implementation does not handle the reCAPTCHA flow. Ensure APNs is configured to avoid this — see the Push Notifications section in the main README.
