/*
The score of each hand is computed as follows:

The value of each card in each hand is determined. Each Ace, 2, 3, 4, 5, 6, 7, 8, and 9 has a value equal the face value 
(eg. Ace has value of 1, 2 is a value of 2, 3 has a value of 3, etc.). Tens, Jacks, Queens, and Kings have a value of 0.

The score for each hand (which can contain up to three cards) is then computed by summing the values of each card in the hand, 
and the rightmost digit (in base 10) of the sum is the score of the hand. In other words, if Value1 to Value 3 are the values 
of Card 1 to 3, then score of hand = (Value1 + Value2 + Value3) mod 10
*/

module scorehand(input logic [3:0] card1, input logic [3:0] card2, input logic [3:0] card3, output logic [3:0] total);

    wire[3:0] card1_o, card2_o, card3_o; 

    card_value CV1(.card_num(card1), .card_val(card1_o));
    card_value CV2(.card_num(card2), .card_val(card2_o));
    card_value CV3(.card_num(card3), .card_val(card3_o));

    // This always block is purely combinational and basically does a mod 10 operation on the sum of the three card values
    always_comb begin

        if((card1_o + card2_o + card3_o) >= 5'b10100)
            total = (card1_o + card2_o + card3_o) - 5'b10100;
        else if((card1_o + card2_o + card3_o) >= 5'b01010)
            total = (card1_o + card2_o + card3_o) - 5'b01010;
        else
            total = card1_o + card2_o + card3_o;

    end

endmodule

/*
This module converts the card number to its corresponding value in baccarat. (10, J, Q, K get converted to a value of 0)
*/

module card_value(input logic [3:0] card_num, output logic [3:0] card_val);
    
    // This always block is purely combinational and determines the card value based on the card number
    always_comb begin

        if(card_num >= 4'b1010)
                card_val = 4'b0000;
        else
                card_val = card_num; 

    end 


endmodule

