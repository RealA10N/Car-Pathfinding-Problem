classdef DijkstraPositionQueue < PositionQueue
    % Stores multiple postions of the car, and has methods to add positions
    % and pull-out position from the queue (those methods follow the
    % Dijkstra's algorithm!)
    
    properties (Access = protected)
        costArray
    end
    
    
    methods
        
        function obj = DijkstraPositionQueue()
            % Calls "PositionQueue" constructor
            % Creates new cost array, for more efficient search.
            
            obj = obj@PositionQueue();
            obj.costArray = [];
        end
        
        function addPosition(obj, positionObj)
            % Adds a position object to the queue
            % If the position is already visited and has a cost,
            % the cost will be updated to the lowest one.
            
            positionFromQueue = obj.getPositionInQueue(positionObj);
            
            if(~isempty(positionFromQueue))
                % if already visited same position -> checks cost and
                % updates if needed!
                
                if(positionObj.getTotalCost() < positionFromQueue.getTotalCost())
                    obj.removeFromQueue(positionFromQueue);
                    obj.literallyAddPosition(positionObj);
                end
                
            else
                obj.literallyAddPosition(positionObj);
            end
        end
        
        function nextPos = pullOut(obj)
            % Pulls out the lowest cost position
            % and removes it from the queue.
            % The pulled out point is added to the "pulledPoints" array
            
            lowest_cost = min(obj.costArray);
            lowest_index = find(obj.costArray == lowest_cost);
            
            if (length(lowest_index) > 1)
                lowest_index = lowest_index(1);
            end

            nextPos = obj.queue(lowest_index);

            objectFromPulled = obj.getPositionInPulled(nextPos);
            if (isempty(objectFromPulled))  % if the point doesn't apper in the pulled list
                obj.pulled = [obj.pulled obj.queue(lowest_index)];  % Add item to pulled list
                obj.pulled_matrix = [obj.pulled_matrix; obj.queue_matrix(lowest_index,:)];
            end
            
            obj.queue(lowest_index) = []; % Remove item from queue list
            obj.queue_matrix(lowest_index,:) = [];
            obj.costArray(lowest_index) = [];
        end
        
        function removeFromQueue(obj, positionObj)
            % Removes the given point from the queue, if already in queue.
            
            [member, index] = ismember(positionObj.getPosition(), obj.queue_matrix, 'rows');
            
            if(member)
                obj.queue(index) = [];
                obj.queue_matrix(index,:) = [];
                obj.costArray(index) = [];
            end
        end
        
    end
        
    methods (Access = private)
        
        function literallyAddPosition(obj, positionObj)
            % Adds the given position to the queue.
            
            obj.queue = [obj.queue positionObj];
            obj.queue_matrix = [obj.queue_matrix; positionObj.getPosition()];
            obj.costArray = [obj.costArray positionObj.getTotalCost()];
        end
        
    end
    
end

