classdef Test_TimingData < matlab.unittest.TestCase
	%% TEST_TIMINGDATA 

	%  Usage:  >> results = run(mldata_unittest.Test_TimingData)
 	%          >> result  = run(mldata_unittest.Test_TimingData, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 15-Jun-2017 17:34:34 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/Local/src/mlcvl/mldata/test/+mldata_unittest.
 	%% It was developed on Matlab 9.2.0.538062 (R2017a) for MACI64.  Copyright 2017 John Joowon Lee.
 	
	properties
 		registry
 		testObj
 	end

	methods (Test)
		function test_timeDuration(this)
 			import mldata.*;
            this.verifyEqual(this.testObj.timeDuration, 99);
            this.testObj.timeDuration = 89;
            this.verifyEqual(this.testObj.timeDuration, 89);
            this.verifyEqual(this.testObj.time0, 0);
            this.verifyEqual(this.testObj.timeF, 89);
            this.verifyWarning(@this.assignLargeTimeDuration, 'mldata:setPropertyIgnored', 'TimingData.set.timeDuration');           
 		end
    end

 	methods (TestClassSetup)
		function setupTimingData(this)
 			import mldata.*;
 			this.testObj_ = TimingData( ...
                'times', [0 99], ...
                'datetime0', datetime('1-Jan-2017 09:00:00'));
 		end
	end

 	methods (TestMethodSetup)
		function setupTimingDataTest(this)
 			this.testObj = this.testObj_;
 			this.addTeardown(@this.cleanFiles);
 		end
	end

	properties (Access = private)
 		testObj_
 	end

	methods (Access = private)
		function cleanFiles(this)
 		end
    end
    
    %% PRIVATE
    
    methods (Access = private)        
        function assignLargeTimeDuration(this)
            this.testObj.timeDuration = 100;
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

