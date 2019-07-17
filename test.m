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
           % check group_number
           testCase.verifyNotEmpty(group_number);
           testCase.verifyGreaterThan(group_number, 0);
           testCase.verifyNotEmpty(members);
           
           % check members and mail
           testCase.verifyGreaterThan(length(members), 0);
           testCase.verifyEqual(length(members), length(mail));
           
           % check D, R, T, p, elapsed_time;
           testCase.verifyNotEmpty(D);
           testCase.verifyTrue(sum(D > 0,'all') > 0);
           
           testCase.verifyNotEmpty(R);
           testCase.verifyTrue(sum(R > 0,'all') > 0);
           
           testCase.verifyNotEmpty(T);
           testCase.verifyTrue(sum(T > 0,'all') > 0);
           
           testCase.verifyNotEmpty(p);
           testCase.verifyTrue(p > 0);
           
           testCase.verifyNotEmpty(elapsed_time);
           testCase.verify(elapsed_time > 0);
           
        end
        
        function check_toolboxes(testCase)
            [~,pList1] = matlab.codetools.requiredFilesAndProducts('verify_dmap.m');
            [~,pList2] = matlab.codetools.requiredFilesAndProducts('disparity_map.m');
            [~,pList3] = matlab.codetools.requiredFilesAndProducts('verify_dmap.m');
            actOut = [length(pList1), length(pList2), length(pList3)];
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