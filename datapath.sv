/*
The datapath does all the “heavy lifting” (in this case, keeping track of each hand and computing the score for each hand) 
and the state machine controls the datapath (in this case, telling the datapath when to load a new card into either the 
player’s or dealer’s hand). 
*/

module datapath(input logic slow_clock, input logic fast_clock, input logic resetb,
                input logic load_pcard1, input logic load_pcard2, input logic load_pcard3,
                input logic load_dcard1, input logic load_dcard2, input logic load_dcard3,
                output logic [3:0] pcard3_out,
                output logic [3:0] pscore_out, output logic [3:0] dscore_out,
                output logic [6:0] HEX5, output logic [6:0] HEX4, output logic [6:0] HEX3,
                output logic [6:0] HEX2, output logic [6:0] HEX1, output logic [6:0] HEX0);

    logic [5:0] load_reg; // one hot for enabling card registers (reg4)
    logic [3:0] new_card; 
    logic [3:0] pcard1, pcard2, pcard3, dcard1, dcard2, dcard3;

    assign load_reg = {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2, load_dcard3}; // load signals concatenated to a 6-bit one-hot signal
	assign pcard3_out = pcard3;

    // This always block is sequential and functions as a load enable register with a reset for the 6 cards
    always @(posedge slow_clock) begin
        if(~resetb) begin
            pcard1 = 4'b0000;
            pcard2 = 4'b0000;
            pcard3 = 4'b0000;
            dcard1 = 4'b0000;
            dcard2 = 4'b0000;
            dcard3 = 4'b0000;
        end
        else begin
            case(load_reg)
                6'b000001: // load new_card into dealer's third card slot
                    begin
                        dcard3 = new_card; 
                        dcard2 = dcard2; 
                        dcard1 = dcard1; 
                        pcard3 = pcard3; 
                        pcard2 = pcard2; 
                        pcard1 = pcard1;
                    end
                6'b000010: // load new_card into dealer's second card slot
                    begin
                        dcard3 = dcard3; 
                        dcard2 = new_card; 
                        dcard1 = dcard1; 
                        pcard3 = pcard3; 
                        pcard2 = pcard2; 
                        pcard1 = pcard1;
                    end
                6'b000100: // load new_card into dealer's first card slot
                    begin
                        dcard3 = dcard3; 
                        dcard2 = dcard2; 
                        dcard1 = new_card; 
                        pcard3 = pcard3; 
                        pcard2 = pcard2; 
                        pcard1 = pcard1;
                    end
                6'b001000: // load new_card into player's third card slot
                    begin
                        dcard3 = dcard3; 
                        dcard2 = dcard2; 
                        dcard1 = dcard1; 
                        pcard3 = new_card; 
                        pcard2 = pcard2; 
                        pcard1 = pcard1;
                    end
                6'b010000: // load new_card into player's second card slot
                    begin
                        dcard3 = dcard3; 
                        dcard2 = dcard2; 
                        dcard1 = dcard1; 
                        pcard3 = pcard3; 
                        pcard2 = new_card; 
                        pcard1 = pcard1;
                    end
                6'b100000: // load new_card into player's first card slot
                    begin
                        dcard3 = dcard3; 
                        dcard2 = dcard2; 
                        dcard1 = dcard1; 
                        pcard3 = pcard3; 
                        pcard2 = pcard2; 
                        pcard1 = new_card;
                    end
                default: 
                    begin
                        dcard3 = dcard3; 
                        dcard2 = dcard2; 
                        dcard1 = dcard1; 
                        pcard3 = pcard3; 
                        pcard2 = pcard2; 
                        pcard1 = pcard1;
                    end
            endcase
        end
    end

    // Instantiate the dealcard module, which cycles through the cards with the 50MHz clock, stopping on a random card when slow_clock is asserted
    dealcard DC(.clock(fast_clock), .resetb(resetb), .new_card(new_card));

    // Instantiate the scorehand modules for the player and dealer, which calculates the score of each hand and returns the value back to the state machine
    scorehand PS(.card1(pcard1), .card2(pcard2), .card3(pcard3), .total(pscore_out));
    scorehand DS(.card1(dcard1), .card2(dcard2), .card3(dcard3), .total(dscore_out));

    // Instantiate the card7seg modules, which converts the values of each card into a value to be read on a seven-segment display
    card7seg PCH1(.card(pcard1), .seg7(HEX0));
    card7seg PCH2(.card(pcard2), .seg7(HEX1));
    card7seg PCH3(.card(pcard3), .seg7(HEX2));
    card7seg DCH1(.card(dcard1), .seg7(HEX3));
    card7seg DCH2(.card(dcard2), .seg7(HEX4));
    card7seg DCH3(.card(dcard3), .seg7(HEX5));

endmodule
