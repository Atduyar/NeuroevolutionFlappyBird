classdef Pipe
	properties
		x
		y
		height
	end
	properties (Constant)
		speed = 5;
		width = 20;
		gap_height = 35;
	end
	methods
		function obj = Pipe(x, y, height)
			obj.height = height;
			obj.x = x;
			obj.y = y;
		end
		function obj = draw(obj)
			rects = obj.getRects();
			rectangle('Position', rects(1,:), 'FaceColor', 'green', 'EdgeColor', 'green');
			rectangle('Position', rects(2,:), 'FaceColor', 'green', 'EdgeColor', 'green');
		end
		function obj = update(obj)
			obj.x = obj.x - obj.speed;
		end
		function obj = reset(obj)
			obj.x = 500;
			obj.y = randi([100, 400]);
		end
		function rects = getRects(obj)
			rects = [
				[obj.x, 0, obj.width, obj.y],
				[obj.x, obj.y+obj.gap_height, obj.width, obj.height-(obj.y+obj.gap_height)]
			];
		end
	end
end
