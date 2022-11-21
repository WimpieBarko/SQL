--===================================================================================================--
--==    File Name:    fn_FormatBytes.sql                                                           ==--
--==    Author:       Wimpie Norman                                                                ==--
--==    Date:         02/11/2022                                                                   ==--
--==    Description:  Script to format/convert a data value.                                       ==--
--===================================================================================================--

IF EXISTS (SELECT * FROM   sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[fn_FormatBytes]') AND TYPE IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
BEGIN
	PRINT '[DROP]:[DROPPING THE Function fn_FormatBytes]';
	DROP FUNCTION [dbo].[fn_FormatBytes]
END
GO
PRINT '[CREATE]:[CREATING THE VIEW fn_FormatBytes]';
GO

CREATE FUNCTION [dbo].[fn_FormatBytes] 
( 
	@decInputNumber DECIMAL(38,7), 
	@txtInputUOM VARCHAR(32)
) 
RETURNS VARCHAR(20) 
WITH SCHEMABINDING 
AS 
BEGIN 
-- Declare the return variable here 
DECLARE @Output VARCHAR(48) 
DECLARE @Prefix MONEY 
DECLARE @Suffix VARCHAR(6) 
DECLARE @Multiplier DECIMAL(38,2) 
DECLARE @Bytes DECIMAL(38,2)

SELECT @Multiplier = 
CASE @txtInputUOM 
WHEN 'Bytes' THEN 1 
WHEN 'Byte' THEN 1 
WHEN 'B' THEN 1 
WHEN 'Kilobytes' THEN 1024 
WHEN 'Kilobyte' THEN 1024 
WHEN 'KB' THEN 1024 
WHEN 'Megabytes' THEN 1048576 
WHEN 'Megabyte' THEN 1048576 
WHEN 'MB' THEN 1048576 
WHEN 'Gigabytes' THEN 1073741824 
WHEN 'Gigabyte' THEN 1073741824 
WHEN 'GB' THEN 1073741824 
WHEN 'Terabytes' THEN 1099511627776 
WHEN 'Terabyte' THEN 1099511627776 
WHEN 'TB' THEN 1099511627776 
WHEN 'Petabytes' THEN 1125899906842624 
WHEN 'Petabyte' THEN 1125899906842624 
WHEN 'PB' THEN 1125899906842624 
WHEN 'Exabytes' THEN 1152921504606846976 
WHEN 'Exabyte' THEN 1152921504606846976 
WHEN 'EB' THEN 1152921504606846976 
WHEN 'Zettabytes' THEN 1180591620717411303424 
WHEN 'Zettabyte' THEN 1180591620717411303424 
WHEN 'ZB' THEN 1180591620717411303424 
WHEN 'Yottabytes' THEN 1208925819614629174706176 
WHEN 'Yottabyte' THEN 1208925819614629174706176 
WHEN 'YB' THEN 1208925819614629174706176 
WHEN 'Brontobytes' THEN 1237940039285380274899124224 
WHEN 'Brontobyte' THEN 1237940039285380274899124224 
WHEN 'BB' THEN 1237940039285380274899124224 
WHEN 'Geopbytes' THEN 1267650600228229401496703205376 
WHEN 'Geopbyte' THEN 1267650600228229401496703205376 
END
SELECT @Bytes = @decInputNumber*@Multiplier
SELECT @Prefix = 
CASE 
WHEN ABS(@Bytes) < 1024 THEN @Bytes --bytes 
WHEN ABS(@Bytes) < 1048576 THEN (@Bytes/1024) --kb 
WHEN ABS(@Bytes) < 1073741824 THEN (@Bytes/1048576) --mb 
WHEN ABS(@Bytes) < 1099511627776 THEN (@Bytes/1073741824) --gb 
WHEN ABS(@Bytes) < 1125899906842624 THEN (@Bytes/1099511627776) --tb 
WHEN ABS(@Bytes) < 1152921504606846976 THEN (@Bytes/1125899906842624) --pb 
WHEN ABS(@Bytes) < 1180591620717411303424 THEN (@Bytes/1152921504606846976) --eb 
WHEN ABS(@Bytes) < 1208925819614629174706176 THEN (@Bytes/1180591620717411303424) --zb 
WHEN ABS(@Bytes) < 1237940039285380274899124224 THEN (@Bytes/1208925819614629174706176) --yb 
WHEN ABS(@Bytes) < 1267650600228229401496703205376 THEN (@Bytes/1237940039285380274899124224) --bb 
ELSE (@Bytes/1267650600228229401496703205376) --geopbytes 
END, 
@Suffix = 
CASE 
WHEN ABS(@Bytes) < 1024 THEN ' Bytes' 
WHEN ABS(@Bytes) < 1048576 THEN ' KB' 
WHEN ABS(@Bytes) < 1073741824 THEN ' MB' 
WHEN ABS(@Bytes) < 1099511627776 THEN ' GB' 
WHEN ABS(@Bytes) < 1125899906842624 THEN ' TB' 
WHEN ABS(@Bytes) < 1152921504606846976 THEN ' PB' 
WHEN ABS(@Bytes) < 1180591620717411303424 THEN ' EB' 
WHEN ABS(@Bytes) < 1208925819614629174706176 THEN ' ZB' 
WHEN ABS(@Bytes) < 1237940039285380274899124224 THEN ' YB' 
WHEN ABS(@Bytes) < 1267650600228229401496703205376 THEN ' BB' 
ELSE ' Geopbytes' 
END
-- Return the result of the function 
SELECT @Output = CAST(@Prefix AS VARCHAR(39)) + @Suffix 
RETURN @Output
END 
GO