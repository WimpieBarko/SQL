SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- SELECT EOMONTH(dteStartDate), dteEndDate FROM [conf].[fn_TaxYearDates] ('July 2022')

/**********************************************************************************************************************
This function is used to return the Start & End dates of a tax year, based on a given Effective Date!
**********************************************************************************************************************/
CREATE FUNCTION [conf].[fn_TaxYearDates] (@dteEffectiveDate DATE)

RETURNS @TaxYear TABLE 
(
	 dteStartDate DATE,
	 dteEndDate DATE
)
AS
BEGIN
	DECLARE @intStartYearAdjust INT = 0,
				  @intEndYearAdjust INT = 0

	IF MONTH(@dteEffectiveDate) < 7
		SELECT @intStartYearAdjust = - 1
	ELSE
		SELECT @intEndYearAdjust = 1

	INSERT INTO @TaxYear 
	(
		dteStartDate,
		dteEndDate
	)
	SELECT CAST(CAST(YEAR(@dteEffectiveDate) + @intStartYearAdjust AS VARCHAR(4)) + 
		RIGHT('0' + CAST(7 AS VARCHAR(2)), 2) + RIGHT('0' + CAST(1 AS VARCHAR(2)), 2) AS DATE) AS dteStartDate,
	EOMONTH(CAST(CAST(YEAR(@dteEffectiveDate) + @intEndYearAdjust AS VARCHAR(4)) + RIGHT('0' + CAST(6 AS VARCHAR(2)), 2) + 
		RIGHT('0' + CAST(1 AS VARCHAR(2)), 2) AS DATE)) AS dteEndDate

	RETURN
END
GO


