module tb_scorehand();

    reg [3:0] card1, card2, card3, total;
    reg err; 

    scorehand DUT(.card1(card1), .card2(card2), .card3(card3), .total(total)); 

    // This task compares the expect score of a hand with the actual score
    task segment_checker;

        input [6:0] expected_total;

        if(tb_scorehand.DUT.total != expected_total) begin
            $display("Error: total is: %b, expected: %b", tb_scorehand.DUT.total, expected_total);
            err = 1'b1;
        end
        else
            err = 1'b0;
        
    endtask

    // This initial block manually inputs a test hand and determines if the correct score is computed
    initial begin

        $display("Seven segment display checker"); 
        #5; 

        // Test 1: All 3 face cards (J, Q, K) -> 0
        card1 = 4'b1011;
        card2 = 4'b1100;
        card3 = 4'b1101;
        #5; 
        segment_checker(4'b0000); 
        #5; 

        // Test 2: 2 face cards with a 5 -> 5
        card1 = 4'b0101;
        card2 = 4'b1101;
        card3 = 4'b1101;
        #5; 
        segment_checker(4'b0101); 
        #5; 
        
        // Test 3: 2, 3, 4 -> 9
        card1 = 4'b0010;
        card2 = 4'b0011;
        card3 = 4'b0100;
        #5; 
        segment_checker(4'b1001); 
        #5; 

        // Test 4: 7, 1, 2 -> 0
        card1 = 4'b0111;
        card2 = 4'b0001;
        card3 = 4'b0010;
        #5; 
        segment_checker(4'b0000); 
        #5; 

        // Test 5: 8, 9, 7 -> 4
        card1 = 4'b1000;
        card2 = 4'b1001;
        card3 = 4'b0111;
        #5; 
        segment_checker(4'b0100); 
        #5; 

        // Test 6: 9, 9, 2 -> 0
        card1 = 4'b1001;
        card2 = 4'b1001;
        card3 = 4'b0010;
        #5; 
        segment_checker(4'b0000); 
        #5; 

        // Test 7: 9, 9, 5 -> 0
        card1 = 4'b1001;
        card2 = 4'b1001;
        card3 = 4'b0101;
        #5; 
        segment_checker(4'b0011); 
        #5; 

    end
						
endmodule








