# App Review Notes — OTW Grocery Partners App

Apple requested additional information under **Guideline 2.1 - Information
Needed - New App Submission** for the **OTW Grocery Partners App**. This is
not a code error — Apple just needs more context because the developer
account has a limited App Review history.

Below is a ready-to-paste template you can copy into App Store Connect when
you reply to Apple. The credentials and base URL are already filled in —
just attach the screen recording and submit.

---

## App Review Information — paste into App Store Connect

**App name:** OTW Grocery Partners App
**Bundle ID:** `com.otwgrocers.seller`
**App Store category:** Business
**Version under review:** 2.0 (1)
**Submission ID:** 8667aac3-a54f-4889-a661-b076f870e797

### 1. Screen recording

> A screen recording captured on a physical iPhone 17 Pro Max running
> iOS 27, demonstrating the app's functionality, is attached to this reply
> as `PartnersApp-Demo.mov`. The recording begins with launching the app
> and shows the typical user flow:
>
> - Partner (seller) login screen
> - Account registration flow with email + password
> - Login using the demo credentials below
> - Dashboard showing new incoming orders
> - Order acceptance / rejection flow
> - Order status update (received, processed, out for delivery, delivered)
> - Product catalogue management (add / update / delete product)
> - Stock management screen
> - Wallet history and cash collection screens
> - Account deletion flow accessible from Profile → Settings →
>   Delete Account (this is the mandatory user-account-deletion flow
>   per App Store guideline 5.1.1(v))

### 2. App purpose and target audience

> **Purpose:** OTW Grocery Partners App is the companion app for sellers
> (partners) and delivery boys of the OTW Grocery App customer app. It
> enables registered partners to receive, manage, and fulfil customer
> orders placed through the OTW Grocery App, and to manage their own
> product catalogue, inventory, and earnings.
>
> **Target audience:** Independent grocery sellers, supermarket operators,
> and delivery drivers who have signed a partnership agreement with
> OTW Grocers (the operating company).
>
> **Value provided:** The app digitises the order-management workflow for
> partners — replacing phone calls and paper receipts — with real-time
> order notifications, in-app status updates, and daily earnings reports.
>
> **Both account types are supported by this single app:**
> - Type 3 — Seller (partner): manages products, fulfils orders
> - Type 4 — Delivery boy: delivers orders, collects cash

### 3. Setup and access instructions

> The app is intended for use only by approved partners of OTW Grocers.
> To access the app:
>
> 1. A partner must first be onboarded by OTW Grocers via a signed
>    partnership agreement. Onboarding creates their account in the
>    OTW Grocers backend with a verified email address and a temporary
>    password.
> 2. The partner downloads the OTW Grocery Partners App from the App
>    Store.
> 3. The partner logs in using their registered email and password.
> 4. After login the partner is taken to their dashboard.
>
> **Demo credentials for review (seller account):**
>
> - Email: `seller@gmail.com`
> - Password: `12345678`
> - Account type: Seller (type = 3)
>
> These credentials are valid for the duration of the review. They will
> be deactivated within 24 hours of approval.
>
> **Login API used by the app:**
> - Endpoint: `POST https://admin.bshgrocery.in/api/login`
> - Headers: `x-access-key: 903361`, `accept: application/json`
> - Body params: `email`, `password`, `type` (3 = seller, 4 = delivery
>   boy), `fcmToken`, `platform`

### 4. External services, tools, and platforms

> The app uses the following external services to deliver its core
> functionality:
>
> - **Firebase Authentication** — partner login session management.
> - **Firebase Cloud Messaging (FCM)** — real-time push notifications for
>   new orders and order status updates.
> - **Apple Push Notification service (APNs)** — iOS push delivery.
> - **Google Maps Platform (Maps SDK, Distance Matrix API)** — used by
>   delivery partners for navigation and ETA calculation.
> - **OTW Grocers Backend API** (owned by the developer, hosted at
>   `https://admin.bshgrocery.in/`) — order data, product catalogue,
>   partner earnings, withdrawal requests, fund transfers.
> - **Google Gemini AI** *(optional, used in product description
>   generator)* — generates HTML product descriptions from custom
>   prompts.
>
> All third-party SDKs are listed in the app's privacy nutrition labels
> in App Store Connect.

### 5. Regional differences

> The app functions consistently across all regions where OTW Grocers
> operates. Partner availability, payout currency, and supported payment
> methods may differ by region based on the partner's registered country,
> but the in-app user experience is identical worldwide.

### 6. Regulated industry / third-party material

> The app does not operate in a regulated industry. All product images
> and catalogues shown in the app are uploaded by verified partners and
> remain the property of the respective partners. OTW Grocers has a
> signed partnership agreement with each partner authorising the use of
> their product data in this app.

---

## Additional tips for getting the Partners app approved

1. **Always attach the screen recording to the App Review Information
   "Notes" section, not just in your reply message.** Apple's reviewer
   reads the Notes field first.
2. **Demo account must work for at least 7 days** after submission —
   reviewers sometimes return to an app days later for re-verification.
3. **Account deletion flow is mandatory** since the app supports account
   creation. Make sure the demo account can also be deleted from within
   the app (Profile → Settings → Delete Account) and that the deletion
   actually removes the account from the backend.
4. **If the app requires partner verification** before login (e.g.,
   admin approval), mention this clearly and provide a pre-approved
   demo account so the reviewer can log in immediately.
5. **If the Partners app and the customer-facing OTW Grocery App share
   a backend**, mention this — it helps the reviewer understand why
   both apps exist.

---

## Submission checklist (paste this into App Review Information "Notes")

```
[ ] Screen recording attached (physical iOS device, full user flow)
[ ] Demo account credentials provided above:
      Email:    seller@gmail.com
      Password: 12345678
[ ] App purpose, audience, and value described
[ ] Setup and access instructions described
[ ] External services list provided
[ ] Regional differences confirmed
[ ] No regulated industry / no third-party IP issues
[ ] Account deletion flow demonstrated in the recording
[ ] Both account types (seller type=3, delivery boy type=4) accessible
```

---

## IMPORTANT — Before you submit

⚠️ **On 2026-09-15, I tested the demo credentials against the production
backend at `https://admin.bshgrocery.in/api/login` and received:**

```json
{"status":0,"message":"User is not register with this email address!"}
```

This means the email `seller@gmail.com` is **NOT registered** on your
backend yet. Before you submit the Partners app to Apple, you MUST:

1. Log in to your admin panel at `https://admin.bshgrocery.in/admin`
2. Create a new seller account with:
   - Email: `seller@gmail.com`
   - Password: `12345678`
   - Status: Active
   - All required seller details (name, store name, bank details, etc.)
3. Verify the credentials work by running:
   ```bash
   curl -X POST https://admin.bshgrocery.in/api/login \
     -H 'x-access-key: 903361' \
     -d 'email=seller@gmail.com' \
     -d 'password=12345678' \
     -d 'type=3' \
     -d 'platform=ios'
   ```
   You should see `{"status":1, ...}` in the response.
4. Log in to the Partners app on a physical iPhone with the same
   credentials and confirm the dashboard loads successfully.
5. **Then record the screen capture** and submit to Apple.

If Apple's reviewer tries to log in with credentials that don't work,
they will reject the app again under **Guideline 2.1 — App Completeness**
("we were unable to access the app"). Don't skip this step.
