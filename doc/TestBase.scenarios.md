# Scenarios

Look up the thing you are writing. Coroutines sit together, and threads sit together. The heading is the situation. The paragraph is that situation, then the result the host reports.

The note pairs with [TestBase.md](TestBase.md) and [CaseHarness.md](CaseHarness.md). A harness change holds when every paragraph still comes out as written. A change that moves a paragraph is an edit here first. The status words are pass, fail, timeout, refused, setup failed, and cleanup failed.

## How a test case reports success or failure

A comparison, a return, and an assert are the ways the body records its own result.

- Happy Path can show all success modes at once
- Unhappy path needs individualised examples.
- When can a test fail
	- config
	- pre - hooks
	- setup
	- run
	- cleanup
	- post - hooks
- How are failures triggered
	- fail on assert
	- fail on bad return code
	- fail on bad runcode
- What changes the runcode
	- manual change
	- Check Functions
		- check
		- refuse



### Checking a Value

The body compares a few values and returns the session result. The case needs no tree. The host reports pass. The file is `res://cases/TR Features/checks.gd`.

### Failed check

One comparison fails, and the body still returns pass. The host reports fail. The label is an output line, and the return leaves the check failed. The file is `res://cases/TR Features/failure/check.gd`. It passes one comparison, fails `1 == 2`, passes a later check, and returns pass.

### Fail return

Every check passes, and the body returns fail. The host reports fail. The file is `res://cases/TR Features/failure/return_code.gd`.

### Assert

The body executes `assert(false)` and has nothing after it. The editor host and a template_debug play report fail. template_release refuses the case before the body, because that flavour compiles `assert` out. `res://tests/test_runner/test_001/test_assert_fail.gd` is that body on the old base, and it stays until a feature file exists.

## Coroutines

The body can await. Work it starts and leaves parked is still this run. The next case is the wrong place to notice it.

### One frame

The body awaits one process frame and then returns. A tree host reports pass. The script host refuses the case before the body, reason `needs_tree`. The file is `res://cases/TR Features/frame.gd`.

### Unawaited timer

Setup parents a node to the root. The body arms a short timer, connects it to a function that writes a mark on that node, and returns pass without awaiting. Cleanup frees the node. The mark, and any error on the freed node after the result was stored, belong to this run.

### Cleanup returns early

Cleanup queues the node free, defers a rename, and returns before the next idle. The rename belongs to this run. The next case finding the node still there, or the rename landing on a freed instance, is this run's failure.

### Deferred call

The body defers a function that appends a line and parents a node, then returns pass with no await. The stored output is missing that line, the call lands on a freed instance, or the node is on the root after the result. Any of those is this run's failure.

### Signal left connected

Setup connects `node_added` on the tree to a method on the case. The body returns pass. Cleanup leaves the connection. The next case parents a node and that method runs, or the method errors because the case is already gone. The connection belongs to the run that made it.

### Two fibers

The body awaits a signal nobody emits, and it also connects `process_frame` to a function that awaits another frame and then parents a node. The budget ends the run. The host stores one result. The process-frame function parenting a node after that result is this run's failure.

### Handshake

A node emits `ready` as it enters the tree and emits `settled` on the next frame. The body adds the node, awaits `ready`, and returns. `settled` writes a mark. Cleanup frees the node before that frame. The mark, or `settled` on a freed node, belongs to this run.

## Threads

A thread keeps running after the body returns. Joining it is part of the case. `wait_to_finish` on the main thread can also stall the process the budget is supposed to protect.

### Still running

The body starts a thread that sleeps and then writes an autoload, and returns pass without joining. Cleanup returns without joining. The autoload changing after the result, or a thread-safety error from the worker, is this run's failure.

### Deadlock

Setup locks a mutex and starts a worker whose first act is to lock that same mutex. Cleanup calls `wait_to_finish` while the main thread still holds the lock. The editor freezes. The budget never fires, because the main thread is inside the join and is not pumping.

### Never started

The body fails before `Thread.start` succeeds. Cleanup calls `wait_to_finish` on a thread that never started. The stored failure is the body's. The error from the join does not replace it.

### Hand-off

The worker instantiates a scene and defers a call onto the case with that node. The body returns without awaiting the call. Cleanup joins a thread that is already exiting and does not free the node. An orphan node, or a call on a freed case, is this run's failure. `res://tests/test_runner/threads/test_instantiate.gd` performs the hand-off and still waits. It times the instantiate. It is not this failure.

### One joined

The body starts two threads that each sleep and then increment one counter. Cleanup joins the first. The counter moving after the result, or the second thread still started, is this run's failure.

### Pool task

The body adds a pool task that waits, then appends to an autoload array, and does not wait for the task. Cleanup returns. The next case reads the array twice, a frame apart. The array growing between the reads is this run's failure.

## Setup and cleanup

Setup takes something. Cleanup gives it back. A phase that fails has its own status.

### Owned node

Setup parents a node, the body uses it, and cleanup frees it. A tree host reports pass. The script host refuses the case, reason `needs_tree`. The file is `res://cases/TR Features/setup_cleanup.gd`.

### Setup error

Setup returns an error and has acquired nothing. The host reports setup failed and stops before the body and before cleanup. The file is `res://cases/TR Features/failure/setup.gd`. The body would fail a check if it ran. Anything acquired before that error has to be released in setup, because cleanup will not run.

### Cleanup error

The body passes and cleanup returns an error. The host reports cleanup failed. The file is `res://cases/TR Features/failure/cleanup.gd`.

### Halfway

Setup parents a node and then returns an error before the thread it meant to start. A cleanup that joins the thread first, and only then frees the node, errors on the missing thread and leaves the node. Cleanup releases what exists and tolerates what was never created. The host still reports setup failed.

### Same-frame free

Cleanup `queue_free`s a node named `leftover` and returns. The next case, started on this same frame, still finds `leftover`. The node is gone after the idle flush. Finding it is this run's leftover, seen one case too late.

### Orphan

The body does `Node.new()` and drops the variable, with no `free` and no `add_child`. The orphan count rises across the run. `print_orphan_nodes` names it. The suite can still report pass. The orphan is this run's failure.

### Timer name

The harness parents its timer to the root under the validated name of the script path. A node already there under that name is queued free, because it looks like an old timer. Two script paths that sanitize to one name share one timer, so one budget finishes both waits or neither.

### Tween left running

The body creates a tween on an autoload property over half a second and returns without killing it. Cleanup leaves it. The next case reads that property twice and sees it change. The change belongs to the run that created the tween.

### File and port

The body starts a long-lived process that holds a file under `user://` and a port, and it does not store the pid. Cleanup returns. The next case fails to rewrite the file or to bind the port. On Windows the lock is the usual shape. `TracyCapture` is the same shape when the capture process is still alive after a failed end.

### Time scale and pause

One run sets `Engine.time_scale` to `0` and returns. One sets the tree paused and returns. One disables a profiler category and returns. None of them restore the value. A following case that only awaits a short timer hangs, or the category stays off. The restore belongs to the run that changed it.

### Mouse and window

The body sets `Input.mouse_mode` to captured and returns. The suite can report pass while the editor looks hung. Restoring `VISIBLE` belongs to that run.

### Shared values

Four runs, one mutation each. An autoload integer incremented and left there. A `static var` on the case set to a sentinel. A property written on a preloaded resource. `seed` called and left there. The following case reads that location and fails when it sees the sentinel. It reads before it resets anything. The sentinel belongs to the run that wrote it.

### Edited scene

The body adds a child to `EditorInterface.get_edited_scene_root()` and adds an input action named `failure_case_action`. Cleanup removes neither. The open scene stays dirty, and a following case sees `InputMap.has_action("failure_case_action")`. Both belong to the run that added them.

### Group and meta

The body adds the root to the group `failure_case` and sets meta `failure_case` on the root. Cleanup undoes neither. The next case sees the group or the meta. Either one belongs to the run that set it.

## Instance

The host stores a result and drops the case. A fiber still parked on that case then runs against a freed object, or it keeps the case alive after the suite has moved on.

### Dropped while parked

The body awaits a signal nobody emits and would parent a node after that await. The budget fires and the host drops the case. The signal is delivered anyway. An error on a freed instance, or a node appearing after the timeout result, is this run's failure.

### Freed with the fiber

The body connects `process_frame` to a function that frees a `RID` stored on the case, then awaits a signal nobody emits. The budget frees the case before that frame. The `RID` still allocated after the result is this run's leak.

### Held alive

The body connects an autoload signal to a method on the case and never disconnects. The method increments a counter. After the result, that signal is emitted twice and the counter moves. The case is still alive. The connection belongs to the run that made it.

### Deferred finish

A worker defers the method that would emit the signal the body is awaiting. The host drops the case before that idle, the way a timeout drop does. The body never resumes. The budget is the only thing that ends the run.

### Scene torn down

Two runs. One calls `change_scene_to_file` on a scene that does not contain the case, while the case is parented to the current scene, during an await. The other frees every direct child of the root, including the harness timer, then awaits a signal nobody emits. The await hits a freed node, or the run never returns. The run that tore the tree down owns that result.

### No tree yet

The case is constructed and `run_test` is called before `add_child`. The body awaits `get_tree().process_frame` on the assumption there is a tree. The failure is a reported fail from this run. An editor error with no stored result is the wrong outcome.

## Clock

The budget is the host giving up on a body that has not returned. It only helps while the main thread is pumping and the timer is in a tree that is advancing.

### Replaced budget

The case declares a budget of 3 seconds. Configure checks that value and sets 4 seconds. The body checks the replacement. The host reports pass. The file is `res://cases/TR Features/budget.gd`.

### Timeout

The body waits longer than its budget. A tree host reports timeout. Cleanup would record a mark, and the stored run is missing that mark, because the host stops before cleanup. Post still runs, and the status stays timeout. The script host refuses the case, reason `needs_tree`. The file is `res://cases/TR Features/failure/timeout.gd`. It waits 0.75 seconds on a 0.25 second budget. The cleanup mark is the part this file still owes.

### Zero budget

The case sets the budget to 0. The host reports timeout, and the run ends on that status. A pass that depends on the next frame is the wrong result. The body would return pass if the clock let it finish. There is no file yet.

### Main thread blocked

The body calls `OS.delay_msec` for several times the budget, with no await. The host stays inside the run for that whole delay and then takes the result the body returns. The delay ending is a return, not a timeout.

### Paused clock

Setup sets `Engine.time_scale` to `0` and pauses the tree. The body awaits a signal nobody emits. A timer that respects time scale and pause never elapses. The run fails to time out until something else unpauses the tree. A budget that ignores both reports timeout.

### Same frame

The budget is one frame. The body awaits exactly one process frame and returns pass. Run it many times. Each run stores one result, and cleanup either always runs or never runs. A mix that depends on call order is the failure.

### Cleanup still waiting

The body returns pass. Cleanup frees the node the body created, then awaits a signal nobody emits. The budget fires during that await and the host records timeout. The signal is emitted afterward. The stored result stays timeout. A second completion, or a freed-instance error from the rest of cleanup, is the failure.

## Hooks

Pre runs before the body. Post runs after the run has a status, including a timeout. A capture is a hook the session installs when this run asked for one.

### Pre and post

Configure installs a hook. Pre runs before the body. Post appends a line. The host reports pass, and the line is in the output. The file is `res://cases/TR Features/hooks.gd`.

### Pre fails

Pre returns an error. The host reports fail, the output names the hook, and the host stops before the body. The file is `res://cases/TR Features/failure/pre.gd`.

### Post fails

The body passes and post returns an error. The host reports fail. The output names the hook. The file is `res://cases/TR Features/failure/post.gd`.

### Capture

The body checks the hook against this run's capture request. The hook is the capture when the tools are configured and the run asked for one, and the hook is empty when the capture was skipped. A tree host reports pass. The script host refuses the case, reason `needs_tree`. The file is `res://cases/hooks/tracy.gd`.

## Suite

One process runs the cases in a folder. Each case finishes before the next one starts. A leftover from a section above is the next case's starting state when that order slips.

### One then the next

Two cases in one folder share a marker. The first writes the marker in cleanup. The second reads it in setup and checks that the write already happened. The host finishes the first case before it starts the second. Both report pass. There is no file yet.

### Started together

Two cases each await two frames and parent a uniquely named node. They are started together. Both nodes, both results, and any error from a second `add_child` of the same timer name are visible. One result each, with the nodes from that case alone, is the sound run.

### Twice at once

The same case is started twice without waiting. Each run writes a marker into a static and reads it back after a frame. The marker changing under the other run, or one run deleting a script the other is still on, is the failure. Play shares one generated file path. The editor and the script host share the static and the preloaded resource.

### Parse error

A file whose name begins with `test` has a parse error after a `static var` initialiser that increments an autoload. It sits between two plain passes. The passes keep their own results. The increment from the broken file is still a leftover of the scan that loaded it.

### Nested run

The body asks the service to run a second case that increments an autoload and returns. The outer case then reads the autoload and returns. The inner result exists, the outer result exists, and the outer body can see the increment. The outer cleanup leaves the inner case's node alone.

### Two games

The editor is set to more than one run instance. A case writes a fixed path under `user://` and binds a fixed port. The second instance fails on the file or the port. That failure belongs to the shared resource. The two processes do not share a scene tree, so a tree leak in one is invisible to the other.

## Editor

The case is running where scripts reload, dialogs open, and the dock scans files. Some cases belong only to the editor, or only to the project main scene.

### Editor only

The body checks that the host is the editor and that the hint is set. The editor host reports pass. Play and the script host refuse the case before the body, reason `editor_only`. The file is `res://cases/TR Features/editor_only.gd`.

### Main scene

The case needs the project main scene. A play of that scene reports pass. The editor dock and the script host refuse the case when another scene was the one started, reason `needs_main_scene`. The file is `res://cases/TR Features/failure/main_scene.gd`.

### File saved during the run

During the body, after an await has begun, a harmless comment is written to a `.gd` file the running case depends on, and the body awaits another frame. The resume faults, or it runs a mix of old and new bytecode. A script error after the write, with the host never storing a result, is the failure. A generated play copy beside the case is the usual way the file gets written.

### Reload on the stack

A command that is itself a running script reloads that script's resource before the command returns. The command still produces one result, or a single reported failure. A bytecode fault with no result is the failure. This is the reload that faults when `RUN_SCRIPT` reloads the command that is executing.

### Progress on the flush

File > Run enters on a message-queue flush. Opening an `EditorProgress` task is the first line of the body, before any further await. The task opens, or the host reports fail. A pass with an error in the debugger is the failure. This build has no script-visible `EditorProgress`. `EditorToaster.push_toast` is the call a body can make instead, and `res://tests/test_runner/editor_reenters/test_editor_toast.gd` only brackets that call.

### Dialog left open

The body shows an `AcceptDialog` and returns without hiding it. The next case is a plain pass that does not look for the dialog. The dialog still visible after the suite result belongs to the run that opened it.

### Headless

The body awaits `gui_input` on a control under the headless main loop, with a normal budget. There is no viewport to grab and no popup to show. The host reports timeout from this run. A hang, or a pass, is the wrong result.

### Error after the result

The body defers `push_error` and returns pass. The stored result and the debugger both show that error on this run. A green row, with the editor paused on a red error that belongs to the previous case, is the failure.

### Scan runs the body

A case file has a `static var` initialiser that increments an autoload. Refreshing the test tree, without running the case, leaves the autoload alone. Running the case increments it once. An increment on the scan is a run that nobody asked for.

## Native

A native class is another way to write the body. The script names the class. The session calls are the class's.

### Native pass

The script names a native class. The class returns pass. The editor host, template_debug, and template_release report pass. There is no file yet. `res://tests/scene_tree` times `add_child` for a flat list and for a hierarchy, in GDScript and in a native library. Those files are the measurement. This heading is the pass.

## Files

These scripts repeat a heading above, or they were written while a trace was open. The guidance is the heading. The trace is not a second scenario.

### Samples

`test_success.gd`, `test_failed.gd`, `test_tests.gd`, and `test_timeout.gd` under `res://tests/test_runner/test_001` repeat Values, Fail return, Values again, and Timeout. `test_assert_fail.gd` stays with Assert.

### Happy path

`res://tests/test_runner/happy_path` repeats Values, One frame, and Owned node on the old base.

### Proof

`res://cases/proof` repeats Values, One frame, and Pre and post. That folder was the migration proof. The feature cases cover those three results.

### Probes

The scripts under `res://tests/test_runner/cap`, `coroutines`, `editor_reenters`, `instance_and_tree`, `result_hides`, `setup_left`, `suite`, `threads`, and `work_still_running` were written while a trace was open. Timeout, Failed check, and Owned node hold the three results that already have a feature file. The other scripts tidy the accident before they return, so a pass never meant the accident was contained.

### Servers

`res://tests/server` is twelve scripts. Each one checks that a named engine server is registered.

### Timings

`res://tests/scene_tree` is the measurement named under Native pass. It leaves the suite of host results.
