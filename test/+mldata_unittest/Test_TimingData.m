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
        function test_times(this)
            this.verifyEqual(this.testObj.times, 100:199);
        end
        function test_timeMidpoints(this)
            this.verifyEqual(this.testObj.timeMidpoints, 100.5:1:199.5);
        end
        function test_taus(this)
            this.verifyEqual(this.testObj.taus, ones(1,100));
        end
        function test_time0(this)
            this.verifyEqual(this.testObj.time0, 100);
            this.testObj.index0 = 2;
            this.verifyEqual(this.testObj.time0, 101);
        end
        function test_timeF(this)
            this.verifyEqual(this.testObj.timeF, 199);
            this.testObj.indexF = 2;
            this.verifyEqual(this.testObj.timeF, 101);
        end
        function test_index0(this)
            this.testObj.time0 = 149.9;
            this.verifyEqual(this.testObj.index0, 51);
        end
        function test_indexF(this)
            this.testObj.timeF = 149.9;
            this.verifyEqual(this.testObj.indexF, 51);
        end
		function test_timeDuration(this)
            this.verifyEqual(this.testObj.timeDuration, 99);         
        end
        function test_datetime0(this)
            this.verifyTrue(this.testObj.datetime0 == datetime('1-Jan-2017 09:00:00', 'TimeZone', 'America/Chicago'));
        end
        
        function test_length(this)
            this.verifyEqual(length(this.testObj), 100);
        end
        function test_timeInterpolants(this)
            this.verifyEqual(this.testObj.timeInterpolants, 100:0.5:199);
            this.testObj.dt = 0.25;
            this.verifyEqual(this.testObj.timeInterpolants, 100:0.25:199);
        end
        function test_timeMidpointInterpolants(this)
            this.verifyEqual(this.testObj.timeMidpointInterpolants, 100.5:0.5:199.5);
            this.testObj.dt = 0.25;
            this.verifyEqual(this.testObj.timeMidpointInterpolants, 100.5:0.25:199.5);
        end
    end

 	methods (TestClassSetup)
		function setupTimingData(this)
 			import mldata.*;
 			this.testObj_ = TimingData( ...
                'times', 100:199, ...
                'dt', 0.5, ...
                'datetime0', datetime('1-Jan-2017 09:00:00', 'TimeZone', 'America/Chicago'));
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

