# LibreDex Release Checklist

Use this checklist to verify reliability before releasing any new version of LibreDex.

## 1. Data Integrity and Audits
- [ ] Run the Python data audit: `python3 tools/audit_libredex_data.py`
- [ ] Verify zero duplicate IDs across Pokémon, moves, and abilities.
- [ ] Verify that no sprite URLs or item icon URLs are broken or return 404.

## 2. Local Database & Migrations
- [ ] Increment the database schema version in `lib/core/database/app_database.dart` if tables changed.
- [ ] Test the upgrading migration path from previous database versions.
- [ ] Verify cold-boot performance with fresh databases.

## 3. Automated Tests & Static Analysis
- [ ] Run formatter check: `dart format --set-exit-if-changed lib test`
- [ ] Run static analysis: `flutter analyze`
- [ ] Run unit and widget tests: `flutter test`

## 4. UI, Accessibilities, and Caches
- [ ] Test on tablet layouts (600px width and up) to confirm table-rendering safety.
- [ ] Test minimum touch targets are at least 44x44.
- [ ] Verify "Clear Artwork Cache" works as expected inside settings.
- [ ] Verify "Bulk Download Item Icons" successfully downloads offline assets with correct progress bars.
