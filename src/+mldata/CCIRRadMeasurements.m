classdef CCIRRadMeasurements < mldata.IManualMeasurements
	%% CCIRRADMEASUREMENTS  

	%  $Revision$
 	%  was created 19-Jan-2018 17:16:28 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/Local/src/mlcvl/mldata/src/+mldata.
 	%% It was developed on Matlab 9.3.0.713579 (R2017b) for MACI64.  Copyright 2018 John Joowon Lee.
 	
	properties (Dependent)
        countsLogFdg
        countsLogOo
        tracerAdminLog
        clocks
        doseCalibrator
        phantom
        wellCounter        
    end
    
    methods (Static)
        function this = loadDate(aDate)
            assert(isdatetime(aDate));
            if (isempty(aDate.TimeZone))
                aDate.TimeZone = mldata.TimingData.PREFERRED_TIMEZONE;
            end
            import mldata.*;
            this = CCIRRadMeasurements.load( ...
                CCIRRadMeasurements.date2filename(aDate));
        end
        function this = load(fqfn)
            this = mldata.CCIRRadMeasurements;
            this = this.readtables(fqfn);
        end
        function fn = date2filename(aDate)
            mon = lower(month(aDate, 'shortname'));
            fn = fullfile(getenv('CCIR_RAD_MEASUREMENTS_DIR'), ...
                sprintf('CCIRRadMeasurements %i%s%i.xlsx', aDate.Year, mon{1}, aDate.Day));
        end
    end

	methods 
        
        %% GET
        
        %%
        
        function dt = datetime(this)
            dt = NaT;
        end
    end
    
    %% PROTECTED
    
    properties (Access = protected)
        countsLogFdg_
        countsLogOo_
        tracerAdminLog_
        clocks_
        doseCalibrator_
        phantom_
        wellCounter_
        
        tableNames = { ...
            'countsLogFdg_' 'countsLogOo_' 'tracerAdminLog_' ...
            'clocks_' 'doseCalibrator_' 'phantom_' ...
            'wellCounter_'}
        sheetNames = { ...
            'Radiation Counts Log - Runs' 'Radiation Counts Log - Runs-1' 'Radiation Counts Log - Runs-2' ...
            'Twilite Calibration - Runs' 'Twilite Calibration - Runs-2' 'Twilite Calibration - Runs-2-1' ...
            'Twilite Calibration - Runs-2-2'}
        hasRowNames = [1 1 1 1 1 0 0]
        datetimeTypes = {'exceldatenum' 'exceldatenum' 'exceldatenum' 'exceldatenum' 'exceldatenum' 'exceldatenum' 'exceldatenum' }
    end
    
    methods (Access = protected)
        function this = readtables(this, fqfn)
            fprintf('mldata.CCIRRadMeasurements.readtables:  reading %s\n', fqfn);
            for t = 1:length(this.tableNames)
                this.(this.tableNames{t}) = this.readtable(fqfn, ...
                    this.sheetNames{t}, this.hasRowNames(t), this.datetimeTypes{t});
            end
        end
        function tbl = readtable(this, fqfn, sheet, hasRowNames, datetimeType)            
            warning('off', 'MATLAB:table:ModifiedVarnames');   
            warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');  
            warning('off', 'MATLAB:table:ModifiedDimnames');
            
            tbl = this.correctTableToReferenceDate( ...
                readtable(fqfn, ...
                'Sheet', sheet, ...
                'FileType', 'spreadsheet', ...
                'ReadVariableNames', true, 'ReadRowNames', hasRowNames, ...
                'DatetimeType', datetimeType));
            
            warning('on', 'MATLAB:table:ModifiedVarnames');
            warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');
            warning('on', 'MATLAB:table:ModifiedDimnames');
        end
        function tbl = correctTableToReferenceDate(this, tbl)
        end
        
 		function this = CCIRRadMeasurements(varargin)
        end        
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

