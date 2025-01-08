classdef Pipe
	properties
		x
		y
		height
		handler_up
		handler_down
	end
	properties (Constant)
		speed = 5;
		width = 20;
		gap_height = 40;
	end
	methods
		function obj = Pipe(x, y, height)
			obj.height = height;
			obj.x = x;
			obj.y = y;
			obj.handler_up = 0;
			obj.handler_down = 0;
		end
		function obj = firstDraw(obj)
			rects = obj.getRects();
			obj.handler_up = rectangle('Position', rects(1,:), 'FaceColor', 'green', 'EdgeColor', 'green');
			obj.handler_down = rectangle('Position', rects(2,:), 'FaceColor', 'green', 'EdgeColor', 'green');
		end
		function obj = draw(obj)
			rects = obj.getRects();
			set(obj.handler_up, 'Position', rects(1,:));
			set(obj.handler_down, 'Position', rects(2,:));
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
