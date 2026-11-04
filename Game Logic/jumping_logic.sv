module character_jump(
    input  logic        Reset, 
    input  logic        frame_clk,
    input  logic        keycode,
    input  logic [9:0]  collision_Y, ceiling, floor,
    input  logic [3:0]        collision_type,
    input  logic        in_home, in_spaceship,
    
    output logic [9:0]  CharX, CharY, CharS,
    output logic        game_over, game_won //change to game state instead of game_over, to accomodate for game_won
    //output logic [1:0] game_state //0 = in game, 1 = in game-over, 2 = game spaceship, 3 = game won
    
);

    // Parameters
    assign CharX = 320;
    assign CharS = 25; //25 away from center
    parameter [9:0] CharY_Center = 349; 
    logic [9:0] CharY_Min, CharY_Max;

    logic [9:0] Char_Y_Step;
    parameter signed [10:0] GRAVITY = 1;

    // Signed motion variables
    logic signed [10:0] CharY_Motion;
    logic signed [10:0] CharY_Motion_next;
    logic game_over_next, game_over_b;
    logic game_won_next;
    logic [9:0] CharX_next, CharY_next, CharY_temp;
    logic counter;
   

    // ------------------------------------------------------------- //
    
//Setting new floor/ceiling if anything is in the way 
//We simply have ceiling + 25, floor - 25.
       
//Motion Logic
    always_comb begin
        
        CharY_Motion_next = CharY_Motion + GRAVITY;

        //Modifying for spaceship mode
        if(in_spaceship) begin 
            Char_Y_Step = 8;
            if (keycode == 1'b1) begin //changed to accomodate push button input
                    CharY_Motion_next = -Char_Y_Step; 
                end 
        end else begin
            // Regular mode
            Char_Y_Step = 15;
            if ((CharY) >= floor) begin //If we are currently exceed Y_max (too low)
                if (keycode == 1'b1) begin //changed to accomodate push button input
                    CharY_Motion_next = -Char_Y_Step; 
                end else begin
                    CharY_Motion_next = 0; // Stop downward motion on ground
                end
            end
        end

        CharY_next = CharY + CharY_Motion_next;
        
        if(in_spaceship) begin
            //Default ceiling is 50, floor is 430. 
            if (CharY_next < ceiling) CharY_next = ceiling; 
            if (CharY_next > floor) CharY_next = floor;
        end else begin
            if (CharY_next < ceiling) CharY_next = ceiling; 
            if (CharY_next > floor) CharY_next = floor;
        end
        
        //clamping is affected by CharY_Min_next stuff
    
    end
 
 //Game-Over Logic
    always_comb begin       
        game_over_next = 0;
        game_won_next = 0;
        game_over_b = 0;
        if(in_spaceship && collision_type == 8) begin
            game_over_next = 0;
            
        end
        else if(collision_Y != 0) begin //If we might be colliding
            //If spike, check for full collision
            if(collision_type == 9) begin
                //We have won, period
                game_won_next = 1;
            end else 
            if(collision_type == 0 || collision_type == 5 || collision_type == 6) begin
                if(!(collision_Y - 15 >= CharY_next + 25 || collision_Y + 15 < CharY_next - 25)) begin 
                    game_over_next = 1;
                end 
//                if(!(collision_Y - 10 >= CharY_next + 25 || collision_Y + 10 < CharY_next - 25))
//                begin 
//                    game_over_next = 1;
//                end
            end 
            else if(collision_type == 1 || collision_type == 3) begin
            //Check for phasing through -- bottom of spike is in range or top of spike is in range
                if(!(collision_Y - 25 >= CharY_next + 25 || collision_Y + 25 < CharY_next- 25)) begin
                    game_over_next = 1; //For now
                end
            end
        end
       
    end
    
    
    // Update registers on clock
    always_ff @(posedge frame_clk or posedge Reset) begin
        if (Reset || in_home) begin
            CharY <= CharY_Center;
            CharY_Motion <= 0;
            //
            CharY_Min <= 25;
            CharY_Max <= 349;
            game_over <= 0;
            game_won <= 0;
        end else begin
            if(game_over || game_won) begin
                CharY <= CharY_Center;
                CharY_Motion <= 0;
                CharY_Min <= ceiling;
                CharY_Max <= floor;
                counter <= counter + 1;
                //We will also need to set game_over and game_won to 0 if we press jump from this point. 
                if(keycode == 1 && counter == 5) begin
                    game_over <= 0;
                    game_won <= 0;
                    CharY <= CharY_Center;
                    CharY_Motion <= 0;
                    CharY_Min <= 25;
                    CharY_Max <= 349;
                end
            end else begin
            CharY <= CharY_next;
            CharY_Motion <= CharY_Motion_next;
            game_over <= game_over_next;
                if(!game_won) begin
                    game_won <= game_won_next;
                end
            end
        end
    end
endmodule
