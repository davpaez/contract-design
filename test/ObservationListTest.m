classdef ObservationListTest < matlab.unittest.TestCase
    %EVENTTEST Unit test of Event class
    %   Detailed explanation goes here
    
    properties
        originalPath
    end
    
    methods (TestClassSetup)
        function addEventClassToPath (testCase)
            
            testLocation = pwd;
            testCase.originalPath = path;
            
            cd ..\'source'  % Go to source folder
            sourceLocation = pwd;   % Source folder location
            cd(testLocation)   % Go to test folder
            
            addpath(sourceLocation);
        end        
    end
    
    methods (TestClassTeardown)
        function restorePath(testCase)
            path(testCase.originalPath);
        end
    end
    
    methods (Test)
        
        
        function testConstructor(testCase)
            
            % Empty arguments - Empty object
            o1 = dataComponents.ObservationList();
            testCase.assertClass( o1, 'dataComponents.ObservationList');
        end
        
        
        function testGetData(testCase)
            % List observations
            [o1 , ~, ~] = setupScenario1();
            
            st = o1.getData();
            
            % Registered lists
            values_actual = st.value;
            times_actual = st.time;
            
            % Calculated lists
            cumsum_actual = st.cumsum;
            area_actual = st.area;
            average_actual = st.average;
            meanvalue_actual = st.meanvalue;
            deviation_actual = st.deviation;
            
            % State list
            state_actual = st.state;
            
            % Auxiliary list
            jumpsindex_actual = st.jumpsindex;
            
            % Assumed length
            lg = length(values_actual);
            
            % Check lists' length
            testCase.verifyLength(times_actual, lg);
            testCase.verifyLength(cumsum_actual, lg);
            testCase.verifyLength(area_actual, lg);
            testCase.verifyLength(average_actual, lg);
            testCase.verifyLength(meanvalue_actual, lg);
            testCase.verifyLength(deviation_actual, lg);
            testCase.verifyLength(state_actual, lg);
            
        end
        
        
        function testRegister(testCase)
            
            % List observations
            [o1 , times_expected, values_expected] = setupScenario1();
            
			st = o1.getData();
            
            values_actual = st.value;
            times_actual = st.time;
            
            testCase.verifyEqual(values_actual, values_expected);
            testCase.verifyEqual(times_actual, times_expected);
        end
        
        
        function testGetCumSum(testCase)
            
            % List observations
            [o1 , ~, values_expected] = setupScenario1();
            
            st = o1.getData();
            
            cumsum_actual = st.cumsum;
            cumsum_expected = cumsum(values_expected);
            
            testCase.verifyEqual(cumsum_actual, cumsum_expected);
        end
        
        
        function testGetArea(testCase)
            
            % List observations
            
            [o1 , times_expected, values_expected] = setupScenario1();
            
            st = o1.getData();
            
            area_actual = st.area;
            area_expected = cumtrapz(times_expected, values_expected);
            
            testCase.verifyEqual(area_actual, area_expected, 'AbsTol', 0.0001);
        end
        
        
        function testGetAverage(testCase)
            
            % List observations
            
            [o1 , vector] = setupScenario1();
            
            lastPointer = o1.pt;
            
            average_method = o1.getAverage(lastPointer);
            average_correct = mean(vector);
            
            testCase.verifyEqual(average_method, average_correct);
        end
        
        
        function testGetMeanValue(testCase)
            
            % List observations
            
            [o1 , vector] = setupScenario1();
            
            lastPointer = o1.pt;
            st = o1.getData();
            time = st.time;
            
            meanValue_method = o1.getMeanValue(lastPointer);
            meanValue_correct = trapz(time,vector)/(time(end)-time(1));
            
            testCase.verifyEqual(meanValue_method, meanValue_correct);
        end
        
        
        function testGetDeviation(testCase)
            
            % List observations
            
            [o1 , vector] = setupScenario1();
            
            lastPointer = o1.pt;
            
            deviation_method = o1.getDeviation(lastPointer);
            deviation_correct = std(vector);
            
            testCase.verifyEqual(deviation_method, deviation_correct);
        end
        
        
        function testExtractLastJumpPair(testCase)
             
            [o1, indexLastPreJump, timeLastJump, valueLastPreJump, valueLastPostJump] = setupScenario2();
            
            % Extracts last jump pair
            jumpPair = o1.extractLastJumpPair();
            
            testCase.verifyEqual(jumpPair.indexPreJump, indexLastPreJump);
            testCase.verifyEqual(jumpPair.time, timeLastJump);
            testCase.verifyEqual(jumpPair.valuePreJump, valueLastPreJump);
            testCase.verifyEqual(jumpPair.valuePostJump, valueLastPostJump);
            
        end
        
    end
    
end


function [o1 , times, values] = setupScenario1()
% Creates observation list with a random number of elements, whose time is
% strictly incremental

    numAleat = round(rand()*10000);
    values = rand(numAleat,1);
    times = (1:numAleat)';
    o1 = dataComponents.ObservationList();
    
    for i=times
        t = times(i);
        v = values(i);
        
        o1.register(t, v);
    end
end


function [o1, indexLastPreJump, timeLastJump, valueLastPreJump, valueLastPostJump] = setupScenario2()
% Creates observation list with jumps created according to some probability
% * A jump is defined as pair of consecutive observations which share the
%   same time of occurrence

    numAleat = round(rand()*10000);
    values = rand(numAleat,1);
    
    o1 = dataComponents.ObservationList();
    
    probabilityOfJumps = 0.1;
    
    indexLastPreJump = -1;
    timeLastJump = -1;
    valueLastPreJump = -1;
    valueLastPostJump = -1;
    
    for i=1:numAleat
        currentValue = values(i);
        if rand<probabilityOfJumps && i>1
            time = i-1;
            
            indexLastPreJump = i-1;
            timeLastJump = time;
            valueLastPreJump = values(i-1);
            valueLastPostJump = currentValue;
            
        else
            time = i;
        end
        
        o1.register(time,values(i));
    end
end

