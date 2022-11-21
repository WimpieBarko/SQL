SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_GetWorkingDays]  
(  
    @startDate SMALLDATETIME,  
    @endDate SMALLDATETIME  
) 
RETURNS INT  
AS  
BEGIN 
  DECLARE @range INT, 
					@intPub INT,
					@intOut INT,
					@intYear INT

	DECLARE @tmpPublicHolidays TABLE (txtHolidayName VARCHAR(100), dteHolidayDate DATETIME NULL, blnAdhocHoliday BIT NULL)

	IF @endDate < @startDate
		SELECT @endDate = @startDate

	WHILE ISNULL(@intYear, 0) <> YEAR(@endDate)
	BEGIN
		SELECT @intYear = CASE WHEN ISNULL(@intYear, 0) = 0 THEN YEAR(@startDate) ELSE @intYear + 1 END

		;WITH tmpPublicHolidays AS (SELECT DISTINCT CONVERT(DATETIME, RIGHT('00' + DATENAME(DAY, dteHolidayDate), 2) + '-' + DATENAME(MONTH, dteHolidayDate) + '-' + CONVERT(VARCHAR, @intYear)) AS dteHolidayDate, txtHolidayName, blnAdhocHoliday
		FROM [table_name] 
		WHERE blnAdhocHoliday = 0)

		INSERT INTO @tmpPublicHolidays(dteHolidayDate, txtHolidayName, blnAdhocHoliday)
		SELECT dteHolidayDate, txtHolidayName, blnAdhocHoliday
		FROM tmpPublicHolidays 

		INSERT INTO @tmpPublicHolidays(dteHolidayDate, txtHolidayName, blnAdhocHoliday)
		SELECT tfn.dteHolidayDate, tfn.txtHolidayName, tfn.blnAdhocHoliday
		FROM dbo.fn_tmpPublicHolidays(CONVERT(DATETIME, '01 Jan ' + CONVERT(VARCHAR, @intYear)), NULL) tfn
		LEFT JOIN @tmpPublicHolidays tmp
		ON tfn.dteHolidayDate = tmp.dteHolidayDate
		WHERE tmp.dteHolidayDate IS NULL
	END

	SELECT @intPub = ISNULL(@intPub, 0) + COUNT (*) 
	FROM @tmpPublicHolidays 
	WHERE DATENAME(WEEKDAY, dteHolidayDate) NOT IN ('Saturday', 'Sunday')
	AND dteHolidayDate BETWEEN @startDate AND @endDate 
	AND blnAdhocHoliday = 0

	SELECT @intPub = ISNULL(@intPub, 0) + COUNT (*) 
	FROM [table_name] 
	WHERE dteHolidayDate BETWEEN @startDate AND @endDate 
	AND DATENAME(WEEKDAY, dteHolidayDate) NOT IN ('Saturday', 'Sunday')
	AND blnAdhocHoliday = 1

	SELECT @intPub = ISNULL(@intPub, 0) + COUNT (tmp.dteHolidayDate) 
	FROM @tmpPublicHolidays tmp
	LEFT JOIN [table_name] tbl
	ON tmp.dteHolidayDate = tbl.dteHolidayDate
	WHERE tmp.dteHolidayDate BETWEEN @startDate AND @endDate 
	AND DATENAME(WEEKDAY, tmp.dteHolidayDate) NOT IN ('Saturday', 'Sunday')
	AND tmp.blnAdhocHoliday = 1 AND tbl.dteHolidayDate IS NULL
 
    SET @range = DATEDIFF(DAY, @startDate, @endDate)+1
 
    SELECT @intOut =   
    ( 
        SELECT  
            @range / 7 * 5 + @range % 7 -  
            ( 
                SELECT COUNT(*)  
            FROM 
                ( 
                    SELECT 1 AS d 
                    UNION ALL SELECT 2  
                    UNION ALL SELECT 3  
                    UNION ALL SELECT 4  
                    UNION ALL SELECT 5  
                    UNION ALL SELECT 6  
                    UNION ALL SELECT 7 
                ) weekdays 
                WHERE d <= @range % 7  
                AND DATENAME(WEEKDAY, @endDate - d + 1)  
                IN 
                ( 
                    'Saturday', 
                    'Sunday' 
                ) 
            ) 
    )

	SELECT @intOut = @intOut - ISNULL(@intPub, 0)
	RETURN @intOut
END
GO


