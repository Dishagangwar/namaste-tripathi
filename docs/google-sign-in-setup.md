# Google sign-in setup

The app code is done. What remains is console work in two places, because a
client ID can only be issued by Google and only you can sign in to these
accounts.

Until it is finished, the app behaves honestly rather than pretending:
tapping **Continue with Google** in a build without client IDs shows
"Google sign-in is not configured in this build" instead of walking into
the shell with no session.

---

## 1. Google Cloud Console — the consent screen first

Google will not issue an OAuth client until the project has a consent screen,
so this comes before everything else.

**Google Auth Platform → Overview**, in the project this app belongs to. The
wizard asks for four things:

| Step | Value |
|---|---|
| App Information | App name `Namaste Tripathi`, and your own address as the user support email. The name is what appears on the consent sheet. |
| Audience | **External**. Internal is only available with a Google Workspace organisation and would limit sign-in to that domain. |
| Contact Information | Your email again — where Google sends consent and API notices. |
| Finish | Accept the policy, then **Create**. |

### Then let yourself actually sign in

An External app starts in **Testing**, and in testing only accounts on the
test-user list can sign in. Everyone else is refused with "Access blocked:
app has not completed the Google verification process" — which looks like a
broken integration but is just this setting.

In **Audience**, either:

* add your Google account under **Test users**, or
* click **Publish app**.

Publishing is safe for this app. Verification is only demanded for sensitive
scopes, and the app requests `email` and `profile`, which are not.

---

## 2. Google Cloud Console — three OAuth clients

**Google Auth Platform → Clients → Create client.** (In the older console
this lived under APIs & Services → Credentials.) You need **three**, and it
matters which is which.

### a. Web client  ← the important one

**Application type: Web application.**

This is the one the app and Supabase both use. Android asks Google to mint
the identity token *for this client*, and Supabase validates that audience.
Get this wrong and sign-in fails with a token-audience error.

Keep the **client ID** and the **client secret**.

### b. Android client

**Application type: Android.**

| Field | Value |
|---|---|
| Package name | `com.namastetripathi.app` |
| SHA-1 (debug) | `A6:FC:34:8E:40:C0:D9:93:F6:CF:EE:55:39:D4:DF:81:50:13:3F:82` |

That SHA-1 is from the debug keystore on this machine, so it covers
`flutter run` and debug APKs. A release build is signed with a different
key, so when you set one up add its SHA-1 here too:

```bash
keytool -list -v -keystore <your-release.keystore> -alias <your-alias>
```

You never paste the Android client ID anywhere — Google matches the app by
package name and signing certificate.

### c. iOS client

**Application type: iOS**, bundle ID `com.namastetripathi.app`.

Keep the client ID.

---

## 3. Supabase — enable the provider

Dashboard → **Authentication → Providers → Google** (project
`cwfozayeingrqomplcgg`), which is currently disabled.

| Field | Value |
|---|---|
| Enable Sign in with Google | on |
| Client ID | the **Web** client ID from 2a |
| Client Secret | the **Web** client secret from 2a |
| Authorized Client IDs | the **Android** and **iOS** client IDs from 2b and 2c, comma-separated |

The last row is what permits the native flow: Supabase accepts an identity
token issued to those clients instead of only its own web one.

---

## 4. The app — pass the client IDs in

They are read from the build environment, like the Supabase key, so nothing
project-specific is committed. In `.vscode/launch.json` the placeholders are
already there to replace:

```
--dart-define=GOOGLE_SERVER_CLIENT_ID=<WEB client ID>.apps.googleusercontent.com
--dart-define=GOOGLE_IOS_CLIENT_ID=<iOS client ID>.apps.googleusercontent.com
```

`GOOGLE_SERVER_CLIENT_ID` is the **Web** client ID, not the Android one.
That is the single easiest thing to get wrong here.

### iOS only

`ios/Runner/Info.plist` has a URL scheme placeholder to replace with your
iOS client ID **reversed**:

```
1234-abcd.apps.googleusercontent.com
  →  com.googleusercontent.apps.1234-abcd
```

Android needs no manifest change at all.

---

## 5. Check it worked

Run the **Namaste Tripathi** launch config (not the bundled-data one) and tap
Continue with Google. You should get the native account sheet, not a browser.

Then confirm a real account exists — this is what was empty before.

In the dashboard: **Authentication → Users**. One row should appear, and
**Table Editor → profiles** should gain a matching row, created by the
sign-up trigger.

> Do not reach for `supabase projects api-keys` here. It lists API keys, not
> accounts, so it answers a different question — and it prints the
> `service_role` key in full to your terminal. That key bypasses Row Level
> Security entirely: it is full read/write access to every table, including
> `auth`. Treat it like a database password. If it has been shown on screen,
> pasted anywhere, or screenshotted, rotate it under **Project Settings →
> API Keys**. The app itself never uses it — it signs in with the
> `sb_publishable_` key, which is public by design.

After that, a hotel booking will actually persist: every user table is keyed
to `auth.uid()`, which is why nothing could be stored until an account
existed.

---

## If sign-in is refused after all this

"Access blocked: app has not completed the Google verification process" is
almost always the testing-mode list from step 1, not a problem with the
client IDs. Add the account under Audience → Test users, or publish the app.

---

## What this does not cover

* **Phone OTP is still dead in a keyed build.** `sms_provider` is Twilio with
  no sender, and Indian numbers additionally need DLT registration. The
  "Continue with OTP" button now reports the provider's own error instead of
  failing silently, but it cannot deliver a code until you either finish that
  registration or switch to a provider like MSG91. Supabase test phone
  numbers remain the free way through.
* **Release signing.** Only the debug SHA-1 is registered above.
* **Android `namespace`.** `android/app/build.gradle.kts` still says
  `com.mycityapp.my_city_app` while `applicationId` is
  `com.namastetripathi.app`. OAuth matches on `applicationId`, so this does
  not break sign-in, but it is a leftover from a rename worth tidying.
