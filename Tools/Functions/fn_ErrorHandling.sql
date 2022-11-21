SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_ErrorHandling]()
RETURNS 
@tmpErrorHandling TABLE 
(
	ErrorNumber [int] NULL, ErrorSeverity [int] NULL, ErrorState [int] NULL, ErrorProcedure [nvarchar](100) NULL, ErrorLine [int] NULL, ErrorMessage [nvarchar](MAX) NULL, ErrorDate [datetime] NULL, 
	DomainUserName [nvarchar](100), [HostName] [nvarchar](300), AppName [nvarchar](300)
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	
	RETURN 
END
GO


