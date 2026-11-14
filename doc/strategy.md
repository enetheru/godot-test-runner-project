# Strategy

A strategy is a schedule. A case is one run. The tree shows both. A click on a case goes straight to a case session. A click on a strategy, or on a folder, asks a strategy session to walk the children and roll them into one result.

The hosts and the status words are in [case.md](case.md). The situations those children repeat are in [scenarios.md](scenarios.md).

## Terms

**Case**
  One body. Configure, pre, setup, the run, cleanup, and post belong to one case session. The session keeps one status word.

**Strategy**
  A script that extends `TR_StrategyScript`. It does not extend `TR_Case`. It names children and accepts or rejects each child's status.

**Strategy session**
  The walk, `TR_StrategySession`. It finds or builds the children, runs each one, and writes one result for the row. A case session still runs each case.

**Child**
  A case or a strategy. Either one returns the same record: a name, a status, and the lines.

**Folder strategy**
  The run of a folder. It is not a file inside that folder. Its children are the case scripts and strategy scripts the scan lists, and each subfolder is walked the same way.

**Verdict**
  The strategy's rule for those records. A folder passes when every child passes. The failure matrix passes when every child reports the status it expects.

## The tree

The scan lists case scripts and strategy scripts. A strategy script gets the checklist icon on its name. A folder keeps the folder icon. Running that folder still uses a strategy session.

A click on one case skips the strategy layer. A folder that holds one case is a strategy with one child. Those are different clicks.

## The walk

The starter looks at the row. A case calls the case session. A strategy script calls a strategy session. A folder calls a strategy session whose children are the discovered scripts. A `res://` directory on the command line or in `CASE_PATHS` is kept, so the session receives the folder.

The strategy session walks its children. A case child gets a case session. A strategy child gets the same walk again. The host is the button the user pressed, and a nested strategy inherits it. One play of a strategy is one game. Each child inside that game is still its own case session. The editor and the script host run the walk in that process.

The walk keeps the paths it has already entered. A strategy that names an ancestor is refused. The folder strategy is not a file in the folder, so a folder run does not find itself and start again.

The row's report is the line the panel, the play host, and the script host already read. One status for the row. The children's lines sit in the output.

## Children

`_children` returns dictionaries.

**path**
  A case script, a strategy script, or a folder.

**case**
  A built `TR_Case`. The strategy session runs that instance. The report path is the strategy file, because the body has no file of its own.

**expect**
  The status word that passes. Empty means `pass`.

**skip**
  A line for a child that does not run. The row does not fail for it.

**hook_plant**
  True when the plant itself is the pre or post hook. A hook error on any other child fails the row even when the status word matches.

`_accept` is the verdict. The base compares the status word to `expect`.

Two shapes cover the expansions.

**One case per child**
  Each child is its own case and its own case session. Setup, the run, and cleanup belong to that child. The failure matrix uses this shape, because a plant in pre, setup, cleanup, or post has to be inside that child's steps.

**One case for the product**
  The strategy builds one case. Setup runs once, the body walks the product, and cleanup runs once. `res://cases/TR Features/strategy_checks.gd` uses this shape. Its `_run_test` calls every `TEST_*` function.

## The failure matrix

`res://cases/TR Features/strategy/failure_matrix/failure_matrix.gd` is one row. It builds one case per cell and runs a case session for each. The verdict is the expected status.

The product is place × trigger. Place is `config`, `pre`, `setup`, `run`, `cleanup`, or `post`. Trigger is `assert`, `retcode`, `runcode_manual`, or `runcode_check`. The cells that run are the seven whose status the case session already produces.

| Place | Trigger | Expected status |
| --- | --- | --- |
| `pre` | `retcode` | `fail` |
| `setup` | `retcode` | `setup failed` |
| `run` | `retcode` | `fail` |
| `run` | `runcode_check` | `fail` |
| `run` | `runcode_manual` | `fail` |
| `cleanup` | `retcode` | `cleanup failed` |
| `post` | `retcode` | `fail` |

The hand-written scripts under `res://cases/TR Features/failure/` are still separate rows. A run of that folder fails, because a folder expects every child to pass and those scripts do not. Removing one edits its paragraph in [scenarios.md](scenarios.md) first.

`failure_matrix.tres`, beside the script, trims place and trigger. A missing file means those seven cells. A listed pair with no expected status produces a line such as `pre / runcode_manual — no expected status` and does not run. `assert` and `config` are in the product and have no expected status, so they stay off the default lists.

The card line names the pair and the two words: `run / retcode status=fail expected=fail`. A wrong expected word fails the row and that line shows the pair. A hook error is indented under the child. On a child that is not itself the pre or post plant, that hook line fails the row.

## A folder

`res://cases/proof` is a small folder of ordinary cases. `hooks.gd` and `value.gd` pass on a play host. `frame.gd` passes its body. A capture crop that fails in post still fails that child, and the folder fails with it.

`res://cases/TR Features/failure` fails until those scripts leave.
