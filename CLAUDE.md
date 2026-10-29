# Tuoora app

## Access Share (sub-access) permissions
Every institute feature must be gated for sub-access users. When you add or change a feature:
1. Backend (php/fee_easy): add the permission to `InstituteSubAccess::PERMISSIONS` (it appears in the Access Share form automatically) and enforce it in `CheckInstituteSubAccessPermission` (API module rule, or `sub_access_check:<perm>` on routes outside `/api/v1/institute`).
2. App: add the key to `lib/core/constants/app_permissions.dart` and gate every entry point with `AuthService.can` / `canAny` / `canModule` — dashboard tile, app-bar icons, buttons, tabs, push-notification taps, and data preloads (anything that would otherwise show "Access Denied" or a failed-load toast).
3. Never use raw permission strings in the app; use `AppPermissions`.
4. Make the app rule match the backend rule (e.g. a list read the backend allows for any staff permission must not be stricter in the app).
