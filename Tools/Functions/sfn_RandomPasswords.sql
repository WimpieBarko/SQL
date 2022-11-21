IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'dbo.sfn_RandomPasswords') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.sfn_RandomPasswords
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sfn_RandomPasswords] (
	@pLength int = 10, --default to 10 characters
	@charSet int = 2, -- 2 is alphanumeric + special characters,
					 -- 1 is alphanumeric, 0 is alphabetical only
	@Password VARCHAR(50) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	IF @pLength < 6 SET @pLength = 6 -- set minimum length
	ELSE IF @pLength > 50 SET @pLength = 50 -- set maximum length
 
	DECLARE
		--@Password varchar(50),
		@string varchar(72), --52 possible letters + 10 possible numbers + up to 20 possible extras
		@stringFinal varchar(72), --52 possible letters + 10 possible numbers + up to 20 possible extras
		@numbers varchar(10),
		@extra varchar(20),
		@stringlen tinyint,
		@index tinyint
 
	--table variable to hold password list
	DECLARE @PassList TABLE (
		[password] varchar(50)
	)
 
	-- eliminate 0, 1, I, l, O to make the password more readable
	SET @string = 'BCDFGHJKLMNPQRSTVWXYZbcdfghjkmnpqrstvwxyz' -- option @charset = 0
	SET @numbers = '23456789'
	SET @extra = '#$+=' -- special characters
 
	SET @stringFinal = @string +
		CASE @charset
			WHEN 2 THEN @string + @numbers + @extra
			WHEN 1 THEN @string + @numbers
			ELSE @string
		END
 
	SET @stringlen = len(@stringFinal)

	SET @Password = ''
	DECLARE @i int; 
	
	SET @i = @pLength - 3
	WHILE (@i > 0)
	BEGIN
		SET @index = (ABS(CHECKSUM(newid())) % @stringlen) + 1 --or rand()
		SET @Password = @Password + SUBSTRING(@stringFinal, @index, 1)
		SET @i = @i - 1 --SET @pLength = @pLength - 1
	END
	
	SET @index = (ABS(CHECKSUM(newid())) % 52) + 1 --or rand()
	SET @Password = SUBSTRING(@string, @index, 1) + @Password

	SET @index = (ABS(CHECKSUM(newid())) % 8) + 1 --or rand()
	SET @Password = @Password + SUBSTRING(@numbers, @index, 1)

	SET @index = (ABS(CHECKSUM(newid())) % 10) + 1 --or rand()
	SET @Password = @Password + SUBSTRING(@extra, @index, 1)
END
GO


