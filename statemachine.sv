/*
This module implements a Mealy finite state machine that controls the game logic of dealing cards in baccarat. 

1. Two cards are dealt to both the player and the dealer (i.e., the banker) face up (first card to the player, second card to 
dealer, third card to the player, fourth card to the dealer).

2. Case 1 (Natural): If the player's or banker's hand has a score of 8 or 9, the game is over and whoever has the higher score 
wins (if the scores are the same, it is a tie). 

3. Case 2 (Player Score 0-5): The player gets a third card and the banker may get a third card depending on the following rule:
    a) If the banker's score from the first two cards is 7, the banker does not take another card
    b) If the banker's score from the first two cards is 6, the banker gets a third card if the face value of the player's third card was a 6 or 7
    c) If the banker's score from the first two cards is 5, the banker gets a third card if the face value of the player's third card was 4, 5, 6, or 7
    d) If the banker's score from the first two cards is 4, the banker gets a third card if the face value of player's third card was 2, 3, 4, 5, 6, or 7
    e) If the banker's score from the first two cards is 3, the banker gets a third card if the face value of player's third card was anything but an 8
    f) If the banker's score from the first two cards is 0, 1, or 2, the banker gets a third card.

4. Case 3 (Player Score 6/7): The player does not get a third card and the banker may get a third card depending on the following rule:
    a) If the banker's score from his/her first two cards was 0 to 5, the banker gets a third card
    b) Otherwise the banker does not get a third card

5. The game is over. Whoever has the higher score wins, or if they are the same, it is a tie.
*/

`define deal_p_1    3'b000
`define deal_d_1    3'b001
`define deal_p_2    3'b010
`define deal_d_2    3'b011
`define decide      3'b100
`define deal_p_3    3'b101
`define deal_d_3    3'b110
`define compare     3'b111

module statemachine(input logic slow_clock, input logic resetb,
                    input logic [3:0] dscore, input logic [3:0] pscore, input logic [3:0] pcard3,
                    output logic load_pcard1, output logic load_pcard2, output logic load_pcard3,
                    output logic load_dcard1, output logic load_dcard2, output logic load_dcard3,
                    output logic player_win_light, output logic dealer_win_light);

    reg[2:0] present_state; 
    reg[2:0] next_state;

    // This sequential always block controls the logic for state transitions of the FSM, based on the rising edge of the clock
    always_ff @(posedge slow_clock) begin
        if(~resetb) begin
            present_state <= `deal_p_1;
        end
        else
            present_state <= next_state;
    end
   
    // This combinational always block determines the next state of the FSM based on the present state and input conditions
    always_comb begin
        case(present_state)
            `deal_p_1:  next_state = `deal_d_1;
            `deal_d_1:  next_state = `deal_p_2;
            `deal_p_2:  next_state = `deal_d_2;
            `deal_d_2:  next_state = `decide; 
            `decide: 
                begin
                    if(pscore == 8 || pscore == 9 || dscore == 8 || dscore == 9)
                        next_state = `compare;
                    else if(pscore <= 5)
                        next_state = `deal_p_3;
                    else if((pscore == 6 && dscore <= 5) || (pscore == 7 && dscore <= 5))
                        next_state = `deal_d_3;
                    else if((pscore == 6 && (dscore == 6 || dscore == 7)) || (pscore == 7 && (dscore == 6 || dscore == 7)))
                        next_state = `compare; 
                    else
                        next_state = `compare; 
                end
            `deal_p_3: 
                begin
                    if(dscore == 6 && (pcard3 == 6 || pcard3 == 7))
						next_state = `deal_d_3;
                    else if(dscore == 5 && (pcard3 == 4 || pcard3 == 5 || pcard3 == 6 || pcard3 == 7))
                        next_state = `deal_d_3; 
                    else if(dscore == 4 && (pcard3 == 2 || pcard3 == 3 || pcard3 == 4 || pcard3 == 5 || pcard3 == 6 || pcard3 == 7))
                        next_state = `deal_d_3; 
					else if(dscore == 3 && (pcard3 != 8))
						next_state = `deal_d_3; 
					else if(dscore <= 2)
                        next_state = `deal_d_3;
                    else
                        next_state = `compare;
                end
            `deal_d_3:  next_state = `compare;
            `compare:   next_state = `compare;
            default:    next_state = `compare; 
        endcase
    end

    // This always block is purely combinational and determines the output signals based on the current state of the FSM and inputs
    always_comb begin
	    case(present_state)
            `deal_p_1: 
                begin
                    load_dcard1 = 1'b0;
                    load_dcard2 = 1'b0;
                    load_dcard3 = 1'b0;
                    load_pcard1 = 1'b1; 
                    load_pcard2 = 1'b0;
                    load_pcard3 = 1'b0;
                    player_win_light = 1'b0;
                    dealer_win_light = 1'b0;
                end
            `deal_d_1:
                begin
                    load_dcard1 = 1'b1;
                    load_dcard2 = 1'b0;
                    load_dcard3 = 1'b0;
                    load_pcard1 = 1'b0;
                    load_pcard2 = 1'b0;
                    load_pcard3 = 1'b0;
                    player_win_light = 1'b0;
                    dealer_win_light = 1'b0;
                end
            `deal_p_2:
                begin
                    load_dcard1 = 1'b0;
                    load_dcard2 = 1'b0;
                    load_dcard3 = 1'b0;
                    load_pcard1 = 1'b0;
                    load_pcard2 = 1'b1;
                    load_pcard3 = 1'b0;
                    player_win_light = 1'b0;
                    dealer_win_light = 1'b0;
                end
            `deal_d_2: 
                begin
                    load_dcard1 = 1'b0;
                    load_dcard2 = 1'b1;
                    load_dcard3 = 1'b0;
                    load_pcard1 = 1'b0;
                    load_pcard2 = 1'b0;
                    load_pcard3 = 1'b0;
                    player_win_light = 1'b0;
                    dealer_win_light = 1'b0;
                end
            `decide: 
					 begin	
						  if(pscore == 8 || pscore == 9 || dscore == 8 || dscore == 9)
								begin
									load_dcard1 = 1'b0;
									load_dcard2 = 1'b0;
									load_dcard3 = 1'b0;
									load_pcard1 = 1'b0;
									load_pcard2 = 1'b0;
									load_pcard3 = 1'b0;
									player_win_light = 1'b0;
									dealer_win_light = 1'b0;
								end
						  else if(pscore <= 5)
								begin
									load_dcard1 = 1'b0;
									load_dcard2 = 1'b0;
									load_dcard3 = 1'b0;
									load_pcard1 = 1'b0;
									load_pcard2 = 1'b0;
									load_pcard3 = 1'b1;
									player_win_light = 1'b0;
									dealer_win_light = 1'b0;
								end
						  else if((pscore == 6 && dscore <= 5) || (pscore == 7 && dscore <= 5))
								begin
									load_dcard1 = 1'b0;
									load_dcard2 = 1'b0;
									load_dcard3 = 1'b1;
									load_pcard1 = 1'b0;
									load_pcard2 = 1'b0;
									load_pcard3 = 1'b0;
									player_win_light = 1'b0;
									dealer_win_light = 1'b0;
								end
						  else if((pscore == 6 && (dscore == 6 || dscore == 7)) || (pscore == 7 && (dscore == 6 || dscore == 7)))
								begin
									load_dcard1 = 1'b0;
									load_dcard2 = 1'b0;
									load_dcard3 = 1'b0;
									load_pcard1 = 1'b0;
									load_pcard2 = 1'b0;
									load_pcard3 = 1'b0;
									player_win_light = 1'b0;
									dealer_win_light = 1'b0;
								end
						  else
								begin
									load_dcard1 = 1'b0;
									load_dcard2 = 1'b0;
									load_dcard3 = 1'b0;
									load_pcard1 = 1'b0;
									load_pcard2 = 1'b0;
									load_pcard3 = 1'b0;
									player_win_light = 1'b0;
									dealer_win_light = 1'b0;
								end
                end
            `deal_p_3: 
                begin
                    if((dscore == 6 && (pcard3 == 6 || pcard3 == 7)) || 
                        (dscore == 5 && (pcard3 == 4 || pcard3 == 5 || pcard3 == 6 || pcard3 == 7)) || 
                        (dscore == 4 && (pcard3 == 2 || pcard3 == 3 || pcard3 == 4 || pcard3 == 5 || pcard3 == 6 || pcard3 == 7)) || 
                        (dscore == 3 && pcard3 != 8) || 
                        dscore == 0 || dscore == 1 || dscore == 2)
                        begin
                            load_dcard1 = 1'b0;
                            load_dcard2 = 1'b0;
                            load_dcard3 = 1'b1;
                            load_pcard1 = 1'b0;
                            load_pcard2 = 1'b0;
                            load_pcard3 = 1'b0;
                            player_win_light = 1'b0;
                            dealer_win_light = 1'b0;
                        end
                    else
                        begin
                            load_dcard1 = 1'b0;
                            load_dcard2 = 1'b0;
                            load_dcard3 = 1'b0;
                            load_pcard1 = 1'b0;
                            load_pcard2 = 1'b0;
                            load_pcard3 = 1'b0;
                            player_win_light = 1'b0;
                            dealer_win_light = 1'b0;
                        end
                end
            `deal_d_3:
                begin
                    load_dcard1 = 1'b0;
                    load_dcard2 = 1'b0;
                    load_dcard3 = 1'b0;
                    load_pcard1 = 1'b0;
                    load_pcard2 = 1'b0;
                    load_pcard3 = 1'b0;
                    player_win_light = 1'b0;
                    dealer_win_light = 1'b0;
                end
            `compare: 
                begin
                    load_dcard1 = 1'b0;
                    load_dcard2 = 1'b0;
                    load_dcard3 = 1'b0;
                    load_pcard1 = 1'b0;
                    load_pcard2 = 1'b0;
                    load_pcard3 = 1'b0;
                    if(pscore > dscore) begin
                        player_win_light = 1'b1;
                        dealer_win_light = 1'b0;
                    end
                    else if(dscore > pscore) begin
                        player_win_light = 1'b0;
                        dealer_win_light = 1'b1;
                    end
                    else begin
                        player_win_light = 1'b1;
                        dealer_win_light = 1'b1;
                    end
                end
            default: 
                begin
                    load_dcard1 = 1'bx;
                    load_dcard2 = 1'bx;
                    load_dcard3 = 1'bx;
                    load_pcard1 = 1'bx;
                    load_pcard2 = 1'bx;
                    load_pcard3 = 1'bx;
                    player_win_light = 1'bx;
                    dealer_win_light = 1'bx;
                end
        endcase
    end

endmodule


