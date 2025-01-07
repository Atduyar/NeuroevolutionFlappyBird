classdef Bird
	properties
		y
		brain
		isAI
		velocity
		isDead
		score
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
			obj.velocity = obj.velocity + obj.gravity;
			obj.y = obj.y + obj.velocity;
		end

		function obj = draw(obj)
			rectangle('Position', [obj.x, obj.y, obj.size, obj.size], ...
				'Curvature', [1, 1], 'FaceColor', 'red', 'EdgeColor', 'none');
		end
		
		function obj = checkCollision(obj, pipes, game_height)
			if obj.y <= 0 || obj.y + obj.size >= game_height
				obj.isDead = true;
			end
			birdRect = [obj.x, obj.y, obj.size, obj.size];
			for i = 1:length(pipes)
				rects = pipes(i).getRects();
				% AABB rectangle collision x y w h
				% rectangle circle collision
				for j = 1:size(rects, 1)
					rect = rects(j, :);
					if birdRect(1) < rect(1) + rect(3) && birdRect(1) + birdRect(3) > rect(1) && ...
						birdRect(2) < rect(2) + rect(4) && birdRect(2) + birdRect(4) > rect(2)
						obj.isDead = true;
					end
					% disp(birdRect);
					% disp("=====");
					% disp(rects));
					% rect = rects(j, :);
					% obj.isDead = true;
				end
			end
		end
	end
end
