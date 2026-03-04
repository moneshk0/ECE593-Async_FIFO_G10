class fifo_base_seq extends uvm_sequence #(fifo_packet);

    `uvm_object_utils(fifo_base_seq)

    function new(string name="fifo_base_seq");
        super.new(name);
    endfunction

    task pre_body();
        uvm_phase phase;
        `ifdef UVM_VERSION_1_2
            phase = get_starting_phase();
        `else
            phase = starting_phase;
        `endif
        if(phase != null) begin
            phase.raise_objection(this, get_type_name());
            `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
        end
    endtask

    task post_body();
        uvm_phase phase;
        `ifdef UVM_VERSION_1_2
            phase = get_starting_phase();
        `else
            phase = starting_phase;
        `endif
        if(phase != null) begin
            phase.drop_objection(this, get_type_name());
            `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
        end
    endtask

endclass

class fifo_5_packets extends fifo_base_seq;
    
    `uvm_object_utils(fifo_5_packets)

    function new(string name = "fifo_5_packets");
        super.new(name);
    endfunction

    int ok;

    virtual task body();
        `uvm_info(get_type_name(), "Executing fifo_5_packets sequence", UVM_LOW)
        repeat (100) begin
            req = fifo_packet#()::type_id::create("req");
            start_item(req);
            assert (req.randomize() with {length == 450;});
            finish_item(req);
        end
            
    endtask

endclass