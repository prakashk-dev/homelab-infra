# ADR 0001 — Bare-metal Ubuntu, not a VM on macOS

Context: Intel 2014 mini, no T2, runs Linux cleanly. A VM would add overhead and drive/GPU
passthrough fragility. Decision: wipe macOS, run Ubuntu bare metal. Consequence: the mini IS
the portable baseline; file/media servers are first-class k8s workloads; ~3.5GB freed vs VM.
