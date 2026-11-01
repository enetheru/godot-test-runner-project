# Failure cases

Pair to [TestBase.md](TestBase.md). Each entry is a what-if that can leave the editor wrong after a run has already reported a result. Under it is the failure, then a case that makes the failure visible.

Watch three places. The run that caused it. The next run. The process after both, including orphan nodes, open processes, and the editor's scene. A pass that only happened because nothing was watching those places is not a pass. The case belongs to the run that made the mess. The next run is not the detector.

## Work still running

`_run_test` and `_cleanup` can return while another fiber is still parked. The host then stores the result and starts something else. The parked fiber resumes into that world.

**What if the body starts a coroutine and never awaits it?**
  The coroutine resumes after cleanup, often on a node cleanup already freed, or during the next test.
  Case. Setup parents a `Node` to the root. The body starts `SceneTree.create_timer(0.2)` and connects `timeout` to a function that writes a mark on that node. The body does not await the timer. It returns pass. Cleanup frees the node and returns. Wait past the timer. Watch for an error after the result was stored, and for the mark being written while the next test is running.

**What if cleanup starts work and returns before that work finishes?**
  The host believes teardown is done. The deferred free, the signal, or the frame callback runs one idle later and hits the next test.
  Case. Cleanup `queue_free`s the node from the case above and also does `node.call_deferred("set_name", "late")`, then returns without awaiting a frame. The next test runs on the following idle and looks up children of the root. Watch for the renamed node still being there, or for `set_name` on a freed instance.

**What if a deferred call is queued and the result is stored first?**
  `call_deferred` and `process_frame` run after the host has copied `output` and released the instance. The call lands on a freed object, or on a live one whose result can no longer change.
  Case. The body `call_deferred`s a function that appends a line to `output` and parents a node. The body then returns pass with no await. Watch the stored output for the missing line, the debugger for a call on a freed instance, and the root for the node.

**What if a signal on a long-lived object stays connected?**
  The tree, the root, or an autoload outlives the test. The connection fires on the next scene change, the next input event, or the next test's node.
  Case. Setup connects `scene_tree.node_added` to a method on the test. The body returns pass. Cleanup does not disconnect. The next test parents a node. Watch that method run, or an error if the test instance has already been freed.

**What if two fibers are parked and only one is the body?**
  The timeout, or a normal finish, completes one fiber. The other is still awaiting. When it resumes it calls `_cleanup` again, emits a second result, or touches objects the first finish already released.
  Case. The body awaits a signal nobody emits, and before that await it also connects `scene_tree.process_frame` to a function that awaits a second frame and then parents a node. Force the cap. Watch for a single result, then for the process-frame function parenting a node after that result.

**What if the body awaits one frame of a two-step handshake?**
  The first resume is enough for the body to return. The second step was another signal, already connected, and it runs after cleanup.
  Case. A node emits `ready` immediately on `add_child`, and emits a custom `settled` on the next frame. The body adds the node, awaits `ready`, and returns. It does not await `settled`. `settled` writes a mark. Cleanup frees the node before the next frame. Watch for the mark, or for `settled` on a freed node.

## Threads

A `Thread` or a `WorkerThreadPool` task is not a coroutine. Cleanup can return while it is still inside Godot. `wait_to_finish` on the main thread can also deadlock the process the cap is supposed to protect.

**What if a thread is still running when cleanup returns?**
  The worker later calls into a node, a resource, or the tree. That call is off the main thread. It errors, corrupts the tree, or lands in the next test.
  Case. The body starts a `Thread` that sleeps, then sets a variable on an autoload. The body returns pass without joining. Cleanup returns without joining. The next test reads the autoload, then the worker writes it. Watch the autoload change after the first result, and any thread-safety error from the worker.

**What if the worker and the main thread wait for each other?**
  The main thread calls `wait_to_finish` while it still holds the lock, the semaphore, or the queue the worker needs. The cap never fires, because the main thread is blocked inside the join.
  Case. Setup creates a `Mutex`, locks it, and starts a worker whose first act is to lock that same mutex. Cleanup locks nothing new and calls `wait_to_finish`. Watch the editor freeze. A cap that depends on the main thread pumping does not expire during this freeze.

**What if the worker was never started?**
  `Thread.start` failed, or the body returned before `start`. Cleanup always joins. `wait_to_finish` on a thread that never started is an error, and that error can replace the original failure.
  Case. The body calls `start` with a callable and, on a forced failure from a stand-in that returns an error before `start`, returns fail. Cleanup calls `wait_to_finish` unconditionally. Watch which failure is stored: the body's, or the join's.

**What if the worker hands an object back after the test has released it?**
  The worker builds a node or a resource and `call_deferred`s it to the test. The test has already returned, and the host has dropped it. The deferred call is discarded or hits a freed instance. The object is now orphaned on a thread that is about to exit.
  Case. The worker instantiates a packed scene and `call_deferred`s a function on the test with that node. The body does not await that function. Cleanup joins the thread, which is already exiting, and does not free the node. Watch for an orphan node and for a call on a freed instance. `tests/threads/test_instantiate.gd` is the shape of the hand-off, without the early return.

**What if only one of two workers is joined?**
  The joined worker is gone. The other is still in the pool or the `Thread`. The test looks clean because the join that was written down succeeded.
  Case. The body starts two threads that each sleep and then increment one autoload counter. Cleanup joins the first only. Watch the counter move after the result, and watch `Thread.is_started` on the second.

**What if a `WorkerThreadPool` task is never waited on?**
  `add_task` runs on a pool thread after the test has returned. The task captures the test, or a node, and runs during the next test.
  Case. The body adds a task that waits briefly, then appends to an autoload array. It does not call `wait_for_task_completion`. Cleanup returns. The next test reads the array twice, a frame apart. Watch the array grow between the reads.

## Setup left in place

Anything setup acquires is still there when setup fails, when the body fails, or when cleanup forgets it. `queue_free` does not mean the node is gone yet.

**What if setup acquires something and then fails?**
  The body never runs. A harness that skips cleanup on a failed setup never releases the node, the thread, the process, or the profiler setup already started.
  Case. Setup parents a node, starts a `Thread` that waits on a semaphore, then returns a failure. Do not give the body a chance to clean up. Watch the root for the node and `OS` for the thread after the result. The following test is a plain pass. Watch it stay a plain pass while the node and the thread are still there. That plain pass is the bug.

**What if setup fails halfway through two acquisitions?**
  The first resource exists. The second never did. A single cleanup path that assumes both exist will error on the second and skip releasing the first.
  Case. Setup parents a node, then returns failure before starting the thread it would have stored in the same field. Cleanup, if it runs, joins the thread without a null check and only then frees the node. Watch the node remain when the join errors.

**What if a node is parented to the root and never freed?**
  The next test finds it, collides with its name, or treats it as part of the game.
  Case. Setup does `Node.new()`, names it `leftover`, and `add_child`s it to the root. The body returns pass. Cleanup returns without freeing it. The next test fails if `leftover` is still a direct child of the root.

**What if the only free is `queue_free`, and the next test starts on this frame?**
  The node is still in the tree until the idle flush. A suite that starts the next test immediately still sees it. So does `find_child`.
  Case. Cleanup `queue_free`s `leftover` and returns. The suite starts the next test without awaiting a frame. That test looks for `leftover`. Watch it find the node. Await one more frame and watch the node disappear too late.

**What if a node is never added to the tree and never freed?**
  It is an orphan. The suite can pass. The leak shows up as an orphan count, or at editor exit.
  Case. The body does `Node.new()` and drops the variable without `free` or `add_child`. Snapshot the orphan-node count before the run and after cleanup. Watch it rise. `print_orphan_nodes` names it.

**What if the test's node name is the harness timer's name?**
  The timer is parented to the root under `resource_path.validate_node_name()`. A leftover, or a real node, with that name is queued free on the next run because it looks like an old timer. The inverse also holds: two script paths that sanitize to one name share one timer.
  Case. Parent a `Label` to the root under the validated name of a known test, before that test runs. Run the test. Watch the `Label` get queued free. Then run two tests whose sanitized names match and whose bodies both hang. Watch them share one timer, so one cap finishes both or neither.

**What if a `Timer`, a `Tween`, or a `SceneTreeTimer` of the test's own is left running?**
  It fires during the next test and calls a method, or fires on a freed instance.
  Case. The body creates a `Tween`, tweens an autoload property over half a second, and returns without killing the tween. Cleanup does not kill it. The next test reads that property twice. Watch it change.

**What if a file, a port, or a process is left behind?**
  On Windows the next open of that path fails because the process still holds it. A capture port stays bound. A later run then fails for a reason that belongs to the earlier run.
  Case. The body starts a long-lived process that writes a file under `user://`, and does not store the pid. Cleanup returns. The next test tries to rewrite that file and to bind the same port. Watch the lock and the bind error. `TracyCapture` is the real shape of this case when the capture process is still alive after a failed end.

**What if the profiler, the time scale, or the pause flag is left changed?**
  Recording stays on, categories stay off, `Engine.time_scale` stays at 0, or the tree stays paused. Later tests hang, record nothing, or run in slow motion. A timer that respects time scale or pause never reaches the cap.
  Case. Three separate runs. One sets `Engine.time_scale` to `0` and returns. One sets `get_tree().paused` to true and returns. One disables a profiler category and returns. None of them restore the value. A following test that only awaits a short timer is the watch. It should finish. A hang, or a category that stays off, is the failure.

**What if the editor's input or window is left captured?**
  `Input.mouse_mode` captured, or a fullscreen window, makes the editor look hung. The suite result can still say pass.
  Case. The body sets `Input.mouse_mode` to captured and returns without restoring `VISIBLE`. Watch the editor after the result. Restore belongs to that run.

**What if an autoload, a static, a preloaded resource, or the random seed is mutated?**
  The next test's pass depends on what the previous test wrote. Order changes the result. A static on the test script survives the instance. A preloaded resource is one object shared by every load.
  Case. Four mutations, one per run. An autoload integer incremented and not restored. A `static var` on the test script set to a sentinel. A property written on a `preload`ed resource. `seed(1)` called and not restored. Each following test reads that location and fails if it sees the sentinel. The following test must not itself reset the value before reading it.

**What if the edited scene or a global input action is mutated?**
  A node added to `EditorInterface.get_edited_scene_root()` dirties the scene the person has open. An `InputMap` action added and not erased is still there for the next test and for the editor.
  Case. The body adds a child to the edited scene root and adds an input action named `failure_case_action`. Cleanup does neither removal. Watch the scene stay dirty, and watch `InputMap.has_action("failure_case_action")` from a following test.

**What if a group or a meta entry is left on a node the test does not own?**
  The root, an autoload, or the edited scene keeps `set_meta` and `add_to_group`. A later `get_nodes_in_group` or `get_meta` sees the test's value.
  Case. The body adds the root to group `failure_case` and `set_meta("failure_case", 1)` on the root. Cleanup does not undo either. The next test fails if that group or that meta is present.

## The instance and the tree

The host drops its reference when it sees a result. Anything still parked on that instance then runs against a freed object, or keeps the instance alive forever.

**What if the last reference is dropped while a fiber is parked?**
  The timeout path does this on purpose today: the host returns, the pin goes, the body is still awaiting. The resume errors on a freed instance, or never happens.
  Case. The body awaits a signal nobody emits and would parent a node after that await. Force the cap. Let the host drop the instance. Deliver the signal anyway. Watch for a freed-instance error, and for whether a node appears after the timeout result.

**What if a `Node` test is `queue_free`d while a child fiber is parked?**
  Play mode frees the node when the run returns. A callback queued on it dies with it, or runs in the free. A resource the callback was going to release leaks.
  Case. The body connects `process_frame` to a function that frees a `RID` stored on the test, then awaits a signal nobody emits. Force the cap so the host frees the node before that frame. Watch the `RID` still allocated after the result.

**What if something that outlives the test holds the test?**
  A lambda on an autoload, a signal connection from the autoload to the test, or `set_meta` of the test on the root keeps the instance. Its `_process`, its timer, or its connections keep running after the suite has moved on. The mirror is a cycle that should have ended and does not.
  Case. The body connects an autoload signal to a method on the test and never disconnects. The method increments a counter. After the result, emit that signal twice. Watch the counter move. The test instance is still alive.

**What if a deferred call was the only way the body would finish, and the instance is already gone?**
  Godot drops a deferred call on a freed object. A waiter that needed that call hangs until some other cap.
  Case. A worker `call_deferred`s the method that would emit the signal the body is awaiting. Before the idle runs, drop the test instance the way a timeout drop does. Watch the body never resume, and watch the host's cap be the only thing that ends the run.

**What if the test removes the current scene, or frees the children of the root?**
  A test parented under the current scene is freed mid-body. A harness timer parented under the root is freed with those children. The cap then never fires, and the await errors because the tree or the node is gone.
  Case. Two runs. One calls `change_scene_to_file` on a scene that does not contain the test, while the test node is parented to the current scene, during an await. The other frees every direct child of the root, including the harness timer, then awaits a signal nobody emits. Watch for an await on a freed node, and for a run that does not return.

**What if the test is not in the tree when it waits?**
  `get_tree()` is null. A timer parented to the test does not tick. An await on `process_frame` from that node fails. The host can sit in setup with no cap.
  Case. Construct the test and call `run_test` before `add_child`. The body awaits `get_tree().process_frame` under the assumption there is a tree. Watch the failure be a reported fail from this run, not an editor error with no result.

## The cap

The deadline only helps if the main thread is pumping, and if the timer is still in a tree that is actually advancing.

**What if the body never returns to the tree?**
  `while true` with no await, or `OS.delay_msec` for longer than the cap, blocks the main thread. The timer cannot emit. The host cannot store a timeout.
  Case. The body calls `OS.delay_msec` for several times the cap. Watch the host stay inside the run for that whole delay, then take whatever result the body returns. The delay ending is not a timeout.

**What if time scale is 0, or the tree is paused, and the timer respects both?**
  The cap is armed and does not elapse. A test that paused the game as its subject, and then awaits, never finishes.
  Case. Setup sets `Engine.time_scale` to `0` and `get_tree().paused` to true. The body awaits a signal nobody emits. Use a timer that does not ignore time scale and does not ignore pause. Watch the run fail to time out until something else unpauses the tree.

**What if the body and the cap finish on the same frame?**
  One path stores pass and runs cleanup. The other stores timeout and skips cleanup. Whichever runs second overwrites the result, frees twice, or cleans up after the host has already returned.
  Case. Setup sets the cap to one frame. The body awaits exactly one `process_frame` and returns pass. Run it many times. Watch for one result per run, and for cleanup either always running or never running, not a mix that depends on call order.

**What if cleanup is still awaiting when the cap fires?**
  The host stores timeout and releases the instance. Cleanup later resumes, fails, and writes a second result over the timeout. Or it releases something the late body is still using.
  Case. The body returns pass. Cleanup awaits a signal nobody emits, after it has already freed the node the body created. Force the cap during that await, let the host record timeout, then emit the signal. Watch the stored result stay timeout, and watch for a second completion or a freed-instance error from the rest of cleanup.

**What if the cap is 0 or negative?**
  Some timers emit on the next frame. Some treat the value as already expired. Some never arm. The run can pass, hang, or timeout before setup finishes, depending on that accident.
  Case. Setup sets the cap to `0` and returns success. The body would return pass. Run again with the cap set to `-1`. Watch both runs return a definite result, and watch a pass not depend on winning a race against the next frame.

## The suite

One process runs every test. A leftover from one case above becomes the next test's starting state. Overlap makes two bodies share that state at once.

**What if the next test starts before the previous test's late work?**
  The selection does not wait, or the service starts a parallel batch. Both bodies parent nodes, both connect the same autoload signal, both name a timer from their script path.
  Case. Two tests. Each awaits two frames and parents a uniquely named node in cleanup's last line, which is too late if cleanup is skipped, and in the body if it is not. Start them together. Watch both nodes, both results, and any error from a second `add_child` of the same timer name.

**What if the same script is run twice at once?**
  Both runs share one static, one preloaded resource, and, in play, one generated file path. One cleanup deletes the file the other is still executing.
  Case. Start the same play-mode test twice without waiting. Each run writes a marker into a static and reads it back after a frame. Watch the marker change under the other run. Watch one run delete a script the other is still on.

**What if one script in the middle cannot instantiate?**
  The suite records a failure for it and continues. The half-loaded script, or a static initialiser that already ran, is still in the process.
  Case. A file that begins with `test` has a parse error after a `static var` initialiser that increments an autoload. It sits between two plain passes. Watch the passes keep their own results, and watch the autoload. The increment from the broken file is still a leftover.

**What if a test starts another test?**
  The outer run is awaiting. The inner run uses the same tree, the same autoload, and maybe the same harness service. The outer cleanup runs after the inner run has already mutated what the outer setup built.
  Case. The body asks the service to run a second test that increments an autoload and returns. The outer test then reads the autoload and returns. Watch the inner result exist, the outer result exist, and the autoload change be visible to the outer body. Then watch the outer cleanup not tear down the inner test's node.

**What if two game instances both enter the runner?**
  The editor is set to more than one run instance. A scene whose `_ready` starts a test starts it once per process. Files under `user://` and any shared port collide. The two processes do not share a scene tree, so a tree leak in one is invisible to the other.
  Case. A test writes a fixed path under `user://` and binds a fixed port. Launch two instances on purpose. Watch the second fail on the file or the port. That failure belongs to the shared resource, not to the assertions in the test.

## The editor re-enters

The test is running inside the editor. Saving a script, reloading a plugin, or opening a dialog is not outside the run. It can replace the bytecode under the parked function.

**What if a `.gd` file is written during the run?**
  The editor reimports and reloads scripts. A function that is currently awaiting is reloaded out from under itself. The resume faults, or runs a mix of old and new bytecode. A generated play copy beside the test is the usual way this happens.
  Case. During the body, after an await has begun, write a harmless comment to a `.gd` file the running test actually depends on, then await another frame. Watch the resume. A script error after the write, with the host never storing a result, is the failure.

**What if the running command reloads the script that is on the stack?**
  The reload replaces the script while `_run` or a command is still inside it. The finish path then calls into a null script, or the VM reports a bad instruction pointer.
  Case. From a command that is itself a running script, reload that script's resource before the command returns. Watch the command still produce one result, or a single reported failure. A bytecode fault with no result is the failure. This is the reload that already faults when `RUN_SCRIPT` reloads the command that is executing.

**What if `EditorProgress` is opened from the flush the host arrived on?**
  File > Run enters on a message-queue flush. `EditorProgress` refuses to open there. The test errors, or the dialog never appears, and the body still returns pass.
  Case. Open an `EditorProgress` task as the first line of the body, on File > Run, before any further await. Watch the task open, or watch a reported fail. A pass with an error in the debugger is the failure.

**What if a dialog is left open?**
  A modal file dialog or accept dialog holds the editor. The next test's input goes to the dialog. The person cannot tell the suite from a stuck editor.
  Case. The body shows an `AcceptDialog` and returns without hiding it. The next test is a plain pass that does not look for the dialog. Watch the dialog still be visible after the suite result.

**What if a headless editor runs a test that needs a window?**
  There is no viewport to grab, no mouse to capture, and a popup cannot show. The test awaits an input event that will never come.
  Case. Run a body that awaits `gui_input` on a control under the headless main loop, with a normal cap. Watch a timeout from this run, not a hang and not a pass.

**What if an engine error is delivered after the result?**
  `push_error` inside `call_deferred`, after the body has returned pass, breaks the debugger on the next idle when break-on-error is set. The panel already shows pass. The editor is paused on a red error that belongs to the previous test.
  Case. The body `call_deferred`s `push_error` and returns pass. Watch the stored result and the debugger. The error belongs to that run's result.

**What if merely loading the script runs the test?**
  An `@tool` script with work in a static initialiser, `_init`, or `_enter_tree` runs when the dock scans the file. The suite has not started. The autoload is already mutated, and a later run sees a dirty process and calls it a failure of the test.
  Case. Give a test file a `static var` initialiser that increments an autoload. Refresh the test tree and do not run the test. Watch the autoload. Then run the test once and watch it increment again. The scan and the run are both visible, or the scan does not count as a run.

## A result that hides the failure

The leftovers above are one family. A stored pass in front of a real failure is the other. The case watches the stored result, not the absence of a crash.

**What if checks failed and the body still returns pass?**
  The failed check is in the log. The stored result is pass, because the return replaced it. The panel shows success.
  Case. Fail one equality check, then return the pass value. Watch the stored result be fail, and watch the check's message still be in the output. `tests/test_001/test_tests.gd` is the passing shape of "return the running result". This case is that shape with a check that does not hold.

**What if the body aborts with no return?**
  An `assert`, a null call, or a stack overflow never reaches a return. The default integer is a success on a normal function. The host can store pass because nothing wrote a failure.
  Case. `assert(false)` as the only line. A second run calls a method on `null`. Watch both store fail. `tests/test_001/test_assert_fail.gd` is the assert seed.

**What if `push_error` or `push_warning` is the only symptom?**
  The body returns pass. The debugger is red or yellow. The suite is green.
  Case. The body calls `push_error` and `push_warning` and returns pass. Watch the stored result be fail, or watch the output carry those messages and the result stay fail. A green row with a red debugger is the failure.

**What if a late line arrives after the host copied the output?**
  The copy is what `TESTS_RUN` returns and what the panel shows. The test's own array grows afterwards. Anyone reading the live object disagrees with the stored result.
  Case. The body schedules a deferred append to `output` and returns pass. The host copies `output` at the result. Wait a frame and compare the copy with the live array. Watch them diverge.

**What if a timeout and a late failure disagree?**
  The cap stores timeout. A cleanup fiber that was already past the cancel later stores fail, or pass. The caller that read the result early disagrees with the caller that reads the fields again.
  Case. Use the cleanup-versus-cap case from above. Read the result at the moment the host returns, and read the same fields again after the late cleanup resumes. Watch the two reads match.
