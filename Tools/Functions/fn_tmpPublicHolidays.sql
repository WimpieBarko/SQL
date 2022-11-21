SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_tmpPublicHolidays](
	@dteEffectivateDate DATETIME = NULL,
	@txtCountryCode VARCHAR(10) = NULL
	)
RETURNS 
@tmpPublicHolidays TABLE 
(
	txtHolidayName VARCHAR(100), dteHolidayDate DATETIME NULL, blnAdhocHoliday BIT NULL
)
AS
-- SELECT *, DATENAME(WEEKDAY, fn_tmpPublicHolidays.dteHolidayDate) FROM dbo.fn_tmpPublicHolidays(GETDATE(), NULL)
BEGIN
	-- Fill the table variable with the rows for your result set
	DECLARE @tmpList TABLE (txtHolidayName VARCHAR(100), dteHolidayDate DATETIME NULL, blnAdhocHoliday BIT NULL)

	SELECT @dteEffectivateDate = ISNULL(@dteEffectivateDate, GETDATE())

	IF @txtCountryCode = 'ZA' OR ISNULL(@txtCountryCode, '') = ''
	BEGIN
		INSERT INTO @tmpList(txtHolidayName, dteHolidayDate, blnAdhocHoliday)
		SELECT txtHolidayName, RTRIM(LTRIM(txtDate)) + ' ' + DATENAME(YEAR, @dteEffectivateDate) AS dteHolidayDate, 0 AS blnAdhocHoliday
		FROM (
		SELECT 'New Year''s Day' AS txtHolidayName, '01 Jan' AS txtDate -- + DATENAME(YEAR, @dteEffectivateDate) AS dteHolidayDate
		UNION ALL SELECT 'Human Rights Day', '31 Mar' AS txtDate
		UNION ALL SELECT 'Freedom Day', '27 Apr' AS txtDate
		UNION ALL SELECT 'Worker''s Day', '01 May' AS txtDate
		UNION ALL SELECT 'Youth Day', '16 Jun' AS txtDate
		UNION ALL SELECT 'National Women''s Day', '09 Aug' AS txtDate
		UNION ALL SELECT 'Heritage Day', '24 Sep' AS txtDate
		UNION ALL SELECT 'Day of Reconciliation', '16 Dec' AS txtDate
		UNION ALL SELECT 'Christmas Day', '25 Dec' AS txtDate
		UNION ALL SELECT 'Day of Goodwill', '26 Dec' AS txtDate
		) AS tmpList
	END
	ELSE
	BEGIN
		INSERT INTO @tmpList(txtHolidayName, dteHolidayDate, blnAdhocHoliday)
		SELECT txtHolidayName, RTRIM(LTRIM(txtDate)) + ' ' + DATENAME(YEAR, @dteEffectivateDate) AS dteHolidayDate, 0 AS blnAdhocHoliday
		FROM (
		SELECT 'New Year''s Day' AS txtHolidayName, '01 Jan' AS txtDate -- + DATENAME(YEAR, @dteEffectivateDate) AS dteHolidayDate
		UNION ALL SELECT 'Worker''s Day', '01 May' AS txtDate
		UNION ALL SELECT 'Christmas Day', '25 Dec' AS txtDate
		UNION ALL SELECT 'Day of Goodwill', '26 Dec' AS txtDate
		) AS tmpList
	END

	-- If Public Holiday falls on a Sunday, add Monday as Public Holiday
	;WITH tmpPub AS (SELECT 'Public Holiday' AS txtHolidayName, DATEADD(DAY, 1, dteHolidayDate) AS dteHolidayDate, 1 AS blnAdhocHoliday
	FROM @tmpList tmpList
	WHERE DATENAME(WEEKDAY, tmpList.dteHolidayDate) IN ('Sunday'))
	INSERT INTO @tmpList(txtHolidayName, dteHolidayDate, blnAdhocHoliday)
	SELECT tmpPub.txtHolidayName, tmpPub.dteHolidayDate, tmpPub.blnAdhocHoliday
	FROM tmpPub
	LEFT JOIN @tmpList tmpList
	ON tmpPub.dteHolidayDate = tmpList.dteHolidayDate
	WHERE tmpList.dteHolidayDate IS NULL
	
	INSERT INTO @tmpPublicHolidays(txtHolidayName, dteHolidayDate, blnAdhocHoliday)
	SELECT txtHolidayName, dteHolidayDate, blnAdhocHoliday
	FROM @tmpList
	ORDER BY dteHolidayDate

	RETURN 
END
GO


