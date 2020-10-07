classdef Histogram
    % A handy tool that will generate a map and
    % random points on it. The random points can
    % and will be displayed as a Histogram.
    
    properties (Access = private)
        size
        car
        map
    end
    
    methods
        function obj = Histogram(size)
            % Create a new map with the given size.
            
            if (nargin < 1)
                size = 20;
            end
            
            obj.size = size;
            obj.car = Car(-5, -5, 90);  % Create a car, but outside of the map
            obj.map = PathMap(obj.car, obj.size);
            
            obj.generate()
        end
        
        function setEnd(obj, rotation, x, y)
            % Set the end, target point.
            
            if (nargin < 2)
                rotation = 0;
            end
            
            if (nargin < 4)
                obj.generate()
                [ x, y ] = obj.userInPoints(1);
            end
            
            obj.map.setend([x y rotation])
            obj.generate()
        end
        
        function throw_random_points(obj, num)
            % throw 'num' random points on the map and show the histogram.
            
            rand_points = zeros(num, 3);
            
            for count = 1:num
                cur_point = RandomPoint(obj.map);
                rand_points(count, :) = cur_point.getPosition();
            end
            
            hist3([rand_points(:, 1), rand_points(:, 2)], 'CDataMode', 'auto')
        end
        
        function throw_smart_points(obj, num)
            % throw 'num' random special points on the map and show the histogram.
            
            
            rand_points = zeros(num, 3);
            
            for count = 1:num
                cur_point = SmartRandomPoint(obj.map);
                rand_points(count, :) = cur_point.getPosition();
            end
            
            hist3([rand_points(:, 1), rand_points(:, 2)], 'CDataMode', 'auto')
            
        end
        
    end
    
    methods (Access = private)
        
        function generate(obj)
            obj.map.generate()
        end
        
        function [x, y] = userInPoints(~, num_of_points)
            % This method uses the ginput function to take in input from
            % the user, but the points are rounded.
            [ x, y ] = ginput(num_of_points);
            x = round(x);
            y = round(y);
        end
        
    end
end

