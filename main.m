function main()
	format short g;
	lastGameRestart = 0;
	bestAIBirdJson = '[{"layers":[5,9,2],"weights":[[-0.5583827824079658,-0.2988211403896029,-0.386702649856541,-0.9504104523872645,0.9389361145761433,-0.3676718674326874,0.9544810609186334,-0.7513021103759725,0.08048121029981299],[1.3160459105448,-0.29371027237881788,-0.9524890448550459,-0.18778376556540178,0.38280671281936376,-0.7500739421780187,0.1643807303389363,0.900827325505739,-0.3280171196028812],[-0.6598972499267223,-1.056894516902397,-0.7284795103335575,0.46594475317389857,1.1883192737476507,0.3747482263607729,-0.17460947418515347,0.5390102689763386,-0.8675945934187763],[1.4582986645843217,-0.09098226656379723,0.9468974613781983,-0.5736932728573363,-0.7035081627422504,-0.17137666186582618,0.9451247059873966,-0.21303256797869309,-0.8937541737453507],[-0.7539379168553761,0.9107914867522882,0.7743228538384911,1.2168076463967613,0.13367720601441919,0.4634627486458002,0.3280962297544553,0.34999129809328008,0.2988983295981611]],"biases":[-0.8407422875747013,-0.2705111226476535,0.8450341258086979,-0.07742641532267247,0.32944754536035139,-0.654293928598717,-0.3605190032392443,0.3866139151676028,1.5990584771538286]},{"layers":[5,9,2],"weights":[[0.7504816770811718,-0.16600689821846305],[0.6454273995056747,-0.21094781634149013],[-0.9279198994988704,0.2017182732942609],[0.1434175380881807,-0.07646250408658728],[0.4887263871588776,0.5937977217595856],[0.20061417614871464,-1.2273700566860014],[-0.24060202794513128,0.7783324915696585],[0.8886832567835391,0.41583259091594296],[-0.6287510611336326,-0.07688402249656587]],"biases":[0.25413336511068987,0.07217880720522044]}]';

    % Game Parameters
    game_height = 128;    % Game area height (pixels)
    game_width = 128;     % Game area width (pixels)

	% note: fist pipe is on frame 17
	% note: there are 23 frame between pipes
	frame = 0;
    
    % Initial States
	birds = [];
	newBirdBrains = {};
	% birds = [Bird(false, game_height/2)];
	% birds(end+1) = Bird(BirdBrain(true), game_height/2);

	pipes = [Pipe(game_width/1.2, randi([16, 86]), game_height)];
	pipes(end+1) = Pipe(pipes(end).x + game_width*0.9, randi([16, 86]), game_height);
	pipes(end+1) = Pipe(pipes(end).x + game_width*0.9, randi([16, 86]), game_height);

    % GUI Creation
    fig = figure('Name', 'Flappy Bird Game', ...
        'NumberTitle', 'off', 'MenuBar', 'none', ...
        'Resize', 'off', 'Position', [100, 100, game_width*4 + 235, 600]);
	set(fig, 'KeyPressFcn', @(src, event) keyPressHandler(event));

	% info text on top
	uicontrol('Style', 'text', 'String', 'Click on screen to focus. Press [Spcae] to Jump, [R] to Restart, [Q] to Quit', ...
		'Position', [10, 580, game_width*4 + 220, 20]);

	% Jump & Restart Button
	jump_button = uicontrol('Style', 'pushbutton', 'String', 'Restart', 'BackgroundColor', 'green', ...
		'Position', [10, 10, 80, 30], 'Callback', @jump);

	% Pause & Resume Button
	pause_game = false;
	pause_button = uicontrol('Style', 'pushbutton', 'String', 'Pause', ...
		'Position', [100, 10, 80, 30], 'Callback', @setPause);

	% range for number of birds
	ai_birds_count = 0;
	ai_birds_label = uicontrol('Style', 'text', 'String', 'Ai Bird Count: 0' , ...
		'Position', [game_width*4 + 20, 550, 150, 20]);
	ai_birds_slider = uicontrol('Style', 'slider', 'Min', 0, 'Max', 150, 'Value', ai_birds_count, ...
		'Position', [game_width*4 + 20, 530, 200, 20], 'Callback', @setAiBirdsCount);

	% player delay
	player_delay = 0.024;
	player_delay_label = uicontrol('Style', 'text', 'String', 'Playing Delay: 0.024' , ...
		'Position', [game_width*4 + 20, 505, 200, 20]);
	player_delay_slider = uicontrol('Style', 'slider', 'Min', 0, 'Max', 100, 'Value', player_delay*1000, ...
		'Position', [game_width*4 + 20, 480, 200, 20], 'Callback', @setPlayerDelay);

	% toggle for skip drawing
	skip_draw = false;
	uicontrol('Style', 'checkbox', 'String', 'Skip Draw', ...
		'Position', [game_width*4 + 20, 450, 200, 20], 'Callback', @toggleSkipDraw);

	% Player toggle
	arePlayerPlaying = true;
	arePlayerPlaying_checkbox = uicontrol('Style', 'checkbox', 'String', 'Player Playing', 'Value', arePlayerPlaying, ...
		'Position', [game_width*4 + 20, 420, 200, 20], 'Callback', @togglePlayerPlaying);

	% auto replay
	auto_replay = false;
	auto_replay_checkbox = uicontrol('Style', 'checkbox', 'String', 'Auto Replay', 'Value', auto_replay, ...
		'Position', [game_width*4 + 20, 390, 200, 20], 'Callback', @toggleAutoReplay);

	% Birds List
	birds_list_label = uicontrol('Style', 'text', 'String', 'Birds List', ...
		'Position', [game_width*4 + 20, 360, 200, 20]);
	birds_list = uicontrol('Style', 'listbox', 'Position', [game_width*4 + 20, 160, 200, 200], 'String', {}, ...
		'Callback', @showBirdBrain);

	% Quick Play buttons 
	uicontrol('Style', 'text', 'String', 'Quick Play', 'BackgroundColor', 'green', ...
		'Position',	[game_width*4 + 20, 130, 200, 20]);
	% Play solo
	uicontrol('Style', 'pushbutton', 'String', 'Play Solo', ...
		'Position', [game_width*4 + 20, 100, 200, 20], 'Callback', @quickPlaySolo);

	% Race with pre-trained AI
	uicontrol('Style', 'pushbutton', 'String', 'Player vs AI', ...
		'Position', [game_width*4 + 20, 70, 200, 20], 'Callback', @quickPlayAI);

	% Train AI
	uicontrol('Style', 'pushbutton', 'String', 'Train AI', ...
		'Position', [game_width*4 + 20, 40, 200, 20], 'Callback', @quickTrainAI);

	% Start Custom Game
	uicontrol('Style', 'pushbutton', 'String', 'Start Custom Game', ...
		'Position', [game_width*4 + 20, 10, 200, 20], 'Callback', @StartCustomGame);

	% Test Custom AI
	uicontrol('Style', 'pushbutton', 'String', 'Test Custom AI', ...
		'Position', [game_width*4 - 190, 10, 200, 20], 'Callback', @quickCustomAI);

    % Create an Axes for the game area
    game_screen = axes('Units', 'pixels', 'Position', [10, 40, game_width*4, game_height*4]);
    axis off;
    hold on;

    % Initialize the Game State
    isRunning = true;
	gameOver = true;

	function showBirdBrain(~, ~)
		% get the selected bird
		birds_list_arr = get(birds_list, 'String');
		selectedBird = get(birds_list, 'Value');
		if isempty(selectedBird)
			return;
		end
		selectedBird = selectedBird(1);
		% display(selectedBird);
		% display(birds_list_arr(selectedBird,1));
	

		birdScoreText = birds_list_arr(selectedBird,1);
		% string not contains # then it is player
		if isempty(strfind(birdScoreText{1}, '#'))
			return;
		end
		birdId = str2num(birdScoreText{1}(strfind(birdScoreText{1}, '#')+1:end));
		% display(birdId);
		if birdId > length(birds)
			return;
		end
		if birds(birdId).isAI == false
			return;
		end
		% show the neural network
		birds(birdId).popUpWindow(fig);
	end

	% quick plays
	function quickPlaySolo(~, ~)
		auto_replay = false;
		updateUIValues();
		restart("solo");
	end
	function quickPlayAI(~, ~)
		auto_replay = false;
		updateUIValues();
		restart("best");
	end
	function quickTrainAI(~, ~)
		auto_replay = true;
		updateUIValues();
		restart("train");
	end
	function StartCustomGame(~, ~)
		updateUIValues();
		restart();
	end
	function quickCustomAI(~, ~)
		restart("custom");
	end

	function setPause(~, ~)
		if gameOver
			return;
		end
		pause_game = ~pause_game;
		updateUIValues();
	end
	function setAiBirdsCount(~, ~)
		ai_birds_count = round(get(ai_birds_slider, 'Value'));
		updateUIValues();
	end
	function setPlayerDelay(~, ~)
		player_delay = get(player_delay_slider, 'Value')/1000;
		updateUIValues();
	end
	function toggleSkipDraw(~, ~)
		skip_draw = ~skip_draw;
	end
	function togglePlayerPlaying(~, ~)
		if gameOver == false
			updateUIValues();
			msgbox('Can not change while game is running', 'Error', 'error');
			return;
		end
		arePlayerPlaying = ~arePlayerPlaying;
	end
	function toggleAutoReplay(~, ~)
		if arePlayerPlaying == false && ai_birds_count == 0
			updateUIValues();
			msgbox('Can not change while no AI birds to play', 'Error', 'error');
			return;
		end
		auto_replay = ~auto_replay;
	end
	function updateUIValues()
		set(ai_birds_slider, 'Value', ai_birds_count);
		set(ai_birds_label, 'String', ['Ai Bird Count: ', num2str(ai_birds_count)]);
		set(player_delay_slider, 'Value', player_delay*1000);
		set(player_delay_label, 'String', ['Playing Delay: ', num2str(player_delay)]);
		set(arePlayerPlaying_checkbox, 'Value', arePlayerPlaying);
		set(auto_replay_checkbox, 'Value', auto_replay);
		if pause_game
			set(pause_button, 'String', 'Resume');
			set(pause_button, 'BackgroundColor', 'red');
		else
			set(pause_button, 'String', 'Pause');
			set(pause_button, 'BackgroundColor', 'default');
		end
	end

    function keyPressHandler(event)
        switch event.Key
            case 'space'
				jump();
            case 'r'
				makeGameOver();
				restart(lastGameRestart);
			case 'q'
				isRunning = false;
        end
    end

	function cleanup()
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

		birds = [];
		pipes = [];
	end

	function createPipe()
		% new Pipes
		pipes = [Pipe(game_width/1.2, randi([16, 86]), game_height)];
		pipes(end+1) = Pipe(pipes(end).x + game_width*0.9, randi([16, 86]), game_height);
		pipes(end+1) = Pipe(pipes(end).x + game_width*0.9, randi([16, 86]), game_height);
	end

	function createPlayerBird()
		if isempty(birds)
			birds = [Bird(false, game_height/2)];
		else
			birds(end+1) = Bird(false, game_height/2);
		end
	end

	function createAIBird(n_ai_birds)
		useNewBrains = false;
		if isempty(newBirdBrains) == false && length(newBirdBrains) == n_ai_birds
			useNewBrains = true;
		end

		for i = 1:n_ai_birds
			tmpBrain = 0;
			if useNewBrains
				tmpBrain = newBirdBrains{i};
			else
				tmpBrain = BirdBrain(true);
			end

			if isempty(birds)
				birds = [Bird(tmpBrain, game_height/2)];
			else
				birds(end+1) = Bird(tmpBrain, game_height/2);
			end
		end
	end

	function restart(resetType=0)
		lastGameRestart = resetType;

		figure(fig);
		cleanup();

		switch resetType
			case "solo"
				ai_birds_count = 0;
				arePlayerPlaying = true;
				updateUIValues();
				createPlayerBird();
			case "best"
				ai_birds_count = 1;
				arePlayerPlaying = true;
				updateUIValues();
				display('Best AI');
				birds = [Bird(BirdBrain(bestAIBirdJson), game_height/2)]; % best AI
				createPlayerBird();
			case "train"
				ai_birds_count = 150;
				arePlayerPlaying = false;
				updateUIValues();
				createAIBird(ai_birds_count);
			case "custom"
				ai_birds_count = 1;
				arePlayerPlaying = false;
				updateUIValues();
				customAIJson = inputdlg('Enter AI Json', 'Custom AI', [1 50], {bestAIBirdJson});
				disp("Custom AI: ");
				display(customAIJson);
				birds = [Bird(BirdBrain(customAIJson{1}), game_height/2)];
			case 0
				if ai_birds_count == 0 && arePlayerPlaying == false
					msgbox('No birds to play', 'Error', 'error');
					return;
				end
				if ai_birds_count > 0
					createAIBird(ai_birds_count);
				end
				if arePlayerPlaying
					createPlayerBird();
				end
			otherwise
		end

		createPipe();

		gameOver = false;
		pause_game = false;
		frame = 0;
		if arePlayerPlaying
			pause_game = true;
			set(jump_button, 'BackgroundColor', 'green');
			set(jump_button, 'String', 'Start');
		else
			set(jump_button, 'BackgroundColor', 'default');
			set(jump_button, 'String', 'Restart');
		end
		updateUIValues();

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

		updateUI();

		% Don't show overflow
		axis([0, game_width, 0, game_height]);
		return;
	end

    % Function to Start or Jump
    function jump(~, ~)
		% restart
		if gameOver
			restart(lastGameRestart);
			return;
		end
		if arePlayerPlaying == false
			restart(lastGameRestart);
		end
		if pause_game
			pause_game = ~pause_game;
			set(jump_button, 'String', 'Jump');
			set(jump_button, 'BackgroundColor', 'default');
			updateUIValues();
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
				if ~auto_replay || player_delay ~= 0
					pause(0.1);
				end
				if auto_replay
					restart();
				end
				continue;
			end
			if pause_game
				pause(0.1);
				continue;
			end
			
			% Update
			updateScene();
			updateUI();
			frame += 1;

            % Draw the Game Scene
			if skip_draw
				if mod(frame, 20) == 0 % for button press to work
					pause(0.01);
				end
				continue;
			end
            drawScene();
			drawnow;

            % Pause for Animation Effect
			if arePlayerPlaying
            	pause(player_delay);
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
		% Update pipes
		% printlog('Update Pipes');
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
		% printlog('Find Next Pipe');
		nextPipe = findNextPipe(pipes);

		% Update birds position
		% printlog('Update Birds');
		for i = 1:length(birds)
			birds(i) = birds(i).update(nextPipe, game_width);
		end

		% Check collision
		% printlog('Check Collision');
		for i = 1:length(birds)
			birds(i) = birds(i).checkCollision(nextPipe, game_height, frame);
		end

		% if everyone is dead, game over
		% printlog('Check Game Over');
		if all([birds.isDead])
			makeGameOver();
			updateUI();
			return
		end
	end

	function updateUI()
		if mod(frame, 17) == 0
			birdListString = {}; % with score
			scoreSize = num2str(length(num2str(max([birds.score]))));
			formatForScroe = ['%0', scoreSize, 'd'];
			for i = 1:length(birds)
				if birds(i).isAI
					birdListString{end+1} = [' 🤖 AI: ', num2str(birds(i).score, formatForScroe), '    #', num2str(i)];
				else
					birdListString{end+1} = ['*👤 Player: ', num2str(birds(i).score, formatForScroe)];
				end
			end
			set(birds_list, 'String', sort(birdListString, 'descend'));
		end
		% disp('Frame: ');
		% disp(frame);
	end

	function makeGameOver()
		gameOver = true;
		set(jump_button, 'BackgroundColor', 'green');
		set(jump_button, 'String', 'Restart');
		pause_game = false;
		set(pause_button, 'String', 'Pause');
		set(pause_button, 'BackgroundColor', 'default');
		if arePlayerPlaying
			return;
		end

		% find fitness value
		sumScore = sum([birds.lifetime]);

		newBirdBrains = {};

		% create new birds
		for i = 1:ai_birds_count
			% choose new birds parent
			randomFitness = rand() * sumScore;
			% diplay type
			parentIndex = 1;
			while randomFitness > 0
				randomFitness = randomFitness - birds(parentIndex).lifetime;
				parentIndex += 1;
			end
			parentIndex -= 1;
			% display(parentIndex);
			parent = birds(parentIndex);
			newBirdBrains{end+1} = BirdBrain(parent);
			% display(parent.brain.nn.weights{1}(1,2));
			% display(newBirdBrains{end}.nn.weights{1}(1,2));
		end
		% display(newBirdBrains);
	end

	gameLoop();
	disp('Game Over');
end
