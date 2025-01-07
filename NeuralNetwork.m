classdef NeuralNetwork
	properties
		layers
		weights
		biases
	end
	properties (Constant)
	end
	methods
		function obj = NeuralNetwork(layers)
			obj.layers = layers; % e.g. [5, 9, 2]
			% hidden layers + output layer weights
			obj.weights = cell(1, length(layers)-1); 
			% hidden layers + output layer biases
			obj.biases = cell(1, length(layers)-1);

			for i = 2:length(layers)
				% create random weights between -1 and 1
				obj.weights{i-1} = 2*rand(layers(i-1), layers(i)) - 1;
				% create random biases between -1 and 1
				obj.biases{i-1} = 2*rand(layers(i), 1) - 1;
			end
			% disp(obj);
			% disp(obj.weights{1});
			% disp(size(obj.weights{1}));
			% disp(obj);
			% disp(obj.weights{1}(1,2));
		end
		function out = sigmoid(obj, x)
			out = 1 ./ (1 + exp(-x));
		end
		function out = feedforward(obj, input)
			% feedforward
			% disp("Input: ");
			% disp(size(input));
			% disp(input);
			for i = 1:length(obj.weights)
				% calculate the dot product of weights and inputs
				% disp("Weights: ");
				% disp(size(obj.weights{i}'));
				% disp(obj.weights{i}');
				% disp(size(input));
				% disp(size(obj.weights{i}));
				% disp(size(obj.biases{i}));
				% disp(obj.weights{i});
				z = input * obj.weights{i} + obj.biases{i}';

				% apply the sigmoid function
				input = obj.sigmoid(z);
			end
			out = input;
		end
	end
end
