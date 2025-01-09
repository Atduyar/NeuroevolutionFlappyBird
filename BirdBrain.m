classdef BirdBrain
	properties
		nn
	end
	properties (Constant)
	end
	methods
		function obj = BirdBrain(parentBrain)
			if islogical(parentBrain)
				obj.nn = NeuralNetwork([5, 9, 2]);
			else
				obj.nn = parentBrain.mutate();
			end
		end
		function desision = think(obj, bird)
			inputs = [bird.y, bird.velocity, 0, 0, 0];
			outputs = obj.nn.feedforward(inputs);
			desision = outputs(1) > outputs(2);
		end
		function obj = popUpWindow(obj)
			obj.nn.popUpWindow();
		end
	end
end
