classdef Test_CCIRRadMeasurements < matlab.unittest.TestCase
	%% TEST_CCIRRADMEASUREMENTS 

	%  Usage:  >> results = run(mldata_unittest.Test_CCIRRadMeasurements)
 	%          >> result  = run(mldata_unittest.Test_CCIRRadMeasurements, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 21-Jan-2018 15:05:06 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mldata/test/+mldata_unittest.
 	%% It was developed on Matlab 9.3.0.713579 (R2017b) for MACI64.  Copyright 2018 John Joowon Lee.
 	
	properties
        aDate
        home = '/data/nil-bluearc/raichle/PPGdata/jjlee2/Documents'
 		registry
 		testObj
 	end

	methods (Test)
		function test_afun(this)
 			import mldata.*;
 			this.assumeEqual(1,1);
 			this.verifyEqual(1,1);
 			this.assertEqual(1,1);
        end
        function test_loadDate(this)
            this.verifyClass(this.testObj, 'mldata.CCIRRadMeasurements')
        end
        function test_date(this)
        end
        function test_countsLogFdg(this)
        end
        function test_countsLogOo(this)
        end
        function test_tracerAdminLog(this)
        end
        function test_clocks(this)
        end
        function test_doseCalibrator(this)
        end
        function test_phantom(this)
        end
        function test_wellCounter(this)
        end
	end

 	methods (TestClassSetup)
		function setupCCIRRadMeasurements(this)
 			import mldata.*;
            setenv('CCIR_RAD_MEASUREMENTS_DIR', this.home);
            this.aDate = datetime('9-Sep-2016');
 			this.testObj_ = CCIRRadMeasurements.loadDate(this.aDate);
 		end
	end

 	methods (TestMethodSetup)
		function setupCCIRRadMeasurementsTest(this)
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

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

