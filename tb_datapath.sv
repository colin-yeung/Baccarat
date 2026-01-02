module tb_datapath();

reg slow_clock, fast_clock, resetb;
reg load_pcard1, load_pcard2, load_pcard3;
reg load_dcard1, load_dcard2, load_dcard3;
reg [3:0] pcard3_out, pscore_out, dscore_out;
reg [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
reg err;

    datapath DUT (
        .slow_clock(slow_clock),
        .fast_clock(fast_clock),
        .resetb(resetb),
        .load_pcard1(load_pcard1),
        .load_pcard2(load_pcard2),
        .load_pcard3(load_pcard3),
        .load_dcard1(load_dcard1),
        .load_dcard2(load_dcard2),
        .load_dcard3(load_dcard3),
        .pcard3_out(pcard3_out),
        .pscore_out(pscore_out),
        .dscore_out(dscore_out),
        .HEX5(HEX5),
        .HEX4(HEX4),
        .HEX3(HEX3),
        .HEX2(HEX2),
        .HEX1(HEX1),
        .HEX0(HEX0)
    );

    // This task compares the expect score of the player and dealer as well as the HEX outputs
    task dp_checker;
    
        input [3:0] expected_pscore;
        input [3:0] expected_dscore;
        input [6:0] expected_HEX0;
        input [6:0] expected_HEX1;
        input [6:0] expected_HEX2;
        input [6:0] expected_HEX3;
        input [6:0] expected_HEX4;
        input [6:0] expected_HEX5; 

        if(tb_datapath.DUT.pscore_out != expected_pscore) begin
            $display("Error: pscore is: %b, expected: %b", tb_datapath.DUT.pscore_out, expected_pscore);
            err = 1'b1;
        end
        else if(tb_datapath.DUT.dscore_out != expected_dscore) begin
            $display("Error: dscore is: %b, expected: %b", tb_datapath.DUT.dscore_out, expected_dscore);
            err = 1'b1;
        end
        else if(tb_datapath.DUT.HEX0 != expected_HEX0) begin
            $display("Error: HEX0 is: %b, expected: %b", tb_datapath.DUT.HEX0, expected_HEX0);
            err = 1'b1;
        end
        else if(tb_datapath.DUT.HEX1 != expected_HEX1) begin
            $display("Error: HEX1 is: %b, expected: %b", tb_datapath.DUT.HEX1, expected_HEX1);
            err = 1'b1;
        end
        else if(tb_datapath.DUT.HEX2 != expected_HEX2) begin
            $display("Error: HEX2 is: %b, expected: %b", tb_datapath.DUT.HEX2, expected_HEX2);
            err = 1'b1;
        end
        else if(tb_datapath.DUT.HEX3 != expected_HEX3) begin
            $display("Error: HEX3 is: %b, expected: %b", tb_datapath.DUT.HEX3, expected_HEX3);
            err = 1'b1;
        end
        else if(tb_datapath.DUT.HEX4 != expected_HEX4) begin
            $display("Error: HEX4 is: %b, expected: %b", tb_datapath.DUT.HEX4, expected_HEX4);
            err = 1'b1;
        end
        else if(tb_datapath.DUT.HEX5 != expected_HEX5) begin
            $display("Error: HEX5 is: %b, expected: %b", tb_datapath.DUT.HEX5, expected_HEX5);
            err = 1'b1;
        end
        else
            err = 1'b0;

    endtask  

    // This initial block generates the slow clock with a period of 10 time units
    initial begin
        slow_clock = 1'b0;
        forever begin
            #5;
            slow_clock = ~slow_clock;
        end
    end

    // This initial block manually inputs a test hand and determines if the correct numbers are shown on HEX 
    initial begin 

        // Temporary to initialize all loads to 0
        load_pcard1 = 1'b0;
        load_pcard2 = 1'b0;
        load_pcard3 = 1'b0;
        load_dcard1 = 1'b0;
        load_dcard2 = 1'b0;
        load_dcard3 = 1'b0;
        
        $display("Datapath Testbench");
        #5; 
        resetb = 1'b0; 
        #10; 
        resetb = 1'b1;

        // Task 1: Player dealt 2, 8, 3 (3), dealer dealt J, Q, 4 (4)
        load_pcard1 = 1'b1; 
        force tb_datapath.DUT.DC.dealer_card = 4'b0010;
    
        #10;
        load_pcard1 = 1'b0; 
        $display("test 1");
        dp_checker(4'b0010, 4'b0000, 7'b0100100, 7'b1111111, 7'b1111111, 7'b1111111, 7'b1111111, 7'b1111111);
        #5; 

        load_dcard1 = 1'b1; 
        force tb_datapath.DUT.DC.dealer_card = 4'b1011;
        #10;
        load_dcard1 = 1'b0; 
        $display("test 2");
        dp_checker(4'b0010, 4'b0000, 7'b0100100, 7'b1111111, 7'b1111111, 7'b1100001, 7'b1111111, 7'b1111111);
        #5; 

        load_pcard2 = 1'b1; 
        force tb_datapath.DUT.DC.dealer_card = 4'b1000;
        #10;
        load_pcard2 = 1'b0; 
        $display("test 3");
        dp_checker(4'b0000, 4'b0000, 7'b0100100, 7'b0000000, 7'b1111111, 7'b1100001, 7'b1111111, 7'b1111111);
        #5; 

        load_dcard2 = 1'b1; 
        force tb_datapath.DUT.DC.dealer_card = 4'b1100;
        #10;
        load_dcard2 = 1'b0; 
        $display("test 4");
        dp_checker(4'b0000, 4'b0000, 7'b0100100, 7'b0000000, 7'b1111111, 7'b1100001, 7'b0011000, 7'b1111111);
        #5; 

        load_pcard3 = 1'b1; 
        force tb_datapath.DUT.DC.dealer_card = 4'b0011;
        #10;
        load_pcard3 = 1'b0;
        $display("test 5");
        dp_checker(4'b0011, 4'b0000, 7'b0100100, 7'b0000000, 7'b0110000, 7'b1100001, 7'b0011000, 7'b1111111);
        #5; 

        load_dcard3 = 1'b1; 
        force tb_datapath.DUT.DC.dealer_card = 4'b0100;
        #10;
        load_dcard3 = 1'b0;
        $display("test 6");
        dp_checker(4'b0011, 4'b0100, 7'b0100100, 7'b0000000, 7'b0110000, 7'b1100001, 7'b0011000, 7'b0011001);
        #5; 

        resetb = 1'b0; 
        #10; 
        resetb = 1'b1;
        $display("test 7");
        dp_checker(4'b0000, 4'b0000, 7'b1111111, 7'b1111111, 7'b1111111, 7'b1111111, 7'b1111111, 7'b1111111);

    end

endmodule
