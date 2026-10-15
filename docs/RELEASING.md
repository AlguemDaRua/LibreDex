# Releasing LibreDex

This guide covers how a LibreDex release is produced, how the automatic pipeline works,
how to sign releases, and how to get LibreDex onto F-Droid. It is written for maintainers
who are new to Android release tooling.

## 1. How releases work (the short version)

Every push to `main` runs `.github/workflows/ci.yml`:

1. **Build, Analyze, and Test** — formatting, `flutter analyze`, data validators, tests,
   and a debug build. If this fails, nothing is released.
2. **Build & publish release APK** — only after step 1 passes:
   - reads the version from `pubspec.yaml` (`version: 1.0.0+1` → tag `v1.0.0`, build 1);
   - builds `app-release.apk`;
   - moves the tag `v1.0.0` to the new commit;
   - creates the GitHub release `v1.0.0` the first time, or **replaces the APK** on the
     existing release if it already exists.

So the newest `main` build for a version number is always the one on the release page.

**Important for F-Droid:** because the tag moves with each push, an F-Droid build recipe
pointing at `v1.0.0` would silently change. Once a version has been submitted to F-Droid
or installed by users, **bump the version** (see §4) instead of pushing more changes under
the same number.

## 2. Turning the pipeline on

The release job only runs on pushes to `main` (not on pull requests or other branches).
Merge the pull request into `main` to start it. Check the **Actions** tab on GitHub for
progress and the **Releases** page for the output.

## 3. Signing (recommended before public release)

Without signing secrets, the pipeline still publishes an APK, but it is signed with the
**debug key** and marked as a **pre-release** with a warning. Android users can install it,
but it is not a proper distributable build, and it cannot be upgraded by a build signed
with a different key. Set up a real upload key once:

1. Create a keystore on your own computer (keep the file and passwords somewhere safe —
   losing them means you can never update the app under the same identity):

   ```bash
   keytool -genkey -v -keystore libredex-release.jks -keyalg RSA -keysize 2048 \
     -validity 10000 -alias libredex
   ```

2. Encode it for GitHub:

   ```bash
   base64 -w 0 libredex-release.jks > libredex-release.jks.b64    # Linux
   base64 -i libredex-release.jks -o libredex-release.jks.b64     # macOS
   ```

3. In GitHub: **Settings → Secrets and variables → Actions → New repository secret**, add:

   | Secret | Value |
   | --- | --- |
   | `ANDROID_KEYSTORE_BASE64` | contents of `libredex-release.jks.b64` |
   | `ANDROID_KEYSTORE_PASSWORD` | the keystore password |
   | `ANDROID_KEY_ALIAS` | `libredex` |
   | `ANDROID_KEY_PASSWORD` | the key password |

4. Delete the local `.b64` file. Never commit the `.jks` file or `android/key.properties`
   (both are git-ignored).

The next push to `main` will publish a `…-signed.apk`. Local builds use the same
`android/key.properties` file, described in the comments of `android/app/build.gradle.kts`.

## 4. Bumping the version

Edit `version:` in `pubspec.yaml`:

- `1.0.0+1` → `1.0.1+2` for a fix. The part before `+` is the name shown to users; the
  number after `+` is the build number, which **must increase** on every release (Android
  refuses to install an older build number over a newer one).
- Add a changelog for the build number: `fastlane/metadata/android/en-US/changelogs/<build>.txt`
  (F-Droid shows it to users).

A new version number creates a new GitHub release. The old release stays as it was.

## 5. Submit to F-Droid

F-Droid builds LibreDex from source itself and signs the result with its own key, so you
do not upload an APK. The recipe is a small YAML file kept in F-Droid's repository.

The draft recipe is in [`fdroid/com.alguemdarua.libredex.yml`](../fdroid/com.alguemdarua.libredex.yml).

1. **Create a GitLab account** at <https://gitlab.com> (F-Droid's metadata lives on GitLab).
2. **Fork** <https://gitlab.com/fdroid/fdroiddata>.
3. **Copy the recipe** into the fork as `metadata/com.alguemdarua.libredex.yml`.
4. **Test it locally** (optional but recommended). With `fdroidserver` installed
   (`pip install fdroidserver`) and Docker available:

   ```bash
   fdroid lint com.alguemdarua.libredex
   fdroid build -v -l com.alguemdarua.libredex
   ```

   `lint` may warn that `Reading`/`Games` are not valid categories: those names are read from
   F-Droid's own `categories.yml`, which is only present in the fdroiddata repository, so
   check them there.

5. **Open a merge request** on fdroiddata. The F-Droid maintainers review it, may ask for
   changes (commonly about build steps, Flutter/SDK versions, or anti-features), and then
   merge it. The first build appears on F-Droid after that, typically within days to weeks.
6. **Keep it updated.** F-Droid's `AutoUpdateMode: Version v%v` and `UpdateCheckMode: Tags`
   pick up new `v<version>` tags automatically. Bump the `Builds:` entry in the recipe when
   you add a version, or let the maintainers help.

Things F-Droid checks that LibreDex must keep true:

- Open-source license (MIT ✔) and no proprietary libraries (none are used).
- Everything builds from the tagged source with no closed tools. The build depends only on
  the Flutter SDK and pub.dev packages.
- Pokémon artwork is downloaded at runtime from the PokeAPI sprite repository. F-Droid may
  review that under its *anti-features* rules; the NOTICE file explains the situation.

## 6. Before tagging v1.0.0 (manual checks)

These cannot be automated and must be done on a real device with the release APK:

- [ ] Install the APK from the GitHub release and open every section (Pokédex, MoveDex,
      AbilityDex, ItemDex, NatureDex, type chart, team builder, calculator).
- [ ] First-launch database setup works with no network.
- [ ] Offline artwork download can be started, paused and deleted.
- [ ] Verify launcher icon and app name on the home screen.
- [ ] Add phone screenshots to `fastlane/metadata/android/en-US/images/phoneScreenshots/`
      (F-Droid shows them on the app page; the repo does not yet have any).
