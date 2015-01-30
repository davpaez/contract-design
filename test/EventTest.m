classdef EventTest < matlab.unittest.TestCase
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
        % The constructor Event() creates object of class Event
        function testConstructorEvent(testCase)
            % Empty arguments - Empty object
            e1 = setupScenario1();
            testCase.assertClass( e1, 'Event');
        end

        function testGetCurrentPerf (testCase)
            % Single event
            e1 = setupScenario1();
            currentPerf = e1.observation().value;
            testCase.verifyEqual(currentPerf, 89, ...
                'Method getCurrentPerf() is not returning the correct value')
            
            clear e1 currentPerf
            
            % List event
            listEvents = setupScenario2();
            currentPerf2 = listEvents.next.observation().value;
            testCase.verifyEqual(currentPerf2, 40, ...
                'Method getCurrentPerf() is not returning the correct value')
            currentPerf3 = listEvents.next.next.observation().value;
            testCase.verifyEqual(currentPerf3, 76, ...
                'Method getCurrentPerf() is not returning the correct value')
        end

        function testGetPreviousPerf (testCase)
            % Single event
            e1 = setupScenario1();
            previousPerf = e1.observation().returnHead().value;
            testCase.verifyEqual(previousPerf, 89, ...
                'Method getPreviousPerf() is not returning the correct value')
            
            clear e1 previousPerf
            
            % List event
            listEvents = setupScenario2();
            previousPerf2 = listEvents.next.observation().returnHead().value;
            testCase.verifyEqual(previousPerf2, 60, ...
                'Method getPreviousPerf() is not returning the correct value')
            previousPerf3 = listEvents.next.next.observation().returnHead().value;
            testCase.verifyEqual(previousPerf3, 38, ...
                'Method getPreviousPerf() is not returning the correct value')

        end
        
        function testIsInspection (testCase)
            % Single event
            e1 = setupScenario1();
            isInspection = e1.isInspection();
            testCase.verifyEqual(isInspection, false, ...
                'Method isInspection() is not returning the correct value');
            
            clear e1 isInspection
            
            % List event
            listEvents = setupScenario2();
            isInspection2 = listEvents.next.isInspection();
            testCase.verifyEqual(isInspection2, true, ...
                'Method isInspection() is not returning the correct value');
            isInspection3 = listEvents.next.next.isInspection();
            testCase.verifyEqual(isInspection3, true, ...
                'Method isInspection() is not returning the correct value');
        end
        
    end
    
end
function e1 = setupScenario1()
    obs = Observation(1.5, 89);
    e1 = Event(obs.time, 0, 0, 0, 0, obs);
end

function e1 = setupScenario2()
    obs1 = Observation(1.5, 89);
    
    obs2_a = Observation(2, 60);
    obs2_b = Observation(2, 40);
    obs2_a.insertAfter(obs2_b);
    
    obs3_a = Observation(3, 38);
    obs3_b = Observation(3, 76);
    obs3_a.insertAfter(obs3_b);
    
    e1 = Event(1.5, 0, 0, 0, 0, obs1);
    e2 = Event(2, 1, 0, 0, 1, obs2_a);
    e3 = Event(3, 1, 1, 1, 0, obs3_b);
    
    e1.insertAfter(e2);
    e2.insertAfter(e3);
end

