classdef test < matlab.unittest.TestCase
    %Test your challenge solution here using matlab unit tests
    %
    % Check if your main file 'challenge.m', 'disparity_map.m' and 
    % verify_dmap.m do not use any toolboxes.
    %
    % Check if all your required variables are set after executing 
    % the file 'challenge.m'
    
%     properties
%     end
    
    methods (Test)
        function check_variables(testCase)
           challenge;
           testCase.assertNotEmpty(group_number);
           testCase.assertGreaterThan(group_number, 0);
           testCase.assertNotEmpty(members);
           testCase.assertGreaterThan(length(members), 0);
        end
        
        function check_toolboxes(testCase)
            [~,pList] = matlab.codetools.requiredFilesAndProducts('verify_dmap.m');
            actOut = [length(pList), 1, 1];
            expOut = [1, 1, 1];
            testCase.verifyEqual(actOut,expOut);
            
            [~,pList] = matlab.codetools.requiredFilesAndProducts('show_demo.m');
            actOut = [length(pList), 1, 1];
            expOut = [1, 1, 1];
            testCase.verifyEqual(actOut,expOut);
        end
        
        function check_psnr(testCase)
            A = uint8(randi(255, 200, 300));
            ref = uint8(randi(255, 200, 300));
            actOut = verify_dmap(A, ref);
            expOut = psnr(A, ref);
            tol = 1e-8;
            testCase.verifyLessThan(sum(abs(actOut-expOut), 'all'),tol);
        end
    end
end