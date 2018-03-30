classdef NNICUData < mldata.IFacilityData
	%% NNICUDATA  

	%  $Revision$
 	%  was created 19-Jan-2018 16:40:44 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/Local/src/mlcvl/mldata/src/+mldata.
 	%% It was developed on Matlab 9.3.0.713579 (R2017b) for MACI64.  Copyright 2018 John Joowon Lee.
 	
	properties
 		
 	end

	methods 
		  
 		function this = NNICUData(varargin)
 			%% NNICUDATA
 			%  Usage:  this = NNICUData()

 			this = this@mldata.IFacilityData(varargin{:});
 		end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

