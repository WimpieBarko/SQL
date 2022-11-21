SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**Sample of use*** 
SELECT dbo.fn_GetWorkingHours('2009-03-27 09:00:00', '2009-03-31 12:15:00', '1900-01-01 08:00:00', '1900-01-01 16:00:00')
***Sample of use***/
CREATE FUNCTION [dbo].[fn_GetWorkingHours]  
(  
    @dteEventStart DATETIME,  
    @dteEventEnd DATETIME,
		@dteStartWorkingTime DATETIME, /* Format is '1900-01-01 08:15:00' for a work day starting at 08:15 */
		@dteEndWorkingTime DATETIME /* Format is '1900-01-01 16:15:00' for a work day ending at 16:15 */
) 
RETURNS DECIMAL(18,2)  
AS  
BEGIN 
	DECLARE @return DECIMAL(18,2),
					@dteCalculationDate DATETIME

	SET @dteCalculationDate = dbo.fn_DateOnly(@dteEventStart) + dbo.fn_TimeOnly(@dteEndWorkingTime)
	
	WHILE @dteCalculationDate < @dteEventEnd
	BEGIN
		IF NOT DATENAME(WEEKDAY, @dteCalculationDate) IN 
    ( 
        'Saturday', 
        'Sunday' 
    ) 
		BEGIN
			SET @return = ISNULL(@return,0) + DateDiff(Second, @dteEventStart, @dteCalculationDate)
			-- Set the date to the start of the next business day
			SET @dteEventStart = dbo.fn_DateOnly(DateAdd(Day,1,@dteEventStart))+ dbo.fn_TimeOnly(@dteStartWorkingTime)
			-- Set the calculation date to the end of the next business day
			SET @dteCalculationDate = dbo.fn_DateOnly(@dteEventStart) + dbo.fn_TimeOnly(@dteEndWorkingTime)
		END
		ELSE
		BEGIN
			-- Set the date to the start of the next business day
			SET @dteEventStart = dbo.fn_DateOnly(DateAdd(Day,1,@dteEventStart))+ dbo.fn_TimeOnly(@dteStartWorkingTime)
			-- Set the calculation date to the end of the next business day
			SET @dteCalculationDate = dbo.fn_DateOnly(@dteEventStart) + dbo.fn_TimeOnly(@dteEndWorkingTime)
		END
	END

	-- If the startDateTime is still less than the endDateTime we want to calculate the additional time it took
	-- We only do this additional time if it is a working day
	IF @dteEventStart < @dteEventEnd AND DATENAME(WEEKDAY, @dteCalculationDate) NOT IN 
                ( 
                    'Saturday', 
                    'Sunday' 
                ) 
		SET @return = ISNULL(@return,0) + DateDiff(Second, @dteEventStart, @dteEventEnd)

	RETURN ISNULL(@return,0)
END
GO


