class fifo_driver #(parameter DATA_WIDTH = 8);

    fifo_packet packet;
    
    mailbox gen_drv_mb;

    virtual interface fifo_if vif;

    function new(mailbox gen_drv_mb, virtual interface fifo_if vif);
        this.gen_drv_mb = gen_drv_mb;
        this.vif = vif;
    endfunction

    int num_sent;

    task run();
        fork
            get_and_drive();
            reset_signals();
        join
    endtask

    task get_and_drive();
        @(negedge vif.wrst_n);
        @(posedge vif.wrst_n);
        $display("[DRIVER] Reset Dropped");
        forever begin
            gen_drv_mb.get(packet);
            $display("[DRIVER] Driving Packet ID: %0d", packet.id);
            send_to_dut(packet.length, packet.parity, packet.write_idle_cycles, packet.id, packet.payload);
            num_sent++;
        end
    endtask

    task reset_signals();
        forever fifo_reset();
    endtask

    task fifo_reset();
        fork
            begin
                @(negedge vif.wrst_n);
                vif.data_in <= 'hz;
                vif.w_en <= 1'b0;
                disable send_to_dut;
            end
            begin
                @(negedge vif.rrst_n);
                vif.r_en <= 1'b0;
            end
        join_any
    endtask

    task send_to_dut(
        input bit [DATA_WIDTH-1:0] length, 
        bit [DATA_WIDTH-1:0] parity, 
        int write_idle_cycles,
        bit [DATA_WIDTH-1:0] id,
        logic [DATA_WIDTH-1:0] payload[]
    );
        // $display("debug 1 %0d", length);
        repeat(write_idle_cycles) @(posedge vif.wclk);
        // $display("debug 2");
        vif.w_en <= 1'b1;

        @(negedge vif.wclk iff !vif.full);
        vif.data_in <= id;

        @(negedge vif.wclk iff !vif.full);
        vif.data_in <= length;

        for(int i=0; i<length; i++) begin
            // $display("%0t full is %0d", $time, vif.full );
            @(negedge vif.wclk iff !vif.full);
            // $display("sending payload %0d",i);
            vif.data_in <= payload[i];
            // $display("%0t full is %0d",$time, vif.full );
        end

        @(negedge vif.wclk iff !vif.full);
        vif.data_in <= parity;
        @(negedge vif.wclk iff !vif.full);

        vif.w_en <= 1'b0;

        $display("done driving");
    endtask

endclass