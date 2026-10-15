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

---

## v4 fixes (Sep 22, 2026 — crash on phone login + Sign in with Apple)

Apple rejected the customer app AGAIN on Sep 22, 2026 with two new
crashes on iPad Air 11-inch (M3) and iPhone 17 Pro Max running iOS 27.0:

1. **Guideline 2.1(a) — App crashed** when typing a phone number and
   tapping the Login button.
2. **Guideline 2.1(a) — App Completeness bug** — "We were unable to
   progress from the login page after using Sign in with Apple."

### Root cause #1 — phone login crash

The login screen accessed `context.read<AppSettingsProvider>().settingsData!.phoneAuthPassword`
in 8 places using the `!` null-assertion operator. `settingsData` is a
nullable `SettingsData?` field that is only populated AFTER the
`AppSettingsProvider.getAppSettingsProvider()` async API call completes.

When a user navigated directly to the login screen (e.g., from the cart
"Login to checkout" button) and tapped Login before the settings had
finished loading, `settingsData` was still `null` and `settingsData!.X`
threw a null-check exception, crashing the app.

The same `settingsData!` pattern existed in `editProfileScreen.dart`,
`forgotPasswordScreen.dart`, and `otpVerificationScreen.dart`.

Additionally, `_formKey.currentState!.save()` and `_formKey.currentState!.validate()`
in the login button callback could crash if the form hadn't been built
yet on slower iPad hardware.

### Root cause #2 — Sign in with Apple hang

The Apple Sign In button used `signInWithApple(...).then((value) {...})`
with no `.catchError(...)` handler. If the user cancelled the Apple
sign-in sheet (which throws `AuthorizationErrorCode.canceled`), or if
`SignInWithApple.getAppleIDCredential` threw any other error (network
failure, iOS 27 quirk, etc.), the `.then()` callback never ran and
`isLoading` stayed `true` forever — the spinner spun forever and the
user "could not progress from the login page".

The underlying `signInWithApple` helper also had `!` null-assertions on
`userCredential.additionalUserInfo!.isNewUser`, `userCredential.user!.displayName`,
and `credential.identityToken` — all of which can be null on iOS 27 when
the user re-authenticates with Face ID/Touch ID.

### Fix applied (v4)

1. **`lib/helper/utils/generalMethods.dart`** — `signInWithApple()`:
   - Null-safe `credential.identityToken` (throw a friendly error if null)
   - Null-safe `userCredential.additionalUserInfo` and `userCredential.user`
   - Wrap `user.updateDisplayName(...)` in try/catch so a stale session
     doesn't crash the whole sign-in flow.

2. **`lib/screens/loginAccountScreen/loginAccountScreen.dart`**:
   - Apple Sign In button: rewrote the `onPressed` callback to use
     `try { await signInWithApple(...) } catch (e) { ... }` instead of
     `.then()` with no error handler. The `catch` block clears
     `isLoading` so the spinner never hangs. Cancels are silently
     swallowed; real errors show a toast.
   - Set `isLoading = true` BEFORE calling `signInWithApple` so the user
     sees a spinner immediately when they tap the button.
   - All 8 `settingsData!.X` accesses replaced with null-safe
     `(settingsData?.X ?? "0")`. When settings haven't loaded, the safer
     code path runs (treats phoneAuthPassword / firebaseAuthentication
     as disabled, falls back to OTP-only flow).
   - `proceedBtn` callback: null-safe `_formKey.currentState` — shows a
     "something went wrong" toast instead of crashing if the form
     hasn't been built yet.
   - Wrapped the entire login callback in `try/catch` as a safety net
     so ANY unexpected exception shows a toast instead of crashing.

3. **`lib/screens/editProfileScreen.dart`** (registration form):
   - All 5 `settingsData!.X` accesses replaced with null-safe versions.
   - `_formKey.currentState!.save()` / `.validate()` made null-safe.

4. **`lib/screens/forgotPasswordScreen.dart`**:
   - All 3 `settingsData!.X` accesses replaced with null-safe versions.

5. **`lib/screens/otpVerificationScreen.dart`**:
   - All 4 `settingsData!.X` accesses replaced with null-safe versions.

### Build number bumped again

- `ios/Runner.xcodeproj/project.pbxproj` — `CURRENT_PROJECT_VERSION`
  14 → 15 (all 3 configs: Debug / Release / Profile).
- `pubspec.yaml` — `version: 5.0.0+2` → `version: 5.0.0+3`.

This forces App Store Connect to require a fresh archive upload — the
old build #14 will not be accepted.

### Files changed (v4)

| File | Change |
|---|---|
| `lib/helper/utils/generalMethods.dart` | `signInWithApple()` null-safe (identityToken, additionalUserInfo, user, updateDisplayName) |
| `lib/screens/loginAccountScreen/loginAccountScreen.dart` | Apple Sign In button try/catch + null-safe settingsData (×8) + null-safe formKey + try/catch around login callback |
| `lib/screens/editProfileScreen.dart` | null-safe settingsData (×5) + null-safe formKey |
| `lib/screens/forgotPasswordScreen.dart` | null-safe settingsData (×3) |
| `lib/screens/otpVerificationScreen.dart` | null-safe settingsData (×4) |
| `ios/Runner.xcodeproj/project.pbxproj` | `CURRENT_PROJECT_VERSION` 14 → 15 |
| `pubspec.yaml` | `version: 5.0.0+2` → `5.0.0+3` |

### How to verify before re-submitting (v4 specific)

On a physical iPad Air / iPhone 17 Pro Max (iOS 27):

1. **Phone login crash**: Open the app → tap Profile → Login → type the
   demo phone number → tap Login. The app should NOT crash even if
   settings haven't loaded. If settings aren't loaded yet, you should
   see a "something went wrong" toast, not a crash.
2. **Sign in with Apple**: Tap "Continue with Apple" → cancel the Apple
   sheet by tapping "Cancel". The spinner should disappear, the login
   screen should be usable again (no infinite spinner).
3. **Sign in with Apple (success path)**: Tap "Continue with Apple" →
   complete the sign-in with a real Apple ID. The spinner should appear
   briefly, then `backendApiProcess` should fire and take the user to
   the registration / home screen.

---

## v5 fixes (Oct 15, 2026 — crash on iPad Air 11-inch M3 / iPadOS 27.2 sign-in)

Apple rejected the customer app AGAIN on Oct 14, 2026 (review date),
build 1.0 (3) / pubspec `19.0.0+3`, with:

> Guideline 2.1(a) - Performance — App Completeness
> The app crashed when we attempted to sign in with the credentials
> provided, we were unable to proceed.
> Device: iPad Air 11-inch (M3), iPadOS 27.2

### Root cause analysis

After auditing the entire sign-in flow on iPad/iOS 27, six independent
crash / hang points were identified. Any one of them could trigger the
rejection — together they almost guaranteed a crash during Apple's
review pass on an iPad without a SIM card.

#### 1. `KeyboardOverlay.showOverlay()` could crash during focus transitions

`lib/helper/utils/keyboardOverlay.dart` called `Overlay.of(context)`
without `rootOverlay: true` and without any null / mounted check. On
iPad/iOS 27, during the keyboard show / hide cycle that fires when the
reviewer tapped the phone field, `Overlay.of(context)` could return an
unmounted `OverlayState` (because the focus listener runs outside the
build pipeline). Inserting an `OverlayEntry` into an unmounted state
threw a `StateError` → app crashed.

#### 2. `showMessage()` had the same Overlay fragility

`lib/helper/utils/generalMethods.dart` `showMessage()` — the helper
used by EVERY error toast in the app — also did
`Overlay.of(context).insert(...)` without a null / mounted check. So
even if the underlying auth / API code handled an error gracefully,
showing the error toast itself could crash on iPad.

#### 3. `firebaseLoginProcess()` could hang forever

In `lib/screens/loginAccountScreen/loginAccountScreen.dart` (and the
parallel implementations in `editProfileScreen.dart` and
`forgotPasswordScreen.dart`), the phone-login flow had this structure:

```
if (phoneAuthPassword == "1")        { callLoginApi(); }
else if (firebaseAuthentication == "1") { verifyPhoneNumber(); }
else if (customSmsGatewayOtpBased == "1") { sendCustomOTPSms(); }
// NO else BRANCH — isLoading stayed true forever
```

If the backend returned `phoneAuthPassword=0`, `firebaseAuthentication=0`,
and `customSmsGatewayOtpBased=0` (e.g., settings hadn't loaded yet, or
the admin disabled all phone auth methods), the spinner spun forever
and Apple reported "unable to proceed".

#### 4. `firebaseAuth.currentUser!` null-assertions in `callLoginApi`

`lib/screens/loginAccountScreen/loginAccountScreen.dart` lines 1224,
1237–1240 used `firebaseAuth.currentUser!.photoURL.toString()`,
`firebaseAuth.currentUser!.displayName ?? ""`, etc. On iOS 27, the
Firebase Auth state can lag behind the Google Sign-In result by a
run-loop cycle — `currentUser` is briefly null right after a successful
`signInWithCredential`. The `!` then crashed the app.

#### 5. `otpVerificationScreen.dart` `selectedCountryCode.code!` null-assertion

`lib/screens/otpVerificationScreen.dart` line 241 used
`widget.selectedCountryCode.code!` to populate
`initialCountryCode`. `code` is nullable on the `CountryCode` model,
and on iPad/iOS 27 with a slow `CountryCodePicker.onInit`, `code` was
still null when the resend-OTP path fired → crash.

The same file also had `widget.selectedCountryCode.dialCode.toString()`
(without null-safe access) used inside a `replaceAll` — when `dialCode`
was null, `.toString()` returned the string `"null"` and the
`replaceAll` silently corrupted the phone number sent to the backend.

#### 6. `otpVerificationScreen.firebaseLoginProcess()` sent an invalid phone-number format

The OTP resend path built the phone number as
`'${widget.selectedCountryCode.dialCode} - ${widget.phoneNumber}'`
(with spaces around the dash). Firebase rejected this format and
fired `verificationFailed`. On iPad/iOS 27 with no APNs token bridge
(see #7 below), the failure cascade crashed the app via the broken
toast path (#2).

#### 7. iOS APNs token was not bridged to Firebase

`ios/Runner/AppDelegate.swift` did not implement
`application(_:didRegisterForRemoteNotificationsWithDeviceToken:)`,
and `Info.plist` has `FirebaseAppDelegateProxyEnabled = false`. With
the proxy disabled, Firebase phone auth requires the host app to
manually forward the APNs device token via `Messaging.apnsToken =
deviceToken`. Without this bridge, `verifyPhoneNumber` failed with
`auth/missing-apns-token` on every iPad (which has no SIM and
therefore must use the silent-push path for Firebase phone auth).

#### 8. `setUserDataInSession` / `updateUserDataInSession` could crash on missing JSON fields

`lib/provider/userProfileProvider.dart` used
`int.parse(userData[ApiAndParams.status].toString())` and
`as Map<String, dynamic>` casts. If the backend's user object was
missing `status`, `balance`, `type`, or `access_token`, `int.parse`
threw `FormatException` or the cast threw `TypeError` — crashing the
app immediately after a successful login.

### Fix applied (v5)

1. **`lib/helper/utils/keyboardOverlay.dart`** — rewrote `showOverlay()`:
   - Use `Overlay.of(context, rootOverlay: true)` so we always target
     the root overlay, not a transient nested one.
   - Wrap `Overlay.of` in `try / catch` and explicit null + mounted
     checks. If the overlay is unavailable, silently skip (the system
     keyboard still works).
   - Wrap the `overlayState.insert(...)` call in `try / catch` and
     reset `_overlayEntry` on failure so the next focus event can retry.
   - `removeOverlay()` is also wrapped in `try / catch`.

2. **`lib/helper/utils/generalMethods.dart`** — rewrote `showMessage()`:
   - Same overlay-state hardening as `KeyboardOverlay`.
   - If the Overlay is unavailable / unmounted, fall back to
     `ScaffoldMessenger.showSnackBar` so the user still sees the
     message.
   - If even SnackBar fails, silently ignore — a toast must never
     crash the app.

3. **`lib/screens/loginAccountScreen/loginAccountScreen.dart`**:
   - **Hang fix**: `firebaseLoginProcess()` now has an explicit `else`
     branch that resets `isLoading = false` and shows a "something
     went wrong" toast. The spinner can no longer spin forever.
   - **Empty-input safety**: added an outer `else` branch for when
     `editMobileTextEditingController.text` is empty — also resets
     the spinner.
   - **mounted checks** added to every `setState` inside async
     callbacks (`verificationFailed`, `codeSent`,
     `codeAutoRetrievalTimeout`).
   - **`callLoginApi` hardened**: the entire `.then(...)` callback is
     wrapped in `try / catch` so any unexpected exception shows a
     toast instead of crashing. All `firebaseAuth.currentUser!.X`
     accesses replaced with `firebaseAuth.currentUser?.X ?? ""` /
     `?? false`. `user.email.toString()` replaced with
     `user.email?.toString() ?? ""`.
   - **`fcmToken`** (which can be null) replaced with `fcmToken ?? ""`
     in the registration-redirect params map.
   - **`sendCustomOTPSmsProvider` params**: `"$selectedCountryCode..."`
     (which interpolated the `CountryCode` object as
     `Instance of 'CountryCode'`) replaced with
     `"$dialCode..."` where `dialCode =
     (selectedCountryCode?.dialCode ?? "").toString()`.

4. **`lib/screens/otpVerificationScreen.dart`**:
   - **`code!` → `(code ?? "").toString()`** — the null-assertion that
     crashed the resend-OTP path on iPad is gone.
   - **`dialCode.toString()` inside `replaceAll`** replaced with
     `final dialCodeStr = (widget.selectedCountryCode.dialCode ?? "").toString();`
     then `dialCodeStr.replaceAll("+", "")`. No more `"null"` string
     leaking into API payloads.
   - **`containKey` typo fixed** → `containsKey`. The previous typo
     would have thrown a `NoSuchMethodError` if the resend-OTP custom-
     SMS path was ever actually executed.
   - **`value[ApiAndParams.status]`** is now guarded by
     `if (value is Map && ...)` because `sendCustomOTPSmsProvider`
     can return the string `"0"` on error (per its catch block), and
     indexing a string would crash.
   - **`user.phoneNumber.toString()`** made null-safe via
     `(user.phoneNumber ?? "").toString()`.
   - **`firebaseLoginProcess()` phone-number format** corrected from
     `'+91 - 8434207055'` (invalid) to `'+918434207055'` (E.164).
   - **`mounted` checks** added to every callback.

5. **`lib/screens/editProfileScreen.dart`** (registration form):
   - **Hang fix**: explicit `else` branch when neither firebase nor
     custom-SMS is enabled — resets spinner, shows toast.
   - **Empty-input safety**: outer `else` for empty phone.
   - **`sendCustomOTPSmsProvider` params** made null-safe (same
     `dialCode` fix as login screen).
   - **`mounted` checks** added to every async callback.

6. **`lib/screens/forgotPasswordScreen.dart`**:
   - Same hang fix, same `dialCode` null-safety, same `mounted` checks.

7. **`lib/provider/userProfileProvider.dart`**:
   - `setUserDataInSession` rewritten: every field read uses
     `(userData[key] ?? default).toString()` and the `int.parse` on
     `status` is replaced with `int.tryParse(...) ?? 0`. The two
     `as Map<String, dynamic>` casts at the top are replaced with
     `is Map<String, dynamic>` runtime checks that bail out cleanly
     if the JSON shape is unexpected.
   - `updateUserDataInSession` got the same treatment.

8. **`ios/Runner/AppDelegate.swift`** — rewrote the iOS bootstrap:
   - Added `import FirebaseMessaging` and `import UserNotifications`.
   - Set `FirebaseMessaging.delegate = self` so Firebase can receive
     APNs tokens and remote-notification payloads even with the app
     proxy disabled.
   - Implemented
     `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)`
     that calls `Messaging.apnsToken = deviceToken`. This is the
     missing bridge that caused `verifyPhoneNumber` to fail with
     `auth/missing-apns-token` on iPad.
   - Implemented
     `application(_:didFailToRegisterForRemoteNotificationsWithError:)`
     that logs the error (so we can debug) but does NOT crash.
   - Called `application.registerForRemoteNotifications()` in
     `didFinishLaunchingWithOptions` so iOS prompts the APNs token.
   - Added a `MessagingDelegate` extension that forwards the FCM token
     via `NotificationCenter` for the Flutter side to pick up.

### Build number bumped again (v5)

- `ios/Runner.xcodeproj/project.pbxproj` — `CURRENT_PROJECT_VERSION`
  15 → 16 (all 3 configs: Debug / Release / Profile).
- `pubspec.yaml` — `version: 19.0.0+3` → `19.0.0+4`.

This forces App Store Connect to require a fresh archive upload — the
old build #15 will not be accepted.

### Files changed (v5)

| File | Change |
|---|---|
| `lib/helper/utils/keyboardOverlay.dart` | `showOverlay` / `removeOverlay` hardened: `rootOverlay: true` + try/catch + null/mounted checks |
| `lib/helper/utils/generalMethods.dart` | `showMessage` hardened: same overlay checks + SnackBar fallback |
| `lib/screens/loginAccountScreen/loginAccountScreen.dart` | `firebaseLoginProcess` hang fix (else branch) + `callLoginApi` try/catch + `currentUser!` → `currentUser?.X ?? ""` + `fcmToken ?? ""` + mounted checks + dialCode null-safety |
| `lib/screens/otpVerificationScreen.dart` | `code!` → `(code ?? "")` + `dialCode.toString()` → null-safe + `containKey` typo fix + `value is Map` guard + phone-number format `+91 - XXX` → `+91XXX` + mounted checks |
| `lib/screens/editProfileScreen.dart` | hang fix (else branch) + empty-input safety + dialCode null-safety + mounted checks |
| `lib/screens/forgotPasswordScreen.dart` | same hang fix + dialCode null-safety + mounted checks |
| `lib/provider/userProfileProvider.dart` | `setUserDataInSession` + `updateUserDataInSession` rewritten with null-safe JSON parsing (`int.tryParse`, `is Map<String, dynamic>` runtime checks, `?? ""` defaults) |
| `ios/Runner/AppDelegate.swift` | APNs token bridge: `Messaging.delegate = self` + `didRegisterForRemoteNotificationsWithDeviceToken` → `Messaging.apnsToken = deviceToken` + `registerForRemoteNotifications()` + `MessagingDelegate` extension |
| `ios/Runner.xcodeproj/project.pbxproj` | `CURRENT_PROJECT_VERSION` 15 → 16 |
| `pubspec.yaml` | `version: 19.0.0+3` → `19.0.0+4` |

### How to verify before re-submitting (v5 specific)

On a physical **iPad Air 11-inch (M3)** running **iPadOS 27.2** (the
exact review device), and also on an **iPhone 17 Pro Max** running
**iOS 27.x**:

1. **Phone login — happy path**: Profile → Login → enter the demo
   phone number `8434207055` and password `Testnew@123` → tap Login.
   App should NOT crash. If the credentials are valid, you land on
   the home screen. If invalid, you see a "user not registered" toast
   (not a crash, not an infinite spinner).
2. **Phone login — settings not loaded**: Force-quit the app, clear
   its storage, relaunch, and IMMEDIATELY navigate to Profile →
   Login → enter credentials → tap Login within 1 second. The app
   should show a "something went wrong" toast and the spinner should
   disappear. NOT a crash, NOT an infinite spinner.
3. **OTP flow**: If `phoneAuthPassword` is disabled in your backend
   settings and `firebaseAuthentication` is enabled, tapping Login
   should navigate to the OTP screen without crashing. iPad without
   SIM should still receive the SMS (manual entry) and complete
   verification.
4. **Resend OTP**: On the OTP screen, wait 90 seconds for the timer
   to expire, then tap "Resend OTP". App should NOT crash. (This was
   the `code!` null-assertion crash point.)
5. **Toast reliability**: Trigger any error toast (e.g., enter an
   invalid email format and tap Login). The toast should appear
   cleanly, not crash the app. Try this while the keyboard is
   visible AND while it's hidden.
6. **Sign in with Google** (if enabled): Profile → Login → Continue
   with Google → complete the Google sheet → app should land on the
   registration or home screen. No `currentUser!` crash.

### MANDATORY build steps before re-submitting (do ALL of these)

1. Replace your local project with the new zip (overwrite, don't merge).
2. `cd` into the project root and run:
   ```
   flutter clean
   flutter pub get
   ```
3. iOS — refresh the CocoaPods cache so the new `FirebaseMessaging`
   import in `AppDelegate.swift` is linked correctly:
   ```
   cd ios
   rm -rf Pods Podfile.lock
   pod cache clean --all
   pod install
   cd ..
   ```
4. Open `ios/Runner.xcworkspace` in Xcode and do
   **Product → Clean Build Folder** (`Cmd + Shift + K`).
5. In Xcode, confirm:
   - **Runner** target → **General** → **Identity** → **Name** reads
     **OTW Grocery App**.
   - **Build Settings** → `CFBundleDisplayName` → **OTW Grocery App**
     in all three configurations.
   - **Build Settings** → `CURRENT_PROJECT_VERSION` → **16** in all
     three configurations.
6. Confirm the **Push Notifications** capability is enabled on the
   Runner target (Signing & Capabilities tab). The new
   `registerForRemoteNotifications()` call in `AppDelegate.swift`
   requires it. If you don't see "Push Notifications" under
   capabilities, click **+ Capability** and add it.
7. Confirm `ios/Runner/Runner.entitlements` contains
   `aps-environment = development` for development builds. For the
   App Store build, switch this to `production` (Xcode usually does
   this automatically when you switch the signing config to
   "App Store Connect").
8. **Product → Archive** to produce a fresh `.xcarchive`.
9. In the Xcode Organizer window, click **Distribute App → App Store
   Connect**. Upload the NEW archive — do NOT select an old build.
10. In App Store Connect, ensure the new uploaded build (build #16 /
    +4) is selected as the build for the next review, then click
    **Submit for Review**.

### Pre-existing v1–v4 fixes are STILL IN PLACE

This v5 patch is additive. All previously applied fixes (guest
browsing, prominent Skip button, null-safe CountryCode, null-safe
settingsData, null-safe formKey, Info.plist display-name fix,
pbxproj `INFOPLIST_KEY_CFBundleDisplayName` injection) remain in
effect. No v1–v4 fix was reverted.

### IMPORTANT — also create the demo account on your backend

The rejection reason says "we attempted to sign in with the
credentials provided". As documented in `APP_INFO.md`, the demo
account `8434207055` / `Testnew@123` was NOT registered on the
production backend as of 2026-09-15. If it's still not registered,
the reviewer will see a "user not registered" toast instead of a
crash — better, but still a rejection under
**Guideline 2.1 — App Completeness** ("we were unable to access the
app").

Before re-submitting, log in to `https://admin.otwgrocers.com/admin`
and create a customer account with phone `8434207055` and password
`Testnew@123` (and `Testnew@123` must match the
`phone_auth_password` flow). Verify with:

```bash
curl -X POST https://admin.otwgrocers.com/customer/login \
  -H 'x-access-key: 903361' \
  -d 'id=8434207055' -d 'type=phone' \
  -d 'password=Testnew@123' -d 'phone_auth_type=phone_auth_password' \
  -d 'platform=ios'
```

You should see `{"status":1, ...}`. Only then re-submit to Apple.
