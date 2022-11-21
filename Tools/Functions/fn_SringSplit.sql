IF EXISTS (SELECT * FROM   sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[fn_SringSplit]') AND type IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
BEGIN
	PRINT '[DROP]:[DROPPING THE Function fn_SringSplit]';
	DROP FUNCTION [dbo].[fn_SringSplit]
END
GO
PRINT '[CREATE]:[CREATING THE VIEW fn_SringSplit]';
GO

CREATE FUNCTION [dbo].[fn_SringSplit] (@delimiter char(1), @value varchar(512))
 RETURNS table
AS
RETURN (
WITH Pieces(id, start, stop) AS (
  SELECT 1, 1, CHARINDEX(@delimiter, @value)
  UNION ALL
  SELECT id + 1, stop + 1, CHARINDEX(@delimiter, @value, stop + 1)
  FROM Pieces
  WHERE stop > 0
)
SELECT id,
  SUBSTRING(@value, start, CASE WHEN stop > 0 THEN stop-start ELSE 512 END) AS result
FROM Pieces
)
GO