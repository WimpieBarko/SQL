IF EXISTS (SELECT * FROM   sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[fn_TitleCase]') AND type IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
BEGIN
	PRINT '[DROP]:[DROPPING THE Function fn_TitleCase]';
	DROP FUNCTION [dbo].[fn_TitleCase]
END
GO
PRINT '[CREATE]:[CREATING THE VIEW fn_TitleCase]';
GO

CREATE FUNCTION dbo.fn_TitleCase
(
    @Input nvarchar(1000)
)
RETURNS TABLE
AS
RETURN
SELECT Item = STRING_AGG(splits.Word, ' ')
FROM (
    SELECT Word = UPPER(LEFT(value, 1)) + LOWER(RIGHT(value, LEN(value) - 1))
    FROM STRING_SPLIT(@Input, ' ')
    ) splits(Word);
GO