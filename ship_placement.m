%All methods used for placing ships

%ship_placement class defined so multiple functions can be used from
%ship_placement
classdef ship_placement

    %Static methods (no object needed)
    methods (Static)

    %Check if selected coordinate is a valid placement
    function valid = isValidShipPlacement(r,c,p, board,shipType)
        water_sprite = 2;
    
        %Initialize to invalid space
        valid = true;
        
                    
            %If vertical ship, check below coordinate is in bounds
            if (p == 1)

                %If any part of ship is out of bounds, coordinate is
                %invalid
                if (r + (shipType - 1) > height(board))
                    valid = false;
                    return;
                end
                
                %If part of ship is overlapping with another, coordinate is
                %invalid
                for i = r:r+ (shipType - 1)

                    %If coordinate isn't water, ship is overlapping with
                    %another
                    if (board(i,c) ~= water_sprite)
                        valid = false;
                        return;
                    end
                end
                
            
            %If horizontal ship, check right of coordinate is in bounds
            elseif (p == 3)
                
                %If any part of ship is out of bounds, coordinate is
                %invalid
                if (c + (shipType - 1) > length(board))
                    valid = false;
                    return;
                end
                
                %If part of ship is overlapping with another, coordinate is
                %invalid
                for i = c:c+ (shipType - 1)

                    %If coordinate isn't water, ship is overlapping with
                    %another
                    if (board(r,i) ~= water_sprite)
                        valid = false;
                        return;
                    end
                end
                
            end
    end
    
    %Draw ships to board
    function board = drawShip(r,c,p, board, shipType)
        
        %left, horizontal, right, top, vertical, and bottom sprite codes
        left_ship_sprite = 3;
        horiz_ship_sprite = 4;
        right_ship_sprite = 5;
        top_ship_sprite = 6;
        vert_ship_sprite = 7;
        bot_ship_sprite = 8;
    
        %If vertical ship draw below coordinate
        if (p == 1)

            %Selected coordinate is top of ship
            board(r,c) = top_ship_sprite;

            %Loop through length of ship
            for i = r+1:r+(shipType - 1)

               %If bottom of ship, place bottom sprite
               if i == r+(shipType - 1)
                   board(i,c) = bot_ship_sprite;

               %Else place vertical sprite
               else
                   board(i,c) = vert_ship_sprite;
               end
            end
    
        %If horizontal ship draw to right of coordinate
        elseif (p == 3)
            
            %Selected coordinate is left of ship
            board(r,c) = left_ship_sprite;

            %Loop through length of ship
            for i = c+1:c+ (shipType - 1)

               %If right of ship place right sprite
               if i == c+(shipType - 1)
                   board(r,i) = right_ship_sprite;

               %Else place horizontal sprite
               else
                   board(r,i) = horiz_ship_sprite;
               end
            end
        end
    end
    
    %Get player ship placement
    function [board, r, c, p] = getShipPlacement(board, scene, shipType)
        
        %Get player mouse input
        [r,c,p]=getMouseInput(scene);
    
        %Get new input until placement is valid
        while ~ship_placement.isValidShipPlacement(r,c,p,board,shipType)
            %Get initial mouse input
            [r,c,p]=getMouseInput(scene);
        end 
        
        %Update board with new ship placement
        board = ship_placement.drawShip(r,c,p,board,shipType);
        
    end
    
    %Get cpu ship placement
    function [board, r, c, p] = getCPUPlacement(board,shipType)

        %Size of board constant
        SIZE = length(board);
        
        %Get random values for r and c within the board dimensions
        r =randi(SIZE);
        c = randi(SIZE);

        %Get random value 1-2 determining the orientation of the ship
        p = randi(2);

        %If orientationRand is 2, change to 3 (1 is vertical, 3 is
        %horizontal)
        if (p == 2)
            p = 3;
        end
        
        %Get new input until placement is valid
        while ~ship_placement.isValidShipPlacement(r,c,p,board,shipType)
            %Get random values for r and c within the board dimensions
            r = randi(SIZE);
            c = randi(SIZE);

            %Get random value 1-2 determining the orientation of the ship
            p = randi(2);
            
            %If orientationRand is 2, change to 3 (1 is vertical, 3 is
            %horizontal)
            if (p == 2)
                p = 3;
            end
        end
        
        %Update board with new ship placement
        board = ship_placement.drawShip(r,c,p,board,shipType);
    end
    
    %Place all ships (overloaded function using varagin/nargin)
    function [board, ships] =placeShips(varargin)
        
        %If 3 arguments are passed, use player ship placement
        if nargin==3
            %Argument 1 is the board
            board = varargin{1};
            %Argument 2 is the ships matrix
            ships = varargin{2};
            %Argument 3 is the board scene used for mouse input
            scene = varargin{3};
            
            %Number of ships is the number of rows in ships matrix
            numberOfShips = height(ships);
            
            %Loop through all player ships to place them
            for i = numberOfShips+1:-1:2

                %Add ship placement to board
                [board,r,c,p] = ship_placement.getShipPlacement(board, scene, i);

                %Draw board with new ship placed
                drawScene(scene,board);
                
                %Add ship row, column, and orientation to ship
                ships(i-1, 2) = r;
                ships(i-1, 3) = c;
                ships(i-1, 4) = p;
            end

            
        %If 2 arguments are passed, us cpu ship placement
        elseif nargin==2
            %Argument 1 is the board
            board = varargin{1};
            %Argument 2 is the ships matrix
            ships = varargin{2};
            
            %Number of ships is the number of rows in ships matrix
            numberOfShips = height(ships);
            

            %Loop through all cpu ships to place them
            for i = numberOfShips+1:-1:2
                %Add ship placement to board
                [board, r,c,p] = ship_placement.getCPUPlacement(board,i);
                
                %Add ship row, column, and orientation to ship
                ships(i -1,2) = r;
                ships(i -1,3) = c;
                ships(i -1,4) = p;
            end

        %If any number of arguments other than 2 or 3 are passed, report
        %error
        else
          error('placeShips accepts 2 or 3 input arguments!');
        end
    end
    end
end
    
    

