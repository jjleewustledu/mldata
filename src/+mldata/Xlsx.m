classdef (Abstract) Xlsx < handle & dynamicprops & mlio.AbstractHandleIO
	%% XLSX  

	%  $Revision$
 	%  was created 18-Oct-2018 18:02:09 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mldata/src/+mldata.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
 	
	properties (Constant) 		
        EXCEL_INITIAL_DATETIME = datetime(1899,12,31)
        PREFERRED_TIMEZONE = mlkinetics.Timing.PREFERRED_TIMEZONE
        SERIAL_DAYS_1900_TO_1904 = 1462	
 	end

    %% PROTECTED
    
	methods (Access = protected)	
        function        addgetprop(this, varargin)
            ip = inputParser;
            addRequired(ip, 'prop', @ischar);
            addOptional(ip, 'init_val', []);
            parse(ip, varargin{:});
            
            p = addprop(this, ip.Results.prop);
            this.(ip.Results.prop) = ip.Results.init_val;
            p.GetMethod = @getter;
            p.SetMethod = @setter;
            
            function g = getter(this)
                g = this.(ip.Results.prop);
            end
            function     setter(this, s)
                this.(ip.Results.prop) = s;
                %throwAsCaller(MException('mldata:AttributeError', 'Xlsx.addgetprop only permits getting dyn props'));
            end
        end
        function tbl  = correctDates2(this, tbl, varargin)
            vars = tbl.Properties.VariableNames;
            for v = 1:length(vars)
                col = tbl.(vars{v});
                if (this.hasTimings(vars{v}))
                    if (any(isnumeric(col)))                        
                        lrows = logical(~isnan(col) & ~isempty(col));
                        dt_   = this.datetimeConvertFromExcel2(tbl{lrows,v});
                        col   = NaT(size(col));
                        col.TimeZone = dt_.TimeZone;
                        col(lrows) = dt_;
                    end
                    if (any(isdatetime(col)))
                        col.TimeZone = this.PREFERRED_TIMEZONE;
                    end
                end
                tbl.(vars{v}) = col;
            end
        end
        function dati = datetimeConvertFromExcel(this, days)
            assert(isnumeric(days));
            dati = datetime(days + this.SERIAL_DAYS_1900_TO_1904, 'ConvertFrom', 'excel');
            dati.TimeZone = this.PREFERRED_TIMEZONE;
        end
        function dati = datetimeConvertFromExcel2(this, days)
            %% DATETIMECONVERTFROMEXCEL2
            %  addresses what may be an artefact of linking cells across sheets in Numbers/Excel on MacOS
            
            assert(isnumeric(days));
            dati = datetime(days, 'ConvertFrom', 'excel') + 2*this.SERIAL_DAYS_1900_TO_1904;
            dati.TimeZone = this.PREFERRED_TIMEZONE;
        end
        function tf   = equivDates(~, dt1, dt2)
            d1 = datetime(dt1.Year, dt1.Month, dt1.Day);
            d2 = datetime(dt2.Year, dt2.Month, dt2.Day);
            tf = d1 == d2;
        end
        function s    = excelNum2sec(this, excelnum)
            import mlkinetics.*;
            pm            = sign(excelnum);
            dt_           = datetime(abs(excelnum), 'ConvertFrom', 'excel');
            dt_.TimeZone  = this.PREFERRED_TIMEZONE;
            dt__          = datetime(dt_.Year, dt_.Month, dt_.Day);
            dt__.TimeZone = this.PREFERRED_TIMEZONE;
            s             = pm*seconds(dt_ - dt__);
        end
        
 		function this = Xlsx(varargin)
 		end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

