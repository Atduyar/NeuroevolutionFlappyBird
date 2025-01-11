classdef NeuralNetwork
	properties
		layers
		weights
		biases
	end
	properties (Static)
		OpenedFigure
	end
	properties (Constant)
	end
	methods
		function obj = NeuralNetwork(layers)
			if ischar(layers)
				jsonString = jsondecode(layers);

				obj.layers = jsonString(1).layers;
				obj.weights = cell(1, length(jsonString));
				obj.biases = cell(1, length(jsonString));

				for i = 1:length(jsonString)
					obj.weights{i} = jsonString(i).weights;
					obj.biases{i} = jsonString(i).biases;
				end
			else
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
			end
		end
		
		% NeuralNetwork Visualizer
		function obj = popUpWindow(obj, mainFigure)
			% close the previous window
			persistent OpenedFigure;
			if ~isempty(OpenedFigure)
				try
					close(OpenedFigure);
				catch
				end
				OpenedFigure = [];
			end

			% Create a figure and an axes
			fig_width = 150*(length(obj.layers)-1) + 50;
			fig_height = 50 * max(obj.layers) + 50;
			OpenedFigure = figure('Name', 'Neural Network Visualizer', 'NumberTitle', 'off', 'MenuBar', 'none', 'Resize', 'off', ...
				'Position', [1000, 100, fig_width, fig_height]);
			hold on;
			axis off;

			% draw the nodes
			for i = 1:length(obj.layers)
				for j = 1:obj.layers(i)
					% draw the node centerd
					r = rectangle('Position', [(i-1)*150, j*50, 20, 20], 'Curvature', [1, 1], 'FaceColor', 'white', 'EdgeColor', 'black');
					% set edge color and Edge size depending on the bias value
					if i ~= 1 % first layer don't have bias
						if obj.biases{i-1}(j) < 0
							set(r, 'EdgeColor', 'red', 'LineWidth', max(1, abs(obj.biases{i-1}(j)*6)));
						else
							set(r, 'EdgeColor', 'green', 'LineWidth', max(1, abs(obj.biases{i-1}(j)*6)));
						end
					end
				end
			end

			for i = 1:length(obj.layers)-1
				for j = 1:obj.layers(i)
					for k = 1:obj.layers(i+1)
						% draw the line between nodes
						% line([x1, x2], [y1, y2])

						nodeValue= round(abs(obj.weights{i}(j, k))*255);
						if nodeValue > 255
							nodeValue = 255;
						end
						hexColor = dec2hex(nodeValue);
						if length(hexColor) == 1
							hexColor = ['0', hexColor];
						end
						if obj.weights{i}(j, k) < 0
							line([(i-1)*150+10, i*150+10], [j*50+10, k*50+10], 'Color', ['#FF', hexColor, hexColor], 'LineWidth', 1);
						else
							line([(i-1)*150+10, i*150+10], [j*50+10, k*50+10], 'Color', ['#', hexColor, 'FF', hexColor], 'LineWidth', 1);
						end
					end
				end
			end
			
			% 600x600
			axis([0 fig_width 0 fig_height]);

			% close button
			uicontrol('Style', 'pushbutton', 'String', 'Close', 'Position', [fig_width-50, fig_height-30, 50, 30], ...
				'Callback', @(src, event) close(OpenedFigure));

			% print the NN object as json string
			nnJson = struct('layers', obj.layers, 'weights', obj.weights, 'biases', obj.biases);
			uicontrol('Style', 'pushbutton', 'String', 'Print', 'Position', [fig_width-100, fig_height-30, 50, 30], ...
				'Callback', @(src, event) disp(jsonencode(nnJson)));

			% copy from hear inputdlg button
			uicontrol('Style', 'pushbutton', 'String', 'Copy', 'Position', [fig_width-150, fig_height-30, 50, 30], ...
				'Callback', @(src, event) inputdlg('Copy from this box:', 'Bird NN', [1 50], {jsonencode(nnJson)}));
			% set the main figure
			figure(mainFigure);
		end

		function obj = copy(obj)
			% copy the neural network
			new_nn = NeuralNetwork(obj.layers);
			for i = 1:length(obj.weights)
				new_nn.weights{i} = obj.weights{i};
				new_nn.biases{i} = obj.biases{i};
			end
			obj = new_nn;
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
