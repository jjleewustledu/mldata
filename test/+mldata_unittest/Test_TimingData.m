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
        datetimeMeas = datetime(2017,1,1,9,0,0,0.0, 'TimeZone', 'America/Chicago')
 		registry
 		testObj
    end
    
	methods (Test)
        function test_timing2num(this)
            % retains subseconds
            
            this.assertEqual(this.testObj.timing2num(milliseconds(1123)), 1.123);
            this.assertEqual(this.testObj.timing2num(seconds(1.123)), 1.123);
            this.assertEqual(this.testObj.timing2num(minutes(1.123/60)), 1.123);
            this.assertEqual(this.testObj.timing2num(hours(1.123/3600)), 1.123);
            
            dt = datetime(2017,1,1,9,0,1,123, 'TimeZone', 'America/Chicago');        
            this.assertEqual(this.testObj.timing2num(dt), 1.123);            
        end
        function test_ctor_times(this)
 			obj = mldata.TimingData( ...
                'times', [0 1 2 4 8], ...
                'datetimeMeasured', this.datetimeMeas);
            this.verifyCtorVariations(obj);
            
 			obj = mldata.TimingData( ...
                'times', [0.123 1.123 2.123 4.123 8.123], ...
                'datetimeMeasured', this.datetimeMeas);
            this.verifyEqual(obj.times, [0.123 1.123 2.123 4.123 8.123]);
            
 			obj = mldata.TimingData( ...
                'times', this.datetimeMeas + seconds([0 1 2 4 8]), ...
                'datetimeMeasured', this.datetimeMeas);
            this.verifyCtorVariations(obj);
        end
        function test_ctor_duration(this)
        end
        function test_ctor_datetime(this)
        end
        function test_taus(this)
            % get
            this.verifyEqual(this.testObj.taus, ones(1,100));
            % set
            this.testObj.taus = 0.01:0.01:1;
            this.verifyEqual(this.testObj.taus, 0.01:0.01:1);
        end
        function test_times(this)
            % get
            this.verifyEqual(this.testObj.times, 100:199);
            % set
            this.testObj.times = 0:99;
            this.verifyEqual(this.testObj.times, 0:99);
        end
        function test_time0(this)
            % get
            this.verifyEqual(this.testObj.time0, 100);
            % set
            this.testObj.time0 = 101;
            this.verifyEqual(this.testObj.index0, 2);
            this.verifyEqual(this.testObj.time0, 101);
            this.verifyEqual(this.testObj.datetime0, this.datetimeMeas + seconds(1));
            this.verifyEqual(this.testObj.timeWindow, 98);
            this.verifyEqual(this.testObj.datetimeWindow, duration(0,0,98)); 
            % set again
            this.testObj.time0 = 111;
            this.verifyEqual(this.testObj.index0, 12);
            this.verifyEqual(this.testObj.time0, 111);
            this.verifyEqual(this.testObj.datetime0, this.datetimeMeas + seconds(11));
            this.verifyEqual(this.testObj.timeWindow, 88);
            this.verifyEqual(this.testObj.datetimeWindow, duration(0,0,88)); 
            % set again
            this.testObj.time0 = 100;
            this.verifyEqual(this.testObj.index0, 1);
            this.verifyEqual(this.testObj.time0, 100);
            this.verifyEqual(this.testObj.datetime0, this.datetimeMeas);
            this.verifyEqual(this.testObj.timeWindow, 99);
            this.verifyEqual(this.testObj.datetimeWindow, duration(0,0,99)); 
        end
        function test_timeF(this)
            % get
            this.verifyEqual(this.testObj.timeF, 199);
            % set
            this.testObj.timeF = 198;
            this.verifyEqual(this.testObj.indexF, 99);
            this.verifyEqual(this.testObj.timeF, 198);
            this.verifyEqual(this.testObj.datetimeF, this.datetimeMeas + seconds(98));
            this.verifyEqual(this.testObj.timeWindow, 98);
            this.verifyEqual(this.testObj.datetimeWindow, duration(0,0,98)); 
        end
		function test_timeDuration(this)
            % get
            this.verifyEqual(this.testObj.timeWindow, 99);         
            % set
            this.testObj.timeWindow = 50;
            this.verifyEqual(this.testObj.indexF, 51);
            this.verifyEqual(this.testObj.timeF, 150);
            this.verifyEqual(this.testObj.datetimeF, this.datetimeMeas + seconds(50));
            this.verifyEqual(this.testObj.timeWindow, 50);
            this.verifyEqual(this.testObj.datetimeWindow, duration(0,0,50));
        end
        function test_datetime(this)
            % get
            dt_ = this.testObj.datetime;
            this.verifyEqual(dt_(1),   this.datetimeMeas);
            this.verifyEqual(dt_(end), this.datetimeMeas + seconds(99));
        end
        function test_datetime1(this)
            this.testObj.index0 = 2;
            dt_ = this.testObj.datetime; this.verifyEqual(dt_(1),   this.datetimeMeas + seconds(1));
        end
        function test_datetime2(this)
            this.testObj.time0 = 101;
            dt_ = this.testObj.datetime; this.verifyEqual(dt_(1),   this.datetimeMeas + seconds(1));
        end
        function test_datetime3(this)
            this.testObj.datetime0 = this.datetimeMeas + seconds(1);
            dt_ = this.testObj.datetime; this.verifyEqual(dt_(1),   this.datetimeMeas + seconds(1));
        end
        function test_datetime4(this)
            this.testObj.timeWindow = 98;
            dt_ = this.testObj.datetime; this.verifyEqual(dt_(end), this.datetimeMeas + seconds(98));
        end
        function test_datetime5(this)
            this.testObj.datetimeWindow = seconds(98);
            dt_ = this.testObj.datetime; this.verifyEqual(dt_(end), this.datetimeMeas + seconds(98));
        end
        function test_datetime0(this)
            % get
            this.verifyEqual(this.testObj.datetime0, this.datetimeMeas);
            % set
            this.testObj.datetime0 = this.datetimeMeas + seconds(1);
            this.verifyEqual(this.testObj.index0, 2);
            this.verifyEqual(this.testObj.time0, 101);
            this.verifyEqual(this.testObj.datetime0, this.datetimeMeas + seconds(1));
            this.verifyEqual(this.testObj.timeWindow, 98);
            this.verifyEqual(this.testObj.datetimeWindow, duration(0,0,98));
        end
        function test_datetimeF(this)
            % get
            this.verifyEqual(this.testObj.datetimeF, this.datetimeMeas + seconds(99));
            % set
            this.testObj.datetimeF = this.datetimeMeas + seconds(98);
            this.verifyEqual(this.testObj.indexF, 99);
            this.verifyEqual(this.testObj.timeF, 198);
            this.verifyEqual(this.testObj.datetimeF, this.datetimeMeas + seconds(98));
            this.verifyEqual(this.testObj.timeWindow, 98);
            this.verifyEqual(this.testObj.datetimeWindow, duration(0,0,98));
        end
		function test_datetimeDuration(this)
            % get
            this.verifyEqual(this.testObj.datetimeWindow, seconds(99));         
            % set
            this.testObj.datetimeWindow = seconds(50);
            this.verifyEqual(this.testObj.indexF, 51);
            this.verifyEqual(this.testObj.timeF, 150);
            this.verifyEqual(this.testObj.datetimeF, this.datetimeMeas + seconds(50));
            this.verifyEqual(this.testObj.timeWindow, 50);
            this.verifyEqual(this.testObj.datetimeWindow, duration(0,0,50)); 
        end
        function test_index0(this)
            % get            
            this.verifyEqual(this.testObj.index0, 1);
            % set
            this.testObj.index0 = 51;
            this.verifyEqual(this.testObj.index0, 51);
            this.verifyEqual(this.testObj.time0, 150);
            this.verifyEqual(this.testObj.datetime0, this.datetimeMeas + seconds(50));
            this.verifyEqual(this.testObj.timeWindow, 49);
            this.verifyEqual(this.testObj.datetimeWindow, duration(0,0,49)); 
        end
        function test_indexF(this)
            % get
            this.verifyEqual(this.testObj.indexF, 100);
            % set
            this.testObj.indexF = 51;
            this.verifyEqual(this.testObj.indexF, 51);
            this.verifyEqual(this.testObj.timeF, 150);
            this.verifyEqual(this.testObj.datetimeF, this.datetimeMeas + seconds(50));
            this.verifyEqual(this.testObj.timeWindow, 50);
            this.verifyEqual(this.testObj.datetimeWindow, duration(0,0,50)); 
        end
        function test_dt(this)
            % get            
            this.verifyEqual(this.testObj.dt, 0.5);
            % set
            this.testObj.dt = 1;
            this.verifyEqual(this.testObj.dt, 1);
            this.verifyEqual(this.testObj.timeInterpolants, 100:199);
        end
        
        function test_timeInterpolants(this)
            this.verifyEqual(this.testObj.timeInterpolants, 100:0.5:199);
            this.testObj.dt = 0.25;
            this.verifyEqual(this.testObj.timeInterpolants, 100:0.25:199);
        end
        
        function test_resetTimeLimits(this)
            this.testObj.time0 = 133;
            this.testObj.timeF = 166;
            this.testObj.resetTimeLimits;
            this.verifyEqual(this.testObj.time0, 100);
            this.verifyEqual(this.testObj.timeF, 199);
            
            this.testObj.index0 = 33;
            this.testObj.indexF = 66;
            this.testObj.resetTimeLimits;
            this.verifyEqual(this.testObj.index0, 1);
            this.verifyEqual(this.testObj.indexF, 100);
            
            this.testObj.datetime0 = this.datetimeMeas + seconds(33);
            this.testObj.datetimeF = this.datetimeMeas + seconds(66);
            this.testObj.resetTimeLimits;
            this.verifyEqual(this.testObj.datetime0, this.datetimeMeas);
            this.verifyEqual(this.testObj.datetimeF, this.datetimeMeas + seconds(99));
        end
    end

 	methods (TestClassSetup)
		function setupTimingData(this)
 		end
	end

 	methods (TestMethodSetup)
		function setupTimingDataTest(this)
 			this.testObj = mldata.TimingData( ...
                'times', 100:199, ...
                'datetimeMeasured', this.datetimeMeas);
 			this.addTeardown(@this.cleanFiles);
 		end
	end
    
    %% PRIVATE

	properties (Access = private)
 	end

	methods (Access = private)
        function assignLargeTimeDuration(this)
            this.testObj.timeWindow = 100;
        end
		function cleanFiles(this)
 		end
        function verifyCtorVariations(this, obj)
            this.verifyEqual(obj.taus, [1 1 2 4 4]);
            this.verifyEqual(obj.times, [0 1 2 4 8]);
            this.verifyEqual(obj.timeInterpolants, 0:0.5:8);
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

