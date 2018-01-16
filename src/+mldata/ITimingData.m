classdef (Abstract) ITimingData 
	%% ITIMINGDATA  

	%  $Revision$
 	%  was created 30-Jan-2017 02:04:15
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mldata/src/+mldata.
 	%% It was developed on Matlab 9.1.0.441655 (R2016b) for MACI64.
 	

	properties (Abstract)
        times         % frame starts
        timeMidpoints % frame middle times, length() == length(times)  
        taus          % frame durations,    length() == length(times)    
        time0         % selects time window; >= this.time(1)                
        timeF         % selects time window; <= this.times(end)
        index0        % index of time0
        indexF        % index of timeF
        timeDuration  % timeF - time0     
        datetime0     % measured datetime of this.time(1)
        dt            % for timeInterpolants; <= min(taus)/2   
 	end

    methods (Abstract)
        length(this)
        timeInterpolants(this)
        timeMidpointInterpolants(this)
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

