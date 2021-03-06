classdef CarDriver
    % defines all of the possible movments of the car
    % and allows you to name them and move the car just by
    % using the "move" function and the name of the move.
    
    properties (SetAccess = protected, GetAccess = public)
        directions
        car
    end
    
    properties (Constant)
        one_step_rot = 22.5;
        one_step_jump = 1;
        step_division = 5;
    end
    
    methods
        function obj = CarDriver(car)
            
            obj.car = car;
            
            obj.directions = struct();
            
            % Go straight
            obj.directions.uparrow    = CarCurvedSingleMove(obj, 0, obj.one_step_jump, obj.step_division);
            obj.directions.downarrow  = CarCurvedSingleMove(obj, 0, -obj.one_step_jump, obj.step_division);
            
            % Rotate forwards
            obj.directions.leftarrow  = CarCurvedSingleMove(obj, obj.one_step_rot, obj.one_step_jump, obj.step_division);
            obj.directions.rightarrow = CarCurvedSingleMove(obj, -obj.one_step_rot, obj.one_step_jump, obj.step_division);
            
            % Rotate backwards
            obj.directions.x  = CarCurvedSingleMove(obj, obj.one_step_rot, -obj.one_step_jump, obj.step_division);
            obj.directions.z = CarCurvedSingleMove(obj, -obj.one_step_rot, -obj.one_step_jump, obj.step_division);
        end
        
        function boolean = move(obj, direction)
            % will move the car in the given direction, if exsistes.
            % If moved, returns true. Returns false if the given direction
            % is invalid.
            
            if (isfield(obj.directions, direction))
                obj.directions.(direction).move();
                boolean = true;
            else
                boolean = false;
            end
            
        end
        
        function direction = getDirection(obj, name)
            % Returns CarSingleMove object by its name
            direction = obj.directions.(name);
        end
        
        function names = getDirectionNames(obj)
            % Returns a list of the direction names of the driver.
            names = fieldnames(obj.directions);
        end
 
    end
end

