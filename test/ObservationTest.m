classdef ObservationTest < matlab.unittest.TestCase
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
            o1 = dataComponents.Observation();
            testCase.assertClass( o1, 'dataComponents.Observation');
        end
        
        
        function testRegisterAndGetData (testCase)
            
            % List observations
            [o1 , vector] = setupScenario1();
            
			st = o1.getData();
            
            values = st.value;
            
            testCase.verifyEqual(values,vector);
        end
        
        
        function testGetCumSum(testCase)
            
            % List observations
            [o1 , vector] = setupScenario1();
            lastPointer = o1.pt;
            
            cumSum_method = o1.getCumSum(lastPointer);
            cumSum_correct = sum(vector);
            
            testCase.verifyEqual(cumSum_method, cumSum_correct);
            
        end
        
        
        function testGetArea(testCase)
            
            % List observations
            
            [o1 , vector] = setupScenario1();
            
            lastPointer = o1.pt;
            st = o1.getData();
            time = st.time;
            
            area_method = o1.getArea(lastPointer);
            area_correct = trapz(time,vector);
            
            testCase.verifyEqual(area_method, area_correct);
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

% Creates observation list with a random number of elements
function [o1 , values] = setupScenario1()

    numAleat = round(rand()*10000);
    values = rand(numAleat,1);
    
    o1 = dataComponents.Observation();
    
    for i=1:numAleat
        o1.register(i,values(i));
    end
end

% Creates observation list with jumps created according to some probability
% * A jump is defined as pair of consecutive observations which share the
%   same time of occurrence
function [o1, indexLastPreJump, timeLastJump, valueLastPreJump, valueLastPostJump] = setupScenario2()
    
    numAleat = round(rand()*10000);
    values = rand(numAleat,1);
    
    o1 = dataComponents.Observation();
    
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

