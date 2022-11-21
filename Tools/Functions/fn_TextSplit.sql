SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[fn_TextSplit]
(
	@txtInput VARCHAR(2000),
	@txtDelimiter VARCHAR(1) = '|'
)
RETURNS 
@tblOutput TABLE 
(
	txtResult VARCHAR(255)
)
AS
BEGIN
	
	DECLARE @intStart int
	SET @intStart = 1

	IF @txtInput <> @txtDelimiter
	BEGIN
		IF LEFT(REVERSE(@txtInput), 1) <>  @txtDelimiter
		BEGIN
			SET @txtInput = @txtInput + @txtDelimiter
		END

		IF CHARINDEX( @txtDelimiter, @txtInput, @intStart) = 0
		BEGIN
			INSERT INTO @tblOutput(txtResult)
			SELECT @txtInput
	
			RETURN
		END

		WHILE CHARINDEX( @txtDelimiter, @txtInput, @intStart) > 0
		BEGIN
			INSERT INTO @tblOutput(txtResult)
			SELECT SUBSTRING(@txtInput, @intStart, CHARINDEX( @txtDelimiter, @txtInput, @intStart) - @intStart)
			SET @intStart = CHARINDEX( @txtDelimiter, @txtInput, @intStart) + 1		
		END
	END
	RETURN 
END
GO


