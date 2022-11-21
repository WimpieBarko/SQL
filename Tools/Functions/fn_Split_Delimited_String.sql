IF EXISTS (SELECT * FROM sysobjects WHERE [name] = 'fn_Split_Delimited_String' AND xtype IN ('FN', 'IF', 'TF'))
BEGIN
	PRINT '[DROP]:[Dropping the Function: {fn_Split_Delimited_String}]'
	DROP FUNCTION [fn_Split_Delimited_String]
END
GO

PRINT '[CREATE]:[Creating the Function: {fn_Split_Delimited_String}]'
GO

CREATE FUNCTION [fn_Split_Delimited_String] 
(
		@txtSQLQuery  VARCHAR(MAX), 
    @txtDelimitor CHAR(1)
)

RETURNS @RESULT TABLE(txtValue VARCHAR(MAX),intValuePosition INT) 
AS 
  BEGIN 
      DECLARE @intDelimitorPostion INT = CHARINDEX(@txtDelimitor, @txtSQLQuery), 
              @txtValue VARCHAR(MAX), 
              @intStartPostion INT = 1,
							@intValuePosition INT

      IF @intDelimitorPostion = 0 
      BEGIN 
            INSERT INTO @RESULT 
            VALUES (@txtSQLQuery, @intValuePosition) 

            RETURN 
      END 

      SET @txtSQLQuery = @txtSQLQuery + @txtDelimitor 

      WHILE @intDelimitorPostion > 0 
      BEGIN 
            SET @txtValue = SUBSTRING(@txtSQLQuery, @intStartPostion, @intDelimitorPostion - @intStartPostion) 
						SET @intValuePosition = CHARINDEX(@txtValue, @txtSQLQuery)

            IF( @txtValue <> '' ) 
						BEGIN
							INSERT INTO @RESULT(txtValue, intValuePosition)
							VALUES (@txtValue,@intValuePosition) 
						END

            SET @intStartPostion = @intDelimitorPostion + 1 
            SET @intDelimitorPostion = CHARINDEX(@txtDelimitor, @txtSQLQuery, @intStartPostion) 
        END 

      RETURN 
  END