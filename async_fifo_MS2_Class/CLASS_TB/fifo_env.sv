class fifo_env #(parameter DATA_WIDTH = 8);

    //mailbox
    mailbox gen_drv_mb;
    mailbox mon_scb_mb;
    mailbox inf_mon_scb;
    
    //class components
    fifo_generator generator;
    fifo_driver #(DATA_WIDTH) driver;
    fifo_monitor_out #(DATA_WIDTH) monitor_out;
    fifo_monitor_in  #(DATA_WIDTH) monitor_in;
    fifo_scoreboard scoreboard;

    function new(virtual interface fifo_if vif);
        gen_drv_mb = new;
        mon_scb_mb = new;
        inf_mon_scb = new;
        generator = new(gen_drv_mb);
        driver = new(gen_drv_mb, vif);
        monitor_out = new(mon_scb_mb, vif);
        monitor_in = new(inf_mon_scb, vif);
        scoreboard = new(mon_scb_mb, inf_mon_scb);
    endfunction

    task run();
        fork
            generator.run();
            driver.run();
            monitor_out.run();
            monitor_in.run();
            scoreboard.run();
        join_any
    endtask

endclass