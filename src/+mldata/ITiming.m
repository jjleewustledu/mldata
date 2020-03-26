classdef (Abstract) ITiming < handle
	%% ITIMING  

	%  $Revision$
 	%  was created 17-Oct-2018 17:02:56 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlkinetics/src/+mlkinetics.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
 	
	properties (Abstract)
        datetime0            % datetime of time0
        datetimeF            % datetime of timeF
        datetimeInterpolants % uniform sampling ~ 1/dt
        datetimeMeasured     % datetime of measurement of times(1)
        datetimes            % synonym for datetime(), delimited by time0, timeF
        dt                   % for timeInterpolants; <= min(diff(times))
        index0               % index of time0
        indexF               % index of timeF
        indices              % all stored indices
        time0                % adjustable time window start; >= time(1)                
        timeF                % adjustable time window end; <= times(end)
        timeInterpolants     % uniform sampling ~ 1/dt
        times                % all stored times
    end 
    
    methods (Abstract)
        datetime(this)        % overloads datetime(), delimited by time0, timeF
        duration(this)        % times as seconds
        resetTimeLimits(this) % time0 := times(1); timeF := times(end)
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

