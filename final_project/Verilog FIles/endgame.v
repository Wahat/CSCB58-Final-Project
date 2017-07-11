// mux module endgame
// 1 for winner
// 0 for loser

module endgamemux (reg_win, reg_lose, select, out);
  input select;
  input [3:0] reg_win;
  input [3:0] reg_lose;
  output [6:0] out;
  reg out;

  always @ (*)
  begin
    case(select)
      1'b0: out <= reg_lose;
      1'b1: out <= reg_win;
    endcase
  end

endmodule
