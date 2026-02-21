class fifo_generator;

    mailbox gen_drv_mb;

    integer num_of_packets = 20;

    function new (mailbox gen_drv_mb);
        this.gen_drv_mb = gen_drv_mb;
    endfunction

    task run();
        for(int i=0;i<num_of_packets;i++) begin
            fifo_packet packet = new;
            assert(packet.randomize());
            gen_drv_mb.put(packet);
            $display("[GENERATOR] -----Packet ID: %0d-----\n%p \n --------------",packet.id, packet);
        end
    endtask

endclass