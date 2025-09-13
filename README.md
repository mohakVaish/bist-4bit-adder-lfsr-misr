## Run on EDAPlayground
1) Language: Verilog, Tool: Icarus Verilog, Top: `tb_extract_golden`
2) Design pane: paste `src/design_bist_blocks.v`
3) Testbench pane: paste `tb/tb_extract_golden.v`
4) Run → Console prints `Golden = 0x..`
5) For checking: switch Testbench pane to `tb/tb_check_golden.v`, set `GOLDEN_SIG` to the value printed, Top: `tb_check_golden` → Run

## Known results for this config (seed=0x01)
- 64 cycles → golden `0x16`
- 255 cycles → golden `0x09`
