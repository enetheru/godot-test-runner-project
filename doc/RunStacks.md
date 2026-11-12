# Run stacks

Do these in order. Each one removes a second copy of a step, or a file the run never reaches. The call graph behind the list is a partial pass over the scripts, and it is not a live run.

## One editor run

- [ ] Replace the setup copied between `main_panel.run_case` and `batch._run_case` with one function. It builds the session, sets the editor host, applies the Tracy mode, calls `attach_tree`, instantiates the case, and awaits `run_await`.
- [ ] Teach that function to write TIMEOUT from `session.status`, and to keep at most 200 log lines. Today only the batch does either step, so a dock row and a TESTS_RUN row disagree.
- [ ] Leave Cancel and the info card on `main_panel._walk_rows`. The walk is the only place that has a next row to skip and a card to show.
- [ ] Leave `opts.parallel` inside `batch.start`. Delete any sentence on `begin_run` that reads as if `begin_run` branches on the flag. The dock walk stays one row at a time because Cancel and the card are per row.

## One timeout rule

- [ ] Change `run_sync` so a timeout in setup skips the body, and a timeout in the body skips cleanup. `run_await` already returns at those points. `script_host.gd` is the only `run_sync` caller, so headless `-s` is the run that still finishes the later phases.

## One launch dispatch

- [x] `CaseMenu.launch` starts all five `RunKind` ids. EditorScript walks the panel rows when the panel registered that starter, and otherwise walks the paths.
- [x] The context menu and `_launch_kind` both enter through `launch`. `_run_rows_as_editor` is the EditorScript starter that launch calls.
- [x] `GDFB_HEADLESS_TESTS` awaits `launch` with `Launch.EDITORSCRIPT` on the filesystem menu. The batch is no longer that path.
- [x] The starters stay behind `launch`: the panel walk, the player scene, the two template packs, and the script host. `PlayPack.ensure` still only exports.

## One card

- [x] Play and headless cards are built with `create_info`. `_card_for_case` sets the title, the description, and the log.

## Delete what the run never calls

- [ ] Delete `runner/Strategy.gd`. `TR_Strategy` is declared there and has no caller from the dock, the menu, TESTS_RUN, or `GDFB_HEADLESS_TESTS`.
- [ ] Delete `gate.gd` `create_hold`. The plugin still loads the gate to pause Command Server while a run is active. That connection stays.

## Hooks

- [x] Keep `hook_dirs` as the way a hook joins every run. The scan of `runner/hooks` already yields `TracyCapture.gd`, and `_accept` still keeps it off while the saved enabled flag is false.
- [x] The Tracy case appends a `TracyCapture` instance in `_configure`. Install stays before configure, so the case does not write `hook_paths`. `hook_paths` remains the list the batch fills before the run. `HOOK`, `HOOKS`, and `TR_Hook.const_paths` are gone.
- [x] `_configure` still appends a `TR_Hook`. Pre and post are the call sites. Another moment in the procedure is a new virtual on the hook and a call site in the session.

## Leave alone

- [ ] Leave the clock on the host. `_open` already refuses a missing clock before hooks run, and `_arm` starts whatever clock the host attached.
- [ ] Leave `scan.gd` on reload. A later run reuses the groups when the roots are unchanged.
- [ ] Leave ping, list, last, clear, reload, and set-level on the command server. `tests_run.gd` remains the command that reaches `begin_run`.
