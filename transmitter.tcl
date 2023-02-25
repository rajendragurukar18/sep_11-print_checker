clear -all
analyze -sv12 -f design.f

elaborate -top token_tx

clock clk
reset -expressio {!rst_n}

prove -all
