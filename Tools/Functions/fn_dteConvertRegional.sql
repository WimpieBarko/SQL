IF EXISTS (SELECT * FROM   sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[fn_dteConvertRegional]') AND type IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
BEGIN
	PRINT '[DROP]:[DROPPING THE Function fn_dteConvertRegional]';
	DROP FUNCTION [dbo].[fn_dteConvertRegional]
END
GO
PRINT '[CREATE]:[CREATING THE VIEW fn_dteConvertRegional]';
GO

CREATE FUNCTION fn_dteConvertRegional
(
  @d DATETIME,
  @style TINYINT
)
RETURNS CHAR(10)
AS
BEGIN
    RETURN (SELECT CONVERT(VARCHAR, CONVERT(DATE, @d), @style));
END
GO

DECLARE @d DATETIME;
SELECT @d = '2022-06-12 20:01:25.5739295 +02:00';

SELECT 
 --dbo.ConvertDate(@d),
 dbo.fn_dteConvert('2022-06-12'),
 dbo.fn_dteConvertRegional(@d, 23),
 dbo.fn_dteConvertRegional(@d, 120);