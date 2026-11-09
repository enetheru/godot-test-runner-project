# Case and harness

Sketch for review. Nothing here is a change to the runner yet. It replaces the "One class" sketch in [TestBase.md](TestBase.md) if it is accepted. That sketch makes the test file the node. This one keeps the test file as the case. The session is shared. The clock is the part that changes when the process has no tree.

The copy is what failed. `scripts/rewrite.gd` turns `TestBase.gd` into `PlayBase_generated.gd` by replacing the header and hoping editor calls sit on the same line. `main_panel.re_write` then skips the first three lines of each test and writes `{name}_alt.gd` extending `PlayBase`. The generated class drifted: its thread check and its scene-tree lookup no longer match `TestBase`. The three-line splice also drops anything that is not `extends TestBase`, including a capture wrapper and a `class_name`. `tests/test_runner/test_001/test_assert_fail_alt.gd` is one of those splices, and it still extends `PlayBase`.

## Terms

**Case**
  The body. `_setup`, `_run_test`, and `_cleanup`. A GDScript case is a `RefCounted`. A GDExtension case is a native class with the same three calls. The case does not extend `EditorScript`, `Node`, or `MainLoop`, and it does not need `@tool`. When the host has a tree, the case awaits signals on that tree. When it does not, the case runs without one.

**Session**
  The run record. It owns `runcode`, the output, and the hooks. It is a `RefCounted`, not a `Node`. Every host uses the same session. This is the part of today's `TestBase` that does not need a tree.

**Clock**
  How the session notices time. A tree host uses a `Timer` parented to a root. A script host uses the iterations of its `MainLoop` and a time check. The case never builds the clock.

**Editor context**
  The editing process. Hint is true. The dock, the context-menu run, and `TESTS_RUN` live here, including a headless editor. `EditorInterface` exists in this process. The editor's own `SceneTree` is the tree. File > Run does not. That command belongs to an `EditorScript`, and a case is not one.

**Play**
  A game `SceneTree`. Hint is false. Play is three executables, not three buttons.

**Script**
  The editor executable started with `-s` or `--script`. This build refuses that launch unless the script inherits `SceneTree` or `MainLoop`. The runner's script is a `MainLoop` and not a `SceneTree`, so the process has a loop and no tree. `EditorInterface` is absent. Hint is false.

**Flavour**
  Which Godot executable the process image is. `OS.has_feature` already names them: `editor`, `template_debug`, and `template_release`. Flavour is not the host. The editor binary is the image for the editor context, for play, and for script.

## Play flavours

**editor**
  The editor binary running a game. Feature `editor` is set, and hint is false. Play Project, Play Current Scene, and Play Custom Scene are this flavour. They choose a scene. They do not choose an executable. A case that needs the main scene says so, and the session skips it when another scene was the one started.

**template_debug**
  The debug export template. Feature `template_debug`. No editor singletons. `assert` still aborts.

**template_release**
  The release export template. Feature `template_release`. `assert` is compiled out. A check that must survive this flavour goes through the session and `runcode`. A case whose point is that `assert` aborts, such as `test_assert_fail`, is bound to the editor binary and `template_debug`.

Guess: a template binary will not run a loose project directory the way the editor binary runs `--path`. Templates expect a pack. How the runner produces that pack, and whether the export plugin ships the session, the player scene, and `res://tests`, is open. [TestBase.md](TestBase.md) already leaves the export question unread.

## GDExtension

A native case is another way to write the body. It is not a host. The same class name is loaded inside whichever flavour is running, and the `.gdextension` file already maps a library onto `editor`, `template_debug`, and `template_release`. The runner does not pick the library.

`tests/scene_tree/gdextension` is the shape, halfway. `SceneTreeAddEach` and `SceneTreeAddHierarchy` are the work. Each `.gd` file repeats the session calls by hand. After this sketch, that file only names the native class and the traits. The scanner can keep looking for `test*.gd`.

## Traits

The session reads these before it starts a case, and refuses a case the current process cannot host.

**editor_only**
  The case calls `EditorInterface` or another editor singleton. Play flavours skip it. The script host skips it too.

**needs_main_scene**
  The case assumes the main scene ran. The editor play flavour skips it when the started scene is not that one. The script host skips it, because that host has no scene.

**needs_tree**
  The case uses a node, `process_frame`, or any other signal that only a `SceneTree` emits. The script host skips it. Editor context and every play flavour can run it.

**native**
  The class name to instantiate. Empty means the `.gd` file is the case.

A case may also read the host and the flavour from the session when the body itself must branch. The refusal above is the default, so most cases never mention an executable or a tree.

## Launch

The dock and `TESTS_RUN` construct the session, attach the tree clock to the editor tree, load the case, and call the run. They stay in the editor context.

Right-click Run is the same call. `plugin.gd` is already an `EditorPlugin`. It registers an `EditorContextMenuPlugin` on `CONTEXT_SLOT_FILESYSTEM` and on `CONTEXT_SLOT_SCRIPT_EDITOR`. The item is added only when the selected path is a case. Choosing it runs that case in the editor context. The code-editor slot stays empty. A right-click in the buffer is not a request to run the file.

Play, on any flavour, starts one player scene. That scene attaches the tree clock to the game root and runs the cases it was given. The editor binary reaches that scene through a normal play launch. `template_debug` and `template_release` reach it through the pack, once that path exists. The case does not change between those launches.

Script points `-s` at the runner's `MainLoop`, not at the case. That loop constructs the session, attaches the loop clock, and runs the cases it was given. A case marked `needs_tree` is refused before it starts. A case that only checks values, or that awaits a signal the loop itself emits, can run. There is no root, no `process_frame`, and no `Timer` node.

`TracyCapture` installs on the session. The header splice can no longer drop it, because the header is no longer rewritten. A capture that needs a frame mark still belongs to a tree host. The script host does not invent one.

## Proof

Migration waits until each host has run a case that was written for it. The proof is a new pair, not a wrapper around `TestBase`. One case checks a value and carries no `needs_tree` trait. One case awaits a frame and carries `needs_tree`. Neither is `@tool`. Neither extends `EditorScript`.

The proof is done when each of these has been seen:

1. The context menu runs the frame case from a right-click in the FileSystem dock, and from a right-click of that script in the script list. The session uses the editor tree.
2. `-s` on the editor executable runs the value case through the runner's `MainLoop`. The same launch refuses the frame case before the body starts.
3. The player scene on the editor binary runs the frame case with hint false.
4. That player scene runs the frame case on `template_debug`, after the pack question is settled.
5. `template_release` runs the value case. The frame case's checks still go through the session, because `assert` is gone on that executable.

A native case is not part of this proof. The GDExtension shape stays as it is until the script and the tree hosts agree.

## What stays until migration

The result words stay: pass, fail, setup failed, cleanup failed, and timeout. `RetCode` stays inverted, with `TEST_OK` as 1, until a separate change. On a tree host the timer still does not cover a `_setup` that never returns. The script host has the same hole until its loop clock covers setup. Moving that deadline is the timeout work in [TestBase.md](TestBase.md), and it is not required to separate the case from the clock.

The existing `@tool` scripts stay on `TestBase` through the proof. They still run from the dock and from File > Run. The proof does not wrap them, and it does not delete `@tool` from them.

## Order

1. Add the case type, the session, and both clocks. Add the two proof cases in a new folder. Leave every existing test file as it is.
2. Register the context menu on `plugin.gd` and run the frame case from both right-clicks.
3. Run the value case through `-s` on the editor executable, and confirm the script host refuses the frame case.
4. Run the frame case from the player scene on the editor binary, hint false.
5. Settle the pack, then run the player scene on `template_debug`.
6. Run the value case on `template_release`.
7. Only after the proof list has been seen, choose the first existing folder to migrate. `tests/test_runner/happy_path` is the likely one, because `test_checks.gd` matches the value case and `test_await_frame.gd` matches the frame case.
8. Point `tests/scene_tree/gdextension` at a native class name and delete the handwritten adapter bodies.
9. Retire `scripts/rewrite.gd`, `main_panel.re_write`, the `_alt.gd` path, and `test_assert_fail_alt.gd`. The assert-fail case remains the one source file, limited to flavours that keep `assert`.

## Recommendation

Prove the hosts with the two new cases before any existing file changes class. The menu item is part of that proof, not a follow-up, because a case has no File > Run. The failure corpus and the scene-tree extension stay untouched until the editor binary and `template_debug` have both run the frame case.
