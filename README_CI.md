# Launchpad CI/CD Setup Guide

## Overview

This project ships with pre-built GitHub Actions workflows for continuous integration and automated QA distribution. The workflows are ready to use out of the box — each project that clones Launchpad only needs to complete the setup steps below before the workflows will run successfully.

| Workflow | File | Trigger | Purpose |
|---|---|---|---|
| Flutter CI | `.github/workflows/flutter_ci.yml` | Pull requests & pushes to `main` | Static analysis and tests |
| Distribute Android | `.github/workflows/distribute_android.yml` | Push to `main` only | Build signed APK and upload to Firebase App Distribution |
| Distribute iOS | `.github/workflows/distribute_ios.yml` | Push to `main` only | Build signed IPA and upload to Firebase App Distribution |

---

## Required GitHub Secrets

Navigate to your GitHub repository **Settings > Secrets and variables > Actions** and add the following secrets.

| Secret Name | What It Contains | How to Generate |
|---|---|---|
| `FIREBASE_SERVICE_ACCOUNT` | Full JSON contents of a Firebase/Google Cloud service account key with the **Firebase App Distribution Admin** role. | **Option A — Firebase Console:** Project Settings > Service Accounts > *Generate new private key*. **Option B — Google Cloud Console:** IAM & Admin > Service Accounts > create a new service account with the *Firebase App Distribution Admin* role > Keys > *Create key* (JSON). Copy the entire JSON file contents into the secret value. |
| `FIREBASE_ANDROID_APP_ID` | The Android app ID from Firebase (e.g. `1:123456789:android:abcdef`). | Firebase Console > Project Settings > *Your apps* > Android app > **App ID**. |
| `FIREBASE_IOS_APP_ID` | The iOS app ID from Firebase (e.g. `1:123456789:ios:abcdef`). Used by the iOS distribution workflow (US-42). | Firebase Console > Project Settings > *Your apps* > iOS app > **App ID**. |
| `GOOGLE_SERVICES_JSON` | Base64-encoded `google-services.json` for Android. | Download from Firebase Console > Project Settings > *Your apps* > Android > *google-services.json*. Base64-encode: **macOS:** `base64 -i google-services.json \| pbcopy` **Linux:** `base64 google-services.json`. |
| `GOOGLE_SERVICE_INFO_PLIST` | Base64-encoded `GoogleService-Info.plist` for iOS. | Download from Firebase Console > Project Settings > *Your apps* > iOS > *GoogleService-Info.plist*. Base64-encode the same way. |
| `FIREBASE_OPTIONS_DART` | Base64-encoded `lib/firebase_options.dart`. | Run `flutterfire configure` locally to generate the file, then base64-encode: **macOS:** `base64 -i lib/firebase_options.dart \| pbcopy` **Linux:** `base64 lib/firebase_options.dart`. |
| `ANDROID_KEYSTORE` | Base64-encoded contents of your release keystore file (`.jks`). | 1. Generate a keystore: `keytool -genkey -v -keystore release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias your-alias`. 2. Base64-encode it: **macOS:** `base64 -i release.jks \| pbcopy` **Linux:** `base64 release.jks`. 3. Paste the output into the secret value. |
| `ANDROID_KEY_ALIAS` | The alias you used when generating the keystore (e.g. `your-alias`). | The `-alias` value from the `keytool` command above. |
| `ANDROID_KEY_PASSWORD` | The key password set during keystore generation. | The password you entered when prompted by `keytool`. |
| `ANDROID_STORE_PASSWORD` | The store password set during keystore generation. | The password you entered when prompted by `keytool`. |
| `IOS_CERTIFICATE` | Base64-encoded Apple distribution certificate (`.p12`). | 1. Open **Keychain Access** on macOS. 2. Find your Apple Distribution certificate, right-click > *Export* as `.p12`. 3. Base64-encode: `base64 -i certificate.p12 \| pbcopy`. 4. Paste the output into the secret value. |
| `IOS_CERTIFICATE_PASSWORD` | The password set when exporting the `.p12` certificate from Keychain Access. | The password you entered during the `.p12` export step above. |
| `IOS_PROVISIONING_PROFILE` | Base64-encoded provisioning profile (`.mobileprovision`). | 1. Go to [Apple Developer Portal](https://developer.apple.com/account/resources/profiles/list) > *Profiles*. 2. Download the distribution provisioning profile for your app. 3. Base64-encode: `base64 -i profile.mobileprovision \| pbcopy`. 4. Paste the output into the secret value. |

---

## Firebase App Distribution Setup

1. **Enable App Distribution** — In the [Firebase Console](https://console.firebase.google.com/), select your project, then navigate to **Release & Monitor > App Distribution** and click *Get Started*.

2. **Create the `internal-qa` tester group:**
   - Go to App Distribution > **Testers & Groups**.
   - Click **Add group**, name it `internal-qa`.
   - Add tester email addresses to the group. Each tester will receive an email invitation to install builds.

3. **Add your apps** — Make sure both the Android and iOS apps are registered in Firebase Project Settings > *Your apps*. Note the **App ID** for each — these go into the `FIREBASE_ANDROID_APP_ID` and `FIREBASE_IOS_APP_ID` secrets.

---

## Android Workflow

**File:** `.github/workflows/distribute_android.yml`

**What it does:**

1. Triggers on every push (merge) to the `main` branch.
2. Checks out the code and sets up Flutter (pinned version).
3. Caches pub dependencies for faster builds.
4. Decodes Firebase config files (`google-services.json`, `firebase_options.dart`) from GitHub Secrets — these are gitignored and never committed to the repo.
5. Runs `flutter pub get`, code generation, and l10n generation.
6. Runs the full test suite — **if any test fails, the build is blocked**.
7. Decodes the release keystore from the `ANDROID_KEYSTORE` secret.
8. Builds a signed release APK with `--obfuscate` and `--split-debug-info`.
9. Generates release notes from Git metadata (see [Release Notes](#release-notes)).
10. Uploads the APK to Firebase App Distribution targeting the `internal-qa` group.
11. Cleans up the temporary keystore file (runs on both success and failure).

**Expected build time:** 5–10 minutes depending on dependency cache hits.

**Adding a new tester group:** In the workflow file, change the `groups` field in the Firebase Distribution step. Multiple groups can be comma-separated (e.g. `internal-qa, beta-testers`).

---

## Release Notes

Release notes are automatically generated from Git metadata on every distribution build. No manual input is required.

**Format:**

```
Build {short-SHA} · {branch} · {commit message}
```

Example: `Build a1b2c3d · main · Add user profile screen`

**Character limit:** Release notes are truncated to a maximum of 500 characters. When the message exceeds this limit, it is cut to 497 characters and `...` is appended. Notes shorter than 500 characters are left unchanged.

**Plain text only:** Firebase App Distribution renders release notes as plain text. The generation script does not introduce any Markdown, HTML, or emoji — what testers see is exactly what the script produces.

**Fallback behaviour:** The release notes step has `continue-on-error: true`. If it fails for any reason, the distribution step uses a fallback string: `Build {full-SHA} — release notes unavailable`. This ensures a release notes failure never blocks a build from reaching testers.

**Edge case — no prior commits:** If `git log` fails (e.g. on a repository with no commit history), the notes default to `Build {short-SHA} · initial build`.

**Customising the format:** To change the release notes format, edit the shell script in the `Generate release notes` step in the distribution workflow file directly. The script uses standard shell commands (`git rev-parse`, `git log`, string operations) and writes the result to `$GITHUB_OUTPUT`.

**Alternative: CHANGELOG.md-based release notes.** For projects that prefer curated release notes, replace the Git metadata script with a step that reads from a `CHANGELOG.md` file:

```yaml
- name: Generate release notes
  id: release_notes
  continue-on-error: true
  run: |
    NOTES=$(head -n 20 CHANGELOG.md 2>/dev/null) || NOTES="No changelog found."
    if [ ${#NOTES} -gt 500 ]; then
      NOTES="${NOTES:0:497}..."
    fi
    echo "notes=${NOTES}" >> "$GITHUB_OUTPUT"
```

This is a project-specific extension — it is not implemented in the template. Maintain a `CHANGELOG.md` at the repo root with the most recent entry at the top.

**iOS workflow:** The same release notes step is included in `distribute_ios.yml` with identical logic.

---

## iOS Workflow

**File:** `.github/workflows/distribute_ios.yml`

**What it does:**

1. Triggers on every push (merge) to the `main` branch.
2. Checks out the code and sets up Flutter (pinned version).
3. Caches pub dependencies for faster builds.
4. Runs `flutter pub get`, code generation, and l10n generation.
5. Runs the full test suite — **if any test fails, the build is blocked**.
6. Decodes Firebase config files (`GoogleService-Info.plist`, `firebase_options.dart`, `google-services.json`) from GitHub Secrets — these are gitignored and never committed to the repo.
7. Installs the Apple distribution certificate into a temporary macOS keychain.
8. Installs the provisioning profile to `~/Library/MobileDevice/Provisioning Profiles/`.
9. Builds a signed release IPA using `ios/ExportOptions.plist`.
10. Generates release notes from Git metadata (see [Release Notes](#release-notes)).
11. Uploads the IPA to Firebase App Distribution targeting the `internal-qa` group.
12. Cleans up all signing materials — keychain, certificate, and provisioning profile (runs on both success and failure).

**Expected build time:** 10–20 minutes depending on dependency cache hits. macOS runners are slower than Ubuntu runners.

**Adding a new tester group:** In the workflow file, change the `groups` field in the Firebase Distribution step. Multiple groups can be comma-separated (e.g. `internal-qa, beta-testers`).

### ExportOptions.plist Setup

The file `ios/ExportOptions.plist` is committed with placeholder values. Before the iOS workflow can build successfully, update the following fields:

| Field | Where to Find |
|---|---|
| `teamID` | Apple Developer Portal > Membership > **Team ID** (a 10-character alphanumeric string). |
| `method` | Use `ad-hoc` for Firebase App Distribution. Use `development` if you are using a development provisioning profile instead of a distribution one. Use `app-store` for TestFlight/App Store builds. |
| `YOUR_BUNDLE_ID` (key under `provisioningProfiles`) | The bundle identifier of your app (e.g. `com.template.templateApp`). Must match the value in `ios/Runner.xcodeproj`. |
| `YOUR_PROVISIONING_PROFILE_NAME` (value under `provisioningProfiles`) | Apple Developer Portal > Profiles > select your profile > the **Name** field (not the UUID). |

### Certificate Setup

1. Open **Keychain Access** on your Mac.
2. Find your **Apple Distribution** certificate (or **iOS Distribution** for older accounts).
3. Right-click the certificate > **Export**. Choose `.p12` format and set a password.
4. Base64-encode the `.p12` file: `base64 -i certificate.p12 | pbcopy` (macOS).
5. Add the base64 string as the `IOS_CERTIFICATE` GitHub secret.
6. Add the password you set in step 3 as the `IOS_CERTIFICATE_PASSWORD` GitHub secret.

### Provisioning Profile Setup

1. Go to [Apple Developer Portal > Profiles](https://developer.apple.com/account/resources/profiles/list).
2. Create or download an **Ad Hoc** distribution provisioning profile for your app.
3. Base64-encode the `.mobileprovision` file: `base64 -i profile.mobileprovision | pbcopy` (macOS).
4. Add the base64 string as the `IOS_PROVISIONING_PROFILE` GitHub secret.

### Provisioning Profile Expiry

Provisioning profiles expire after one year. When the iOS workflow fails with a signing error, **check profile expiry first** — this is the most common cause. Signs of an expired profile in the Xcode build log output in GitHub Actions:

- `error: Provisioning profile "..." has expired`
- `error: No signing certificate "iOS Distribution" found`

To fix: download a renewed profile from the Apple Developer Portal, re-encode it, and update the `IOS_PROVISIONING_PROFILE` secret.

---

## macOS Runner Cost

macOS runners on GitHub Actions hosted infrastructure cost approximately **10x more per minute** than Ubuntu runners. For teams that merge frequently to `main`, this can add up.

**Self-hosted runners:** For high-frequency merge teams, consider setting up a self-hosted macOS runner to reduce costs. See [GitHub's self-hosted runner documentation](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/about-self-hosted-runners) for setup instructions. The `distribute_ios.yml` workflow works on self-hosted runners without modification — just change `runs-on: macos-latest` to `runs-on: self-hosted` (or your custom label).

---

## Maintaining the Flutter Version Pin

The Flutter version is pinned in all three workflow files:

- `.github/workflows/flutter_ci.yml`
- `.github/workflows/distribute_android.yml`
- `.github/workflows/distribute_ios.yml`

**When upgrading Flutter, update the `flutter-version` value in all three workflow files at the same time.** A version mismatch between workflows can cause inconsistent behavior — tests may pass in CI but the distribution build may fail (or vice versa).

The current pinned version is **`3.41.2`**.

---

## Extending the Pipeline

The workflows above cover the core CI and QA distribution flow. Here are common extensions you can add as your project grows:

- **Staging track** — Duplicate the distribution workflow and change the `groups` field to a `staging-testers` group. Optionally trigger on a `release/*` branch pattern instead of `main`.

- **Slack notifications** — Add a step at the end of the distribution job using an action like `slackapi/slack-github-action` to post a message to a Slack channel when a new build is available.

- **Google Play Internal Track** — Replace the Firebase App Distribution step with `r0adkll/upload-google-play@v1` to upload the AAB to Google Play's internal testing track. You will need to build an AAB (`flutter build appbundle`) instead of an APK and add a `GOOGLE_PLAY_SERVICE_ACCOUNT` secret.

- **Automated release notes** — Release notes are generated from Git metadata automatically. See the [Release Notes](#release-notes) section above for the format and how to customise it, including the CHANGELOG.md-based alternative.

- **TestFlight distribution** — To distribute iOS builds via TestFlight instead of Firebase App Distribution, change the `method` in `ios/ExportOptions.plist` to `app-store` and replace the Firebase upload step with `apple-actions/upload-testflight-build@v1`. You will need an App Store Connect API key stored as a GitHub secret.

- **Build number auto-increment** — For projects that need unique build numbers on every CI run, add a step before the build that writes the GitHub Actions run number into the version: `flutter build ipa --build-number=${{ github.run_number }}`. This is a project-specific extension — the template uses the version from `pubspec.yaml` by default.
