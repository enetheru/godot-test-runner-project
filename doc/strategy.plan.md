# Strategy

A strategy is a schedule. A case is one run. The tree shows both. A click on a case goes straight to a case session. A click on a strategy, or on a folder, asks a strategy session to walk the children and roll them into one result.

The seed is [strategy.md](strategy.md). The same note sits under the failure heading in [TestBase.scenarios.md](TestBase.scenarios.md). This document is the order of work. The scenario paragraphs stay the contract until a cell replaces a file, and that replacement edits the paragraph first.

An earlier pass spliced the matrix into the case session. That pass is set aside. The case session runs one case.

## Terms

**Case**
  One body. `_configure`, pre, setup, the run, cleanup, and post belong to one case session. The session keeps one status word.

**Strategy**
  A script that names children and a verdict. It does not extend `TR_Case`. The tree gives it an icon of its own.

**Strategy session**
  The walk. It finds or builds the children, runs each one, and writes one result for the row. It does not grow a second phase machine. A case session still runs each case.

**Child**
  A case or a strategy. Either one returns the same record: a name, a status, and the lines.

**Folder strategy**
  The run of a folder. It is not a file inside that folder. Its children are the scripts the scan already lists.

**Verdict**
  The strategy's rule for those records. A folder passes when every child passes. The failure matrix passes when every child reports the status it expects.

## What the tree shows

The scan lists case scripts and strategy scripts. A strategy script gets an icon on its name. A folder keeps the folder icon. Running that folder still uses a strategy session. Painting every folder as a strategy would repeat what the folder icon already says.

A click on one case skips the strategy layer. A case is a strategy of one, and the scheduler has nothing to decide. A folder that holds one case is a strategy with one child. Those are different clicks.

## The walk

The starter looks at the row. A case calls the case session, as it does today. A strategy script calls a strategy session. A folder calls a strategy session whose children are the discovered scripts.

The strategy session walks its children. A case child gets a case session. A strategy child gets the same walk again. The host is the button the user pressed, and a nested strategy inherits it. Play still means one game per case session. The editor still means this process. A strategy that picked its own host would put two schedules on one click.

The walk keeps the scripts it has already entered. A strategy that names an ancestor is refused. The folder strategy is not itself a file in the folder, so a folder run does not find itself in the scan and start again.

The row's report is the one the panel, the play host, and the script host already read. One status for the row. The children's lines sit in the output. A second result type would land in all three starters at once.

## How a strategy builds children

The strategy decides the children. Two shapes cover the expansions that matter.

**One case per child**
  Each child is its own case and its own case session. Setup, the run, and cleanup belong to that child. The failure matrix uses this shape, because a plant in pre, setup, cleanup, or post has to be inside that child's steps.

**One case for the product**
  The strategy builds one case. Setup runs once, the body walks the product, and cleanup runs once. A matrix whose plants all sit in the run uses this shape.

Reusing one case session and clearing it between children is not a third shape. That asked the case session to be the schedule. The clock frees its timer when a case ends, and the status word belongs to that one case.

## The failure matrix

The first strategy script is the failure matrix from the seed. It stays one row. It builds one case per cell and runs a case session for each. The verdict is the expected status, not "the child passed."

The product is place × trigger. Place is `config`, `pre`, `setup`, `run`, `cleanup`, or `post`. Trigger is `assert`, `retcode`, `runcode_manual`, or `runcode_check`. The first slice runs the seven cells whose status the case session already produces.

| Place | Trigger | Expected status | Sentence |
| --- | --- | --- | --- |
| `pre` | `retcode` | `fail` | Pre returns an error. The host reports fail and skips the body. |
| `setup` | `retcode` | `setup failed` | Setup returns an error and acquires nothing. The host reports setup failed. The body does not run. |
| `run` | `retcode` | `fail` | Every check passes. The body returns fail. The host reports fail. |
| `run` | `runcode_check` | `fail` | A false check. Returning pass does not clear it. The host reports fail, and the label is an output line. |
| `run` | `runcode_manual` | `fail` | The body assigns fail and returns pass. The host reports fail. |
| `cleanup` | `retcode` | `cleanup failed` | The body passes. Cleanup returns an error. The host reports cleanup failed. |
| `post` | `retcode` | `fail` | The body passes. Post returns an error. The host reports fail. |

Five of those sentences already have a file under `res://cases/TR Features/failure/`. The files stay until a live run of the strategy matches them.

A resource beside the strategy trims place and trigger while a cell is being written. A missing file means the seven cells. A pair with no expected status still produces a line, `config / retcode — no expected status`, so a listed pair that is not ready yet is visible. A stop flag can wait. The walk records every child.

The card line names the pair, the plant's status, and the expected word: `pre / retcode`, then the two words. A hook that returns an error gets its own line. The row can still fail for that hook. The cell can still match. A status of `fail` has to say whether the plant or the hook produced it.

## Order of work

1. Add a strategy script type beside `TR_Case`. The scan lists it. The case scan leaves it out.
2. Give strategy rows an icon on the name. Leave folder icons as they are.
3. Add the strategy session. It walks children, sends a case to a case session, sends a strategy back into the same walk, and refuses a script it has already entered.
4. Teach the starters that one branch. A case row uses the case session. A strategy row and a folder row use the strategy session. The host is the button.
5. Add the failure-matrix strategy. It builds the seven cases, one session each, and passes when each status word matches the table.
6. Run that row on the editor host. The card lists seven pair lines. The row passes. A hook error is its own line.
7. Point one expected word at the wrong value, run, and confirm the row fails and the card names that pair. Restore the word.
8. Run the same row on a play host. The seven plants do not need a tree. The status words should match the editor run.
9. Send a folder run through the strategy session. A folder of ordinary cases passes when every case passes. The failure folder will fail until the hand-written failure scripts leave, because those scripts are children and their verdict is pass.
10. Leave those files in place until the strategy's live run has matched them. Removing a file edits its scenario paragraph first.

The case session stays the runner of one case. The strategy session is the only new walker.

## Later

Assert on `run`, with one expected word per flavour. Configure, after the scenario note names the status word. A check during cleanup or post, after the note chooses between the status word and `runcode`. A body that calls `refuse`, filed with the other host refusals. A strategy whose children are other strategies, once the folder walk and the failure matrix both use the same session. Options for a strategy shown when its row is clicked, which [Notes.md](Notes.md) already asks for of a case.
