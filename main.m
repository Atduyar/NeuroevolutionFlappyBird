function main()
    % Game Parameters
    game_height = 128;    % Game area height (pixels)
    game_width = 128;     % Game area width (pixels)

	% note: fist pipe is on frame 17
	% note: there are 23 frame between pipes
	frame = 0;
    
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
	ai_birds_label = uicontrol('Style', 'text', 'String', 'Ai Bird Count: 0' , ...
		'Position', [game_width*4 + 20, 550, 150, 20]);
	ai_birds_slider = uicontrol('Style', 'slider', 'Min', 0, 'Max', 150, 'Value', ai_birds_count, ...
		'Position', [game_width*4 + 20, 530, 200, 20], 'Callback', @setAiBirdsCount);

	% range for max bird draw
	max_bird_draw = 151;
	max_bird_draw_label = uicontrol('Style', 'text', 'String', 'Max Bird Draw', ...
		'Position', [game_width*4 + 20, 505, 100, 20]);
	max_bird_draw_slider = uicontrol('Style', 'slider', 'Min', 1, 'Max', 151, 'Value', max_bird_draw, ...
		'Position', [game_width*4 + 20, 480, 200, 20], 'Callback', @setMaxBirdDraw);

	% toggle for skip drawing
	skip_draw = false;
	uicontrol('Style', 'checkbox', 'String', 'Skip Draw', ...
		'Position', [game_width*4 + 20, 450, 100, 20], 'Callback', @toggleSkipDraw);

	% Player toggle
	arePlayerPlaying = true;
	arePlayerPlaying_checkbox = uicontrol('Style', 'checkbox', 'String', 'Player Playing', 'Value', arePlayerPlaying, ...
		'Position', [game_width*4 + 20, 420, 100, 20], 'Callback', @togglePlayerPlaying);

	% auto replay
	auto_replay = false;
	auto_replay_checkbox = uicontrol('Style', 'checkbox', 'String', 'Auto Replay', 'Value', auto_replay, ...
		'Position', [game_width*4 + 20, 390, 100, 20], 'Callback', @toggleAutoReplay);

	% Birds List
	birds_list_label = uicontrol('Style', 'text', 'String', 'Birds List', ...
		'Position', [game_width*4 + 20, 360, 100, 20]);
	birds_list = uicontrol('Style', 'listbox', 'Position', [game_width*4 + 20, 160, 200, 200], 'String', {});

    % Create an Axes for the game area
    game_screen = axes('Units', 'pixels', 'Position', [10, 40, game_width*4, game_height*4]);
    axis off;
    hold on;

    % Initialize the Game State
    isRunning = true;
	gameOver = true;

	function setAiBirdsCount(~, ~)
		ai_birds_count = round(get(ai_birds_slider, 'Value'));
		set(ai_birds_label, 'String', ['Ai Bird Count: ', num2str(ai_birds_count)]);
	end
	function setMaxBirdDraw(~, ~)
		max_bird_draw = round(get(max_bird_draw_slider, 'Value'));
	end
	function toggleSkipDraw(~, ~)
		skip_draw = ~skip_draw;
	end
	function togglePlayerPlaying(~, ~)
		if gameOver == false
			set(arePlayerPlaying_checkbox, 'Value', arePlayerPlaying);
			msgbox('Can not change while game is running', 'Error', 'error');
			return;
		end
		arePlayerPlaying = ~arePlayerPlaying;
	end
	function toggleAutoReplay(~, ~)
		if arePlayerPlaying == false && ai_birds_count == 0
			set(auto_replay_checkbox, 'Value', auto_replay);
			msgbox('Can not change while no AI birds to play', 'Error', 'error');
			return;
		end
		auto_replay = ~auto_replay;
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
			% clear pipes
			for i = 1:length(pipes)
				pipes(i) = pipes(i).delete();
			end

			% clear birds
			for i = 1:length(birds)
				if birds(i).isDead == false
					birds(i) = birds(i).delete();
				end
			end

			% new Birds
			if arePlayerPlaying
				birds = [Bird(false, game_height/2)];
			else
				if ai_birds_count == 0
					msgbox('No AI birds to play', 'Error', 'error');
					return;
				end
				birds = [];
			end
			if ai_birds_count > 0 && arePlayerPlaying == false
				birds = [Bird(BirdBrain(true), game_height/2)];
				ai_birds_count -= 1;
			end
			for i = 1:ai_birds_count
				birds(end+1) = Bird(BirdBrain(true), game_height/2);
			end
			if ai_birds_count > 0 && arePlayerPlaying == false
				ai_birds_count += 1;
			end

			% new Pipes
			pipes = [Pipe(game_width/1.2, randi([16, 86]), game_height)];
			pipes(end+1) = Pipe(pipes(end).x + game_width*0.9, randi([16, 86]), game_height);
			pipes(end+1) = Pipe(pipes(end).x + game_width*0.9, randi([16, 86]), game_height);


			gameOver = false;
			frame = 0;
			set(jump_button, 'String', 'Jump');

			% first draw
			cla(game_screen);
			rectangle('Position', [0, 0, game_width, game_height], 'FaceColor', 'black');

			for i = 1:length(birds)
				birds(i) = birds(i).firstDraw();
			end
			for i = 1:length(pipes)
				pipes(i) = pipes(i).firstDraw();
			end
			if arePlayerPlaying
				% fix focus to game screen
				set(fig, 'CurrentAxes', game_screen);
			end

			% Don't show overflow
			axis([0, game_width, 0, game_height]);
			return;
		end

		% find player's bird
		theBird = find([birds.isAI] == false, true);
		if isempty(theBird) == false
			birds(theBird) = birds(theBird).jump();
		end
	end
	function printlog(s)
		disp(s);
	end

    % Game Loop
    function gameLoop()
        while isRunning
			if gameOver
				printlog('Game Over');
				if arePlayerPlaying
					pause(0.5);
				end
				if auto_replay
					jump();
				end
				continue;
			end
			
			% Update
			printlog('Update');
			updateScene();
			printlog('Update UI');
			updateUI();
			disp('Frame: ');
			disp(frame);
			frame += 1;

            % Draw the Game Scene
			if skip_draw
				continue;
			end
			printlog('Draw Scene');
            drawScene();
			drawnow;

            % Pause for Animation Effect
			if arePlayerPlaying
            	pause(0.024);
            	% pause(0.324);
			end
        end
    end

    % Function to Draw the Game Scene
    function drawScene()
        % No Clearing
		
		% Draw the Bird
		for i = 1:length(birds)
			if birds(i).isDead
				continue;
			end
			birds(i).draw();
		end
		
		% Draw the Pipes
		for i = 1:length(pipes)
			pipes(i).draw();
		end
    end

	function nextPipe = findNextPipe(pipes)
		nextPipe = pipes(1);
		for i = 1:length(pipes)
			if Bird.x - Bird.size < pipes(i).x + pipes(i).width && nextPipe.x > pipes(i).x
				nextPipe = pipes(i);
				break;
			end
		end
	end

	function updateScene()
		% Update birds position
		printlog('Update Birds');
		for i = 1:length(birds)
			birds(i) = birds(i).update();
		end

		% Update pipes
		printlog('Update Pipes');
		for i = 1:length(pipes)
			pipes(i) = pipes(i).update();
		end

		% Check pipes collision
		for i = 1:length(pipes)
			if pipes(i).x + pipes(i).width < 0
				pipes(i) = pipes(i).changePosition(pipes(i).x + game_width*0.9*3, randi([16, 86]));
			end
		end

		% Find the next pipe
		printlog('Find Next Pipe');
		nextPipe = findNextPipe(pipes);

		% Check collision
		printlog('Check Collision');
		for i = 1:length(birds)
			birds(i) = birds(i).checkCollision(nextPipe, game_height);
		end

		% if everyone is dead, game over
		printlog('Check Game Over');
		if all([birds.isDead])
			gameOver = true;
			updateUI();
			set(jump_button, 'String', 'Restart');
			return
		end
	end

	function updateUI()
		if mod(frame, 17) == 0
			birdListString = {}; % with score
			for i = 1:length(birds)
				if birds(i).isAI
					birdListString{end+1} = [' 🤖 AI: ', num2str(birds(i).score)];
				else
					birdListString{end+1} = ['*👤 Player: ', num2str(birds(i).score)];
				end
			end
			set(birds_list, 'String', sort(birdListString, 'descend'));
			% disp('Frame: ');
			% disp(frame);
		end
		% disp('Frame: ');
		% disp(frame);
	end

	gameLoop();
	disp('Game Over');
end
