--===================================================================================================--
--==    File Name:    sp_trimInput.sql                                                             ==--
--==    Author:       Wimpie Norman                                                                ==--
--==    Date:         18/02/2020                                                                   ==--
--==    Description:  Create Store Proc to create the set property table.                          ==--
--===================================================================================================--

IF EXISTS (SELECT * FROM   sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[sp_trimInput]') AND type IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
BEGIN
	PRINT '[DROP]:[DROPPING THE Function sp_trimInput]';
	DROP FUNCTION [dbo].[sp_trimInput]
END
GO
PRINT '[CREATE]:[CREATING THE VIEW sp_trimInput]';
GO

CREATE PROCEDURE sp_trimInput
(
	@variable NVARCHAR(255),
	@output VARCHAR(255)
)
AS
	SET @variable = LTRIM(RTRIM(@variable));

	RETURN @variable;