# Case

A case is the body of one run. The session is the record of that run. The clock is how the session notices time. A strategy is a schedule of cases, described in [strategy.md](strategy.md). The situations a host must still report are in [scenarios.md](scenarios.md).

The old `TestBase` runner is gone. A case does not extend `EditorScript`, `Node`, or `MainLoop`.

## Terms

**Case**
  The body. Configure, pre, setup, the run, cleanup, and post. A GDScript case extends `TR_Case`. The case awaits signals on the host's tree when that host has one.

**Session**
  `TR_CaseSession`. It runs the case and owns the hooks. `TR_Result` is the record every host passes on: status, `runcode`, host, flavour, hint, reason, path, the log lines, and an `extra` dictionary.

**Clock**
  How the session notices time. A tree host uses a timer on a root. The script host uses the iterations of its main loop. The case does not build the clock.

**Editor**
  The editing process. Hint is true. The dock, the context menu, and `TESTS_RUN` live here. The editor's own scene tree is the tree.

**Play**
  A game scene tree. Hint is false. Play is three executables. The player scene is one. The case does not change between them.

**Script**
  The editor executable started with `-s` on the runner's main loop. The process has a loop and no scene tree. Hint is false.

**Flavour**
  Which executable the process is. `OS.has_feature` names them: `editor`, `template_debug`, and `template_release`. Flavour is not the host. The editor binary is the image for the editor, for play, and for the script host.

## Play

**editor**
  The editor binary running a game. Play Project, Play Current Scene, and Play Custom Scene choose a scene. They do not choose an executable. A case that needs the project main scene is skipped when another scene was the one started.

**template_debug**
  The debug export template. `assert` still aborts. The runner reaches the player scene through a pack.

**template_release**
  The release export template. `assert` is compiled out. A check that must survive this flavour goes through the session and `runcode`.

## Traits

The session reads these before the body and refuses a case the process cannot host.

**EDITOR_ONLY**
  The case calls `EditorInterface` or another editor singleton. Play and the script host skip it.

**NEEDS_MAIN_SCENE**
  The case assumes the project main scene ran. The editor play flavour skips it when the started scene is not that one. The script host skips it.

**NEEDS_TREE**
  The case uses a node, `process_frame`, or another signal only a scene tree emits. The script host skips it. The editor and every play flavour can run it.

## Launch

The dock and `TESTS_RUN` construct the session, attach the tree clock to the editor tree, and run the case.

Right-click Run is that same call. The item is added when the selected path is a case or a strategy. A right-click in the code buffer is not a request to run the file. File > Run belongs to an `EditorScript`, and a case is not one.

Play starts the player scene. That scene attaches the tree clock to the game root and runs what it was given. The editor binary reaches the scene through a normal play launch. `template_debug` and `template_release` reach it through the pack.

The script host points `-s` at the runner's main loop. That loop attaches the loop clock and runs what it was given. A case marked `NEEDS_TREE` is refused before the body. A case that only checks values can run.

Play and the script host run the paths they are given in one executable. Each path still gets its own session. That session loads its own hooks, runs pre, then setup, the body, and cleanup, then post.

A case sets `OWN_PROCESS` when it wants a fresh executable. Absent means share. The editor host is this editor, so the constant changes nothing there. A folder or a strategy is one walk inside the executable that started it, and a child that sets `OWN_PROCESS` stays in that walk.

When a shared executable stops before every path has reported, the launcher runs the first silent path on its own and then continues with the paths that never started.

A strategy or a folder is a strategy session. That walk is [strategy.md](strategy.md). A single case does not go through it.

## Result

The status is `TR_CaseSession.Status`. `OK` and `FAILED` are the labels for pass and fail. The other labels are the enum names: `TIMEOUT`, `REFUSED`, `SETUP_FAILED`, and `CLEANUP_FAILED`.

`TEST_OK` is 1 and `TEST_FAILED` is 0. Setup and cleanup return `Error`, so their success is 0. The body returns the session's `runcode`. A comparison that fails leaves that code failed even when the body returns pass.

`TEST_EQ`, `TEST_APPROX`, `TEST_TRUE`, `TEST_FALSE`, and `TEST_OP` update `runcode`. Each has a `TEST_*_RET` form that also returns the code. `check` is the same idea with a label. `refuse` ends the run before the body.

## Hooks

A hook named by the options list, or by `hook_paths`, loads before configure. A case appends a hook of its own in configure. Pre runs before the body. Post runs after the run has a status, including a timeout.

Capture follows the host's main loop. On a tree it waits for a process frame. On the script host it waits for the loop's next turn, which is when the platform frame mark applies a queued profiler enable. The crop of the saved trace is still post, and a crop error fails that run.
