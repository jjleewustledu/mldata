classdef CCIRData < mldata.IFacilityData
	%% CCIRDATA  

	%  $Revision$
 	%  was created 19-Jan-2018 16:40:32 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/Local/src/mlcvl/mldata/src/+mldata.
 	%% It was developed on Matlab 9.3.0.713579 (R2017b) for MACI64.  Copyright 2018 John Joowon Lee.
 	
	properties (Dependent)
        calibrationData
        radiationData
        sessionData
        sessionDate
        studyData
 	end

	methods 
		  
 		function this = CCIRData(varargin)
 			%% CCIRDATA
 			%  Usage:  this = CCIRData()

 			this = this@mldata.IFacilityData(varargin{:});
 		end
    end 
    
    %% PRIVATE
    
    properties (Access = private)
        ccirRadMeasurements_
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

