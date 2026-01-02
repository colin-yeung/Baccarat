`define A       7'b0001000 // A
`define two     7'b0100100 // 2
`define three   7'b0110000 // 3
`define four    7'b0011001 // 4
`define five    7'b0010010 // 5 
`define six     7'b0000010 // 6
`define seven   7'b1111000 // 7
`define eight   7'b0000000 // 8
`define nine    7'b0010000 // 9
`define ten     7'b1000000 // 10
`define J       7'b1100001 // J
`define Q       7'b0011000 // q
`define K       7'b0001001 // K 
`define Blank   7'b1111111 // blank




module tb_task5();

    reg CLOCK_50;
    reg [3:0] KEY;
    reg [9:0] LEDR;
    reg [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    reg err;
    reg slow_clock;
    reg reset;

    assign KEY[0] = slow_clock;
    assign KEY[3] = reset;

    task5 DUT(.CLOCK_50(CLOCK_50),
              .KEY(KEY),
              .LEDR(LEDR),
              .HEX5(HEX5),
              .HEX4(HEX4),
              .HEX3(HEX3),
              .HEX2(HEX2),
              .HEX1(HEX1),
              .HEX0(HEX0));


    task baccarat_check;

        input [6:0] expected_HEX0, expected_HEX1, expected_HEX2, expected_HEX3, expected_HEX4, expected_HEX5;
        input [9:0] expected_LEDR;


        if (tb_task5.DUT.HEX0 != expected_HEX0) begin
            $display("Error: HEX0 is: %b, expected: %b", tb_task5.DUT.HEX0, expected_HEX0);
            err = 1'b1;
        end 
        else if(tb_task5.DUT.HEX1 != expected_HEX1) begin
            $display("Error: HEX1 is: %b, expected: %b", tb_task5.DUT.HEX1, expected_HEX1);
            err = 1'b1;
        end 
        else if(tb_task5.DUT.HEX2 != expected_HEX2) begin
            $display("Error: HEX2 is: %b, expected: %b", tb_task5.DUT.HEX2, expected_HEX2);
            err = 1'b1;
        end 
        else if(tb_task5.DUT.HEX3 != expected_HEX3) begin
            $display("Error: HEX3 is: %b, expected: %b", tb_task5.DUT.HEX3, expected_HEX3);
            err = 1'b1;
        end 
        else if(tb_task5.DUT.HEX4 != expected_HEX4) begin
            $display("Error: HEX4 is: %b, expected: %b", tb_task5.DUT.HEX4, expected_HEX4);
            err = 1'b1;
        end 
        else if(tb_task5.DUT.HEX5 != expected_HEX5) begin
            $display("Error: HEX5 is: %b, expected: %b", tb_task5.DUT.HEX5, expected_HEX5);
            err = 1'b1;
        end 
        else if (tb_task5.DUT.LEDR != expected_LEDR) begin
            $display("Error: LEDR is: %b, expected: %b", tb_task5.DUT.LEDR, expected_LEDR);
            err = 1'b1;
        end
        else
            err = 1'b0;

    endtask



// In this test bench we will use "force" to assign values to dealer_card instead of using clock_50 so that we can test specific cases and state transitions for the card game
    

    initial begin

    reset = 1'b0;
    slow_clock = 1'b0;
    CLOCK_50 = 1'b0;

     //reset dealcard and whole system
    #5;
    slow_clock = 1'b1;
    CLOCK_50 = 1'b1;
    #5;
    reset = 1'b1;




    //################################################################################################################################################################################
    $display("test 1:");
    // test 1: natural case, player score = 9, dealer score = 5
    //pc1 = 9, pc2 = Q, dc1 = 3, dc2 = 2

    //reset
    #5;
    slow_clock = 1'b1;
    #5;
    reset = 1'b1;


    //curent state should be deal_p_1 after reset, no cards assigned yet, scores = 0

    baccarat_check(`Blank, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000000); //in state deal_p_1




    // get pcard 1
    force tb_task5.DUT.dp.DC.dealer_card = 9;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to deal_d_1
    #5;

    baccarat_check(`nine, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000001001); // pcard 1 shows, currently in state deal_d_1



    // get dcard1
    force tb_task5.DUT.dp.DC.dealer_card = 3;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to deal_p_2
    #5;

    baccarat_check(`nine, `Blank, `Blank, `three, `Blank, `Blank, 10'b0000111001); // dcard 1 shows, currently in state deal_p_2



    //get pcard2
    force tb_task5.DUT.dp.DC.dealer_card = 12; // Q

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to decide
    #5;

    baccarat_check(`nine, `Q, `Blank, `three, `Blank, `Blank, 10'b0000111001); // dcard 1 shows, currently in state deal_p_2



    // get dcard2
    force tb_task5.DUT.dp.DC.dealer_card = 2;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to compare
    #5;

    baccarat_check(`nine, `Q, `Blank, `three, `two,` Blank, 10'b0001011001); //in decide state



    // game over
    force tb_task5.DUT.dp.DC.dealer_card = 2;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; 
    #5;

    baccarat_check(`nine, `Q, `Blank, `three, `two, `Blank, 10'b0101011001); //in compare state, player light on


    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; 
    #5;

    baccarat_check(`nine, `Q, `Blank, `three, `two,`Blank, 10'b0101011001); //shoud stay here intil reset




    //################################################################################################################################################################################
    $display("test 2:");
    // test 1: natural case, player score = 6, dealer score = 8
    //pc1 = 1, pc2 = 5, dc1 = 9, dc2 = 9

    //reset
    slow_clock = 1'b0;
    reset = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;
    reset = 1'b1;


    //curent state should be deal_p_1 after reset, no cards assigned yet, scores = 0

    baccarat_check(`Blank, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000000); //in state deal_p_1




    // get pcard 1
    force tb_task5.DUT.dp.DC.dealer_card = 1;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to deal_d_1
    #5;

    baccarat_check(`A, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000001); // pcard 1 shows, currently in state deal_d_1



    // get dcard1
    force tb_task5.DUT.dp.DC.dealer_card = 9;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to deal_p_2
    #5;

    baccarat_check(`A, `Blank, `Blank, `nine, `Blank, `Blank, 10'b0010010001); // dcard 1 shows, currently in state deal_p_2



    //get pcard2
    force tb_task5.DUT.dp.DC.dealer_card = 5; // Q

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to decide
    #5;

    baccarat_check(`A, `five, `Blank, `nine, `Blank, `Blank, 10'b0010010110); // dcard 1 shows, currently in state deal_p_2



    // get dcard2
    force tb_task5.DUT.dp.DC.dealer_card = 9;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to compare
    #5;

    baccarat_check(`A, `five, `Blank, `nine, `nine,`Blank, 10'b0010000110); //in decide state



    // game over

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; 
    #5;

    baccarat_check(`A, `five, `Blank, `nine, `nine, `Blank, 10'b1010000110); //in compare state, player light on



    //################################################################################################################################################################################
    $display("test 3:");
    // test 1: natural case, player score = 9, dealer score = 9
    //pc1 = 4, pc2 = 5, dc1 = 9, dc2 = K

    //reset
    slow_clock = 1'b0;
    reset = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;
    reset = 1'b1;


    //curent state should be deal_p_1 after reset, no cards assigned yet, scores = 0

    baccarat_check(`Blank, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000000); //in state deal_p_1




    // get pcard 1
    force tb_task5.DUT.dp.DC.dealer_card = 4;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to deal_d_1
    #5;

    baccarat_check(`four, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000100); // pcard 1 shows, currently in state deal_d_1



    // get dcard1
    force tb_task5.DUT.dp.DC.dealer_card = 9;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to deal_p_2
    #5;

    baccarat_check(`four, `Blank, `Blank, `nine, `Blank, `Blank, 10'b0010010100); // dcard 1 shows, currently in state deal_p_2



    //get pcard2
    force tb_task5.DUT.dp.DC.dealer_card = 5;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to decide
    #5;

    baccarat_check(`four, `five, `Blank, `nine, `Blank, `Blank, 10'b0010011001); // dcard 1 shows, currently in state deal_p_2



    // get dcard2
    force tb_task5.DUT.dp.DC.dealer_card = 13;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to compare
    #5;

    baccarat_check(`four, `five, `Blank, `nine, `K,`Blank, 10'b0010011001); //in decide state



    // game over

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; 
    #5;

    baccarat_check(`four, `five, `Blank, `nine, `K,`Blank, 10'b1110011001); //in compare state, player light on



    //################################################################################################################################################################################
    $display("test 4:");
    // test 4: no one gets a new card
    //pc1 = 3, pc2 = 3, dc1 = 6, dc2 = 1

    //reset
    slow_clock = 1'b0;
    reset = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;
    reset = 1'b1;


    //curent state should be deal_p_1 after reset, no cards assigned yet, scores = 0

    baccarat_check(`Blank, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000000); //in state deal_p_1




    // get pcard 1
    force tb_task5.DUT.dp.DC.dealer_card = 3;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;

    baccarat_check(`three, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000011); // pcard 1 shows



    // get dcard1
    force tb_task5.DUT.dp.DC.dealer_card = 6;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; 
    #5;

    baccarat_check(`three, `Blank, `Blank, `six, `Blank, `Blank, 10'b0001100011); // dcard 1 shows, currently in state deal_p_2



    //get pcard2
    force tb_task5.DUT.dp.DC.dealer_card = 3;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;

    baccarat_check(`three, `three, `Blank, `six, `Blank, `Blank, 10'b0001100110); // dcard 1 shows, currently in state deal_p_2



    // get dcard2
    force tb_task5.DUT.dp.DC.dealer_card = 1;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to compare
    #5;

    baccarat_check(`three, `three, `Blank, `six, `A,`Blank, 10'b0001110110); //in decide state



    // game over

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; 
    #5;

    baccarat_check(`three, `three, `Blank, `six, `A,`Blank, 10'b1001110110); //in compare state, player light on



    //################################################################################################################################################################################
    $display("test 5:");
    // test 5: pscore = 7, dscore = 3 
    //pc1 = 7, pc2 = J, dc1 = 10, dc2 = 3

    //reset
    slow_clock = 1'b0;
    reset = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;
    reset = 1'b1;


    //curent state should be deal_p_1 after reset, no cards assigned yet, scores = 0

    baccarat_check(`Blank, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000000); //in state deal_p_1




    // get pcard 1
    force tb_task5.DUT.dp.DC.dealer_card = 7;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;

    baccarat_check(`seven, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000111); // pcard 1 shows



    // get dcard1
    force tb_task5.DUT.dp.DC.dealer_card = 10;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; 
    #5;

    baccarat_check(`seven, `Blank, `Blank, `ten, `Blank, `Blank, 10'b0000000111); // dcard 1 shows, currently in state deal_p_2



    //get pcard2
    force tb_task5.DUT.dp.DC.dealer_card = 11;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;

    baccarat_check(`seven, `J, `Blank, `ten, `Blank, `Blank, 10'b0000000111); // dcard 1 shows, currently in state deal_p_2



    // get dcard2
    force tb_task5.DUT.dp.DC.dealer_card = 3;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to compare
    #5;

    baccarat_check(`seven, `J, `Blank, `ten, `three, `Blank, 10'b0000110111); //in decide state



    // get dcard3
    force tb_task5.DUT.dp.DC.dealer_card = 5;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to compare
    #5;

    baccarat_check(`seven, `J, `Blank, `ten, `three, `five, 10'b0010000111); //in decide state



    // game over

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; 
    #5;

    baccarat_check(`seven, `J, `Blank, `ten, `three,` five, 10'b1010000111); //in compare state, dealer light on



    //################################################################################################################################################################################
    // All tests where banker and dealer both get a third card

    //################################################################################################################################################################################
    $display("test 6:");
    // test 6: pscore = 0, dscore = 6, pcard3 = 7
    //pc1 = 5, pc2 = 5, dc1 = 4, dc2 = 2

    //reset
    slow_clock = 1'b0;
    reset = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;
    reset = 1'b1;


    //curent state should be deal_p_1 after reset, no cards assigned yet, scores = 0

    baccarat_check(`Blank, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000000); //in state deal_p_1




    // get pcard 1
    force tb_task5.DUT.dp.DC.dealer_card = 5;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;

    baccarat_check(`five, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000101); // pcard 1 shows



    // get dcard1
    force tb_task5.DUT.dp.DC.dealer_card = 4;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; 
    #5;

    baccarat_check(`five, `Blank, `Blank, `four, `Blank, `Blank, 10'b0001000101); // dcard 1 shows, currently in state deal_p_2



    //get pcard2
    force tb_task5.DUT.dp.DC.dealer_card = 5;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;

    baccarat_check(`five, `five, `Blank, `four, `Blank, `Blank, 10'b0001000000); // pcard 2 shows



    // get dcard2
    force tb_task5.DUT.dp.DC.dealer_card = 2;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to compare
    #5;

    baccarat_check(`five, `five, `Blank, `four, `two, `Blank, 10'b0001100000); //dcard2 shows



    // get pcard3
    force tb_task5.DUT.dp.DC.dealer_card = 7;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to compare
    #5;

    baccarat_check(`five, `five, `seven, `four, `two, `Blank, 10'b0001100111); //pcard3



    // get dcard3
    force tb_task5.DUT.dp.DC.dealer_card = 1;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to compare
    #5;

    baccarat_check(`five, `five, `seven, `four, `two, `A, 10'b0001110111);  //dcard3



    // game over

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; 
    #5;

    baccarat_check(`five, `five, `seven, `four, `two, `A, 10'b1101110111);  //in compare state, dealer light on


    //################################################################################################################################################################################

    $display("test 7:");
    // test 7: pscore = 2, dscore = 3, pcard3 = 9
    // Expected: Player gets 3rd card, Dealer gets 3rd card, Dealer wins (score 1 vs 8)
    // pc1 = 1 (A), pc2 = 1 (A), dc1 = 1 (A), dc2 = 2

    //reset
    slow_clock = 1'b0;
    reset = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;
    reset = 1'b1;

    
    baccarat_check(`Blank, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000000); //in state deal_p_1

    // get pcard 1
    force tb_task5.DUT.dp.DC.dealer_card = 1;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;

    baccarat_check(`A, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000001); // pcard 1 shows (pscore=1)

    // get dcard1
    force tb_task5.DUT.dp.DC.dealer_card = 1;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;

    baccarat_check(`A, `Blank, `Blank, `A, `Blank, `Blank, 10'b0000010001); // dcard 1 shows, currently in state deal_p_2 (pscore=1, dscore=1)

    //get pcard2
    force tb_task5.DUT.dp.DC.dealer_card = 1;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;

    baccarat_check(`A, `A, `Blank, `A, `Blank, `Blank, 10'b0000010010); // pcard 2 shows (pscore=2, dscore=1)

    // get dcard2
    force tb_task5.DUT.dp.DC.dealer_card = 2;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; 
    #5;

    baccarat_check(`A, `A, `Blank, `A, `two, `Blank, 10'b0000110010); //dcard2 shows (pscore=2, dscore=3)

    // get pcard3
    force tb_task5.DUT.dp.DC.dealer_card = 9;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; 
    #5;

    baccarat_check(`A, `A, `nine, `A, `two, `Blank, 10'b0000110001); //pcard3 (pscore=1, dscore=3)

    // get dcard3
    force tb_task5.DUT.dp.DC.dealer_card = 5;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to compare
    #5;

    baccarat_check(`A, `A, `nine, `A, `two, `five, 10'b0010000001); //dcard3 (pscore=1, dscore=8)

    // game over
    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; 
    #5;

    baccarat_check(`A, `A, `nine, `A, `two, `five, 10'b1010000001); //in compare state, dealer light on

    //################################################################################################################################################################################
    $display("test 8:");
    // test 8: pscore = 3, dscore = 6, pcard3 = 7
    // Expected: Player gets 3rd card, Dealer gets 3rd card, Dealer wins (score 0 vs 9)
    // pc1 = 1 (A), pc2 = 2, dc1 = 4, dc2 = 2

    //reset
    slow_clock = 1'b0;
    reset = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;
    reset = 1'b1;

    //curent state should be deal_p_1 after reset, no cards assigned yet, scores = 0
    baccarat_check(`Blank, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000000); //in state deal_p_1

    // get pcard 1
    force tb_task5.DUT.dp.DC.dealer_card = 1;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;

    baccarat_check(`A, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000001); // pcard 1 shows (pscore=1)

    // get dcard1
    force tb_task5.DUT.dp.DC.dealer_card = 4;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;

    baccarat_check(`A, `Blank, `Blank, `four, `Blank, `Blank, 10'b0001000001); // dcard 1 shows, currently in state deal_p_2 (pscore=1, dscore=4)

    //get pcard2
    force tb_task5.DUT.dp.DC.dealer_card = 2;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;

    baccarat_check(`A, `two, `Blank, `four, `Blank, `Blank, 10'b0001000011); // pcard 2 shows (pscore=3)

    // get dcard2
    force tb_task5.DUT.dp.DC.dealer_card = 2;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to check third cards
    #5;

    baccarat_check(`A, `two, `Blank, `four, `two, `Blank, 10'b0001100011); //dcard2 shows (pscore=3, dscore=6)

    // get pcard3
    force tb_task5.DUT.dp.DC.dealer_card = 7;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to check third cards
    #5;

    baccarat_check(`A, `two, `seven, `four, `two, `Blank, 10'b0001100000); //pcard3 (pscore=0, dscore=6)

    // get dcard3
    force tb_task5.DUT.dp.DC.dealer_card = 3;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to compare
    #5;

    baccarat_check(`A, `two, `seven, `four, `two, `three, 10'b0010010000); //dcard3 (pscore=0, dscore=9)

    // game over
    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; 
    #5;

    baccarat_check(`A, `two, `seven, `four, `two, `three, 10'b1010010000); //in compare state, dealer light on


    

   //################################################################################################################################################################################
    $display("test 9:");
    // test 9: pscore = 2, dscore = 6, pcard3 = 7
    // Expected: Player gets 3rd card, Dealer gets 3rd card, Tie (score 9 vs 9)
    // pc1 = 1 (A), pc2 = 1 (A), dc1 = 4, dc2 = 2

    //reset
    slow_clock = 1'b0;
    reset = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;
    reset = 1'b1;

    //curent state should be deal_p_1 after reset, no cards assigned yet, scores = 0
    baccarat_check(`Blank, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000000); //in state deal_p_1

    // get pcard 1
    force tb_task5.DUT.dp.DC.dealer_card = 1;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;

    baccarat_check(`A, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000001); // pcard 1 shows (pscore=1)

    // get dcard1
    force tb_task5.DUT.dp.DC.dealer_card = 4;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;

    baccarat_check(`A, `Blank, `Blank, `four, `Blank, `Blank, 10'b0001000001); // dcard 1 shows, currently in state deal_p_2 (pscore=1, dscore=4)

    //get pcard2
    force tb_task5.DUT.dp.DC.dealer_card = 1;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;

    baccarat_check(`A, `A, `Blank, `four, `Blank, `Blank, 10'b0001000010); // pcard 2 shows (pscore=2)

    // get dcard2
    force tb_task5.DUT.dp.DC.dealer_card = 2;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to check third cards
    #5;

    baccarat_check(`A, `A, `Blank, `four, `two, `Blank, 10'b0001100010); //dcard2 shows (pscore=2, dscore=6)

    // get pcard3
    force tb_task5.DUT.dp.DC.dealer_card = 7;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to check third cards
    #5;

    baccarat_check(`A, `A, `seven, `four, `two, `Blank, 10'b0001101001); //pcard3 (pscore=9, dscore=6)

    // get dcard3
    force tb_task5.DUT.dp.DC.dealer_card = 3;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to compare
    #5;

    baccarat_check(`A, `A, `seven, `four, `two, `three, 10'b0010011001); //dcard3 (pscore=9, dscore=9)

    // game over
    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; 
    #5;

    baccarat_check(`A, `A, `seven, `four, `two, `three, 10'b1110011001); //in compare state, both lights on


    //################################################################################################################################################################################


    $display("test 10:");
    // test 10: pscore = 2, dscore = 5, pcard3 = 5
    // Expected: Player gets 3rd card, Dealer gets 3rd card, Player wins (score 7 vs 0)
    // pc1 = 1 (A), pc2 = 1 (A), dc1 = 2, dc2 = 3

    //reset
    slow_clock = 1'b0;
    reset = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;
    reset = 1'b1;

    //curent state should be deal_p_1 after reset, no cards assigned yet, scores = 0
    baccarat_check(`Blank, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000000); //in state deal_p_1

    // get pcard 1
    force tb_task5.DUT.dp.DC.dealer_card = 1;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;

    baccarat_check(`A, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000001); // pcard 1 shows (pscore=1)

    // get dcard1
    force tb_task5.DUT.dp.DC.dealer_card = 2;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;

    baccarat_check(`A, `Blank, `Blank, `two, `Blank, `Blank, 10'b0000100001); // dcard 1 shows, currently in state deal_p_2 (pscore=1, dscore=2)

    //get pcard2
    force tb_task5.DUT.dp.DC.dealer_card = 1;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;

    baccarat_check(`A, `A, `Blank, `two, `Blank, `Blank, 10'b0000100010); // pcard 2 shows (pscore=2)

    // get dcard2
    force tb_task5.DUT.dp.DC.dealer_card = 3;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to check third cards
    #5;

    baccarat_check(`A, `A, `Blank, `two, `three, `Blank, 10'b0001010010); //dcard2 shows (pscore=2, dscore=5)

    // get pcard3
    force tb_task5.DUT.dp.DC.dealer_card = 5;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to check third cards
    #5;

    baccarat_check(`A, `A, `five, `two, `three, `Blank, 10'b0001010111); //pcard3 (pscore=7, dscore=5)

    // get dcard3
    force tb_task5.DUT.dp.DC.dealer_card = 5;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to compare
    #5;

    baccarat_check(`A, `A, `five, `two, `three, `five, 10'b0000000111); //dcard3 (pscore=7, dscore=0)

    // game over
    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; 
    #5;

    baccarat_check(`A, `A, `five, `two, `three, `five, 10'b0100000111); //in compare state, player light on


   //################################################################################################################################################################################


    $display("test 11:");
    // test 11: pscore = 2, dscore = 4, pcard3 = 4
    // Expected: Player gets 3rd card, Dealer gets 3rd card, Dealer wins (score 6 vs 9)
    // pc1 = 1 (A), pc2 = 1 (A), dc1 = 2, dc2 = 2

    //reset
    slow_clock = 1'b0;
    reset = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;
    reset = 1'b1;

    //curent state should be deal_p_1 after reset, no cards assigned yet, scores = 0
    baccarat_check(`Blank, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000000); //in state deal_p_1

    // get pcard 1
    force tb_task5.DUT.dp.DC.dealer_card = 1;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;

    baccarat_check(`A, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000001); // pcard 1 shows (pscore=1)

    // get dcard1
    force tb_task5.DUT.dp.DC.dealer_card = 2;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;

    baccarat_check(`A, `Blank, `Blank, `two, `Blank, `Blank, 10'b0000100001); // dcard 1 shows, currently in state deal_p_2 (pscore=1, dscore=2)

    //get pcard2
    force tb_task5.DUT.dp.DC.dealer_card = 1;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;

    baccarat_check(`A, `A, `Blank, `two, `Blank, `Blank, 10'b0000100010); // pcard 2 shows (pscore=2)

    // get dcard2
    force tb_task5.DUT.dp.DC.dealer_card = 2;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to check third cards
    #5;

    baccarat_check(`A, `A, `Blank, `two, `two, `Blank, 10'b0001000010); //dcard2 shows (pscore=2, dscore=4)

    // get pcard3
    force tb_task5.DUT.dp.DC.dealer_card = 4;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to check third cards
    #5;

    baccarat_check(`A, `A, `four, `two, `two, `Blank, 10'b0001000110); //pcard3 (pscore=6, dscore=4)

    // get dcard3
    force tb_task5.DUT.dp.DC.dealer_card = 5;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to compare
    #5;

    baccarat_check(`A, `A, `four, `two, `two, `five, 10'b0010010110); //dcard3 (pscore=6, dscore=9)

    // game over
    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; 
    #5;

    baccarat_check(`A, `A, `four, `two, `two, `five, 10'b1010010110); //in compare state, dealer light on


    //################################################################################################################################################################################


    $display("test 12:");
    // test 12: pscore = 2, dscore = 2, pcard3 = 9
    // Expected: Player gets 3rd card, Dealer gets 3rd card, Dealer wins (score 1 vs 9)
    // pc1 = 1 (A), pc2 = 1 (A), dc1 = 1 (A), dc2 = 1 (A)

    //reset
    slow_clock = 1'b0;
    reset = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;
    reset = 1'b1;

    //curent state should be deal_p_1 after reset, no cards assigned yet, scores = 0
    baccarat_check(`Blank, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000000); //in state deal_p_1

    // get pcard 1
    force tb_task5.DUT.dp.DC.dealer_card = 1;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;

    baccarat_check(`A, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000001); // pcard 1 shows (pscore=1)

    // get dcard1
    force tb_task5.DUT.dp.DC.dealer_card = 1;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;

    baccarat_check(`A, `Blank, `Blank, `A, `Blank, `Blank, 10'b0000010001); // dcard 1 shows, currently in state deal_p_2 (pscore=1, dscore=1)

    //get pcard2
    force tb_task5.DUT.dp.DC.dealer_card = 1;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;

    baccarat_check(`A, `A, `Blank, `A, `Blank, `Blank, 10'b0000010010); // pcard 2 shows (pscore=2)

    // get dcard2
    force tb_task5.DUT.dp.DC.dealer_card = 1;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to check third cards
    #5;

    baccarat_check(`A, `A, `Blank, `A, `A, `Blank, 10'b0000100010); //dcard2 shows (pscore=2, dscore=2)

    // get pcard3
    force tb_task5.DUT.dp.DC.dealer_card = 9;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to check third cards
    #5;

    baccarat_check(`A, `A, `nine, `A, `A, `Blank, 10'b0000100001); //pcard3 (pscore=1, dscore=2)

    // get dcard3
    force tb_task5.DUT.dp.DC.dealer_card = 7;

    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; // switch to compare
    #5;

    baccarat_check(`A, `A, `nine, `A, `A, `seven, 10'b0010010001); //dcard3 (pscore=1, dscore=9)

    // game over
    //clock edge
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1; 
    #5;

    baccarat_check(`A, `A, `nine, `A, `A, `seven, 10'b1010010001); //in compare state, dealer light on



    //################################################################################################################################################################################
    $display("test 13:");
    // pscore = 5, dscore = 7, pcard3 = 6
    // pc1 = 2, pc2 = 3, dc1 = 4, dc2 = 3
    // pscore_final = 1, dscore_final = 7

    //reset
    slow_clock = 1'b0;
    reset = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;
    reset = 1'b1;


    baccarat_check(`Blank, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000000); //in state deal_p_1


    force tb_task5.DUT.dp.DC.dealer_card = 2;


    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000010); // pcard 1 shows, currently in state deal_d_1


    force tb_task5.DUT.dp.DC.dealer_card = 4;


    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `Blank, `Blank, `four, `Blank, `Blank, 10'b0001000010); // dcard 1 shows, currently in state deal_p_2


    force tb_task5.DUT.dp.DC.dealer_card = 3;


    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `three, `Blank, `four, `Blank, `Blank, 10'b0001000101); // pcard 2 shows, currently in state deal_d_2


    force tb_task5.DUT.dp.DC.dealer_card = 3;


    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `three, `Blank, `four, `three, `Blank, 10'b0001110101); // dcard 2 shows, currently in state player_draw


    force tb_task5.DUT.dp.DC.dealer_card = 6;


    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `three, `six, `four, `three, `Blank, 10'b0001110001); // pcard 3 shows, currently in state compare


    //game over
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `three, `six, `four, `three, `Blank, 10'b1001110001); //in compare state, dealer light on


//################################################################################################################################################################################
    $display("test 14:");
    // pscore = 5, dscore = 6, pcard3 = 1 (A)
    // pc1 = 2, pc2 = 3, dc1 = 4, dc2 = 2
    // pscore_final = 6, dscore_final = 6

    //reset
    slow_clock = 1'b0;
    reset = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;
    reset = 1'b1;


    baccarat_check(`Blank, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000000); //in state deal_p_1


    force tb_task5.DUT.dp.DC.dealer_card = 2;


    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000010); // pcard 1 shows, currently in state deal_d_1


    force tb_task5.DUT.dp.DC.dealer_card = 4;


    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `Blank, `Blank, `four, `Blank, `Blank, 10'b0001000010); // dcard 1 shows, currently in state deal_p_2


    force tb_task5.DUT.dp.DC.dealer_card = 3;


    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `three, `Blank, `four, `Blank, `Blank, 10'b0001000101); // pcard 2 shows, currently in state deal_d_2


    force tb_task5.DUT.dp.DC.dealer_card = 2;


    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `three, `Blank, `four, `two, `Blank, 10'b0001100101); // dcard 2 shows, currently in state player_draw


    force tb_task5.DUT.dp.DC.dealer_card = 1;


    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `three, `A, `four, `two, `Blank, 10'b0001100110); // pcard 3 shows, currently in state compare


    //game over
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `three, `A, `four, `two, `Blank, 10'b1101100110); //in compare state, player and dealer lights on


//################################################################################################################################################################################
    $display("test 15:");
    // pscore = 5, dscore = 5, pcard3 = 8
    // pc1 = 2, pc2 = 3, dc1 = 2, dc2 = 3
    // pscore_final = 3, dscore_final = 5

    //reset
    slow_clock = 1'b0;
    reset      = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;
    reset      = 1'b1;


    baccarat_check(`Blank, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000000); //in state deal_p_1


    force tb_task5.DUT.dp.DC.dealer_card = 2;


    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000010); // pcard 1 shows, currently in state deal_d_1


    force tb_task5.DUT.dp.DC.dealer_card = 2;


    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `Blank, `Blank, `two, `Blank, `Blank, 10'b0000100010); // dcard 1 shows, currently in state deal_p_2


    force tb_task5.DUT.dp.DC.dealer_card = 3;


    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `three, `Blank, `two, `Blank, `Blank, 10'b0000100101); // pcard 2 shows, currently in state deal_d_2


    force tb_task5.DUT.dp.DC.dealer_card = 3;


    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `three, `Blank, `two, `three, `Blank, 10'b0001010101); // dcard 2 shows, currently in state player_draw


    force tb_task5.DUT.dp.DC.dealer_card = 8;


    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `three, `eight, `two, `three, `Blank, 10'b0001010011); // pcard 3 shows, currently in state compare


    //game over
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `three, `eight, `two, `three, `Blank, 10'b1001010011); //in compare state, player light on


//################################################################################################################################################################################
    $display("test 16:");
    // pscore = 3, dscore = 4, pcard3 = 8
    // pc1 = 2, pc2 = 1, dc1 = 1, dc2 = 3
    // pscore_final = 8, dscore_final = 4

    //reset
    slow_clock = 1'b0;
    reset      = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;
    reset      = 1'b1;


    baccarat_check(`Blank, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000000); //in state deal_p_1


    force tb_task5.DUT.dp.DC.dealer_card = 2;


    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000010); // pcard 1 shows, currently in state deal_d_1


    force tb_task5.DUT.dp.DC.dealer_card = 1;


    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `Blank, `Blank, `A, `Blank, `Blank, 10'b0000010010); // dcard 1 shows, currently in state deal_p_2


    force tb_task5.DUT.dp.DC.dealer_card = 1;


    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `A, `Blank, `A, `Blank, `Blank, 10'b0000010011); // pcard 2 shows, currently in state deal_d_2


    force tb_task5.DUT.dp.DC.dealer_card = 3;


    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `A, `Blank, `A, `three, `Blank, 10'b0001000011); // dcard 2 shows, currently in state player_draw

    //pcard3
    force tb_task5.DUT.dp.DC.dealer_card = 8;


    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `A, `eight, `A, `three, `Blank, 10'b0001000001); // pcard 3 shows, currently in state compare


    //game over
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `A, `eight, `A, `three, `Blank, 10'b1001000001); //in compare state, player and dealer lights on


//################################################################################################################################################################################
    $display("test 17:");
    // pscore = 5, dscore = 3, pcard3 = 8
    // pc1 = 2, pc2 = 3, dc1 = 1, dc2 = 2
    // pscore_final = 3, dscore_final = 3

    //reset
    slow_clock = 1'b0;
    reset      = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;
    reset      = 1'b1;


    baccarat_check(`Blank, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000000); //in state deal_p_1


    force tb_task5.DUT.dp.DC.dealer_card = 2;


    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000010); // pcard 1 shows, currently in state deal_d_1


    force tb_task5.DUT.dp.DC.dealer_card = 1;


    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `Blank, `Blank, `A, `Blank, `Blank, 10'b0000010010); // dcard 1 shows, currently in state deal_p_2


    force tb_task5.DUT.dp.DC.dealer_card = 3;


    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `three, `Blank, `A, `Blank, `Blank, 10'b0000010101); // pcard 2 shows, currently in state deal_d_2


    force tb_task5.DUT.dp.DC.dealer_card = 2;


    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `three, `Blank, `A, `two, `Blank, 10'b0000110101); // dcard 2 shows, currently in state player_draw


    force tb_task5.DUT.dp.DC.dealer_card = 8;


    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `three, `eight, `A, `two, `Blank, 10'b0000110011); // pcard 3 shows, currently in state compare


    //game over
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `three, `eight, `A, `two, `Blank, 10'b1100110011); //in compare state, player and dealer lights on


//################################################################################################################################################################################
    $display("test 18:");
    // pscore = 4, dscore = 5, pcard3 = 1 (A)
    // pc1 = 2, pc2 = 2, dc1 = 2, dc2 = 3
    // pscore_final = 5, dscore_final = 5

    //reset
    slow_clock = 1'b0;
    reset      = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;
    reset      = 1'b1;


    baccarat_check(`Blank, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000000); //in state deal_p_1


    force tb_task5.DUT.dp.DC.dealer_card = 2;


    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `Blank, `Blank, `Blank, `Blank, `Blank, 10'b0000000010); // pcard 1 shows, currently in state deal_d_1


    force tb_task5.DUT.dp.DC.dealer_card = 2;


    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `Blank, `Blank, `two, `Blank, `Blank, 10'b0000100010); // dcard 1 shows, currently in state deal_p_2


    force tb_task5.DUT.dp.DC.dealer_card = 2;


    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `two, `Blank, `two, `Blank, `Blank, 10'b0000100100); // pcard 2 shows, currently in state deal_d_2


    force tb_task5.DUT.dp.DC.dealer_card = 3;


    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `two, `Blank, `two, `three, `Blank, 10'b0001010100); // dcard 2 shows, currently in state player_draw


    force tb_task5.DUT.dp.DC.dealer_card = 1;


    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `two, `A, `two, `three, `Blank, 10'b0001010101); // pcard 3 shows, currently in state compare


    //game over
    slow_clock = 1'b0;
    #5;
    slow_clock = 1'b1;
    #5;


    baccarat_check(`two, `two, `A, `two, `three, `Blank, 10'b1101010101); //in compare state, player and dealer lights on








    end


endmodule
