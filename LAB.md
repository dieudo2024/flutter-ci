# Lab 7 — Build a Flutter pipeline step by step

Work individually in your own repository's **main** branch. Complete the
[README setup](README.md) and get the starter running before proceeding.

We will begin with a small app, change its behaviour, add small tests, and then
automate those same checks on GitHub. Complete **one checkpoint at a time**.
When a step asks you to push, inspect that Actions run before adding more code.

## What you will build

- A counter with **+**, **-**, and **Reset** buttons.
- A rule: **the count cannot go below zero**.
- **Four unit tests** and **three widget tests**.
- One GitHub Actions job that checks, tests, builds, and uploads an APK.
- One deliberate failed run, followed by a successful repair.

**CI** automatically checks a pushed change. In this activity, **delivery** means
storing a downloadable APK after the checks pass. Installing it is a manual
step; continuous deployment to an app store is outside this activity.

## Checkpoint 1 — Observe a working app

Run the starter from the README and check these behaviours:

| Action | Expected |
| --- | --- |
| Open the app | Counter Lab and 0 appear |
| Tap + three times | The count becomes 3 |
| Fully restart the app | The count returns to 0 |

**Stop and verify:** make this work before writing tests or a workflow. The
counter is intentionally kept in memory; restart persistence is not a feature.

## Checkpoint 2 — Add a small rule and two buttons

Create **`lib/counter.dart`** and copy the complete class below:

```dart
class Counter {
  int _value = 0;

  int get value => _value;

  void increment() => _value++;

  void decrement() {
    if (_value > 0) {
      _value--;
    }
  }

  void reset() => _value = 0;
}

```
The `value` getter exposes the count. `decrement` checks the boundary before
changing it. Keeping this logic separate makes it easy to test without a screen.

Replace **all of `lib/main.dart`** with the following complete file. Do not paste
it below the old code. The import uses the new file in the same `lib` folder:

```dart
import 'package:flutter/material.dart';

import 'counter.dart';

void main() => runApp(const CounterApp());

class CounterApp extends StatelessWidget {
  const CounterApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Counter Lab',
    theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
    home: const CounterPage(),
  );
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  final Counter _counter = Counter();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Counter Lab')),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Current count'),
          Text(
            '${_counter.value}',
            key: const ValueKey('counter-value'),
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton(
                key: const ValueKey('decrement'),
                onPressed: () => setState(_counter.decrement),
                child: const Text('-'),
              ),
              const SizedBox(width: 12),
              FilledButton(
                key: const ValueKey('increment'),
                onPressed: () => setState(_counter.increment),
                child: const Text('+'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                key: const ValueKey('reset'),
                onPressed: () => setState(_counter.reset),
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

```
Run the following, then fully restart the app if needed:

```text
dart format lib
flutter run
```

If you still have a `flutter run` session open, save the files and press **R** in
that terminal to hot restart instead of starting a second session.

**Stop and verify:** + increases the count, - decreases it, - at zero keeps zero,
and Reset returns a positive count to zero. The buttons' keys identify them in
the widget tests; their visible labels remain +, -, and Reset.

## Checkpoint 3 — Write small unit tests

Create **`test/counter_test.dart`** and copy this complete file:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ci_counter/counter.dart';

void main() {
  test('counter starts at zero', () {
    final counter = Counter();
    expect(counter.value, 0);
  });

  test('increment adds one', () {
    final counter = Counter();
    counter.increment();
    expect(counter.value, 1);
  });

  test('decrement subtracts one but never goes below zero', () {
    final counter = Counter();
    counter.increment();
    counter.decrement();
    expect(counter.value, 0);
    counter.decrement();
    expect(counter.value, 0);
  });

  test('reset returns a positive counter to zero', () {
    final counter = Counter();
    counter.increment();
    counter.increment();
    counter.reset();
    expect(counter.value, 0);
  });
}

```
Run this test file locally:

```text
flutter test test/counter_test.dart
```

**Expected: four tests pass.** Each test starts with a new Counter. Read the
third test: it checks normal decrementing and the zero boundary. The `expect`
statements describe the behaviour we want; they are not instructions to change it.

No emulator is required: these tests call the Dart class directly.

## Checkpoint 4 — Test the buttons

Create **`test/counter_widget_test.dart`** and copy this complete file:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ci_counter/main.dart';

void main() {
  testWidgets('plus updates the displayed value', (tester) async {
    await tester.pumpWidget(const CounterApp());
    expect(find.text('0'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('increment')));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('minus at zero keeps the displayed value at zero', (
    tester,
  ) async {
    await tester.pumpWidget(const CounterApp());
    await tester.tap(find.byKey(const ValueKey('decrement')));
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
    expect(find.text('-1'), findsNothing);
  });

  testWidgets('reset updates the displayed value to zero', (tester) async {
    await tester.pumpWidget(const CounterApp());
    await tester.tap(find.byKey(const ValueKey('increment')));
    await tester.tap(find.byKey(const ValueKey('increment')));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('reset')));
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
  });
}

```
Run all local checks:

```text
dart format lib test
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

**Expected: formatting and analysis pass; seven tests pass.**

- `pumpWidget` creates the screen inside Flutter's test environment.
- `tap` simulates pressing a button found by its key.
- `pump` lets Flutter rebuild before we check the text.
- These widget tests also run without an emulator. They do not prove that the
  APK installs on Android; we will check that separately.

If a check fails, fix it locally before moving on. There is no generated default
counter test in this starter, so the final count should be exactly seven.

## Before the first GitHub run — Prepare your repository

Create an **empty GitHub repository** in your account, without adding a README,
license, or .gitignore on GitHub. The downloaded ZIP has no Git history.

From the extracted project folder containing `pubspec.yaml`, run the following.
Replace `YOUR_REPOSITORY_URL` with the full HTTPS URL of your empty repository:

```text
git init -b main
git add .
git commit -m "feat: add counter rules and seven tests"
git remote add origin YOUR_REPOSITORY_URL
git push -u origin main
```

Commit `android/`, the Gradle wrapper,
`pubspec.yaml`, and `pubspec.lock`. The supplied .gitignore excludes local SDK
paths and generated build files. Do not upload an extracted APK or the build
folder into Git. add chakirouAlabani as a collaborator

## The six Actions runs

Each push runs all steps added so far. **Do not assemble the final workflow in
advance.** Keep one file, one job, and one `steps` list.

| Run | What changes | Expected result |
| --- | --- | --- |
| 1 | Add checkout scaffold | Green; project checked out |
| 2 | Add SDK setup and local checks | Green; seven tests pass |
| 3 | Add Android APK build | Green; APK built, not yet downloadable |
| 4 | Add artifact upload | Green; APK artifact available |
| 5 | Introduce a deliberate logic error | Red; tests fail and build/upload are skipped |
| 6 | Restore correct logic | Green; a new commit's APK is available |

## Checkpoint 5 — Run 1 — Start with checkout

Create **`.github/workflows/ci-cd.yml`** at the repository root. Copy this entire
scaffold unchanged and add no later steps yet:

```yaml
name: Flutter checks and APK delivery

on:
  push:
    branches: [main]

permissions:
  contents: read

jobs:
  ci:
    runs-on: ubuntu-24.04
    timeout-minutes: 20
    steps:
      - name: Get the project files
        uses: actions/checkout@v7

```
Commit and push:

```text
git add .github/workflows/ci-cd.yml
git commit -m "ci: add checkout scaffold"
git push
```

Open **Actions → Flutter checks and APK delivery → latest run → ci**.
**Expected: green, with only Get the project files.** No tests, build, or APK
artifact should appear. Save this run link.

The trigger listens for pushes to main. `ubuntu-24.04` is a temporary hosted
Linux runner; checkout puts your repository on it. This run does not require
an Android emulator on GitHub.

For each later block, paste the supplied lines **inside the existing `steps:`
list**, after the last existing step. Every `- name:` begins with **six spaces**;
the fenced blocks already include them. Use spaces, not tabs. Do not add a
second `on`, `jobs`, `ci`, or `steps` block.

## Checkpoint 6 — Run 2 — Automate the checks

Append both blocks below after checkout. Keep the scaffold and its indentation:

```yaml
      - name: Set up Java
        uses: actions/setup-java@v6
        with:
          distribution: temurin
          java-version: '17'

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version: '3.47.1'
          cache: true

      - name: Install dependencies
        run: flutter pub get --enforce-lockfile

      - name: Check formatting
        run: dart format --output=none --set-exit-if-changed lib test

      - name: Analyze the code
        run: flutter analyze

```
```yaml
      - name: Run unit and widget tests
        run: flutter test

```
These are the same checks you ran locally. Java supports the Android build;
Flutter 3.47.1 matches the local SDK. `--enforce-lockfile` uses the committed
dependency resolution and fails if the lockfile is missing or out of date.

Commit and push:

```text
git add .github/workflows/ci-cd.yml
git commit -m "ci: automate formatting analysis and tests"
git push
```

**Expected:** all steps pass, with **seven tests** reported. Inspect each step's
log. Stop here until Run 2 is green. An artifact is not expected yet.

Do not add `continue-on-error` or `if: always()` to these checks or the later
build/upload steps. Their default behaviour stops delivery after a failed check.

## Checkpoint 7 — Run 3 — Build the Android APK

Append this step **after Run unit and widget tests**:

```yaml
      - name: Build the Android debug APK
        run: |
          chmod +x android/gradlew
          flutter build apk --debug

```
`chmod` makes the Gradle wrapper executable on Linux, including when your
repository was prepared on Windows. The hosted runner supplies Android tools;
Flutter/Gradle may download additional SDK components on the first build.
The APK is debug-signed for this classroom exercise.

```text
git add .github/workflows/ci-cd.yml
git commit -m "ci: build the Android debug APK"
git push
```

**Expected:** the earlier checks pass, then the APK build passes. Its path is
`build/app/outputs/flutter-apk/app-debug.apk`. At this checkpoint it exists only
on the temporary runner. Nothing is uploaded yet, so there is no artifact to
download. Save Run 3's link and continue only after it is green.

## Checkpoint 8 — Run 4 — Deliver a downloadable APK

Append this step **after Build the Android debug APK**:

```yaml
      - name: Upload the APK
        uses: actions/upload-artifact@v7
        with:
          name: counter-apk-${{ github.sha }}
          path: build/app/outputs/flutter-apk/app-debug.apk
          if-no-files-found: error
          retention-days: 7

```
Leave `${{ github.sha }}` unchanged: GitHub replaces it with this run's commit
ID. No username, password, token, or custom secret needs to be entered. Keep the
existing `contents: read` permission; no package-publishing permission is needed.
The artifact is retained for seven days, subject to repository policy.

```text
git add .github/workflows/ci-cd.yml
git commit -m "ci: upload the checked Android APK"
git push
```

**Expected:** the upload step passes. Return to Run 4's **summary page**, below
the job logs, and find **Artifacts → counter-apk-COMMIT_ID**. This is a stored
build, not an app-store release. Save the run link and artifact name.

Your final step order is:

```text
Checkout → Java → Flutter → dependencies → formatting → analysis → seven tests
→ Android APK build → artifact upload
```

## Checkpoint 9 — Runs 5 and 6 — Prove the checks protect delivery

In **`lib/counter.dart`**, change only the decrement guard from:

```dart
if (_value > 0) {
```

to:

```dart
if (_value >= 0) {
```

Leave the tests unchanged. This deliberately lets a decrement at zero produce -1.
Run `flutter test` locally and observe the failures. For this checkpoint only,
push that known error so you can inspect CI's response:

```text
dart format lib test
git add lib/counter.dart
git commit -m "test: demonstrate a blocked delivery"
git push
```

**Run 5 must be red.** Check that:

- Formatting and analysis pass; **Run unit and widget tests** fails.
- The decrement boundary unit test and the minus-at-zero widget test report -1.
- **Build the Android debug APK** and **Upload the APK** are skipped.
- This failing run has **no new APK artifact**. Earlier successful runs retain
  their own artifacts until those expire; a failure does not delete them.

Save this failed run link. Do not weaken the tests to make the failure disappear.
Restore the guard to **`if (_value > 0)`**, then run:

```text
dart format lib test
flutter analyze
flutter test
git add lib/counter.dart
git commit -m "fix: prevent negative counter values"
git push
```

**Run 6 must be green:** seven tests pass, the APK builds, and a new artifact
is uploaded with **Run 6's commit ID**. Save this successful run link.

## Checkpoint 10 — Install the APK produced by GitHub

Keep your **Android emulator running**. No installation commands are needed.

1. Stop the local Flutter **Run/Debug** session, but leave the emulator open.
2. Download the APK artifact from **Run 6's summary → Artifacts**.
3. Extract the downloaded ZIP and locate **app-debug.apk**.
4. Drag **app-debug.apk** from File Explorer onto the **emulator screen**.
5. Wait for installation to finish, then open **Counter Lab** from the emulator's
   app launcher.

### If you see INSTALL_FAILED_UPDATE_INCOMPATIBLE

The error may say **"signatures do not match newer version"**. The emulator
already has your locally built Counter Lab, and the GitHub APK uses a different
signing key. Android cannot replace the installed app with that APK.

1. On the emulator, open **Settings → Apps → Counter Lab → Uninstall**.
2. Drag the downloaded **app-debug.apk** onto the emulator screen again.
3. Wait for installation to finish, then open **Counter Lab** from the app launcher.

Keep the emulator running throughout. Uninstalling removes Counter Lab's data;
this sample has no saved data.

**Use the APK downloaded from GitHub.** Do not press Flutter Run afterward:
that would replace it with a local build.

Test these behaviours:

| Behaviour | Expected result |
| --- | --- |
| Open the delivered app | Count starts at 0 |
| Tap + twice | Count is 2 |
| Tap - once | Count is 1 |
| Tap Reset | Count is 0 |
| Tap - at 0 | Count stays 0 |

Show the instructor the running downloaded app, Run 6's commit/artifact, and
the failed Run 5. This confirms you tested the build delivered by the pipeline.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| No Actions run | File is `.github/workflows/ci-cd.yml`; push to main; Actions enabled |
| YAML error | Six spaces before each step; spaces not tabs; one steps list |
| Formatting fails | Run `dart format lib test`, commit the formatted files, push again |
| Lockfile error | Use the pinned SDK, run `flutter pub get`, commit pubspec.lock |
| Test fails unexpectedly | Read the first failing assertion and reproduce it locally |
| Build skipped | Fix the earlier failed step before investigating Android |
| APK build fails | Inspect the Android/Gradle error; confirm android/ and wrapper are committed |
| No artifact at Run 3 | Expected: artifact upload starts at Run 4 |
| No artifact at Run 5 | Expected: the failed tests block build and upload |
| Artifact expired | Re-run a known successful workflow or push a small valid change |
| Wrong downloaded version | Use the repaired run's summary and match its commit ID |
| No space / slow emulator | Stop unnecessary emulators and wait for a fully booted Android home screen |

## Submit

- Call me to grade you
- Show me the downloaded APK working on Android; call me when ready.



