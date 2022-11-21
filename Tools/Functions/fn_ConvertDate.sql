SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[ConvertDate](@txtDate varchar(50))
RETURNS DATETIME
AS
BEGIN
	DECLARE @dteDate	datetime
	DECLARE @txtTemp	varchar(50)
	DECLARE @Year		int
	DECLARE @Month		int
	DECLARE @Day		int

	SET @txtTemp = RTRIM(@txtDate)
	SET @dteDate = NULL

	IF ISNULL(@txtTemp, '') = ''
		RETURN NULL
		
	IF LEN(@txtTemp) = 4
	BEGIN
		SET @Year = CAST(@txtTemp AS int)
		SET @Month = 1
		SET @Day = 1
	END
	
	IF LEN(@txtTemp) = 6
	BEGIN
		SET @Year = CAST(LEFT(@txtTemp, 4) AS int)
		SET @Month = CAST(SUBSTRING(@txtTemp, 5, 2) AS int)
		SET @Day = 1
	END

	IF LEN(@txtTemp) = 8
	BEGIN
		SET @Year = CAST(LEFT(@txtTemp, 4) AS int)
		SET @Month = CAST(SUBSTRING(@txtTemp, 5, 2) AS int)
		SET @Day = CAST(RIGHT(@txtTemp, 2) AS int)
	END
	
	IF @Year < 1900 OR @Year > 2100
		RETURN NULL
	IF @Month < 1 OR @Month > 12
		RETURN NULL
	IF @Day < 1 OR @Day > 31
		RETURN NULL

	SET @dteDate = CAST(CAST(@Year AS varchar) + '-' + CAST(@Month AS varchar) + '-' + CAST(@Day AS varchar) AS datetime)

	RETURN @dteDate
END
GO


