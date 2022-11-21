--===================================================================================================--
--==    File Name:    fn_getTablePrimaryKey.sql                                                    ==--
--==    Author:       Wimpie Norman                                                                ==--
--==    Date:         04/10/2021                                                                   ==--
--==    Description:  Retrieve Table Primary Keys.                                                 ==--
--===================================================================================================--

/*************************************************************************
            Use the following code sample to get result:

		SELECT * FROM dbo.fn_getDependantTables ('Table_Name')

*************************************************************************/

IF OBJECT_ID (N'dbo.fn_getTablePrimaryKey', N'IF') IS NOT NULL
BEGIN
	PRINT 'Dropping The Function fn_getTablePrimaryKey'
    DROP FUNCTION dbo.fn_getTablePrimaryKey;  
END
GO  
PRINT 'Creating The Function fn_getTablePrimaryKey'
GO
CREATE FUNCTION dbo.fn_getTablePrimaryKey (@tableName VARCHAR(255))  
RETURNS TABLE  
AS  
RETURN   
(  
    SELECT TOP 1 column_name AS primary_column
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TC
		INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS KU ON TC.CONSTRAINT_TYPE = 'PRIMARY KEY' AND TC.CONSTRAINT_NAME = KU.CONSTRAINT_NAME AND KU.table_name = @tableName
	ORDER BY KU.TABLE_NAME, KU.ORDINAL_POSITION
);  
		