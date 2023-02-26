//=============================================================================
// usb_handshake_top_tb.sv - self-checking TB for the INTEGRATED top
//
//  Phase A  LOOPBACK  : TX link outputs wired into the RX link inputs.
//                       Every (type x role x hs_mode x split) request, with
//                       random link-layer ready; legal -> RX must decode the
//                       same handshake, illegal -> err_illegal and RX silent.
//  Phase B  RX DIRECT : TB drives the RX link inputs (all 256 PID bytes x
//                       context, framing errors, stray EOP, abort) and checks
//                       against an independent reference model; TX stays idle.
//  Phase C  FULL DUPLEX: a TX request and an unrelated RX packet at the same
//                       time; both paths must give their own correct result.
//  Phase D  RESET     : reset while TX is busy and RX is mid-packet.
//  Always-on: X check, RX flags one-hot-or-zero, SOP/VALID/EOP never overlap.
//
// Compile with run_top.f.   Optional: +define+VCD / +define+SHM
//=============================================================================

module usb_handshake_top_tb;
    import usb_pid_pkg::*;

    logic clk = 1'b0;
    logic rst_n;
    always #5 clk = ~clk;

    // DUT ports
    logic       hs_mode_i, split_hs_phase_i, hs_expected_i;
    logic [7:0] rx_byte_i;
    logic       rx_byte_valid_i, rx_sop_i, rx_eop_i;
    hs_type_e   handshake_type_o;
    logic       handshake_valid_o, err_pid_o, err_length_o, err_unsupported_o, err_unexpected_o;
    logic       tx_req_i, tx_is_host_i;
    hs_type_e   tx_type_i;
    logic       tx_sop_o, tx_byte_valid_o, tx_byte_ready_i, tx_eop_o;
    logic [7:0] tx_byte_o;
    logic       tx_busy_o, tx_done_o, tx_err_illegal_o, tx_err_busy_o;

    // RX link source: loopback from TX, or driven by this TB
    logic       lb;
    logic [7:0] d_byte;
    logic       d_valid, d_sop, d_eop;
    assign rx_byte_i       = lb ? tx_byte_o                       : d_byte;
    assign rx_byte_valid_i = lb ? (tx_byte_valid_o && tx_byte_ready_i) : d_valid;
    assign rx_sop_i        = lb ? tx_sop_o                        : d_sop;
    assign rx_eop_i        = lb ? tx_eop_o                        : d_eop;

    usb_handshake_top dut (
        .clk(clk), .rst_n(rst_n),
        .hs_mode_i(hs_mode_i), .split_hs_phase_i(split_hs_phase_i),
        .rx_byte_i(rx_byte_i), .rx_byte_valid_i(rx_byte_valid_i),
        .rx_sop_i(rx_sop_i), .rx_eop_i(rx_eop_i), .hs_expected_i(hs_expected_i),
        .handshake_type_o(handshake_type_o), .handshake_valid_o(handshake_valid_o),
        .err_pid_o(err_pid_o), .err_length_o(err_length_o),
        .err_unsupported_o(err_unsupported_o), .err_unexpected_o(err_unexpected_o),
        .tx_req_i(tx_req_i), .tx_type_i(tx_type_i), .tx_is_host_i(tx_is_host_i),
        .tx_sop_o(tx_sop_o), .tx_byte_o(tx_byte_o), .tx_byte_valid_o(tx_byte_valid_o),
        .tx_byte_ready_i(tx_byte_ready_i), .tx_eop_o(tx_eop_o),
        .tx_busy_o(tx_busy_o), .tx_done_o(tx_done_o),
        .tx_err_illegal_o(tx_err_illegal_o), .tx_err_busy_o(tx_err_busy_o)
    );

    int pass_count = 0, fail_count = 0;
    int n_lb_ok = 0, n_lb_illegal = 0;
    int cnt_ack = 0, cnt_nak = 0, cnt_stall = 0, cnt_nyet = 0, cnt_err = 0;
    int n_rx_valid = 0, n_rx_pid = 0, n_rx_len = 0, n_rx_unsup = 0, n_rx_unexp = 0;

    //-----------------------------------------------------------------------
    // Always-on monitors
    //-----------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst_n) begin
            if ($isunknown({handshake_valid_o, handshake_type_o, err_pid_o, err_length_o,
                            err_unsupported_o, err_unexpected_o, tx_sop_o, tx_byte_valid_o,
                            tx_eop_o, tx_busy_o, tx_done_o, tx_err_illegal_o, tx_err_busy_o})) begin
                fail_count++; $display("%0t FAIL [monitor] X/Z on outputs", $time);
            end
            if (!$onehot0({handshake_valid_o, err_pid_o, err_length_o,
                           err_unsupported_o, err_unexpected_o})) begin
                fail_count++; $display("%0t FAIL [monitor] >1 RX result flag", $time);
            end
            if (!$onehot0({tx_sop_o, tx_byte_valid_o, tx_eop_o})) begin
                fail_count++; $display("%0t FAIL [monitor] TX SOP/VALID/EOP overlap", $time);
            end
        end
    end

    //-----------------------------------------------------------------------
    // Utilities
    //-----------------------------------------------------------------------
    function automatic logic [7:0] rnd8();
        return $urandom_range(255, 0);
    endfunction

    task automatic step();
        @(posedge clk);
        #1;
    endtask

    task automatic chk(string name, bit cond);
        if (cond) pass_count++;
        else begin
            fail_count++;
            $display("%0t FAIL [%s]", $time, name);
        end
    endtask

    function automatic bit rx_quiet();
        return !handshake_valid_o && !err_pid_o && !err_length_o &&
               !err_unsupported_o && !err_unexpected_o && (handshake_type_o === HS_NONE);
    endfunction

    function automatic bit tx_quiet();
        return !tx_sop_o && !tx_byte_valid_o && !tx_eop_o && !tx_busy_o &&
               !tx_done_o && !tx_err_illegal_o && !tx_err_busy_o;
    endfunction

    // ---- independent TX reference ----
    function automatic bit ref_legal(hs_type_e t, bit host, bit hm, bit sp);
        case (t)
            HS_ACK:   return 1;
            HS_NAK:   return !host;
            HS_STALL: return !host;
            HS_NYET:  return !host && hm;
            HS_ERR:   return !host && hm && sp;
            default:  return 0;
        endcase
    endfunction

    function automatic logic [7:0] ref_byte(hs_type_e t);
        case (t)
            HS_ACK:   return PIDBYTE_ACK;
            HS_NAK:   return PIDBYTE_NAK;
            HS_STALL: return PIDBYTE_STALL;
            HS_NYET:  return PIDBYTE_NYET;
            HS_ERR:   return PIDBYTE_ERR;
            default:  return 8'h00;
        endcase
    endfunction

    // ---- independent RX reference (1 correctly framed byte + EOP) ----
    task automatic ref_rx(
        input  logic [7:0] pid_byte, input bit hm, input bit sp, input bit he,
        output bit e_valid, output hs_type_e e_type, output bit e_pid,
        output bit e_unsup, output bit e_unexp);
        logic [3:0] t, c;
        bit is_ack, is_nak, is_stall, is_nyet, is_err;
        begin
            t = pid_byte[3:0]; c = pid_byte[7:4];
            e_valid = 0; e_type = HS_NONE; e_pid = 0; e_unsup = 0; e_unexp = 0;
            if (c != ~t) e_pid = 1;
            else begin
                is_ack   = (t == 4'b0010);
                is_nak   = (t == 4'b1010);
                is_stall = (t == 4'b1110);
                is_nyet  = (t == 4'b0110);
                is_err   = (t == 4'b1100) && sp;
                if (is_ack || is_nak || is_stall) begin
                    e_valid = 1;
                    e_type  = is_ack ? HS_ACK : is_nak ? HS_NAK : HS_STALL;
                end else if (is_nyet || is_err) begin
                    e_type = is_nyet ? HS_NYET : HS_ERR;
                    if (hm) e_valid = 1; else e_unsup = 1;
                end else if (he) e_unexp = 1;
            end
        end
    endtask

    task automatic chk_rx(string name, bit e_valid, hs_type_e e_type, bit e_pid,
                          bit e_len, bit e_unsup, bit e_unexp);
        bit ok;
        begin
            ok = (handshake_valid_o === e_valid) && (handshake_type_o === e_type) &&
                 (err_pid_o === e_pid) && (err_length_o === e_len) &&
                 (err_unsupported_o === e_unsup) && (err_unexpected_o === e_unexp);
            if (ok) begin
                pass_count++;
                if (e_valid) begin
                    n_rx_valid++;
                    case (e_type)
                        HS_ACK: cnt_ack++;   HS_NAK: cnt_nak++;   HS_STALL: cnt_stall++;
                        HS_NYET: cnt_nyet++; HS_ERR: cnt_err++;   default: ;
                    endcase
                end
                else if (e_pid)   n_rx_pid++;
                else if (e_len)   n_rx_len++;
                else if (e_unsup) n_rx_unsup++;
                else if (e_unexp) n_rx_unexp++;
            end else begin
                fail_count++;
                $display("%0t FAIL [%s]", $time, name);
                $display("      got: valid=%0b type=%0d pid=%0b len=%0b unsup=%0b unexp=%0b",
                         handshake_valid_o, handshake_type_o, err_pid_o, err_length_o,
                         err_unsupported_o, err_unexpected_o);
                $display("      exp: valid=%0b type=%0d pid=%0b len=%0b unsup=%0b unexp=%0b",
                         e_valid, e_type, e_pid, e_len, e_unsup, e_unexp);
            end
        end
    endtask

    //-----------------------------------------------------------------------
    // Phase A : TX -> RX loopback
    //-----------------------------------------------------------------------
    task automatic tx_loopback(string name, hs_type_e t, bit host, bit hm, bit sp);
        bit legal;
        int cyc;
        begin
            legal = ref_legal(t, host, hm, sp);
            hs_mode_i = hm; split_hs_phase_i = sp; hs_expected_i = 1;
            tx_is_host_i = host;
            tx_byte_ready_i = 0;
            tx_type_i = t; tx_req_i = 1;
            step();
            tx_req_i = 0;
            tx_type_i = hs_type_e'($urandom_range(7, 0));      // type must be latched

            if (!legal) begin
                n_lb_illegal++;
                chk({name, " illegal flagged"}, tx_err_illegal_o === 1 && !tx_busy_o &&
                                                 !tx_sop_o && !tx_byte_valid_o && !tx_eop_o);
                step();
                chk({name, " illegal: nothing sent"}, tx_quiet() && rx_quiet());
            end else begin
                chk({name, " SOP"}, tx_sop_o === 1 && tx_busy_o === 1);
                cyc = 0;
                while (!tx_done_o && cyc < 60) begin
                    tx_byte_ready_i = $urandom_range(1, 0);     // link-layer back-pressure
                    step();
                    if (tx_byte_valid_o) chk({name, " byte value"}, tx_byte_o === ref_byte(t));
                    cyc++;
                end
                chk({name, " done within timeout"}, tx_done_o === 1 && !tx_busy_o);
                chk_rx({name, " RX decoded"}, 1, t, 0, 0, 0, 0);
                n_lb_ok++;
                tx_byte_ready_i = 0;
                step();
                chk({name, " quiet"}, tx_quiet() && rx_quiet());
            end
        end
    endtask

    //-----------------------------------------------------------------------
    // Phase B : direct RX driving
    //-----------------------------------------------------------------------
    task automatic drive_rx(bit sop, bit bval, logic [7:0] b, bit eop);
        d_sop = sop; d_valid = bval; d_byte = b; d_eop = eop;
        step();
    endtask

    task automatic rx_pkt(string name, logic [7:0] pid, bit hm, bit sp, bit he, int nbytes);
        bit ev, ep, eu, eun;
        hs_type_e et;
        begin
            hs_mode_i = hm; split_hs_phase_i = sp; hs_expected_i = he;
            drive_rx(1, 0, rnd8(), 0);
            for (int k = 0; k < nbytes; k++)
                drive_rx(0, 1, (k == 0) ? pid : rnd8(), 0);
            drive_rx(0, 0, rnd8(), 1);
            if (nbytes == 1) begin
                ref_rx(pid, hm, sp, he, ev, et, ep, eu, eun);
                chk_rx(name, ev, et, ep, 0, eu, eun);
            end else
                chk_rx(name, 0, HS_NONE, 0, 1, 0, 0);
            chk({name, " TX idle"}, tx_quiet());
            drive_rx(0, 0, rnd8(), 0);
            chk({name, " pulse gone"}, rx_quiet() && tx_quiet());
        end
    endtask

    //-----------------------------------------------------------------------
    // Phase C : TX request and RX packet at the same time
    //-----------------------------------------------------------------------
    task automatic duplex(string name, hs_type_e t, bit host, logic [7:0] rpid,
                          bit hm, bit sp, bit he);
        bit ev, ep, eu, eun, legal;
        hs_type_e et;
        begin
            legal = ref_legal(t, host, hm, sp);
            ref_rx(rpid, hm, sp, he, ev, et, ep, eu, eun);
            hs_mode_i = hm; split_hs_phase_i = sp; hs_expected_i = he;
            tx_is_host_i = host; tx_byte_ready_i = 1;
            tx_type_i = t; tx_req_i = 1;
            drive_rx(1, 0, rnd8(), 0);               // edge0: TX request + RX SOP
            tx_req_i = 0;
            drive_rx(0, 1, rpid, 0);                 // edge1: RX byte
            drive_rx(0, 0, rnd8(), 1);               // edge2: RX EOP
            chk_rx({name, " RX result"}, ev, et, ep, 0, eu, eun);
            if (legal) chk({name, " TX in EOP state"}, tx_eop_o === 1 && !tx_err_illegal_o);
            else       chk({name, " TX quiet (illegal)"}, tx_quiet());
            d_eop = 0;
            step();                                  // TX done
            if (legal) chk({name, " TX done"}, tx_done_o === 1 && !tx_busy_o);
            chk({name, " RX pulse gone"}, rx_quiet());
            step();
            chk({name, " all quiet"}, rx_quiet() && tx_quiet());
        end
    endtask

    //-----------------------------------------------------------------------
    // Main
    //-----------------------------------------------------------------------
    int i, k;
    hs_type_e rt;

    initial begin
        rst_n = 0; lb = 1;
        d_byte = 0; d_valid = 0; d_sop = 0; d_eop = 0;
        tx_req_i = 0; tx_type_i = HS_NONE; tx_is_host_i = 0; tx_byte_ready_i = 0;
        hs_mode_i = 0; split_hs_phase_i = 0; hs_expected_i = 1;

        repeat (3) @(posedge clk);
        #1;
        chk("reset: RX quiet", rx_quiet());
        chk("reset: TX quiet", tx_quiet());
        rst_n = 1;
        step();

        //=========== Phase A : loopback ===========
        lb = 1;
        for (i = 0; i < 8; i++)
            for (k = 0; k < 8; k++)
                tx_loopback($sformatf("lb type=%0d host=%0d hm=%0d sp=%0d", i, k[2], k[1], k[0]),
                            hs_type_e'(i[2:0]), k[2], k[1], k[0]);
        for (i = 0; i < 1500; i++) begin
            rt = hs_type_e'($urandom_range(7, 0));
            tx_loopback($sformatf("lb rand #%0d", i), rt, $urandom_range(1, 0),
                        $urandom_range(1, 0), $urandom_range(1, 0));
        end

        //=========== Phase B : RX direct ===========
        lb = 0;
        d_sop = 0; d_valid = 0; d_eop = 0;
        step();
        for (i = 0; i < 256; i++)
            for (k = 0; k < 8; k++)
                rx_pkt($sformatf("rxd pid=%02h hm=%0d sp=%0d he=%0d", i[7:0], k[2], k[1], k[0]),
                       i[7:0], k[2], k[1], k[0], 1);
        // framing
        rx_pkt("rxd 0 bytes",   8'h00,       0, 0, 1, 0);
        rx_pkt("rxd 2 bytes",   PIDBYTE_ACK, 0, 0, 1, 2);
        rx_pkt("rxd 257 bytes", PIDBYTE_ACK, 0, 0, 1, 257);
        rx_pkt("rxd good after long", PIDBYTE_NAK, 0, 0, 1, 1);
        // stray EOP (no SOP)
        hs_expected_i = 1;
        drive_rx(0, 0, rnd8(), 1);
        chk("rxd stray EOP ignored", rx_quiet());
        drive_rx(0, 0, rnd8(), 0);
        // abort: new SOP before EOP
        drive_rx(1, 0, rnd8(), 0);
        drive_rx(0, 1, PIDBYTE_NAK, 0);
        drive_rx(1, 0, rnd8(), 0);
        drive_rx(0, 1, PIDBYTE_ACK, 0);
        drive_rx(0, 0, rnd8(), 1);
        chk_rx("rxd abort: only 2nd packet reported", 1, HS_ACK, 0, 0, 0, 0);
        drive_rx(0, 0, rnd8(), 0);
        // SOP + first byte same cycle
        drive_rx(1, 1, PIDBYTE_STALL, 0);
        drive_rx(0, 0, rnd8(), 1);
        chk_rx("rxd SOP+byte same cycle", 1, HS_STALL, 0, 0, 0, 0);
        drive_rx(0, 0, rnd8(), 0);

        //=========== Phase C : full duplex ===========
        duplex("dup dev-ACK  / rx-NAK",   HS_ACK,  0, PIDBYTE_NAK,   1, 0, 1);
        duplex("dup dev-NYET / rx-ACK",   HS_NYET, 0, PIDBYTE_ACK,   1, 0, 1);
        duplex("dup dev-ERR  / rx-NYET",  HS_ERR,  0, PIDBYTE_NYET,  1, 1, 1);
        duplex("dup host-NAK(ill)/rx-ACK",HS_NAK,  1, PIDBYTE_ACK,   0, 0, 1);
        duplex("dup dev-STALL/ rx-badPID",HS_STALL,0, 8'hD3,         0, 0, 1);
        duplex("dup host-ACK / rx-DATA0", HS_ACK,  1, PIDBYTE_DATA0, 0, 0, 1);
        for (i = 0; i < 300; i++)
            duplex($sformatf("dup rand #%0d", i), hs_type_e'($urandom_range(7, 0)),
                   $urandom_range(1, 0), rnd8(), $urandom_range(1, 0),
                   $urandom_range(1, 0), $urandom_range(1, 0));

        //=========== Phase D : reset while both paths are active ===========
        lb = 0;
        hs_mode_i = 1; split_hs_phase_i = 1; hs_expected_i = 1;
        tx_is_host_i = 0; tx_byte_ready_i = 0;
        tx_type_i = HS_NYET; tx_req_i = 1;
        drive_rx(1, 0, rnd8(), 0);                   // TX starts, RX SOP
        tx_req_i = 0;
        drive_rx(0, 1, PIDBYTE_ACK, 0);              // TX in BYTE (stalled), RX has PID
        chk("reset test: TX stalled with valid", tx_byte_valid_o === 1);
        rst_n = 0; #1;
        chk("reset mid-activity: TX cleared", tx_quiet());
        chk("reset mid-activity: RX cleared", rx_quiet());
        repeat (2) @(posedge clk);
        #1;
        rst_n = 1;
        d_valid = 0;
        drive_rx(0, 0, rnd8(), 1);                   // EOP with no SOP after reset
        chk("after reset: stray EOP ignored", rx_quiet() && tx_quiet());
        step();
        lb = 1;
        tx_loopback("post-reset ACK",  HS_ACK,  0, 1, 0);
        tx_loopback("post-reset NYET", HS_NYET, 0, 1, 0);

        //=========== Summary ===========
        $display("==============================================================");
        $display(" checks passed : %0d", pass_count);
        $display(" checks failed : %0d", fail_count);
        $display(" loopback      : %0d sent+decoded, %0d illegal rejected", n_lb_ok, n_lb_illegal);
        $display(" RX valid      : %0d (ACK=%0d NAK=%0d STALL=%0d NYET=%0d ERR=%0d)",
                 n_rx_valid, cnt_ack, cnt_nak, cnt_stall, cnt_nyet, cnt_err);
        $display(" RX errors     : pid=%0d len=%0d unsup=%0d unexp=%0d",
                 n_rx_pid, n_rx_len, n_rx_unsup, n_rx_unexp);
        if (cnt_ack == 0 || cnt_nak == 0 || cnt_stall == 0 || cnt_nyet == 0 || cnt_err == 0 ||
            n_rx_pid == 0 || n_rx_len == 0 || n_rx_unsup == 0 || n_rx_unexp == 0 ||
            n_lb_ok == 0 || n_lb_illegal == 0) begin
            fail_count++;
            $display(" FAIL: some outcome class was never exercised");
        end
        if (fail_count == 0) $display(" RESULT : *** TEST PASSED ***");
        else                 $display(" RESULT : *** TEST FAILED (%0d) ***", fail_count);
        $display("==============================================================");
        $finish;
    end

    initial begin
        #500_000_000;
        $display("FAIL: global timeout - simulation hung");
        $finish;
    end

	initial begin
		$shm_open("wave.shm");
		$shm_probe("ACTMF");
	end

endmodule : usb_handshake_top_tb
