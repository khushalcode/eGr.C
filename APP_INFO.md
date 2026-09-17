# OTW Grocery — App Information Reference

This document lists both apps in the OTW Grocery ecosystem with their
**base URLs**, **app names**, **bundle IDs**, **login credentials**, and
**App Store Connect status**. Use this as the single source of truth when
communicating with Apple App Review, your backend admin, or testers.

---

## 1. Customer App — `OTW Grocery App`

> The customer-facing shopping app. End users browse products, add to cart,
> place orders, track delivery, manage wishlist, etc.

| Item | Value |
|---|---|
| **App Store name** | OTW Grocery App |
| **Display name on device** | OTW Grocery App *(fixed — was "eGrocer")* |
| **Bundle ID (iOS)** | `com.otwgrocers` |
| **Package name (Android)** | `com.bshgrocery.customer` |
| **App version (pubspec)** | `5.0.0+2` *(bumped from `5.0.0+1`)* |
| **iOS build number (CURRENT_PROJECT_VERSION)** | `14` *(bumped from `13`)* |
| **iOS MARKETING_VERSION** | `2.0.6` |
| **Backend base URL** | `https://admin.bshgrocery.in/customer/` |
| **Login API endpoint** | `POST https://admin.bshgrocery.in/customer/login` |
| **Login request params** | `id`, `type` (`phone` / `email`), `platform` (`android` / `ios`), `fcmToken`, `password`, `phone_auth_type` (`phone_auth_password` or `phone_auth_otp`) |
| **HTTP header** | `x-access-key: 903361`, `accept: application/json` |
| **Shared `hostUrl`** | `https://admin.bshgrocery.in/` |
| **Website** | `https://bshgrocery.in/` |
| **Apple review device** | iPhone 17 Pro Max and iPad Air 11-inch (M3) |

### Customer app — App Store review status

| Date | Guideline | Issue | Status |
|---|---|---|---|
| Sep 8, 2026 | 5.1.1(v) | Forced login to browse products | ✅ Fixed (guest browsing + prominent Skip button) |
| Sep 8, 2026 | 2.1(a) / 2.1(i) | Crash on sign-up (iPad Air 3, iOS 18.1) | ✅ Fixed (null-safety + try/catch + SafeArea) |
| Sep 14, 2026 | 2.3.8 | Device name "eGrocer" ≠ marketplace name "OTW Grocery App" | ✅ Fixed (Info.plist + pbxproj `INFOPLIST_KEY_CFBundleDisplayName` + build number bumped) |

### Customer app — Demo credentials for Apple review

> ⚠️ **Verified 2026-09-15 — these credentials returned `user_not_exist`
> against the production backend at `admin.bshgrocery.in`.** The account
> `8434207055` is NOT registered as a customer. Before submitting to Apple,
> you MUST create this customer account in your admin panel
> (`https://admin.bshgrocery.in/admin`) so Apple's reviewer can actually
> log in.

```
Phone Number : 8434207055
Password     : Testnew@123
Login type   : phone (with phone_auth_password)
```

---

## 2. Partners App — `OTW Grocery Partners App`

> The companion app for sellers (partners) and delivery boys. Partners
> receive orders, manage products, update stock, view earnings, etc.
> Delivery boys accept/complete deliveries and view cash collections.

| Item | Value |
|---|---|
| **App Store name** | OTW Grocery Partners App |
| **Display name on device** | OTW Grocery Partners App *(fixed — was "eGrocer Partner")* |
| **Bundle ID (iOS)** | `com.otwgrocers.seller` |
| **Package name (Android)** | `com.otwgrocers.seller` |
| **App version (pubspec)** | `2.0.0+2` *(bumped from `2.0.0+1`)* |
| **iOS build number (CURRENT_PROJECT_VERSION)** | `14` *(bumped from `13`)* |
| **iOS MARKETING_VERSION** | `2.0.6` |
| **Backend base URL** | `https://admin.bshgrocery.in/api/` |
| **Login API endpoint** | `POST https://admin.bshgrocery.in/api/login` |
| **Login request params** | `email`, `password`, `type` (`3` = seller, `4` = delivery boy), `fcmToken`, `platform` (`android` / `ios`) |
| **HTTP header** | `x-access-key: 903361`, `accept: application/json` |
| **Shared `hostUrl`** | `https://admin.bshgrocery.in/` |
| **Login type config** | `appLoginType = 3` (both sellers and delivery boys can log in) |
| **TestFlight URL** | `https://testflight.apple.com/join/Bmx2ZdOf` |
| **Apple review device** | iPhone 17 Pro Max and iPad Air 11-inch (M3) |

### Partners app — App Store review status

| Date | Guideline | Issue | Status |
|---|---|---|---|
| Sep 14, 2026 | 2.1 — Information Needed | New developer account, additional info required (screen recording, app purpose, demo credentials, etc.) | ✅ Notes prepared in `App-Review-Notes-PartnersApp.md` |
| Sep 14, 2026 | 2.3.8 (latent) | Device name "eGrocer Partner" ≠ marketplace name "OTW Grocery Partners App" | ✅ Pre-emptively fixed (same fix as customer app) |

### Partners app — Demo credentials for Apple review

> ⚠️ **Verified 2026-09-15 — these credentials returned
> `User is not register with this email address!` against the production
> backend at `admin.bshgrocery.in`.** The email `seller@gmail.com` is NOT
> registered as a seller. Before submitting to Apple, you MUST create this
> seller account in your admin panel (`https://admin.bshgrocery.in/admin`)
> so Apple's reviewer can actually log in.

```
Email      : seller@gmail.com
Password   : 12345678
Login type : 3 (seller)
```

> 💡 **If your reviewer account is a delivery boy rather than a seller,
> set `type=4` in the login API.** The Partners app supports both
> (`appLoginType = 3` in `constant.dart`).

---

## 3. Shared backend (both apps)

Both apps share the same backend at `https://admin.bshgrocery.in/`:

| Endpoint | Used by | Path |
|---|---|---|
| Customer login | Customer app | `POST /customer/login` |
| Customer forgot password OTP | Customer app | `POST /customer/forgot_password_otp` |
| Customer reset password | Customer app | `POST /customer/reset_password` |
| Partner / delivery boy login | Partners app | `POST /api/login` |
| Partner profile | Partners app | `GET /api/sellers/edit-profile/{id}` or `/api/delivery_boys/edit-profile/{id}` |
| Admin panel (create accounts here) | You | `https://admin.bshgrocery.in/admin` |

---

## 4. Action required BEFORE re-submitting to Apple

1. **Create the demo accounts on your backend** (this is the missing step
   that caused both credential checks to fail):
   - Log in to `https://admin.bshgrocery.in/admin`
   - Create a customer account with phone `8434207055` and password
     `Testnew@123` (used by Apple to review the **customer app**)
   - Create a seller account with email `seller@gmail.com` and password
     `12345678` (used by Apple to review the **Partners app**)
   - Verify both accounts can log in successfully via the API:
     ```bash
     # Customer app check
     curl -X POST https://admin.bshgrocery.in/customer/login \
       -H 'x-access-key: 903361' \
       -d 'id=8434207055' -d 'type=phone' \
       -d 'password=Testnew@123' -d 'phone_auth_type=phone_auth_password' \
       -d 'platform=ios'

     # Partners app check
     curl -X POST https://admin.bshgrocery.in/api/login \
       -H 'x-access-key: 903361' \
       -d 'email=seller@gmail.com' -d 'password=12345678' \
       -d 'type=3' -d 'platform=ios'
     ```
   - Both should return `{"status":1, ...}` (NOT `user_not_exist`)

2. **Build & upload** both apps using the fixed zips provided, following
   the build steps in `FIXES_APPLIED.md` (for the customer app) and
   `App-Review-Notes-PartnersApp.md` (for the Partners app).

3. **Record a screen capture** of the Partners app showing:
   - Launch → login with `seller@gmail.com` / `12345678`
   - Dashboard → incoming orders
   - Order acceptance flow
   - **Account deletion flow** (Settings → Delete Account) — MANDATORY
     per Apple's guidelines

4. **Paste the notes** from `App-Review-Notes-PartnersApp.md` into the
   App Review Information "Notes" field in App Store Connect for the
   Partners app, attach the screen recording, and reply to Apple's
   message confirming all requested info has been provided.

5. **Re-submit both apps** for review. Apple will test on iPhone 17 Pro
   Max and iPad Air 11-inch (M3) — make sure the apps work on both.
