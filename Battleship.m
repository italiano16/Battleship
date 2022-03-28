%Main

%Clear command window and workspace
clear;
clc;

%Sprite map
blank_sprite = 1;
water_sprite = 2;
left_ship_sprite = 3;
horiz_ship_sprite = 4;
right_ship_sprite = 5;
top_ship_sprite = 6;
vert_ship_sprite = 7;
bot_ship_sprite = 8;
hit_sprite = 9;
miss_sprite = 10;

%Initialize board scene to Battleship.png with sprites 84x84
boardScene = simpleGameEngine('Battleship.png',84,84);

%Game loop runs until user exits game
while (1)
    %Start menu

    %Background of water
    startBackground = ones(5) * 2;

    %Foreground of blank sprites
    startForeground = ones(5);
    
    %Add sprites for title "Battleship"
    startForeground(2,2) = 21;
    startForeground(2,3) = 22;
    startForeground(2,4) = 23;
    
    %Add sprites for game difficulty selection "Easy", "Med", and "Hard"
    startForeground(4,2) = 19;
    startForeground(4,3) = 20;
    startForeground(4,4) = 24;
    
    %Draw scene of start menu with background and foreground
    drawScene(boardScene, startBackground,startForeground);

    %Get mouse input until it matches the coordinates of a game difficulty
    [r,c] = getMouseInput(boardScene);
    while(r ~= 4 || (c ~= 2 && c ~= 3 && c ~= 4))
        [r,c] = getMouseInput(boardScene);
    end
    
    %Easy mode (8x8, 4 ships, random guessing computer)
    if (c == 2)
        SIZE = 8;
        NUMBER_OF_SHIPS = 4;
        DIFFICULTY = 1;
    
    %Med mode (8x8, 5 ships, smart AI guessing)
    elseif (c == 3)
        SIZE = 8;
        NUMBER_OF_SHIPS = 5;
        DIFFICULTY = 2;

    %Hard Mode (12x12, 8 ships, smart AI guessing)
    else
        SIZE = 12;
        NUMBER_OF_SHIPS = 8;
        DIFFICULTY = 2;
    end
    
    %Initialize playerBoard and cpuBoard to empty water boards
    playerBoard = ones(SIZE) * 2;
    cpuBoard = ones(SIZE) * 2;

    %Initialze hideRightBoard to water, used to hide right side of board
    hideRightBoard = ones(SIZE) * 2;

    %1 columun divider of blank sprites
    divider = ones(SIZE,1);
    
    %Initialize playerShips and cpuShips (ship size, row, col, orientation, sunk)
    playerShips = zeros(NUMBER_OF_SHIPS, 5);
    cpuShips = zeros(NUMBER_OF_SHIPS, 5);
    
    %Initialize column 1 of playerShips and cpuShips to the ship sizes
    for i = 1:NUMBER_OF_SHIPS
        playerShips(i,1) = i + 1;
        cpuShips(i,1) = i + 1;
    end
    
    %Initialize playerHitMissBoard and cpuHitMissBoard to blank boards
    playerHitMissBoard = ones(SIZE,SIZE);
    cpuHitMissBoard = ones(SIZE,SIZE);
    
    %Display empty player board to choose spots for battleships
    drawScene(boardScene,playerBoard);
    
    %Display text to place ships
    placemessage="Place Your Battleships! (Left click vertical, Right click horizontal)";
    title(placemessage)
    
    %Place player ships
    [playerBoard, playerShips] = ship_placement.placeShips(playerBoard, playerShips, boardScene);
    
    %Place cpu ships
    [cpuBoard, cpuShips] = ship_placement.placeShips(cpuBoard, cpuShips);
    
    %Display text for game play
    title("Gameboard");

    %Combine playerBoard, divider and cpuBoard into one large board
    %This will not be displayed until after the game is over, but it will
    %be used to determine if ships are hit or missed
    combinedBoard = [playerBoard, divider, cpuBoard];

    %Combine playerBoard, divider, and hideRightBoard into one large board
    %This will be displayed until someone wins
    combinedHideBoard = [playerBoard, divider, hideRightBoard];

    %Combine playerHitMissBoard, divider, and cpuHitMissBoard into one
    %large board
    hitMissBoard = [playerHitMissBoard, divider, cpuHitMissBoard];
    
    %Draw the gameboard with only the combinedHideBoard and the
    %hitMissBoard
    drawScene(boardScene, combinedHideBoard,hitMissBoard);
    
    %Initialize the winner to none
    winner = "none";
    
    %Loop through the game until a winner is decided
    while (winner == "none")   

        %Player takes turn
        hitMissBoard = hit_miss.attemptAttack(combinedBoard,hitMissBoard,boardScene, 1, DIFFICULTY);
        %Draw result of player's turn
        drawScene(boardScene, combinedHideBoard, hitMissBoard);
        
        %Pause in between player and cpu turn
        tic
        pause(1/3-toc);
        
        %CPU takes turn
        hitMissBoard = hit_miss.attemptAttack(combinedBoard,hitMissBoard,boardScene, 0, DIFFICULTY);
        %Draw result of cpu's turn
        drawScene(boardScene, combinedHideBoard, hitMissBoard); 
    
        %Check how many player and cpu ships are sunk
        playerShips = hit_miss.checkSunkShips(hitMissBoard, playerShips, 1);
        cpuShips = hit_miss.checkSunkShips(hitMissBoard, cpuShips, 2);

        %Add all sunken cpu ships to combinedHideBoard
        combinedHideBoard = hit_miss.displaySunkenShips(combinedHideBoard,cpuShips);
        %Display resulting board
        drawScene(boardScene, combinedHideBoard, hitMissBoard); 
        
        %Check if a winner has been decided (all opponent ship's sunk)
        winner = hit_miss.checkWinner(playerShips,cpuShips);
    end
    
    %Print winner to the command window
    fprintf("Winner: %s", winner);
    
    %Initialize endBoard to empty board of size combined Board
    endBoard = [ones(SIZE, SIZE), divider, ones(SIZE, SIZE)];
    
    %Begin letter at 11 (G in the sprite map)
    letter = 11;

    %Starting position of Gameover message
    r = uint8(height(endBoard) / 2);
    c = uint8(length(endBoard) / 2) - 2;
    
    %For loop to iterate from first to second row
    for i = r:r + 1
        %For loop to iterate between columns 1-4
        for j = c:c+3
            %Set each (row,column) of endboard to the corresponding letter
            %with delay between each letter
            tic
            endBoard(i,j) = letter;
            letter = letter + 1;
    
            %Draw board with added letter
            drawScene(boardScene, combinedBoard, endBoard);
            pause(1/3-toc);
        end
    end
    
    %Delay at end of game before start menu reappears
    tic
    pause(3-toc);
end








