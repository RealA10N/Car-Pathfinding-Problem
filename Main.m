classdef Main < handle
    % This class is the main class of the program.
    % You can use this class in a seperate script, or just run it in the
    % command window!
        
    properties (Access = protected)
        car
        driver
        map
        
        is_recording_path = 0
        last_recorded_path = 0
        cur_recording_path = 0
        
        % Defaults
        user_drive  % boolean: true if the user is controlling the car
        digits_after_decimal_point  % int. >= 0
        algorithm_list % Contains "algorithm" objects for
                       % every algorithm in the program
    end
    
    methods
        %% Constructor
        
        function obj = Main(size)
            % Importing all of the algorithm classes
            addpath(genpath('General'), genpath('Search'), genpath('Tools'))
            
            % If the size of the map is not given
            if (nargin < 1)
                size = 20;
            end
            
            % Creates the needed objects
            obj.car = SearchCar(size/2, size/2, 0);  % default car location
            obj.driver = CarDriver(obj.car);
            obj.map = PathMap(obj.car, size);  % default size, no obstacles
            
            % Set default values
            obj.digits_after_decimal_point = 0;
            obj.user_drive = false;
            
            % Generates and returns the algorithm list, that contains all
            % the "Algorithm" subclasses.
            obj.algorithm_list = { ...
                BreadthFirstAlgorithm(obj.map), ...
                DijkstrasAlgorithm(obj.map), ...
                AstarAlgorithm(obj.map), ...
                RRTAlgorithm(obj.map), ...
                ImprovedRRTAlgorithm(obj.map), ...
                BalancedRRTAlgorithm(obj.map) ...
            };
            
            % Generate the map
            obj.generate()
        end
        
        %% Start and End
        
        function setStart(obj, rotation, x, y)
            % Sets the starting position of the car
            
            if (nargin < 3)
                % if the point (x, y) is not given
                obj.generate()  % generate the map before user input
                [ x, y ] = obj.userInPoints(1);  % user selects the car (x, y)
            end
            
            if (nargin < 2)
                % If rotation is not given
                rotation = 0;
            end
            
            obj.car.teleport(x, y, rotation)
            obj.map.setstart(x, y, rotation)
            obj.generate()  % show the map with the new location of the car
            
            % Checking if the car status is good (if not in obstacle or out of map)
            if (obj.map.checkDead())
                error("The position of the car is invalid.")
            end
        end
        
        function setEnd(obj, rotation, x, y)
            % Defines the point that the car needs to touch for the
            % algotithm to find a path.
            
            if (nargin < 2)
                rotation = 0;
            end
            
            if (nargin < 4)
                % If the point is not given
                obj.generate()  % generate the map before user input
                [ x, y ] = obj.userInPoints(1);  % user selects the end point on graph
            end
            
            obj.map.setend([x y rotation])
            obj.map.generate()  % generate the map with the end point on it
            
            if (obj.map.checkPointDead(x, y))
                error("The position of the end point is invalid.")
            end
            
        end
        
        %% Obstacles
        
        function addObstacle(obj, x, y)
            % Adds an obstacle to the map. if x or y is not given,
            % the user will be requestd to select two points with the
            % ginput funtion.
            
            if (nargin < 3)
                % If the points are not passed as parameters,
                % use ginput to selet on the graph.
                obj.generate()  % generate the map before user input
                disp("Please select two points on the map to create a rectange obstacle.")
                [ x, y ] = obj.userInPoints(2);
            end
            
            % If duplicate point, sets the size of the obstacle to 1.
            % In implementation, obstacle can't be a point!
            if (x(1) == x(2))
                x(2) = x(2) + 1;
            end
            if (y(1) == y(2))
                y(2) = y(2) + 1;
            end
            
            obstacle = RectangleObstacle(x(1), y(1), x(2), y(2));
            obj.map.addObstacles(obstacle);
            obj.generate()  % generate the map after the obstacle is added
        end
        
        %% Generate
        
        function generate(obj)
            % Shows the current state of the map
            obj.map.generate()
        end
        
        %% Search
        
        function statsObj = search(obj, drawEveryStep, pauseEveryStep, algorithmIndex)
            % A function that will search a path to the end position, with
            % the given algorithm. if an algorithm isn't given, the user
            % will be displayed with a window that asks him to choose one.
            
            if (nargin < 4)
                % If algorithmIndex is not given
                algorithmObj = obj.userSelectAlgorithm();
            else
                algorithmObj = obj.algorithm_list{algorithmIndex};
            end
            
            if (nargin < 3)
                % If pauseEveryStep is not given
                pauseEveryStep = false;
            end
            
            if (nargin < 2)
                % If drawEveryStep is not given
                drawEveryStep = true;
            end

            statsObj = algorithmObj.run(drawEveryStep, pauseEveryStep); % The search operation

        end
        
        function debug_search(obj)
            algorithmObj = obj.userSelectAlgorithm();
            algorithmObj.run('d', true); % The search operation, with 'd' representing 'debug'
        end
        
        %% User drive
        
        function drive(obj)
            % Toggles the drive mode. drive mode allows the player to
            % contol the car with the keyboard!
                        
            if(obj.user_drive)
                obj.exitDrive()
            else
                obj.startDrive()
            end
        end
        
        function startDrive(obj)
            % sets the driving mode to true: the player can contol the car
            % with the keyboard!
                        
            set(gcf,'KeyPressFcn',@(source, event)keyPressDrive(obj, source, event));
            obj.user_drive = true;
            
            disp("You are now controlling the car.")
            disp("Use the keyboard arrows to drive!")
        end
        
        function exitDrive(obj)
            % sets the driving mode to false: the player can't control the
            % car with the keyboard!
            
            set(gcf,'KeyPressFcn', '');
            obj.user_drive = false;
            
            disp("You are not controlling the car anymore.")
        end
        
        %% Nodes, Edges, PRM.
        
        function addNodes(obj, amount)
            % Adds the given amout of random nodes to the map.
            % If amount is not given, will add only one random node.
            
            if (nargin < 2)
                % If the amount parameter isn't given it will be defaulted
                % to 1.
                amount = 1;
            end
            
            obj.map.addRandomNodes(amount)
            obj.generate()
        end
        
        function clearNodes(obj)
            % Clears the nodes on the graph.
            obj.map.clearNodes()
            obj.generate()
        end
        
        
        %% Record and show paths
        
        function record(obj)
            % Start / stop recording the path.
            % Path will be recorded only when the user drives the car with
            % The `.drive` method.
            
            if (obj.is_recording_path)
                obj.stop_recording()
            else
                obj.start_recording()                
            end
        end
        
        function start_recording(obj)
            % Start recording the movment of the car
            
            if obj.is_recording_path
                disp("You are already recording.")
            else
                disp("Started recording path.")
                disp("Use the 'drive' method to drive the car.")
                
                obj.is_recording_path = 1;
                obj.cur_recording_path = Path(obj.map);
                obj.add_recording_step()
            end
        end
        
        function stop_recording(obj)
            % Stop recording the movment of the car
            
            if ~obj.is_recording_path
                disp("You are not recording.")
            else
                disp("Stopped recording path.")
                disp("Use the 'show_recording' method to view recording!")
                
                obj.is_recording_path = 0;
                obj.last_recorded_path = obj.cur_recording_path;
                obj.cur_recording_path = 0;
            end
        end
        
        function show_recording(obj)
            % Show the last recorded path, as an animation.
            
            if class(obj.last_recorded_path) == "Path"  % zero is init value
                obj.last_recorded_path.show()
            else
                disp("No path recorded yet.")                
            end
            
        end
        
        function save_recording(obj, filename)
            % Save the last recorded path, as a video file.
            
            if (nargin < 2)
                filename = "recorded_path";
            end
            
            if class(obj.last_recorded_path) == "Path"  % zero is init value
                disp("Generating video file...")
                obj.last_recorded_path.save(filename)
                disp("Video file saved!")
            else
                disp("No path recorded yet.")                
            end
        end
        
    end

    %% Private methods
    
    methods (Access = private)
        
        function [ x, y ] = userInPoints(obj, points_num)
            % This method uses the ginput function to take in input from
            % the user, but the points are rounded.
            [ x, y ] = ginput(points_num);
            x = round(x, obj.digits_after_decimal_point);
            y = round(y, obj.digits_after_decimal_point);
        end
        
        function algorithmObj = userSelectAlgorithm(obj)
            % Opens a window that lets the user select a search algorithm
            % from the list. The selected algorithm object is returned!
            
            % The text that will be shown above the list
            prompt = 'Please select the algorithm you want to search with:';
            
            % Getting the avalible algorithm names
            list = obj.getAlgorithmNames();
            
            % Asking user for input
            i = listdlg('ListString', list, 'SelectionMode', 'single', ...
                'PromptString', prompt, 'ListSize', [300 150]);

            algorithmObj = obj.algorithm_list{i};
        end
        
        function names = getAlgorithmNames(obj)
            % Generates and returns the algorithm list, that contains all
            % the "Algorithm" subclasses.
            
            names = [];
            for i=1:length(obj.algorithm_list)
                curAlgorithm = obj.algorithm_list{i};
                curName = convertCharsToStrings(curAlgorithm.getAlgorithmName());
                names = [ names curName ];
            end
            
        end
            
        function keyPressDrive(obj, ~, event)
            % This function is called automaticly when the player is
            % controling the car using the keyboard and presses one of the
            % keyboard buttons.
            
            did_move = obj.driver.move(event.Key);
            
            if did_move
                obj.generate();
                obj.add_recording_step()
            end
            
        end
        
        function add_recording_step(obj)
            % If currently recording the movment of the car, this method
            % will add the current location of the car into the current
            % path recording.
            
            if obj.is_recording_path
                obj.cur_recording_path = obj.cur_recording_path.add_step();
            end
        end
    
    end

end