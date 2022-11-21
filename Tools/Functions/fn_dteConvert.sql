IF EXISTS (SELECT * FROM   sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[fn_dteConvert]') AND type IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
BEGIN
	PRINT '[DROP]:[DROPPING THE Function fn_dteConvert]';
	DROP FUNCTION [dbo].[fn_dteConvert]
END
GO
PRINT '[CREATE]:[CREATING THE VIEW fn_dteConvert]';
GO

CREATE FUNCTION [dbo].[fn_dteConvert]
(
    @dteDate DATETIME
)
RETURNS DATETIME
AS
BEGIN
	RETURN (SELECT CONVERT(VARCHAR, @dteDate, 23))
END
GO


