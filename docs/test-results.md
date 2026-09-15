# Test results

Generated with MATLAB R2025b on September 15, 2026.

## Automated suite

```text
Running test_pendulum_solve
........
Done test_pendulum_solve

Running test_pendulum_ui
...
Done test_pendulum_ui

Totals:
   11 Passed, 0 Failed, 0 Incomplete.
   8.3500 seconds testing time.
```

The suite covers requested output times, energy conservation and dissipation, the small-angle period, pendulum geometry, invalid inputs, stiff parameters, playback state, responsive sizing, full-circle animation bounds, interpolated rod length, plot labels, and phase-portrait legends.

## Numerical checks

| Check | Result |
| --- | ---: |
| Default case samples | 751 |
| Default case final time | 15 s |
| Default case final angle | -11.796865 deg |
| Default case final energy | 0.290997 J |
| Undamped relative energy variation | 3.59745e-9 |
| Measured 5-degree period | 2.007500 s |
| Analytical small-angle period | 2.006067 s |
| Relative period difference | 0.071449% |

Run the suite again from the project directory with:

```matlab
results = runtests("tests");
assertSuccess(results)
```
