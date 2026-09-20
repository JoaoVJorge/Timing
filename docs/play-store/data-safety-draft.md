# Google Play Data safety draft

This draft is based on the current Flutter source code. Recheck it against the production backend and the final release bundle before submitting it in Play Console.

## High-level answers

- Data collected: **Yes**
- Data shared with third parties: **No**, assuming Supabase and Google authentication are used only as service providers and no data is sold or used for third-party advertising.
- Data encrypted in transit: **Yes**
- Users can request deletion: **Not ready for submission until a working deletion process and public deletion URL are available**
- Independent security review: **No**, unless one is completed before submission.

## Data types to declare as collected

| Play category | Data type | Required? | Purpose | Notes |
| --- | --- | --- | --- | --- |
| Personal info | Name | Required after sign-in | App functionality; account management | Google profile name and editable display name |
| Personal info | Email address | Required after sign-in | App functionality; account management | Received from Google authentication and stored in the profile |
| Personal info | Phone number | Optional | App functionality; account management | User may add it to the profile |
| Personal info | Other info | Optional | App functionality; personalization | Date of birth, nickname, avatar, language, appearance and focus preferences |
| Photos and videos | Photos | Optional | App functionality | Profile photos and images intentionally shared in groups |
| App activity | User-generated content | Optional | App functionality | Notes, subjects, tasks, goals, schedules, group content and related entries |
| App activity | App interactions | Required when features are used | App functionality; analytics within the product | Focus sessions, reading progress, completed tasks, achievements and progress history; no third-party analytics SDK is currently wired |
| Device or other IDs | User IDs | Required | App functionality; account management; security | Supabase/Google-linked account identifier and Timing friend code |

## Data types not observed in the current source

- Approximate or precise location
- Contacts from the device address book
- Financial information
- Health and fitness information
- Audio recordings or music files
- SMS or call logs
- Advertising identifiers
- Third-party advertising or marketing analytics

## Collection characteristics

- Account name, email, user identifier, and core synchronized app activity are not optional when using the signed-in app.
- Phone number, birth date, profile photo, and group images are optional.
- Data is processed for app functionality and account management. Security/fraud-prevention may also apply to authentication and technical identifiers.
- Information intentionally shown to friends or group members is user-directed sharing. Confirm Play's current user-initiated-sharing exception when completing the form.

## Release blockers before submission

1. Publish the privacy policy at a stable public HTTPS URL.
2. Publish a stable public account-deletion URL.
3. Provide a working deletion flow or operational deletion-request process.
4. Confirm production Supabase logging, backups, retention, regions, and any additional processors not visible in this repository.
5. Confirm that the release bundle does not add analytics, crash reporting, advertising, or other SDKs.
