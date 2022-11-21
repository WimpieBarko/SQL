--====================================================================================================--
--==  File Name: fn_getTablePrimary                                                                 ==--
--==  File Type: Function                                                                           ==--
--==  Desc     : This function returns the requested table's constraint                             ==--
--==  Example  : EXEC @result = dbo.fn_getTablePrimary('TABLE_NAME','PRIMARY KEY')                  ==--
--====================================================================================================--

IF EXISTS(SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[fn_getTablePrimary]') AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
BEGIN
	PRINT '[DROP]:[Droppig the following function {fn_getTablePrimary}]'
	DROP FUNCTION [dbo].[fn_getTablePrimary]
END
GO

PRINT '[CREATE]:[CREATING the following function {fn_getTablePrimary}]'
GO

CREATE FUNCTION fn_getTablePrimary
(
	@txtTableName VARCHAR(255),
	@txtConstraintType VARCHAR(255)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @txtColName VARCHAR(MAX)

	SELECT DISTINCT sys.columns.name
		FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
			INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.CONSTRAINT_NAME = ccu.Constraint_name
			INNER JOIN sys.columns ON tc.TABLE_NAME = OBJECT_NAME(sys.columns.object_id)
		WHERE tc.TABLE_NAME = @txtTableName AND tc.CONSTRAINT_TYPE = @txtConstraintType

	SET @txtColName = 
	(
		SELECT DISTINCT sys.columns.name
		FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
			INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.CONSTRAINT_NAME = ccu.Constraint_name
			INNER JOIN sys.columns ON tc.TABLE_NAME = OBJECT_NAME(sys.columns.object_id)
		WHERE tc.TABLE_NAME = @txtTableName AND tc.CONSTRAINT_TYPE = @txtConstraintType
	)
	
	RETURN @txtColName
END
GO

--PRIMARY KEY
--FOREIGN KEY
--UNIQUE
/*
DECLARE @result VARCHAR(100)
SELECT @result = dbo.fn_getTablePrimary('TABLE_NAME','PRIMARY KEY'); 
SELECT @result
*/
