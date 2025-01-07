function main()
    % Game Parameters
    game_height = 128;    % Game area height (pixels)
    game_width = 128;     % Game area width (pixels)
    
    % Initial States
	birds = [];
	% birds = [Bird(false, game_height/2)];
	% birds(end+1) = Bird(BirdBrain(true), game_height/2);

	pipes = [Pipe(game_width/1.2, randi([16, 86]), game_height)];
	pipes(end+1) = Pipe(pipes(end).x + game_width*0.9, randi([16, 86]), game_height);
	pipes(end+1) = Pipe(pipes(end).x + game_width*0.9, randi([16, 86]), game_height);

    % GUI Creation
    fig = figure('Name', 'Flappy Bird Game', ...
        'NumberTitle', 'off', 'MenuBar', 'none', ...
        'Resize', 'off', 'Position', [100, 100, 800, 600]);

	jump_button = uicontrol('Style', 'pushbutton', 'String', 'Jump', ...
		'Position', [10, 10, 80, 30], 'Callback', @jump);
	set(fig, 'KeyPressFcn', @(src, event) keyPressHandler(event));

    % Create a Listbox to display the score
    % listbox_handle = uicontrol('Style', 'listbox', 'Position', [10, 10, 100, 180], ...
    %     'String', {'Score: 0'}, 'Tag', 'listbox');

	% range for number of birds
	ai_birds_count = 0;
	uicontrol('Style', 'text', 'String', 'Ai Bird Count', ...
		'Position', [game_width*4 + 20, 550, 100, 20]);
	ai_birds_slider = uicontrol('Style', 'slider', 'Min', 0, 'Max', 150, 'Value', ai_birds_count, ...
		'Position', [game_width*4 + 20, 530, 200, 20], 'Callback', @setAiBirdsCount);

	% range for max bird draw
	max_bird_draw = 10;
	uicontrol('Style', 'text', 'String', 'Max Bird Draw', ...
		'Position', [game_width*4 + 20, 505, 100, 20]);
	max_bird_draw_slider = uicontrol('Style', 'slider', 'Min', 1, 'Max', 151, 'Value', max_bird_draw, ...
		'Position', [game_width*4 + 20, 480, 200, 20], 'Callback', @setMaxBirdDraw);

	% toggle for skip drawing
	skip_draw = false;
	uicontrol('Style', 'checkbox', 'String', 'Skip Draw', ...
		'Position', [game_width*4 + 20, 450, 100, 20], 'Callback', @toggleSkipDraw);

	% Player toggle
	arePlayerPlaying = true;
	uicontrol('Style', 'checkbox', 'String', 'Player Playing', 'Value', arePlayerPlaying, ...
		'Position', [game_width*4 + 20, 420, 100, 20], 'Callback', @togglePlayerPlaying);


    % Create an Axes for the game area
    game_screen = axes('Units', 'pixels', 'Position', [10, 40, game_width*4, game_height*4]);
    axis off;
    hold on;

    % Initialize the Game State
    isRunning = true;
	gameOver = true;

	function setAiBirdsCount(~, ~)
		ai_birds_count = round(get(ai_birds_slider, 'Value'));
	end
	function setMaxBirdDraw(~, ~)
		max_bird_draw = round(get(max_bird_draw_slider, 'Value'));
	end
	function toggleSkipDraw(~, ~)
		skip_draw = ~skip_draw;
	end
	function togglePlayerPlaying(~, ~)
		arePlayerPlaying = ~arePlayerPlaying;
	end

    function keyPressHandler(event)
        switch event.Key
            case 'space'
				jump();
            case 'r'
                gameOver = true;
				jump();
			case 'q'
				isRunning = false;
        end
    end

    % Function to Start or Jump
    function jump(~, ~)
		% restart
		if gameOver
			if arePlayerPlaying
				birds = [Bird(false, game_height/2)];
			else
				if ai_birds_count == 0
					msgbox('No AI birds to play', 'Error', 'error');
					return;
				end
				birds = [];
			end
			if ai_birds_count > 0
				birds = [Bird(BirdBrain(true), game_height/2)];
				for i = 1:ai_birds_count-1
					birds(end+1) = Bird(BirdBrain(true), game_height/2);
				end
			end
			pipes = [Pipe(game_width/1.2, randi([16, 86]), game_height)];
			pipes(end+1) = Pipe(pipes(end).x + game_width*0.9, randi([16, 86]), game_height);
			pipes(end+1) = Pipe(pipes(end).x + game_width*0.9, randi([16, 86]), game_height);
			gameOver = false;
			set(jump_button, 'String', 'Jump');
		end

		% find player's bird
		theBird = find([birds.isAI] == false, true);
		if isempty(theBird) == false
			birds(theBird) = birds(theBird).jump();
		end
	end

    % Game Loop
    function gameLoop()
        while isRunning
			if gameOver
				pause(0.1);
				drawScene();
				continue;
			end
			% Update
			updateScene();

            % Draw the Game Scene
			if skip_draw
				continue;
			end
            drawScene();
			drawnow;

            % Pause for Animation Effect
            % pause(0.02);
        end
    end

    % Function to Draw the Game Scene
    function drawScene()
        % Clear
		% cla(game_screen);
		rectangle('Position', [0, 0, game_width, game_height], 'FaceColor', 'black');
		
		% Draw the Bird
		% for i = 1:2
		drawCount = 0;
		for i = 1:length(birds)
			if birds(i).isDead || drawCount >= max_bird_draw
				continue;
			end
			drawCount += 1;
			birds(i).draw();
			% birds(i) = birds(i).draw();
		end
		
		% Draw the Pipes
		for i = 1:length(pipes)
			% if pipes(i).x > game_width
			% 	continue;
			% end
			if pipes(i).x + pipes(i).width < 0
				pipes(i) = Pipe(pipes(i).x + game_width*0.9*3, randi([16, 86]), game_height);
			end
			pipes(i) = pipes(i).draw();
		end

		% Don't show overflow
		axis([0, game_width, 0, game_height]);
    end

	function updateScene()
		% Update birds position
		for i = 1:length(birds)
			birds(i) = birds(i).update();
		end

		% Update pipes
		for i = 1:length(pipes)
			pipes(i) = pipes(i).update();
		end

		% Check collision
		for i = 1:length(birds)
			birds(i) = birds(i).checkCollision(pipes, game_height);
		end

		% if everyone is dead, game over
		if all([birds.isDead])
			gameOver = true;
			set(jump_button, 'String', 'Restart');
			return
		end
	end

	gameLoop();
	disp('Game Over');
end
