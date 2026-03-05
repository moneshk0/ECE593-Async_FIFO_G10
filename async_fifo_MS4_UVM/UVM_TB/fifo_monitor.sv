class fifo_monitor #(parameter DATA_WIDTH = 16) extends uvm_monitor;

    `uvm_component_utils(fifo_monitor)

    uvm_analysis_port #(fifo_packet) fifo_out;
    uvm_analysis_port #(fifo_packet) fifo_cov_out;

    virtual interface fifo_if vif;

    // mailbox mon_scb_mb;

    fifo_packet packet;

    int num_pkt_col = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        fifo_out = new("fifo_out", this);
        fifo_cov_out = new("fifo_cov_out", this);
    endfunction

    virtual function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), {"start of simulation phase", get_full_name()}, UVM_HIGH)
    endfunction

    task run_phase(uvm_phase phase);
        // @(negedge vif.rrst_n);
        @(posedge vif.rrst_n);

        `uvm_info(get_type_name(), "Detected Reset Done", UVM_MEDIUM);
        
        forever begin
            packet = fifo_packet#()::type_id::create("packet", this);

            fork
                collect_packet(packet.length, packet.parity, packet.id, packet.payload);
                @(posedge vif.monstart) void'(begin_tr(packet, "Monitor_YAPP_Packet"));
            join
            end_tr(packet);
            `uvm_info(get_type_name(), $sformatf("Packet Collected :\n%s",packet.sprint()), UVM_LOW);
            fifo_out.write(packet);
            num_pkt_col++;
        end
    endtask

    virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("Report: FIFO Monitor Collected %0d Packets", num_pkt_col), UVM_LOW)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        if(!uvm_config_db#(virtual fifo_if)::get(this, get_full_name(), "vif", vif))
            `uvm_error("NOVIF", "vif not set")
    endfunction

    task collect_packet(
        output bit [DATA_WIDTH-1:0] length, 
        bit [DATA_WIDTH-1:0] parity, 
        bit [DATA_WIDTH-1:0] id,
        logic [DATA_WIDTH-1:0] payload[]
    );
        fifo_packet packet_for_func_cov = fifo_packet#()::type_id::create("packet_for_func_cov", this);
        @(negedge vif.rclk);
        vif.r_en <= 1'b1;
        vif.monstart = 1'b1;

        @(posedge vif.rclk iff(!vif.empty));
            #1ns;
            id = vif.data_out;

        @(posedge vif.rclk iff(!vif.empty));
            #1ns;
            length = vif.data_out;
            $display("length %0d", length);

        payload = new[length];

        foreach(payload[i]) begin
            @(posedge vif.rclk iff(!vif.empty));
                #1ns;
                payload[i] = vif.data_out;
                packet_for_func_cov.w_en = vif.w_en;
                packet_for_func_cov.r_en = vif.r_en;
                packet_for_func_cov.empty = vif.empty;
                packet_for_func_cov.full = vif.full;
                fifo_cov_out.write(packet_for_func_cov);
                vif.r_en <= 0;
            repeat(3) @(posedge vif.rclk iff(!vif.empty));
                vif.r_en <= 1;
        end

        @(posedge vif.rclk iff(!vif.empty));
            #1ns;
            parity = vif.data_out;
        @(posedge vif.rclk);
        
        vif.r_en <= '0;
        
        vif.monstart = 1'b0;
    endtask

endclass