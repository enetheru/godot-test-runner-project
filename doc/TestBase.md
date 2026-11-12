# Test base

Removed after tag `before-drop-testbase`. The paragraphs below describe that runner.

`TestBase` exists so one test file can run as an editor script, from the test panel, inside a running game, and on its own. The hosts do not call it the same way. The extra layers are the adaptations between them: a self-pin, a deferred body, and a timeout that gives up on the body.

This note reads `addons/enetheru.test-runner` as it stands. Nothing in it is a decision. The hosts are how a run is started. The run is what `run_test` does after that. The result value and the shared session are where one test comes to mean two things. Idle code is what those paths leave unused. The last part is what a change makes stale, and one smaller shape, offered as a sketch.

## Hosts

Three hosts reach `run_test`. A bare `-s` process never enters. The checks below used `res://tests/Storage/test_cmpdef_bag_uniqueness.gd`. Entering the runner was the point. The assertions inside that script were left alone.

### Editor script

File > Run enters `_run`. The object is an `EditorScript` with no parent, so `_run` stores itself in `cycleref`, defers `run_test`, waits on `test_finished`, and then clears the pin. The defer also leaves the message-queue flush that File > Run arrives on. `EditorProgress` will not open a task inside that flush.

`RUN_SCRIPT` with the `res://` path calls that same `_run` and returns before the await. The log line is `_run() as editorscript - Started`. A `RUN_SCRIPT` of the cmpdef path printed that line.

### Test panel

`main_panel.tscn` loads `main_panel.gd`. The dock instances the script and calls `run_test`. It does not call `_run`, and it does not set `cycleref`. The local variable is the pin until `run_test` returns.

Open the TestRunner main screen. The tree lists `res://tests`. The row button, tooltip `[Re]Run Test Action`, calls `process_test`. Run calls `process_selection`, which calls `process_test` for each selected file. The log line is `Processing:` and the script path. Calling `process_test` on the cmpdef row printed `Processing: res://tests/Storage/test_cmpdef_bag_uniqueness.gd`.

### Command server

`TestRunnerService._run_one` awaits `run_test` and holds its own reference across that await. `TESTS_RUN` with a `res://` path uses that call. `TESTS_RUN all` runs the scripts the service collects under `res://tests`. The plugin starts the same service when `GDFB_HEADLESS_TESTS=1`, still inside the editor. The line that marks the body is `_run() - OK`. A `TESTS_RUN` of the cmpdef path printed that line. The env-var launch was left unrepeated.

### Running game

While a scene is playing, the editor dock stays in editor hint. Run on that dock calls `process_test` on the script in the tree. While `res://tests/Threads/off_thread.tscn` was playing, an editor script still reported hint true and that scene path.

When `process_test` itself runs with the hint false, it loads that same script. A case goes through the session with the play host. An editor-script test is constructed, and `run_test_base` awaits `run_harness`. The tree comes from the main loop: `_ensure_scene_tree` uses the editor base only while the hint is true and the display is not headless. Play `res://addons/enetheru.test-runner/ui/main_panel.tscn` and use the row button or Run.

Debug > Customize Run Instances... has multiple instances enabled, and the count is 2. The editor stores that under `debug_options` as `multiple_instances_enabled` and `run_instance_count`. Embed on play is off, so one Play press starts two processes. A scene whose `_ready` calls `process_test` enters the runner once in each copy. The marker from that check held the sequence twice.

### Standalone

A test file opened by itself still enters `_run`, which is the editor-script host above. The project editor, headless, with `--path` set to the project and `-s` pointed at the cmpdef script, exited after the engine banner. The same launch with `--script` did the same. Neither printed `_run() as editorscript`. The engine requires a `SceneTree` or a `MainLoop` before it will run an editor script.

## The run

`run_test` finds a tree, awaits `_setup`, starts a timer, defers the body, and waits on `test_finished`.

### Tree

`_ensure_scene_tree` uses the editor base control while a tool script is running and the display is not headless. Otherwise it uses the main loop when that loop is a `SceneTree`. The timer is parented to that tree's root, under a name taken from the script path. A later run that finds the same name queues the old timer free.

### Setup

`_setup` runs on `run_test`'s fiber, before the timer exists. A failure emits `test_finished` and returns. `_cleanup` does not run. A `_setup` that waits forever has no deadline.

### Body

`_launch_test_body` is deferred so the test is outside the flush `run_test` may still be in. It awaits `_run_test_body` on a second fiber, which is what lets the timer finish `run_test` while `_run_test` is parked. `_run_test` is abstract. Its return becomes `runcode` only when the timer has not already finished the run. File > Run has already deferred `run_test` once. The service defers `_run_batch` because the command returns before the batch. The test starts on a later flush than the call that asked for it.

The rule that this stay on the main thread is an `assert` of `Thread.is_main_thread()`. A build that strips `assert` keeps the `await` and drops the check.

### Cleanup and the signal

`_cleanup` runs on the second fiber, after `_run_test` returns, and only when `test_finished` has not already been emitted. The OK or FAILED line is logged before it. A failing cleanup can still flip `runcode` to failed. The timeout logs, emits `test_finished`, and leaves the parked `_run_test` in place. When that await later resumes, the body throws the result away and skips `_cleanup`.

`test_finished` is the only completion signal. `_finish_run` emits it, stops the timer, and ignores a second call. On the success path the order is cleanup, then the signal, then the waiter. On the timeout path the signal fires while `_run_test` is still parked. `_run` then drops `cycleref`. The service drops `_keep` at the same moment. The panel holds that same `EditorScript` in a local until `run_harness` returns, in the editor and in a game. The object lasts until its last reference goes, and on the timeout path the caller's reference goes at the signal.

What has to stay true is small. The body has to be able to `await`. A parked `await` has to be unable to wedge the panel, the service, or File > Run. The deadline is a `Timer`, so both hosts have to provide a `SceneTree`. The test author writes `_setup`, `_run_test`, and `_cleanup`.

## The same class

The panel runs the file on disk. In the editor and in a game, `process_test` constructs that script and `run_test_base` awaits `run_harness`. `_run` and `cycleref` remain the File > Run pin. The panel leaves them alone.

`_ensure_scene_tree` reads the editor base while the hint is true and the display is not headless. In a game it takes the main loop when that loop is a `SceneTree`.

`TracyCapture` sits beside `TestBase` in the addon. `install` assigns it to `hooks` when that field is empty. `pre` turns the profiler off before `tracy-capture` connects, and `set_enabled` applies on a later frame mark. A test that runs in that gap records nothing. The hook stays on the instance, so the `extends` line in the test file is the class the panel constructs.

## The result

`run_test` returns void. The outcome is left in fields, and each caller reads a different subset.

### Two zeros

Godot `Error.OK` is 0 and `Error.FAILED` is 1. `RetCode` flips that, because a crash or an `assert` returns the default int, and that 0 had to mean failure. `TEST_FAILED` is 0 and `TEST_OK` is 1. `_setup` and `_cleanup` return `Error`, so their success is 0. `_run_test` is declared `-> RetCode` on the base and `-> int` on the tests under `res://tests`.

`TEST_*` clears the run with `runcode &= RetCode.TEST_FAILED`, which is `&= 0`. The body then assigns `runcode` from the value `_run_test` returned, so the return replaces the field. The suite returns `runcode`, and the clear survives. `return OK` from that function is 0, a failure, and `return FAILED` is 1, a pass. `if not TEST_TRUE_RET(...)` depends on the same flip, because failure is the falsy value. The panel stores `instance.runcode as RetCode`.

Each check is three functions: `_test_*`, `TEST_*_RET` for an early return, and `TEST_*` which only updates `runcode`. The suite uses the equality and true/false forms. `TEST_APPROX` and `TEST_OP` are called from `example/example.gd`. `op_string` lists every operator, and `_test_op` implements the six comparisons.

### Callers rebuild status

The panel reads `runcode`. On a pass it also looks for the substring `warn` in the output. A timeout is `TEST_FAILED` in the tree. The service reads `runcode`, then sets the status to `TIMEOUT` when the output contains `Timeout was reached` or `_timed_out` is set. One run is a failure in the tree and a timeout in `TESTS_RUN`.

### The log is bbcode

`logp` and the assertion failures store bbcode and print it with `print_rich`. The panel shows that array in a rich-text label. The command reply includes the print. A colored print put a control character into that reply, and the caller could not parse the JSON. When the info bit is open, `_run_test_body` reduces `output` to one string and drops the string. The lines that do appear are the ones `logp` already wrote.

`local_lvl` defaults to notice, so File > Run stays quiet. The panel copies its level into the instance. Info, debug, and trace open the harness lines.

## The session

### Which host a test thinks it is

The class is the script on disk in the editor and in a game. Hint is true in the editor process and false while a game is running. The tree is filled by the filename prefix `test`, ending in `.gd`, and skipping `_generated.gd`. The panel and the service each declare that predicate. `example/example.gd` extends `TestBase` and the tree never lists it. `example/test_strategy.gd` is the only user of `TestStrategy`, and it sits in the same place.

### Many tests, one process

`process_selection` calls `process_test` and does not wait, so Run starts every selected file and returns. Those coroutines interleave on the main thread and share its tree, its autoloads, and its files. `_run_batch_parallel` is that same unjoined start on the service. The panel never calls it. A test that leaves a node, a setting, or a profiler flag behind leaves it for the next test.

`run_test_base` copies `local_lvl`, awaits `run_harness`, and copies `runcode` and `output`. In `_run_one`, an instance that is neither `TestBase` nor an object with `run_test` returns before the later branch that reports `run_test` missing.

## Idle

The live hosts leave these unused. This list is the rest.

### Old panel and old batch

Nothing references `scripts/main_panel.gd`. That copy scans one directory level and applies `test_folder_filter`. The live panel still declares `default_folder_filter` and `test_folder_filter`, and `collect_tests` never calls them.

Nothing preloads `run_headless.gd`. `test_dir` and `fbs_dir` are unread. The schema pass stores an empty dictionary and then prints it as a result. The script starts `_run` on a `Thread` and reads `retcode`. The field on the test is `runcode`, and the run is an `await` on the main thread. The live list walk is `test_scan.collect_test_tree`, which the panel calls from `collect_tests`.

### Scanner

`test_scan.gd` returns each folder as `name`, `folder_path`, `test_scripts`, and `children`. The panel and the service call `collect_test_tree`. The service passes `default_folder_filter`, which accepts every folder. `RetCode` and `reducer_to_lines` are members of `TR_Base`. `TestDef` and `TestResult` live in `ui/test_rows.gd`.

### Helpers and controls

`u32`, `u32_`, `u64`, and `u64_` have no reader. `sbytes` repeats `Enetheru.string.sbytes`. `bytes_view` returns `sbytes`. Nothing in the addon or under `res://tests` calls either. `TestResult.path` is never assigned.

A Filter label sits ahead of the glob box above the test list. A bare word matches anywhere in the row name. Scan folders are tests_dir and the cases_dirs list on the Options resource. Help loads ui/help.md into a popup. The script fields for the buttons, the popup, `info_list`, and `info_scroller` are never read. The scene connections are what those controls use. The banner functions, such as `_________IMPORTS_________`, return immediately and nothing calls them. They exist so the script outline has headings.

## What a change disturbs

The run lives in `TestBase`. A change to the run, the result, or the signal lands in that class. The panel already constructs it in the editor and in a game. File > Run still enters `_run` on that same object.

Capture is hooks on the instance, so a play run keeps the trace the file asked for. Re-read the File > Run pin, `RUN_SCRIPT` returning before the await, the flush `EditorProgress` refuses, and the scene-tree lookup. That leaves the result numbers, the log text, the filename scan, and the shared session where they are.

The result value comes after there is one implementation. Changing which int means pass means re-reading every `return runcode`, every `if not TEST_*_RET`, the panel's `as RetCode`, the service's `== TEST_OK`, `TracyCapture`'s writes to `runcode`, and saved results where 1 means pass. Making `run_test` return the outcome, instead of leaving it in fields, is that same set of readers plus `_timed_out`.

Status comes before the log text. Once the panel and the service read a status field, a later change away from bbcode and `print_rich` leaves status alone. Changing the log first means rebuilding the `warn` sniff and the `Timeout was reached` sniff.

The signal and the result live on that class. After `test_finished` means the body has returned and `_cleanup` has run, re-read a setup failure, the timeout path, `cycleref`, `_keep`, `queue_free`, `free`, and `TracyCapture`'s await of `run_test`. A body that never awaits a cancel still needs a backstop, and that backstop is the case where cleanup cannot run, because the body is still using what cleanup would release.

Joining the batch is its own change. After `process_selection` waits, re-read `_run_batch_parallel`, which claims to match the unjoined UI, and re-read a `_setup` that still has no timer. The filename scan is independent. After it keys off `TestBase`, re-read `example/`, any helper whose name starts with `test`, and the `_generated.gd` skip.

`scripts/main_panel.gd`, `run_headless.gd`, `collect_tests`, `flatten_test_tree`, the unused constants, and `sbytes` have no live caller. The thread `assert` needs another look only if `run_test` itself starts being called off the main thread.

## One class

The panel already runs this `EditorScript` in the editor and in a game. One `Node` can still be the test. The panel would parent it to the editor tree, and play would parent that same class to the game tree. File > Run would stay a short `EditorScript` whose only job is to parent that node and wait. `_ensure_scene_tree` would then have nothing to do. A capture hook already stays with the instance in play, because the panel runs the file on disk.

That sketch does not put cleanup beside setup. The timer can move to a cancel the body is already awaiting. `test_finished` then means one thing. The current signal is doing both jobs, and the timeout fires the one that drops the caller's pin.

Standalone `-s` stays out. The engine will not run an editor script, or this node, without a main loop. The editor and the game already are that loop. A bare script process is a different host, and `run_headless.gd` is not it.

## Still unread

These would add edges, and this note does not cover them yet. Who reads `user://test_runner_results`, and which of those readers treat `retcode` 1 as success. What an `@tool` load and a second `TESTS_RUN` do to the editor. What a test is allowed to leave on the root, in an autoload, in the profiler, or on disk. Whether the export plugin ships the runner, or `res://tests`.
