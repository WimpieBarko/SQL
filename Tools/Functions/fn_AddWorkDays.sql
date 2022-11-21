SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[fn_AddWorkDays] 
(    
    @WorkingDays As Int, 
    @StartDate AS DateTime 
) 
RETURNS DateTime 
AS
BEGIN
    DECLARE @Count AS Int
    DECLARE @i As Int
    DECLARE @NewDate As DateTime 
    SET @Count = 0 
    SET @i = 0 
 
    WHILE (@i < @WorkingDays) --runs through the number of days to add 
    BEGIN
-- increments the count variable 
        SELECT @Count = @Count + 1 
-- increments the i variable 
        SELECT @i = @i + 1 
-- adds the count on to the StartDate and checks if this new date is a Saturday or Sunday 
-- if it is a Saturday or Sunday it enters the nested while loop and increments the count variable 
           WHILE DATEPART(weekday,DATEADD(d, @Count, @StartDate)) IN (1,7) 
            BEGIN
                SELECT @Count = @Count + 1 
            END
    END
 
-- adds the eventual count on to the Start Date and returns the new date 
    SELECT @NewDate = DATEADD(d,@Count,@StartDate) 
    RETURN @NewDate 
END

GO


