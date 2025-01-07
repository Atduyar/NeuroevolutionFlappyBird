% test.m - Main game file
function test()
  % Constants
  TOTAL = 500;
  GAME_HEIGHT = 480;
  GAME_WIDTH = 960;
  
  % Initialize figure and main UI
  f = figure('Position', [100 100 GAME_WIDTH 784], ...
             'Name', 'Flappy Bird Neural Evolution', ...
             'MenuBar', 'none', ...
             'NumberTitle', 'off');
             
  % Create game canvas
  ax = axes('Units', 'pixels', ...
           'Position', [0 304 GAME_WIDTH-320 GAME_HEIGHT], ...
           'XLim', [0 GAME_WIDTH-320], ...
           'YLim', [0 GAME_HEIGHT]);
  hold(ax, 'on');
  
  % Create UI controls
  uicontrol('Style', 'slider', ...
           'Position', [10 260 200 20], ...
           'Min', 1, 'Max', 100, 'Value', 1, ...
           'Callback', @speedSliderCallback);
           
  uicontrol('Style', 'pushbutton', ...
           'Position', [220 260 80 20], ...
           'String', 'Start/Stop', ...
           'Callback', @startStopCallback);
           
  uicontrol('Style', 'pushbutton', ...
           'Position', [310 260 80 20], ...
           'String', 'Save', ...
           'Callback', @saveCallback);
           
  uicontrol('Style', 'pushbutton', ...
           'Position', [400 260 80 20], ...
           'String', 'Load', ...
           'Callback', @loadCallback);
           
  % Neural network visualization panel
  nn_panel = uipanel('Position', [0.67 0 0.33 1]);
  
  % Game state variables
  gameState.birds = initBirds(TOTAL);
  gameState.pipes = [];
  gameState.counter = 0;
  gameState.generation = 0;
  gameState.running = false;
  gameState.speed = 1;
  
  % Main game timer
  gameTimer = timer('ExecutionMode', 'fixedRate', ...
                    'Period', 0.033, ...  % ~30 FPS
                    'TimerFcn', @(~,~) gameLoop());
  start(gameTimer);
  
  % Game loop function
  function gameLoop()
    if ~gameState.running
      return;
    end
    
    for s = 1:gameState.speed
      % Add new pipe
      if mod(gameState.counter, 75) == 0
        gameState.pipes = [gameState.pipes; createPipe()];
      end
      gameState.counter = gameState.counter + 1;
      
      % Update pipes
      for i = length(gameState.pipes):-1:1
        gameState.pipes(i) = updatePipe(gameState.pipes(i));
        
        % Check collisions
        for j = length(gameState.birds):-1:1
          if ~gameState.birds(j).dead && checkCollision(gameState.birds(j), gameState.pipes(i))
            gameState.birds(j).dead = true;
          end
        end
        
        % Remove offscreen pipes
        if gameState.pipes(i).x < -gameState.pipes(i).width
          gameState.pipes(i) = [];
        end
      end
      
      % Update birds
      for i = length(gameState.birds):-1:1
        if ~gameState.birds(i).dead
          gameState.birds(i) = updateBird(gameState.birds(i), gameState.pipes);
        end
      end
      
      % Check if all birds are dead
      if allBirdsDead()
        nextGeneration();
      end
    end
    
    % Redraw everything
    drawGame();
  end
  
  % Helper functions
  function birds = initBirds(count)
    birds = [];
    for i = 1:count
      bird.x = 64;
      bird.y = GAME_HEIGHT / 2;
      bird.velocity = 0;
      bird.gravity = 0.8;
      bird.lift = -12;
      bird.score = 0;
      bird.fitness = 0;
      bird.dead = false;
      bird.brain = createNeuralNetwork();
      bird.color = rand(1,3);  % Random RGB color
      birds = [birds; bird];
    end
  end
  
  function pipe = createPipe()
    pipe.spacing = 125;
    pipe.top = rand() * (3/4 * GAME_HEIGHT - GAME_HEIGHT/6) + GAME_HEIGHT/6;
    pipe.bottom = GAME_HEIGHT - (pipe.top + pipe.spacing);
    pipe.x = GAME_WIDTH - 320;
    pipe.width = 80;
    pipe.speed = 6;
  end
  
  function pipe = updatePipe(pipe)
    pipe.x = pipe.x - pipe.speed;
  end
  
  function collision = checkCollision(bird, pipe)
    if bird.y < pipe.top || bird.y > GAME_HEIGHT - pipe.bottom
      if bird.x > pipe.x && bird.x < pipe.x + pipe.width
        collision = true;
        return;
      end
    end
    collision = false;
  end
  
  function bird = updateBird(bird, pipes)
    % Find closest pipe
    closestPipe = findClosestPipe(bird, pipes);
    
    % Neural network thinking
    inputs = getBirdInputs(bird, closestPipe);
    outputs = predict(bird.brain, inputs);
    
    if outputs(1) > outputs(2)
      bird.velocity = bird.velocity + bird.lift;
    end
    
    % Physics update
    bird.velocity = bird.velocity + bird.gravity;
    bird.y = bird.y + bird.velocity;
    
    % Check bounds
    if bird.y > GAME_HEIGHT || bird.y < 0
      bird.dead = true;
    end
    
    bird.score = bird.score + 1;
  end
  
  function inputs = getBirdInputs(bird, pipe)
    inputs = zeros(1, 5);
    inputs(1) = bird.y / GAME_HEIGHT;
    if ~isempty(pipe)
      inputs(2) = pipe.top / GAME_HEIGHT;
      inputs(3) = pipe.bottom / GAME_HEIGHT;
      inputs(4) = (pipe.x - bird.x) / (GAME_WIDTH - 320);
    end
    inputs(5) = bird.velocity / 10;
  end
  
  function closest = findClosestPipe(bird, pipes)
    closest = [];
    closestD = Inf;
    for i = 1:length(pipes)
      d = (pipes(i).x + pipes(i).width) - bird.x;
      if d < closestD && d > 0
        closest = pipes(i);
        closestD = d;
      end
    end
  end
  
  function dead = allBirdsDead()
    dead = true;
    for i = 1:length(gameState.birds)
      if ~gameState.birds(i).dead
        dead = false;
        return;
      end
    end
  end
  
  function nextGeneration()
    % Calculate fitness
    totalScore = 0;
    for i = 1:length(gameState.birds)
      totalScore = totalScore + gameState.birds(i).score;
    end
    
    for i = 1:length(gameState.birds)
      gameState.birds(i).fitness = gameState.birds(i).score / totalScore;
    end
    
    % Create new generation
    newBirds = initBirds(TOTAL);
    for i = 1:TOTAL
      parent = pickParent(gameState.birds);
      newBirds(i).brain = mutateBrain(parent.brain);
    end
    
    gameState.birds = newBirds;
    gameState.pipes = [];
    gameState.counter = 0;
    gameState.generation = gameState.generation + 1;
  end
  
  function drawGame()
    cla(ax);
    
    % Draw pipes
    for i = 1:length(gameState.pipes)
      drawPipe(gameState.pipes(i));
    end
    
    % Draw birds
    for i = 1:length(gameState.birds)
      if ~gameState.birds(i).dead
        drawBird(gameState.birds(i));
      end
    end
    
    % Update stats
    title(sprintf('Generation: %d, Alive: %d', ...
          gameState.generation, ...
          sum(~[gameState.birds.dead])));
  end
  
  function drawPipe(pipe)
    rectangle('Position', [pipe.x 0 pipe.width pipe.top], ...
             'FaceColor', 'g');
    rectangle('Position', [pipe.x GAME_HEIGHT-pipe.bottom pipe.width pipe.bottom], ...
             'FaceColor', 'g');
  end
  
  function drawBird(bird)
    rectangle('Position', [bird.x-8 bird.y-8 16 16], ...
             'Curvature', [1 1], ...
             'FaceColor', bird.color);
  end
  
  % UI Callbacks
  function speedSliderCallback(hObject, ~)
    gameState.speed = round(get(hObject, 'Value'));
  end
  
  function startStopCallback(~, ~)
    gameState.running = ~gameState.running;
  end
  
  function saveCallback(~, ~)
    bestBird = getBestBird();
    save('best_bird.mat', 'bestBird');
  end
  
  function loadCallback(~, ~)
    load('best_bird.mat');
    gameState.birds(end+1) = bestBird;
  end
  
  function bestBird = getBestBird()
    [~, idx] = max([gameState.birds.score]);
    bestBird = gameState.birds(idx);
  end
  
  % Cleanup
  function cleanup()
    stop(gameTimer);
    delete(gameTimer);
    delete(f);
  end
  
  set(f, 'CloseRequestFcn', @(~,~) cleanup());
end

% Neural Network functions
function nn = createNeuralNetwork()
  nn.input_nodes = 5;
  nn.hidden_nodes = 9;
  nn.output_nodes = 2;
  
  % Initialize weights and biases with random values
  nn.weights_ih = 2 * rand(nn.hidden_nodes, nn.input_nodes) - 1;
  nn.weights_ho = 2 * rand(nn.output_nodes, nn.hidden_nodes) - 1;
  nn.bias_h = 2 * rand(nn.hidden_nodes, 1) - 1;
  nn.bias_o = 2 * rand(nn.output_nodes, 1) - 1;
end

function output = predict(nn, inputs)
  % Forward propagation
  hidden = sigmoid(nn.weights_ih * inputs' + nn.bias_h);
  output = sigmoid(nn.weights_ho * hidden + nn.bias_o);
  output = output';
end

function s = sigmoid(x)
  s = 1 ./ (1 + exp(-x));
end

function mutated = mutateBrain(brain)
  mutated = brain;
  mutation_rate = 0.1;
  
  % Mutate weights and biases
  mutated.weights_ih = mutateMatrix(mutated.weights_ih, mutation_rate);
  mutated.weights_ho = mutateMatrix(mutated.weights_ho, mutation_rate);
  mutated.bias_h = mutateMatrix(mutated.bias_h, mutation_rate);
  mutated.bias_o = mutateMatrix(mutated.bias_o, mutation_rate);
end

function matrix = mutateMatrix(matrix, rate)
  mask = rand(size(matrix)) < rate;
  mutations = randn(size(matrix)) * 0.1;
  matrix(mask) = matrix(mask) + mutations(mask);
end

function parent = pickParent(birds)
  r = rand();
  runningSum = 0;
  
  for i = 1:length(birds)
    runningSum = runningSum + birds(i).fitness;
    if runningSum > r
      parent = birds(i);
      return;
    end
  end
  
  parent = birds(end);  % Fallback
end
