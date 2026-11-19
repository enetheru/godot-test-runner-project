# Notes

Open work. A finished item leaves this file.

## 2026-11-12
- [ ] The additional play executables should be configurable rather than hard coded, so we can any variants
- [ ] TR_Case uses @tool, we want to build test cases that are not @tool scripts
	- we either split the case script, or we ignore the warning.
	- I tried a middle script that is empty and ignores the warning, but my experiment failed, my testing was not comprehensive though so there is probably more room for testing there.
- [ ] Tests are arranged haphazardly
- [ ] hooks in general need to be expanded to be able to hook into more locations.
- [ ] if the test case has options, show them in the inspector when the case is clicked
## 2026-11-18
- [ ] loads of places where strict contract conventions can be used in the function calls, there is so much useless error checking after the fact.
## 2026-11-19
- [ ] aggregate runs that use a single run instance to cover multiple tests would be nice as the norm, only tests marked as needing their own complete run should load a separate godot instance.