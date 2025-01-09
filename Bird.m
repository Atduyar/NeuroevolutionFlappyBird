classdef Bird
	properties
		y
		brain
		handler
		isAI
		velocity
		isDead
		score
		justDidScore
	end
	properties (Constant)
		x = 10;
		size = 10;
		gravity = -.8;
		lift = 6;
	end

	methods
		function obj = Bird(brain, y)
			if islogical(brain)
				obj.isAI = false;
			else
				obj.brain = brain;
				obj.isAI = true;
			end
			obj.y = y;
			obj.velocity = 0;
			obj.isDead = false;
			obj.score = 0;
			obj.handler = 0;
		end

		function obj = delete(obj)
			if obj.handler == 0
				return;
			end
			delete(obj.handler);
			obj.handler = 0;
		end
		
		function obj = jump(obj)
			obj.velocity = obj.lift;
		end

		function obj = update(obj)
			if obj.isDead
				return;
			end
			if obj.isAI == true
				desision = obj.brain.think(obj);
				if desision
					obj = obj.jump();
				end
			end
			% obj.score += 1;
			obj.velocity = obj.velocity + obj.gravity;
			obj.y = obj.y + obj.velocity;
		end

		function obj = firstDraw(obj)
			color = 'blue';
			if obj.isAI
				color = 'red';
			end
			obj.handler = rectangle('Position', [obj.x, obj.y, obj.size, obj.size], ...
				'Curvature', [1, 1], 'FaceColor', color, 'EdgeColor', 'none');
		end

		function draw(obj)
			set(obj.handler, 'Position', [obj.x, obj.y, obj.size, obj.size]);
		end
		
		function obj = checkCollision(obj, nextPipe, game_height)
			if obj.isDead
				return;
			end
			if obj.y <= 0 || obj.y + obj.size >= game_height
				obj.isDead = true;
				delete(obj.handler);
				obj.handler = 0;
				return;
			end
			birdRect = [obj.x, obj.y, obj.size, obj.size];

			% Score
			if nextPipe.x > 0
				obj.justDidScore = false;
			elseif obj.justDidScore == false
				obj.justDidScore = true;
				obj.score += 1;
			end

			% Collision
			rects = nextPipe.getRects();
			for j = 1:size(rects, 1)
				rect = rects(j, :);
				if birdRect(1) < rect(1) + rect(3) && birdRect(1) + birdRect(3) > rect(1) && ...
					birdRect(2) < rect(2) + rect(4) && birdRect(2) + birdRect(4) > rect(2)
					obj.isDead = true;
					obj.score += 1;
					delete(obj.handler);
					obj.handler = 0;
				end
			end
		end

		function obj = popUpWindow(obj)
			if obj.isAI == false
				return;
			end
			obj.brain.nn.popUpWindow();
		end
	end
end
