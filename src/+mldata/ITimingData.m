classdef ITimingData 
	%% ITIMINGDATA  

	%  $Revision$
 	%  was created 30-Jan-2017 02:04:15
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mldata/src/+mldata.
 	%% It was developed on Matlab 9.1.0.441655 (R2016b) for MACI64.
 	

	properties (Abstract)
        datetime0
        dt
        time0
        timeF
        timeDuration 
        times
        timeMidpoints % length() <= length(times)
        taus          % length() <= length(times)
 	end

    methods (Abstract)
        length(this)
        timeInterpolants(this)
        timeMidpointInterpolants(this)
        tauInterpolants(this)
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

