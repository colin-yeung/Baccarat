module tb_statemachine();

`define deal_p_1    3'b000
`define deal_d_1    3'b001
`define deal_p_2    3'b010
`define deal_d_2    3'b011
`define decide      3'b100
`define deal_p_3    3'b101
`define deal_d_3    3'b110
`define compare     3'b111

reg slow_clock, resetb, load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2, load_dcard3;
reg [3:0] dscore, pscore, pcard3;
reg player_win_light, dealer_win_light;

reg [5:0] load_reg;
reg err;

assign load_reg = {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2, load_dcard3};

statemachine DUT(.slow_clock(slow_clock),
                 .resetb(resetb),
                 .dscore(dscore), 
                 .pscore(pscore), 
                 .pcard3(pcard3),
                 .load_pcard1(load_pcard1), 
                 .load_pcard2(load_pcard2), 
                 .load_pcard3(load_pcard3),
                 .load_dcard1(load_dcard1), 
                 .load_dcard2(load_dcard2), 
                 .load_dcard3(load_dcard3),
                 .player_win_light(player_win_light), 
                 .dealer_win_light(dealer_win_light));


    // This task checks the load signals, present_state, and win condition lights produced from the state machine
    task state_checker;
    
        input [5:0] expected_load_reg;
        input [3:0] expected_present_state;
        input expected_player_win_light, expected_dealer_win_light;

        if({tb_statemachine.DUT.load_pcard1,tb_statemachine.DUT.load_pcard2,tb_statemachine.DUT.load_pcard3,tb_statemachine.DUT.load_dcard1,tb_statemachine.DUT.load_dcard2,tb_statemachine.DUT.load_dcard3} != expected_load_reg) begin
            $display("Error: load_reg is: %b, expected: %b", {tb_statemachine.DUT.load_pcard1,tb_statemachine.DUT.load_pcard2,tb_statemachine.DUT.load_pcard3,tb_statemachine.DUT.load_dcard1,tb_statemachine.DUT.load_dcard2,tb_statemachine.DUT.load_dcard3} , expected_load_reg);
            err = 1'b1;
        end
        else if(tb_statemachine.DUT.present_state != expected_present_state) begin
            $display("Error: present state is: %b, expected: %b", tb_statemachine.DUT.present_state, expected_present_state);
            err = 1'b1;
        end
        else if(tb_statemachine.DUT.player_win_light != expected_player_win_light) begin
            $display("Error: player_win_light is: %b, expected: %b", tb_statemachine.DUT.player_win_light, expected_player_win_light);
            err = 1'b1;
        end
        else if(tb_statemachine.DUT.dealer_win_light != expected_dealer_win_light) begin
            $display("Error: dealer_win_light is: %b, expected: %b", tb_statemachine.DUT.dealer_win_light, expected_dealer_win_light);
            err = 1'b1;
        end
        else
            err = 1'b0;
    
    endtask

    // We cannot manually write specific cards to the score registers, but we will instead input the scores which are inputs to the state machine. 
    // The scores of the first two cards in each hand don't matter, only when transitioning to the third card the score determines the next state. 
    // However, we can control pcard3, which we will test certain cases to determine if the dealer gets a third card
    // Refer to the statemachine.sv file to see the rules of dealing the third card 
    initial begin

        /* ################################################################################################################################## */

        // Test 1: natural for the player (pscore = 9, dscore = 4)
        $display("\nTest 1"); 

        slow_clock = 1'b0; #5; resetb = 1'b0; #5; slow_clock = 1'b1; #5; resetb = 1'b1; slow_clock = 1'b0; // Assert the reset signal

        state_checker(6'b100000, `deal_p_1, 1'b0, 1'b0);

        #5;
        slow_clock = 1'b1; // transition to deal_d_1
        #5;
        state_checker(6'b000100, `deal_d_1, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_p_2
        #5;
        state_checker(6'b010000, `deal_p_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_d_2
        #5;
        state_checker(6'b000010, `deal_d_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to decide
        // Score changes here on the transition to decide
        pscore = 4'b1001; // 9
        dscore = 4'b0100; // 4
        #5;
        state_checker(6'b000000, `decide, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to compare
        #5;
        state_checker(6'b000000, `compare, 1'b1, 1'b0);

        /* ################################################################################################################################## */

        $display("\nTest 2"); 
        // Test 2: natural for the dealer (pscore = 2, dscore = 8)

        slow_clock = 1'b0; #5; resetb = 1'b0; #5; slow_clock = 1'b1; #5; resetb = 1'b1; slow_clock = 1'b0; // Assert the reset signal

        state_checker(6'b100000, `deal_p_1, 1'b0, 1'b0);

        #5;
        slow_clock = 1'b1; // transition to deal_d_1
        #5;
        state_checker(6'b000100, `deal_d_1, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_p_2
        #5;
        state_checker(6'b010000, `deal_p_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_d_2
        #5;
        state_checker(6'b000010, `deal_d_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to decide
        // Score changes here on the transition to decide
        pscore = 4'b0010; // 2
        dscore = 4'b1000; // 8
        #5;
        state_checker(6'b000000, `decide, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to compare
        #5;
        state_checker(6'b000000, `compare, 1'b0, 1'b1);

        /* ################################################################################################################################## */

        $display("\nTest 3"); 
        // Test 3: natural for both players (pscore = 9, dscore = 9)

        slow_clock = 1'b0; #5; resetb = 1'b0; #5; slow_clock = 1'b1; #5; resetb = 1'b1; slow_clock = 1'b0; // Assert the reset signal

        state_checker(6'b100000, `deal_p_1, 1'b0, 1'b0);

        #5;
        slow_clock = 1'b1; // transition to deal_d_1
        #5;
        state_checker(6'b000100, `deal_d_1, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_p_2
        #5;
        state_checker(6'b010000, `deal_p_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_d_2
        #5;
        state_checker(6'b000010, `deal_d_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to decide
        // Score changes here on the transition to decide
        pscore = 4'b1001; // 9
        dscore = 4'b1001; // 9
        #5;
        state_checker(6'b000000, `decide, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to compare
        #5;
        state_checker(6'b000000, `compare, 1'b1, 1'b1);

        /* ################################################################################################################################## */

        $display("\nTest 4"); 
        // Test 4: not natural for both players, but neither draws a card (pscore = 6, dscore = 7)

        slow_clock = 1'b0; #5; resetb = 1'b0; #5; slow_clock = 1'b1; #5; resetb = 1'b1; slow_clock = 1'b0; // Assert the reset signal

        state_checker(6'b100000, `deal_p_1, 1'b0, 1'b0);

        #5;
        slow_clock = 1'b1; // transition to deal_d_1
        #5;
        state_checker(6'b000100, `deal_d_1, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_p_2
        #5;
        state_checker(6'b010000, `deal_p_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_d_2
        #5;
        state_checker(6'b000010, `deal_d_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to decide
        // Score changes here on the transition to decide
        pscore = 4'b0110; // 6
        dscore = 4'b0111; // 7
        #5;
        state_checker(6'b000000, `decide, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to compare
        #5;
        state_checker(6'b000000, `compare, 1'b0, 1'b1);

        /* ################################################################################################################################## */
        
        $display("\nTest 5"); 
        // Test 5: player does not get a third card but banker does get a third card (pscore = 7, dscore = 3)

        slow_clock = 1'b0; #5; resetb = 1'b0; #5; slow_clock = 1'b1; #5; resetb = 1'b1; slow_clock = 1'b0; // Assert the reset signal

        state_checker(6'b100000, `deal_p_1, 1'b0, 1'b0);

        #5;
        slow_clock = 1'b1; // transition to deal_d_1
        #5;
        state_checker(6'b000100, `deal_d_1, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_p_2
        #5;
        state_checker(6'b010000, `deal_p_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_d_2
        #5;
        state_checker(6'b000010, `deal_d_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to decide
        // Score changes here on the transition to decide
        pscore = 4'b0111; // 7
        dscore = 4'b0011; // 3
        #5;
        state_checker(6'b000001, `decide, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_d_3
        // Score changes here on the transition for third card dealt
        dscore = 4'b0100; // 4 (dealer dealt an A)
        #5;
        state_checker(6'b000000, `deal_d_3, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to compare
        #5;
        state_checker(6'b000000, `compare, 1'b1, 1'b0);
        
        /* ################################################################################################################################## */

        $display("\nTest 6"); 
        // Test 6: rule A, player gets a third card but banker does not (pscore = 0, dscore = 7)

        slow_clock = 1'b0; #5; resetb = 1'b0; #5; slow_clock = 1'b1; #5; resetb = 1'b1; slow_clock = 1'b0; // Assert the reset signal

        state_checker(6'b100000, `deal_p_1, 1'b0, 1'b0);

        #5;
        slow_clock = 1'b1; // transition to deal_d_1
        #5;
        state_checker(6'b000100, `deal_d_1, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_p_2
        #5;
        state_checker(6'b010000, `deal_p_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_d_2
        #5;
        state_checker(6'b000010, `deal_d_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to decide
        // Score changes here on the transition to decide
        pscore = 4'b0000; // 0
        dscore = 4'b0111; // 7
        #5;
        state_checker(6'b001000, `decide, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_p_3
        // Score changes here on the transition for third card dealt
        pscore = 4'b0101; // 5 (dealer dealt a 5)
        #5;
        state_checker(6'b000000, `deal_p_3, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to compare
        #5;
        state_checker(6'b000000, `compare, 1'b0, 1'b1);

        /* ################################################################################################################################## */

        $display("\nTest 7"); 
        // Test 7: rule B, player gets a third card and banker gets a third card (pscore = 5, dscore = 6, pcard3 = 7)

        slow_clock = 1'b0; #5; resetb = 1'b0; #5; slow_clock = 1'b1; #5; resetb = 1'b1; slow_clock = 1'b0; // Assert the reset signal

        state_checker(6'b100000, `deal_p_1, 1'b0, 1'b0);

        #5;
        slow_clock = 1'b1; // transition to deal_d_1
        #5;
        state_checker(6'b000100, `deal_d_1, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_p_2
        #5;
        state_checker(6'b010000, `deal_p_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_d_2
        #5;
        state_checker(6'b000010, `deal_d_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to decide
        // Score changes here on the transition to decide
        pscore = 4'b0101; // 5
        dscore = 4'b0110; // 6
        #5;
        state_checker(6'b001000, `decide, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_p_3
        // Score and pcard3 changes here on the transition for third card dealt
        pcard3 = 4'b0111; // 7 (player dealt a 7)
        pscore = 4'b0010; // 2
        #5; 
        state_checker(6'b000001, `deal_p_3, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_d_3
        // Score changes here on the transition for third card dealt
        dscore = 4'b0011; // 3 (dealer dealt a 7)
        #5;
        state_checker(6'b000000, `deal_d_3, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to compare
        #5;
        state_checker(6'b000000, `compare, 1'b0, 1'b1);

        /* ################################################################################################################################## */

        $display("\nTest 8"); 
        // Test 8: rule B, player gets a third card but banker does not get a third card (pscore = 1, dscore = 6, pcard3 = 4)

        slow_clock = 1'b0; #5; resetb = 1'b0; #5; slow_clock = 1'b1; #5; resetb = 1'b1; slow_clock = 1'b0; // Assert the reset signal

        state_checker(6'b100000, `deal_p_1, 1'b0, 1'b0);

        #5;
        slow_clock = 1'b1; // transition to deal_d_1
        #5;
        state_checker(6'b000100, `deal_d_1, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_p_2
        #5;
        state_checker(6'b010000, `deal_p_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_d_2
        #5;
        state_checker(6'b000010, `deal_d_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to decide
        // Score changes here on the transition to decide
        pscore = 4'b0001; // 1
        dscore = 4'b0110; // 6
        #5;
        state_checker(6'b001000, `decide, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_p_3
        // Score and pcard3 changes here on the transition for third card dealt
        pcard3 = 4'b0100; // 4 (player dealt a 7)
        pscore = 4'b0101; // 5
        #5; 
        state_checker(6'b000000, `deal_p_3, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to compare
        #5;
        state_checker(6'b000000, `compare, 1'b0, 1'b1);
        
        /* ################################################################################################################################## */

        // Test 9: rule C, player gets a third card and banker gets a third card (pscore = 5, dscore = 5, pcard3 = 5)
        $display("\nTest 9"); 

        slow_clock = 1'b0; #5; resetb = 1'b0; #5; slow_clock = 1'b1; #5; resetb = 1'b1; slow_clock = 1'b0; // Assert the reset signal

        state_checker(6'b100000, `deal_p_1, 1'b0, 1'b0);

        #5;
        slow_clock = 1'b1; // transition to deal_d_1
        #5;
        state_checker(6'b000100, `deal_d_1, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_p_2
        #5;
        state_checker(6'b010000, `deal_p_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_d_2
        #5;
        state_checker(6'b000010, `deal_d_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to decide
        // Score changes here on the transition to decide
        pscore = 4'b0101; // 5
        dscore = 4'b0101; // 5
        #5;
        state_checker(6'b001000, `decide, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_p_3
        // Score and pcard3 changes here on the transition for third card dealt
        pcard3 = 4'b0101; // 5 (player dealt a 5)
        pscore = 4'b0000; // 0
        #5; 
        state_checker(6'b000001, `deal_p_3, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_d_3
        // Score changes here on the transition for third card dealt
        dscore = 4'b0011; // 3 (dealer dealt an 8)
        #5;
        state_checker(6'b000000, `deal_d_3, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to compare
        #5;
        state_checker(6'b000000, `compare, 1'b0, 1'b1);

        /* ################################################################################################################################## */

        $display("\nTest 10"); 
        // Test 10: rule C, player gets a third card but banker does not get a third card (pscore = 2, dscore = 5, pcard3 = 9)

        slow_clock = 1'b0; #5; resetb = 1'b0; #5; slow_clock = 1'b1; #5; resetb = 1'b1; slow_clock = 1'b0; // Assert the reset signal

        state_checker(6'b100000, `deal_p_1, 1'b0, 1'b0);

        #5;
        slow_clock = 1'b1; // transition to deal_d_1
        #5;
        state_checker(6'b000100, `deal_d_1, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_p_2
        #5;
        state_checker(6'b010000, `deal_p_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_d_2
        #5;
        state_checker(6'b000010, `deal_d_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to decide
        // Score changes here on the transition to decide
        pscore = 4'b0010; // 2
        dscore = 4'b0101; // 5
        #5;
        state_checker(6'b001000, `decide, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_p_3
        // Score and pcard3 changes here on the transition for third card dealt
        pcard3 = 4'b1001; // 4 (player dealt a 9)
        pscore = 4'b0001; // 1
        #5; 
        state_checker(6'b000000, `deal_p_3, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to compare
        #5;
        state_checker(6'b000000, `compare, 1'b0, 1'b1);

        /* ################################################################################################################################## */

        $display("\nTest 11"); 
        // Test 11, rule D, player gets a third card and banker gets a third card (pscore = 3, dscore = 4, pcard3 = 2)

        slow_clock = 1'b0; #5; resetb = 1'b0; #5; slow_clock = 1'b1; #5; resetb = 1'b1; slow_clock = 1'b0; // Assert the reset signal

        state_checker(6'b100000, `deal_p_1, 1'b0, 1'b0);

        #5;
        slow_clock = 1'b1; // transition to deal_d_1
        #5;
        state_checker(6'b000100, `deal_d_1, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_p_2
        #5;
        state_checker(6'b010000, `deal_p_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_d_2
        #5;
        state_checker(6'b000010, `deal_d_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to decide
        // Score changes here on the transition to decide
        pscore = 4'b0011; // 3
        dscore = 4'b0100; // 4
        #5;
        state_checker(6'b001000, `decide, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_p_3
        // Score and pcard3 changes here on the transition for third card dealt
        pcard3 = 4'b0010; // 2 (player dealt a 2)
        pscore = 4'b0101; // 5
        #5; 
        state_checker(6'b000001, `deal_p_3, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_d_3
        // Score changes here on the transition for third card dealt
        dscore = 4'b0011; // 3 (dealer dealt a 9)
        #5;
        state_checker(6'b000000, `deal_d_3, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to compare
        #5;
        state_checker(6'b000000, `compare, 1'b1, 1'b0);

        /* ################################################################################################################################## */

        $display("\nTest 12"); 
        // Test 12, rule D, player gets a third card but banker does not get a third card (pscore = 3, dscore = 4, pcard3 = J)

        slow_clock = 1'b0; #5; resetb = 1'b0; #5; slow_clock = 1'b1; #5; resetb = 1'b1; slow_clock = 1'b0; // Assert the reset signal

        state_checker(6'b100000, `deal_p_1, 1'b0, 1'b0);

        #5;
        slow_clock = 1'b1; // transition to deal_d_1
        #5;
        state_checker(6'b000100, `deal_d_1, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_p_2
        #5;
        state_checker(6'b010000, `deal_p_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_d_2
        #5;
        state_checker(6'b000010, `deal_d_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to decide
        // Score changes here on the transition to decide
        pscore = 4'b0011; // 3
        dscore = 4'b0100; // 4
        #5;
        state_checker(6'b001000, `decide, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_p_3
        // Score and pcard3 changes here on the transition for third card dealt
        pcard3 = 4'b1011; // J (player dealt a J)
        pscore = 4'b0011; // 3
        #5; 
        state_checker(6'b000000, `deal_p_3, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to compare
        #5;
        state_checker(6'b000000, `compare, 1'b0, 1'b1);

        /* ################################################################################################################################## */

        $display("\nTest 13"); 
        // Test 13, rule E, player gets a third card and banker gets a third card (pscore = 4, dscore = 3, pcard3 = A)

        slow_clock = 1'b0; #5; resetb = 1'b0; #5; slow_clock = 1'b1; #5; resetb = 1'b1; slow_clock = 1'b0; // Assert the reset signal

        state_checker(6'b100000, `deal_p_1, 1'b0, 1'b0);

        #5;
        slow_clock = 1'b1; // transition to deal_d_1
        #5;
        state_checker(6'b000100, `deal_d_1, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_p_2
        #5;
        state_checker(6'b010000, `deal_p_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_d_2
        #5;
        state_checker(6'b000010, `deal_d_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to decide
        // Score changes here on the transition to decide
        pscore = 4'b0100; // 4
        dscore = 4'b0011; // 3
        #5;
        state_checker(6'b001000, `decide, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_p_3
        // Score and pcard3 changes here on the transition for third card dealt
        pcard3 = 4'b0001; // A (player dealt a A)
        pscore = 4'b0101; // 5
        #5; 
        state_checker(6'b000001, `deal_p_3, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_d_3
        // Score changes here on the transition for third card dealt
        dscore = 4'b0011; // 3 (dealer dealt a 9)
        #5;
        state_checker(6'b000000, `deal_d_3, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to compare
        #5;
        state_checker(6'b000000, `compare, 1'b1, 1'b0);

        /* ################################################################################################################################## */
        $display("\nTest 14"); 
        // Test 14, rule E, player gets a third card but banker does not get a third card (pscore = 4, dscore = 3, pcard3 = 8)

        slow_clock = 1'b0; #5; resetb = 1'b0; #5; slow_clock = 1'b1; #5; resetb = 1'b1; slow_clock = 1'b0; // Assert the reset signal

        state_checker(6'b100000, `deal_p_1, 1'b0, 1'b0);

        #5;
        slow_clock = 1'b1; // transition to deal_d_1
        #5;
        state_checker(6'b000100, `deal_d_1, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_p_2
        #5;
        state_checker(6'b010000, `deal_p_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_d_2
        #5;
        state_checker(6'b000010, `deal_d_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to decide
        // Score changes here on the transition to decide
        pscore = 4'b0100; // 4
        dscore = 4'b0011; // 3
        #5;
        state_checker(6'b001000, `decide, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_p_3
        // Score and pcard3 changes here on the transition for third card dealt
        pcard3 = 4'b1000; // 8 (player dealt an 8)
        pscore = 4'b0010; // 2
        #5; 
        state_checker(6'b000000, `deal_p_3, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to compare
        #5;
        state_checker(6'b000000, `compare, 1'b0, 1'b1);

        /* ################################################################################################################################## */
        
        $display("\nTest 15"); 
        // Test 15: rule F, player gets a third card and banker gets a third card (pscore = 5, dscore = 0. pcard3 = Q)

        slow_clock = 1'b0; #5; resetb = 1'b0; #5; slow_clock = 1'b1; #5; resetb = 1'b1; slow_clock = 1'b0; // Assert the reset signal

        state_checker(6'b100000, `deal_p_1, 1'b0, 1'b0);

        #5;
        slow_clock = 1'b1; // transition to deal_d_1
        #5;
        state_checker(6'b000100, `deal_d_1, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_p_2
        #5;
        state_checker(6'b010000, `deal_p_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_d_2
        #5;
        state_checker(6'b000010, `deal_d_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to decide
        // Score changes here on the transition to decide
        pscore = 4'b0101; // 5
        dscore = 4'b0000; // 0
        #5;
        state_checker(6'b001000, `decide, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_p_3
        // Score and pcard3 changes here on the transition for third card dealt
        pcard3 = 4'b1100; // Q (player dealt a Q)
        pscore = 4'b0101; // 5
        #5; 
        state_checker(6'b000001, `deal_p_3, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_d_3
        // Score changes here on the transition for third card dealt
        dscore = 4'b0011; // 3 (dealer dealt a 3)
        #5;
        state_checker(6'b000000, `deal_d_3, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to compare
        #5;
        state_checker(6'b000000, `compare, 1'b1, 1'b0);

        /* ################################################################################################################################## */
        
        $display("\nTest 16"); 
        // Test 16: rule F, player gets a third card and banker gets a third card (pscore = 5, dscore = 1, pcard3 = K)

        slow_clock = 1'b0; #5; resetb = 1'b0; #5; slow_clock = 1'b1; #5; resetb = 1'b1; slow_clock = 1'b0; // Assert the reset signal

        state_checker(6'b100000, `deal_p_1, 1'b0, 1'b0);

        #5;
        slow_clock = 1'b1; // transition to deal_d_1
        #5;
        state_checker(6'b000100, `deal_d_1, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_p_2
        #5;
        state_checker(6'b010000, `deal_p_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_d_2
        #5;
        state_checker(6'b000010, `deal_d_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to decide
        // Score changes here on the transition to decide
        pscore = 4'b0101; // 5
        dscore = 4'b0001; // 1
        #5;
        state_checker(6'b001000, `decide, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_p_3
        // Score and pcard3 changes here on the transition for third card dealt
        pcard3 = 4'b1101; // K (player dealt a K)
        pscore = 4'b0101; // 5
        #5; 
        state_checker(6'b000001, `deal_p_3, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_d_3
        // Score changes here on the transition for third card dealt
        dscore = 4'b0011; // 3 (dealer dealt a 2)
        #5;
        state_checker(6'b000000, `deal_d_3, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to compare
        #5;
        state_checker(6'b000000, `compare, 1'b1, 1'b0);

        /* ################################################################################################################################## */

        $display("\nTest 17"); 
        // Test 17: rule F, player gets a third card and banker gets a third card (pscore = 5, dscore = 2, pcard3 = J)

        slow_clock = 1'b0; #5; resetb = 1'b0; #5; slow_clock = 1'b1; #5; resetb = 1'b1; slow_clock = 1'b0; // Assert the reset signal

        state_checker(6'b100000, `deal_p_1, 1'b0, 1'b0);

        #5;
        slow_clock = 1'b1; // transition to deal_d_1
        #5;
        state_checker(6'b000100, `deal_d_1, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_p_2
        #5;
        state_checker(6'b010000, `deal_p_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_d_2
        #5;
        state_checker(6'b000010, `deal_d_2, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to decide
        // Score changes here on the transition to decide
        pscore = 4'b0101; // 5
        dscore = 4'b0010; // 2
        #5;
        state_checker(6'b001000, `decide, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_p_3
        // Score and pcard3 changes here on the transition for third card dealt
        pcard3 = 4'b1011; // J (player dealt a J)
        pscore = 4'b0101; // 5
        #5; 
        state_checker(6'b000001, `deal_p_3, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to deal_d_3
        // Score changes here on the transition for third card dealt
        dscore = 4'b0011; // 3 (dealer dealt an A)
        #5;
        state_checker(6'b000000, `deal_d_3, 1'b0, 1'b0);
        slow_clock = 1'b0;

        #5;
        slow_clock = 1'b1; // transition to compare
        #5;
        state_checker(6'b000000, `compare, 1'b1, 1'b0);

    end

endmodule


