# Changelog

## 0.6.0

### Security
- The target URL must be `http`, `https` or relative. `javascript:`, `data:` and other schemes now raise `Repost::UnsafeUrlError`, because escaping can't make them safe. Allow more schemes with `options: { allowed_schemes: %w[https myapp] }`.

### Changed
- All markup is built by one helper that escapes every attribute value, so a value can't be left unescaped by mistake. The output is the same apart from formatting: the autosubmit script is on one line, and the CSRF input lists `type` first.
- The Rails helpers now live in `Repost::ExtendController`, included into `ActionController::Base` through `on_load(:action_controller_base)`. Before, the gem reopened `ActionController::Base` from a hook that also ran for API controllers.
- No longer requires the `cgi` library, which prints a warning on Ruby 4.0.

### Added
- Rails integration specs, run on Rails 7.1 through 8.x.

## 0.5.3 (2026-11-05)
- Fixed autosubmit failing when a param is named `submit`: the hidden input shadowed `form.submit`, leaving the user on a blank page.
- Fixed autosubmit failing when `form_id` contains `"`, `&`, `<` or `>`.
- CI moved from Travis to GitHub Actions (Ruby 2.7 to 4.0).

## 0.5.2 (2026-07-03)
- `method: :put`, `:patch` and `:delete` are sent as POST with a hidden `_method` field (Rails-style override).
- An explicit `autosubmit_nonce`, including `nil`, overrides the Rails CSP nonce. The Rails helper no longer modifies the options hash passed to it.
- `class` attributes are left out when no decor classes are set. Generated form ids are random instead of timestamp-based.

## 0.5.1 (2026-01-28)

### Security
- Fixed cross-site scripting ([#29](https://github.com/vergilet/repost/issues/29)): the URL, param names and values, and all options are now HTML-escaped. All earlier versions are affected; please upgrade.

## 0.5.0 (2026-01-28)
- Attempted fix for [#29](https://github.com/vergilet/repost/issues/29) by sanitizing the output of the Rails helper. This also stripped the form, so `repost` and `redirect_post` stopped working in Rails. Use 0.5.1 or later.

## 0.4.2 and earlier
See the [commit history](https://github.com/vergilet/repost/commits/master).
