classdef BirdBrain
	properties
		nn
	end
	properties (Constant)
	end
	methods
		function obj = BirdBrain(parent)
			if islogical(parent)
				% random NN
				obj.nn = NeuralNetwork([5, 9, 2]);
			else
				if ischar(parent)
					% from json
					obj.nn = NeuralNetwork(parent);
				else
					% form parent
					obj.nn = parent.brain.nn;
					obj.nn = obj.mutate(0.1);
				end
			end
		end
		function desision = think(obj, bird, nextPipe, game_width)
			% hacky way to get the game height
			game_height = nextPipe.height;

			inputs = [0, 0, 0, 0, 0];
			inputs(1) = bird.y / game_height;
			% top of next pipe
			inputs(2) = nextPipe.y / game_height;
			% bottom of next pipe
			inputs(3) = (nextPipe.y + nextPipe.gap_height) / game_height;
			% distance to next pipe
			inputs(4) = (nextPipe.x - (bird.x + bird.size)) / game_width;
			% bird velocity
			inputs(5) = bird.velocity / 10;

			% disp(inputs)
			outputs = obj.nn.feedforward(inputs);
			desision = outputs(1) > outputs(2);
		end

		function nn = mutate(obj, rate)
			nn = obj.nn;
			% mutate weights
			for i = 1:length(nn.weights)
				% Random 0 and 1 acording to rate
				chooseMatrix = rand(size(nn.weights{i})) < rate;
				% Random gaussian matrix
				gaussuanMatrix = randn(size(nn.weights{i})) * 0.1;
				% Mutation
				mutation = chooseMatrix .* gaussuanMatrix;
				% display(mutation);
				nn.weights{i} = nn.weights{i} + mutation;
			end

			% mutate biases
			for i = 1:length(nn.biases)
				chooseMatrix = rand(size(nn.biases{i})) < rate;
				gaussuanMatrix = randn(size(nn.biases{i})) * 0.1;
				mutation = chooseMatrix .* gaussuanMatrix;
				% display(mutation);
				nn.biases{i} = nn.biases{i} + mutation;
			end
		end
	end
end
