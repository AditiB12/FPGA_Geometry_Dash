module terrain_motion(
    input  logic        Reset, 
    input  logic        frame_clk,    
    input  logic [9:0]  DrawX, DrawY, CharX, CharY,
    input  logic [1:0]  lvl_select,
    input  logic        in_home, game_over, game_won,
    
    output logic [9:0]  SpikeX,
    output logic [9:0]  SpikeY,
    output logic [3:0]  object_type,
    
    output logic [15:0] offset, lvlEnd,
    
    //add an output logic to check which sprite we're actually drawing
    output logic render_terrain,
    output logic [9:0] collision_Y, //Will be 0 if we cannot collide
    output logic [9:0] ceiling, floor, //The new Y_max, Y_min, without contest
    output logic [3:0] collision_type,

    output logic in_spaceship
    
);

    //Should have different parameters for each level
    logic [7:0] ObjectCount;
    logic seen_spaceship_portal, portal_reg;
    
    parameter [7:0] ObjectCount_Lvl1 = 33;
    parameter [7:0] ObjectCount_Lvl2 = 6;
    parameter [7:0] ObjectCount_Lvl3 = 2;

// --------- Tileset --------
//Have a tileset with the number of spikes.
//Pass out the center of a spike that is in the x range of char. 
typedef struct {
    logic [15:0] x; //To match offset. 
    logic [9:0] y; //Up to 1024 -- matches drawX/drawY
    logic [3:0] t; //t for type
        //0 = spike
        //1 = platform
        //2 = spaceship portal
        //3 = game won! 
        
        //--- new ---
        
//        0 = spike
//        1 = block
//        2 = short spike
//        3 = platform
//        4 = multispike1
//        5 = multispike2
//        6 = multispike3 -- getting rid of this too would shorten the signal but,,, meh. 
//        7 = multispike4 -- get rid of this, all other numbers stay the same. 
//        8 = spaceship portal
//        9 = game won! 

    //Will have a separate array for grounds and ceilings
        
} tile;


//Stereo madness 
tile objects_Lvl1 [ObjectCount_Lvl1] =  '{'{700, 349, 0}, '{1100, 349, 0}, '{1450, 349, 1}, 
'{1500, 349, 5}, '{1550, 349, 6}, '{1600, 299, 1},  //'{1650, 349, 6}, '{1700, 349, 5}, //'{1750, 349, 5}, 
'{1650, 349, 6}, '{1700, 349, 5}, '{1750, 249, 1}, 
'{1800, 249, 1}, '{1850, 249, 1}, '{1900, 249, 1}, 
'{1950, 249, 1}, '{1950, 199, 0}, '{2400, 349, 5}, 
'{2500, 349, 6}, '{2600, 349, 5}, '{2450, 299, 3}, 
'{2550, 249, 3}, '{2650, 199, 3}, '{2700, 199, 1}, 
'{2750, 199, 1}, 
//Spaceship
'{2800, 149, 8}, '{3400, 309, 1},  // '{2800, 199, 1},
'{3600, 141, 1}, '{3750, 349, 0}, '{3900, 299, 1}, 
'{3950, 299, 1}, '{4000, 299, 1}, '{4000, 249, 8},
//Out of spaceship
'{4600, 349, 0}, '{4800, 349, 0}, '{5200, 349, 9}};

//3 spikes is craazy. but doable. 2 spikes is fine

//Debugging 
tile objects_Lvl2 [ObjectCount_Lvl2] = 
'{'{700, 349, 1}, '{750, 349, 1}, '{800, 299, 1},
'{1000, 349, 8}, '{2000, 349, 8}, '{2200, 349, 9}};

//Debugging weird gaps
tile objects_Lvl3 [ObjectCount_Lvl3] = 
'{'{1000, 349, 0}, '{1050, 349, 1}};


// ---------- Updating spikes to move them -------

//With every frame clock we increase the x-offset.
//logic [15:0] offset;
logic [15:0] curr_x; //I feel like I accidentally set this 9:0 in some other module
logic [9:0] curr_y;
logic [3:0] curr_t;
logic signed [16:0] curr_x_signed;
logic signed [16:0] DrawX_signed, DrawY_signed;

assign DrawX_signed = $signed(DrawX);
assign DrawY_signed = $signed(DrawY);


    //Object motion (unconditional, applies to all objects in terrain)
    always_ff @(posedge frame_clk or posedge Reset) begin
    //Maybe we don't need to update SpikeX here then. Since we're updating it below tbh 
            if (Reset || in_home || game_over || game_won) begin
                offset <= 0;
                in_spaceship <= 0;
                portal_reg <= 0;
            end else begin
                offset <= offset + 5; //Normally 5
                portal_reg <= seen_spaceship_portal;
                if(seen_spaceship_portal && !portal_reg) 
                    in_spaceship <= ~in_spaceship;
            end
    end
 
 //Render + collision check
    always_comb begin
    
        //Remember that lvl_select is 0-indexed
        if(lvl_select == 1) begin
            ObjectCount = ObjectCount_Lvl2;
            lvlEnd = 5000;
        end else if(lvl_select == 2) begin
            ObjectCount = ObjectCount_Lvl3;
            lvlEnd = 2200;
        end else begin
            ObjectCount = ObjectCount_Lvl1;
            lvlEnd = 1050;
        end

        SpikeX = 0;
        SpikeY = 0;
        render_terrain = 0;
        object_type = 1'b0;
        seen_spaceship_portal = 0;
    
        collision_Y = 0; //Changed to 0 from 479
        collision_type = 0;

        //New signals -- to be created
        ceiling = 50;
        floor = 349;
        
        for(int i = 0; i < ObjectCount; i++) begin
            if(lvl_select == 1) begin
                 curr_x = objects_Lvl2[i].x; 
                 curr_y = objects_Lvl2[i].y;
                 curr_t = objects_Lvl2[i].t;
            end else if(lvl_select == 2) begin 
                 curr_x = objects_Lvl3[i].x; 
                 curr_y = objects_Lvl3[i].y;
                 curr_t = objects_Lvl3[i].t; 
            end else begin 
                 curr_x = objects_Lvl1[i].x; 
                 curr_y = objects_Lvl1[i].y;
                 curr_t = objects_Lvl1[i].t; 
            end
           
           // ----------------- 
           
            curr_x_signed = $signed(curr_x) - $signed(offset); 

            //"Can we render this object?" = Is it in the bounds of the screen?
            if(curr_x_signed >= $signed(30) && curr_x_signed <= $signed(639)) begin       

                //"Are we rendering this object?"
                //OH, this might be due to - 25 being huge!
                if ((DrawX) >= $unsigned(curr_x_signed[9:0] - 25) && (DrawX) < $unsigned(curr_x_signed[9:0] + 25)  && 
                (DrawY) >= (curr_y - 25) && (DrawY) < (curr_y + 25)) begin 
             
                    //You need to render this one, so give away the appropriate rom address
                    render_terrain = 1'b1;
                    SpikeX = curr_x_signed[9:0];
                    SpikeY = curr_y;
                    object_type = curr_t;
                end
                
                //"Could we possibly collide with it?"
                    //Check if any pixel is within the x bounds of our alien. Then, send the Y coodinate of the center.
                    //WILL it be in bounds in the next clock cycle -- so apply - 5 offset
                if(($signed(curr_x_signed - 5 - 25) >= 295 && $signed(curr_x_signed - 5 - 25) < 345) || 
                ($signed(curr_x_signed - 5 + 25) >= 295 && $signed(curr_x_signed - 5 + 25) < 345)) begin
                    if(curr_t == 8) begin
                        seen_spaceship_portal = 1;
                        //floor = 430;
                    end 

                    //The closest platform object (codes 1, 3) below/above you gets checked for new floor/ceiling each. So basically, 
                    //      absolute value of CharY - curr_y is minimized.
                    else if(curr_t == 1 || curr_t == 3) begin
                        //If the obstacle is below the current ceiling and above the character, its sets new ceiling
                        //Note that if the obstacle center is at ground level, we still need to set the ceiling
                        if(curr_y >= ceiling && curr_y + 25 <= CharY - 25) begin 
                            ceiling = curr_y + 51;
                        end else if(curr_y <= floor && curr_y - 25 >= CharY + 25) begin
                            floor = curr_y - 51; //Since we clamp to the top of platform, we need to pin the center to 25 above the top
                        end else begin
                            collision_Y = curr_y;
                            collision_type = curr_t;
                        end
                    end else begin
                        //floor = 349;

                    //The closest object to you PERIOD gets checked for game-ending collisions.
                        //This will keep collisions strictly 
                        if(curr_t == 0 && ($signed(curr_x_signed - 5 - 10) >= 295 && $signed(curr_x_signed - 5 - 10) < 345) || 
                        ($signed(curr_x_signed - 5 + 10) >= 295 && $signed(curr_x_signed - 5 + 10) < 345)) begin
                            collision_Y = curr_y;
                            collision_type = curr_t;
                        //end else begin
                        
                        end                        
                    
                    end

                end 

            end 
        end 
    end    

endmodule
