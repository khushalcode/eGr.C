# App Store Rejection Fixes — Summary

This document summarises every change made to address the three App Store
rejection issues reported by Apple Review on **Sep 8, 2026** for the
**OTW Grocery App** (bundle: `com.otwgrocers`).

---

## Issue 1 — Guideline 5.1.1(v) — Forced login to browse products

> *"The app requires users to register or log in to access features that are
> not account based. Specifically, the app requires users to register before
> browsing products."*

### Root cause
- `lib/screens/splashScreen.dart` — when a user opened the app for the first
  time (no `keySkipLogin` flag, not logged in), the splash screen always
  redirected them to `loginAccountScreen`, blocking product browsing.
- `lib/screens/introSliderScreen.dart` — both the "Skip" button and the
  "Get Started" button on the last intro slide also forced the user to
  `loginAccountScreen`.
- A "Skip" button already existed on the login screen, but it was small,
  semi-transparent, and tucked into the top-right corner — easy for the
  reviewer to miss on iPad.

### Fix
1. **splashScreen.dart** — in both the Android and iOS branches, when the
   user is not logged in and has not yet explicitly skipped login, the app
   now sets `keySkipLogin = true` and navigates to `mainHomeScreen` so the
   user lands directly on the product browsing experience.
   Login is only ever required for account-based actions (add-to-cart,
   checkout, wishlist, etc.), where the app already redirects the user to
   `loginAccountScreen` with the appropriate `from` argument.
2. **introSliderScreen.dart** — both the "Skip" button (slide 0) and the
   "Get Started" button (final slide) now navigate to `mainHomeScreen`
   instead of `loginAccountScreen`, and set `keySkipLogin = true`.
3. **loginAccountScreen.dart** — the existing top-right Skip button is now
   visually prominent (filled white card, coloured border, drop shadow,
   larger padding, chevron icon) and positioned using
   `MediaQuery.of(context).padding.top + 10` so it never collides with the
   iPad notch / status bar. A second full-width "Skip" `OutlinedButton` was
   added at the bottom of the form so the option is impossible to miss
   for App Review.

### Files changed
- `lib/screens/splashScreen.dart`
- `lib/screens/introSliderScreen.dart`
- `lib/screens/loginAccountScreen/loginAccountScreen.dart`

---

## Issue 2 — Guideline 2.1(a) / 2.1(i) — App crashed on sign-up (iPad)

> *"The app crashed when we attempted to sign up with the credentials
> provided, we were unable to proceed." (iPad Air 3, iOS 18.1)*

### Root cause
Several `!` null-assertions on the `CountryCode` object and on
`FirebaseAuthException.message` could crash if `CountryCodePicker.onInit`
had not yet fired by the time the user tapped "Login" / "Register"
(typical on slower iPad hardware). The `firebaseAuth.verifyPhoneNumber`
call was also unguarded — any unexpected `PlatformException` would crash
the app outright.

Additional iPad-specific risks:
- `Scaffold(resizeToAvoidBottomInset: false)` combined with a tall form
  meant the on-screen keyboard could cover form fields and trigger
  layout overflow on iPad's taller screens.
- `PositionedDirectional(top: 40, end: 10)` for the Skip button did not
  account for the iPad safe-area, so the button could end up under the
  notch / status bar.
- `fcmToken!` could throw if FCM token retrieval failed.

### Fix
1. **loginAccountScreen.dart** —
   - `Scaffold.resizeToAvoidBottomInset` changed from `false` → `true`.
   - The `Stack` is now wrapped in `SafeArea` (with `top: false, bottom: false`
     so the form can still extend edge-to-edge, but the Skip button stays
     clear of the notch).
   - Skip button repositioned with `MediaQuery.of(context).padding.top + 10`.
   - `firebaseLoginProcess()` now performs an explicit null check on
     `selectedCountryCode` and `selectedCountryCode!.dialCode` before
     calling `verifyPhoneNumber`, showing a friendly toast instead of
     crashing.
   - `firebaseAuth.verifyPhoneNumber` is wrapped in `try / catch` so any
     `PlatformException` / `FirebaseAuthException` that escapes the
     `verificationFailed` callback is shown as a toast rather than
     crashing the app.
   - `e.message!` → `e.message ?? getTranslatedValue(context, somethingWentWrongLabel)`.
   - `sendCustomOTPSmsProvider` is also wrapped in `try / catch`.
   - `fcmToken!` → `fcmToken ?? ""` in `callLoginApi`.

2. **editProfileScreen.dart** (the registration form — also reachable from
   "Register Now" on the login screen) — same hardening applied:
   - Null check on `selectedCountryCode` before `verifyPhoneNumber`.
   - `verifyPhoneNumber` wrapped in `try / catch`.
   - `sendCustomOTPSmsProvider` wrapped in `try / catch`.
   - `e.message!` → `e.message ?? "..."`.
   - All `selectedCountryCode!.dialCode.toString()` calls in active code
     paths replaced with `(selectedCountryCode?.dialCode ?? "").toString()`.

3. **otpVerificationScreen.dart** —
   - `verifyPhoneNumber` wrapped in `try / catch`.
   - `e.message!` → `e.message ?? "..."`.

4. **forgotPasswordScreen.dart** —
   - Null check on `selectedCountryCode` before `verifyPhoneNumber`.
   - `verifyPhoneNumber` wrapped in `try / catch`.
   - `sendCustomOTPSmsProvider` wrapped in `try / catch`.
   - `e.message!` → `e.message ?? "..."`.
   - All `selectedCountryCode!.dialCode.toString()` calls in active code
     paths replaced with `(selectedCountryCode?.dialCode ?? "").toString()`.

### Files changed
- `lib/screens/loginAccountScreen/loginAccountScreen.dart`
- `lib/screens/editProfileScreen.dart`
- `lib/screens/otpVerificationScreen.dart`
- `lib/screens/forgotPasswordScreen.dart`

---

## Issue 3 — Guideline 2.3.8 — App name mismatch

> *"Marketplace app name: OTW Grocery App. Name displayed on the device:
> eGrocer. Change one or both names so they are more similar."*

### Root cause
- `ios/Runner/Info.plist` had `CFBundleDisplayName = eGrocer` and
  `CFBundleName = OTW Grocers`.
- `android/app/src/main/AndroidManifest.xml` had
  `android:label = "OTW Grocers"`.

### Fix
- `ios/Runner/Info.plist` — `CFBundleDisplayName` and `CFBundleName` both
  set to `OTW Grocery App`.
- `android/app/src/main/AndroidManifest.xml` — `android:label` set to
  `OTW Grocery App` (kept consistent across platforms).

### Why the first submission still showed "eGrocer" on the device (v2 fix)
Apple's reviewer reported the SAME name mismatch on Sep 14, 2026 even after
the first fix. Investigation showed:
- The `Info.plist` change was correct, BUT
- Xcode's build settings can override `Info.plist` values via
  `INFOPLIST_KEY_CFBundleDisplayName`. When the user re-archived the app
  in Xcode, the OLD `eGrocer` value was still being inherited from the
  cached build settings / DerivedData.
- The build number was not bumped, so App Store Connect may have used
  a cached `.ipa` from the previous submission.

### Additional fix (v2)
1. Added `INFOPLIST_KEY_CFBundleDisplayName = "OTW Grocery App"` directly
   as a build setting in all three target build configurations (Debug,
   Release, Profile) in `ios/Runner.xcodeproj/project.pbxproj`. This
   forces Xcode to inject the correct display name into the final
   `Info.plist` regardless of any stale cached values.
2. Bumped `CURRENT_PROJECT_VERSION` from `13` → `14` in all three target
   configurations in `project.pbxproj`.
3. Bumped the Flutter build number in `pubspec.yaml` from `1.0.0+1` →
   `1.0.0+2` so `FLUTTER_BUILD_NUMBER` is regenerated and a NEW archive
   must be uploaded to App Store Connect.

### Files changed (v1 + v2)
- `ios/Runner/Info.plist`
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner.xcodeproj/project.pbxproj`
- `pubspec.yaml`

### MANDATORY build steps before re-submitting (do ALL of these)
1. Replace your local project with this zip (do not merge — overwrite).
2. `cd` into the project root and run:
   ```
   flutter clean
   flutter pub get
   ```
3. iOS only — refresh the CocoaPods cache so stale `Info.plist` values
   don't leak into the new build:
   ```
   cd ios
   rm -rf Pods Podfile.lock
   pod cache clean --all
   pod install
   cd ..
   ```
4. Open `ios/Runner.xcworkspace` in Xcode and do
   **Product → Clean Build Folder** (`Cmd + Shift + K`).
5. In Xcode, confirm the display name:
   - Select the **Runner** target → **General** tab →
     **Identity** → **Name** should read **OTW Grocery App**.
   - Select **Build Settings** → search for `CFBundleDisplayName` →
     value should be **OTW Grocery App** in all three configurations.
6. **Product → Archive** to produce a fresh `.xcarchive`.
7. In the Xcode Organizer window, click **Distribute App → App Store Connect**.
   Upload the NEW archive — do NOT select an old build from the list.
8. In App Store Connect, ensure the new uploaded build (build #14 / +2)
   is selected as the build for the next review, then click **Submit for Review**.

---

## How to verify before re-submitting

1. Run `flutter clean && flutter pub get` to refresh the build cache.
2. `flutter analyze` — should report no new errors compared to the
   baseline project.
3. `flutter build ios --no-codesign` to confirm the iOS build compiles.
4. Run the app on an iPad simulator (iPad Air 11-inch (M3) and iPad Air 3
   to match Apple's review devices):
   - First launch should land directly on the home screen with the product
     catalogue visible — **no login wall**.
   - The Skip button on the login screen (reachable via the profile tab →
     "Login") should be clearly visible at the top-right and also at the
     bottom of the form.
   - Attempt to add an item to cart → app should redirect to the login
     screen (this is the expected, App-Review-compliant behaviour for
     account-based actions).
   - Attempt to sign up with an invalid phone number / wrong OTP → app
     should show a toast, **not crash**.
5. After installing the build, the device home screen should show the app
   label **"OTW Grocery App"** — identical to the App Store listing name.

---

## Pre-existing project notes

- The Skip button on the login screen and the `keySkipLogin` session flag
  were already part of the original codebase — the fixes above simply make
  them more prominent and ensure users reach the home screen by default
  rather than being forced to the login screen.
- The `SessionManager._performLogout()` method still navigates to
  `loginAccountScreen` after logout (intentional — a logged-out user
  should explicitly choose to log in again or skip).
- No changes were made to any payment / order / wallet code paths.
