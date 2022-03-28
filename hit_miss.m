%All methods for gameplay

%hit_miss class defined so multiple functions can be used from hit_miss
classdef hit_miss

    %Static methods (no object needed)
    methods (Static)
        
        %Get a valid attack for the player
        function [r,c] = getValidAttack(board, hitMissBoard, scene)
            %Blank sprite code
            blank_sprite = 1;
            
            %Initialize valid to false
            valid = false;
            
            %Get a new mouse input until the coordinates are valid
            while (~valid)
                %Get mouse input
                [r,c] = getMouseInput(scene);

                %If the mouse input is on the cpu's side of the board
                %and the coordinates haven't already been guessed, the
                %attack is valid
                if (c > (length(board) / 2 ) + 1 && hitMissBoard(r,c) == blank_sprite)
                    valid = true;
                end
            end
        end
        
        %Get a valid attack for the CPU
        function [r,c] = getValidCPUAttack(board, hitMissBoard, difficulty)
            %Blank sprite code
            blank_sprite = 1;
            
            %Initialize valid to false
            valid = false; 
            
            %Get a new mouse input until the coordinates are valid
            while(~valid)
                
                %If easy difficulty, get random coordinates on player side
                %of the board
                if (difficulty == 1)
                    r = randi(height(board));
                    c = randi(length(board));
                
                %If med or hard difficulty, get next best attack on player
                %side
                else
                    [r,c] = hit_miss.getNextBestAttack(hitMissBoard);
                end
                
                %If the mouse input is on the player's side of the board
                %and the coordinates haven't already been guessed, the
                %attack is valid
                if (c < floor(length(board) / 2 + 1) && hitMissBoard(r,c) == blank_sprite)
                    valid = true;
                end
            end
        end
        
        %Get next best cpu attack
        function [nextBestR,nextBestC] = getNextBestAttack(hitMissBoard)
            %Hit and miss sprite codes
            hit_sprite = 9;
            miss_sprite = 10;
            
            %Initialize ratings to zeros the size of the player's side of
            %the board
            ratings = zeros(height(hitMissBoard),uint8(length(hitMissBoard)/ 2 - 1));
            
            %Loop through every spot on the player's side of the board
            for i = 1:height(ratings)
                for j = 1:length(ratings)

                    %If this coordinate has been guessed, it will have a
                    %rating of 0
                    if (hitMissBoard(i,j) == hit_sprite ...
                            ||hitMissBoard(i,j) == miss_sprite)
                        ratings(i,j) = 0;

                    %Else check all spots surrounding the coordinate to the
                    %right, left, top, and bottom (exclude corners)
                    else
                        %-1:1 is relative to current coordinate
                        for k = -1:1
                            for n = -1:1
                                %If either k or n is 0, then it is not on a
                                %corner
                                if (k == 0 || n == 0)

                                    %Add k and n to i and j to get
                                    %relative coordinate
                                    r = i + k;
                                    c = j + n;
                                    
                                    %If r and c are valid coordinates on
                                    %the player side of the board and the
                                    %coordinate is a hit, add 1 to the
                                    %ratings of this coordinate
                                    if ((r > 0 && r < height(ratings) + 1) ...
                                        && (c > 0 && c < length(ratings) + 1) ...
                                        && hitMissBoard(r,c) == hit_sprite)
                                        
                                        %Add 1 to ratings(i,j)
                                        ratings(i,j) = ratings(i,j) + 1;
                                    end
                                end
                                
                            end
                        end
                    end
                end
            end
            
            %Initialize next best rating to 0
            nextBest = 0;

            %Initialize next best row and column to random values on the
            %player's side of the board
            nextBestR = randi(height(hitMissBoard));
            nextBestC = randi(length(hitMissBoard));
            
            %Find the highest rating in ratings (top to bottom left to 
            %right if same)
            for i = 1:height(ratings)
                for j = 1:length(ratings)

                    %If ratings at this coordinate is better than the
                    %next best rating, set this coordinate to the next best
                    %rating
                    if (ratings(i,j) > nextBest)
                        nextBest = ratings(i,j);
                        nextBestR = i;
                        nextBestC = j;
                    end
                end
            end

            


        end
        
        %Check if spot is a hit
        function hit = isHit(r,c,board)
            %Water sprite code
            water_sprite = 2;
            
            %Initialize hit to false
            hit = false;
            
            %If sprite at coordinate (r,c) is not water, it is a hit
            if (board(r,c) ~= water_sprite)
                hit = true;
            end
        end
        
        %Attempt attack
        function hitMissBoard = attemptAttack(board, hitMissBoard, scene, player, difficulty)
            %Hit and miss sprite codes
            hit_sprite = 9;
            miss_sprite = 10;
            
            %Player 1 is player player 2 is cpu
            if (player == 1)

                %Get valid player attack
                [r,c] = hit_miss.getValidAttack(board,hitMissBoard, scene);
            else

                %Get valid cpu attack
                [r,c] = hit_miss.getValidCPUAttack(board, hitMissBoard, difficulty);
            end

            %Check if guess is a hit or a miss
            if (hit_miss.isHit(r,c,board))

                %Add hit sprite to hitMissBoard at coordinate (r,c)
                hitMissBoard(r,c) = hit_sprite;
            else 

                %Add miss sprite to hitMissBoard at coordinate (r,c)
                hitMissBoard(r,c) = miss_sprite;
            end
        end
        
        %Check for sunken ships
        function ships = checkSunkShips(hitMissBoard, ships, player)
            %Hit sprite code
            hit_sprite = 9;
            
            %Initialize offset to 0
            offset = 0;
            
            %If player is cpu, set offset to the integer value of half the
            %board (no decimals)
            if (player == 2)
                offset = (uint8((length(hitMissBoard) / 2)));
            end
            
            %Loop through all ships
            for i = 1:height(ships)
                %Initialize shipSunk to true
                shipSunk = true;
                
                %Get r, c, and p values of current ship
                r = ships(i,2);
                c = ships(i,3) + offset;
                p = ships(i,4);
                
                %Get ship length of current ship
                shipLength = ships(i,1);
                
                %If vertical ship, check entire ship below (r,c)
                if (p == 1)

                    %Loop from r value to end of ship (r + shipLength - 1)
                    for j = r:r + (shipLength-1)

                        %If any part of the ship isn't hit, shipSunk is
                        %false
                        if (hitMissBoard(j, c) ~= hit_sprite)
                            shipSunk = false;
                        end
                    end
                
                %If horizontal ship, check entire ship to right of (r,c)
                elseif (p == 3)

                    %Loop from c value to end of ship (c + shipLength - 1)
                    for j = c:c + (shipLength-1)

                        %If any part of the ship isn't hit, shipSunk is
                        %false
                        if (hitMissBoard(r, j) ~= hit_sprite)
                            shipSunk = false;
                        end
                    end
                end
                
                %If ship is sunk, update ships matrix to reflect that
                if (shipSunk)
                    ships(i,5) = 1;
                end

            end

        end
        
        %Add sunken ships to board
        function board = displaySunkenShips(board, ships)

            %Loop through all ships
            for i =1:height(ships)

                %If ship is sunk add it to the board
                if (ships(i,5) == 1)
                    
                    %Get ship type (length)
                    shipType = ships(i,1);

                    %Get ship r, c, and p
                    r = ships(i,2);
                    c = ships(i,3) + uint8(length(board) / 2);
                    p = ships(i,4);

                    %Add ship to board
                    board = ship_placement.drawShip(r,c,p,board,shipType);
                end
            end
        end
        
        %Check if a winner has been decided (all oponent ships sunk)
        function winner = checkWinner(playerShips, cpuShips)
            
            %Initialize winner to none
            winner = "none";
            
            %Initialize player and cpu sunk ships count to 0
            playerSunkCount = 0;
            cpuSunkCount = 0;
            
            %Loop through all player and cpu ships
            for i = 1:height(playerShips)

                %If player ship is sunk, add 1 to playerSunkCount
                if (playerShips(i,5) == 1)
                    playerSunkCount = playerSunkCount + 1;
                end

                %If cpu ship is sunk, add 1 to cpuSunkCount
                if (cpuShips(i,5) == 1)
                    cpuSunkCount = cpuSunkCount + 1;
                end
            end
            
            %If all cpu ships are sunk, player wins
            if (cpuSunkCount == height(cpuShips))
                winner = "Player";

            %If all player ships are sunk, cpu wins
            elseif (playerSunkCount == height(playerShips))
                winner = "CPU";
            end
        end
    end
end