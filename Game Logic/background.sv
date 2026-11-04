module nicer_bkg2_palette (
	input logic [3:0] index,
	input logic game_over,
	output logic [3:0] red, green, blue
);

localparam [0:15][11:0] palette_blue = {
	{4'h0, 4'h5, 4'hB},
	{4'h0, 4'h2, 4'h8},
	{4'hA, 4'hC, 4'hE},
	{4'h0, 4'h7, 4'hE},
	{4'h0, 4'h4, 4'hA},
	{4'h0, 4'h6, 4'hD},
	{4'h0, 4'h5, 4'hB},
	{4'h0, 4'h3, 4'h9},
	{4'h9, 4'hB, 4'hD},
	{4'h0, 4'h4, 4'h9},
	{4'h0, 4'h4, 4'hA},
	{4'h0, 4'h5, 4'hC},
	{4'h0, 4'h5, 4'hB},
	{4'h0, 4'h3, 4'h8},
	{4'h0, 4'h2, 4'h7},
	{4'hA, 4'hD, 4'hF}
};

//localparam [0:15][11:0] palette_red = {
//	{4'hB, 4'h5, 4'h0}, // from {0,5,B}
//	{4'h8, 4'h2, 4'h0}, // from {0,2,8}
//	{4'hE, 4'hC, 4'hA}, // from {A,C,E}
//	{4'hE, 4'h7, 4'h0}, // from {0,7,E}
//	{4'hA, 4'h4, 4'h0}, // from {0,4,A}
//	{4'hD, 4'h6, 4'h0}, // from {0,6,D}
//	{4'hB, 4'h5, 4'h0}, // repeat
//	{4'h9, 4'h3, 4'h0}, // from {0,3,9}
//	{4'hD, 4'hB, 4'h9}, // from {9,B,D}
//	{4'h9, 4'h4, 4'h0}, // from {0,4,9}
//	{4'hA, 4'h4, 4'h0}, // from {0,4,A}
//	{4'hC, 4'h5, 4'h0}, // from {0,5,C}
//	{4'hB, 4'h5, 4'h0}, // repeat
//	{4'h8, 4'h3, 4'h0}, // from {0,3,8}
//	{4'h7, 4'h2, 4'h0}, // from {0,2,7}
//	{4'hF, 4'hD, 4'hA}  // from {A,D,F}
//};

localparam [0:15][11:0] palette_red = {
	{4'hD, 4'h3, 4'h5}, // deep magenta-red
	{4'hA, 4'h1, 4'h3}, // dark red
	{4'hF, 4'h9, 4'hB}, // soft pink highlight
	{4'hF, 4'h4, 4'h7}, // hot pink
	{4'hC, 4'h2, 4'h4}, // darker magenta
	{4'hE, 4'h3, 4'h6}, // hot magenta
	{4'hD, 4'h3, 4'h5}, // repeat
	{4'hB, 4'h1, 4'h3}, // red shadow
	{4'hF, 4'h8, 4'hA}, // highlight
	{4'hC, 4'h2, 4'h3}, // mid red tone
	{4'hC, 4'h2, 4'h4}, // darker magenta
	{4'hE, 4'h3, 4'h6}, // hot magenta
	{4'hD, 4'h3, 4'h5}, // repeat
	{4'hA, 4'h1, 4'h3}, // dark red
	{4'h9, 4'h0, 4'h2}, // deep shadow red
	{4'hF, 4'hA, 4'hC}  // bright pinkish highlight
};


always_comb begin
    if(game_over) begin
         {red, green, blue} = palette_red[index];
    end else begin
        {red, green, blue} = palette_blue[index];
    end
end


endmodule
