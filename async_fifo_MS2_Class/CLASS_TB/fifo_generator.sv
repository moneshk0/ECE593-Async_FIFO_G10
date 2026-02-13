class fifo_generator;

    mailbox gen_drv_mg;
    fifo_packet packet;

    integer num_of_packets = 20;

    task run();
        packet = new;
        for(int i=0;i<num_of_packets;i++) begin
            assert(packet.randomize());
            gen_drv_mg.put(packet);
        end
    endtask

endclass