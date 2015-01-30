classdef PayoffTest < matlab.unittest.TestCase
    %PAYOFFTEST Unit test of Payoff class
    %   Detailed explanation goes here
    
    properties
        originalPath
        problem
        array
    end
    
    methods (TestClassSetup)
        function addPayoffClassToPath(testCase)
            testLocation = pwd;
            testCase.originalPath = path;
            
            cd ..\'source'  % Go to source folder
            sourceLocation = pwd;   % Source folder location
            cd(testLocation)   % Go to test folder
            
            addpath(sourceLocation);
        end
        
        
        function setupClassFixture(testCase)
            % Initilize input data
            settingsArray = initializeProblem_singleTest();
            
            % Creation of optimization problem object
            progSettings = ProgramSettings();
            progSettings.importSettings(settingsArray);
            
            % Construction of Contract and Problem objects
            testCase.problem = Problem(progSettings);
        end
        
    end
    
    methods (TestClassTeardown)
        function restorePath(testCase)
            path(testCase.originalPath);
        end
    end
    
    methods (Test)
        %% Get Balance method
        
        
        function testGetBalance(testCase)
            prob = testCase.problem;
            discRate = prob.getDiscountRate();
            
            [head, tail, balanceVector] = setupScenario2(prob);
            
            current = head;
            cont = 1;
            while ~isempty(current)
                testCase.assertEqual(balanceVector(cont), ...
                    current.getBalance(discRate));
                current = current.next;
                cont = cont + 1;
            end
        end
        
        function testReturnPayoffsOfType(testCase)
            [p0, headMaints] = setupScenario1();
            calculatedMaints = p0.returnPayoffsOfType(Payoff.MAINTENANCE);
            
            testCase.assertEqual(calculatedMaints, headMaints);
            testCase.assertEqual(calculatedMaints.next, headMaints.next);
            
        end
    
    end
    
end

%% Setup Scenario Functions

function [p0, p3_c] = setupScenario1()

p0 = Payoff(0, -4, Payoff.INVESTMENT);
p1 = Payoff(1, 5, Payoff.CONTRIBUTION);
p2 = Payoff(2, 6, Payoff.REVENUE);
p3 = Payoff(6, 6, Payoff.MAINTENANCE);
p4 = Payoff(6, -7, Payoff.INSPECTION);
p5 = Payoff(7, -17, Payoff.PENALTY);
p6 = Payoff(9, 12, Payoff.MAINTENANCE);


p3_c = copy(p3);
p6_c = copy(p6);

p3_c.insertAfter(p6_c);

copyObj = {p3_c, p6_c};

p0.insertAfter(p1);
p1.insertAfter(p2);
p2.insertAfter(p3);
p3.insertAfter(p4);
p4.insertAfter(p5);
p5.insertAfter(p6);

end

function [head, tail, balanceVector] = setupScenario2(problem)

discountRate = problem.getDiscountRate();

valueVector = 100*rand(1,20) - 100*rand(1,20);

head = Payoff(0, valueVector(1), Payoff.CONTRIBUTION);
current = head;
for i=1:19
    current.insertAfter(Payoff(i, valueVector(i+1), Payoff.PENALTY));
    current = current.next;
end
tail = current;


balanceVector = zeros(1,20);
current = head;
cont = 1;
prevBal = 0;
while ~isempty(current)
    if current.isFirst()
        deltaTime = current.time;
    else
        deltaTime = current.time - current.prev.time;
    end
    cumBal = prevBal*exp(discountRate*deltaTime) + current.value;
    balanceVector(cont) = cumBal;
    
    cont = cont + 1;
    current = current.next;
    prevBal = cumBal;
end
end