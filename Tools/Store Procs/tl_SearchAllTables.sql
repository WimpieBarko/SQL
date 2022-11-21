--====================================================================================================--
--==  File Name: tl_SearchAllTables                                                                 ==--
--==  File Type: Store Procedure                                                                    ==--
--==  Desc     : This store procedure search for a value in all tables.                             ==--
--==  Example  : EXEC tl_SearchAllTables 'test'                                                     ==--                                                                                 
--====================================================================================================--

IF OBJECT_ID('dbo.tl_SearchAllTables', 'P') IS NOT NULL
BEGIN
	PRINT '[DROP]:[Droppig the following store procedure {tl_SearchAllTables}]'
	DROP PROCEDURE [dbo].[tl_SearchAllTables]
END
GO

PRINT '[CREATE]:[Creating the following store procedure {tl_SearchAllTables}]'
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC tl_SearchAllTables
(
    @txtValue NVARCHAR(100)
)
AS
BEGIN

DECLARE @Results TABLE(txtColumnName NVARCHAR(370), txtColumnValue NVARCHAR(3630))

SET NOCOUNT ON

DECLARE @txtTableName NVARCHAR(256), @txtColumnName NVARCHAR(128), @txtValue2 NVARCHAR(110)
SET  @txtTableName = ''
SET @txtValue2 = QUOTENAME('%' + @txtValue + '%','''')

WHILE @txtTableName IS NOT NULL
BEGIN
    SET @txtColumnName = ''
    SET @txtTableName = 
    (
        SELECT DISTINCT MIN(QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME))
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_TYPE = 'BASE TABLE'
        AND QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME) > @txtTableName
        AND OBJECTPROPERTY(OBJECT_ID(QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME)), 'IsMSShipped') = 0
		)

    WHILE (@txtTableName IS NOT NULL) AND (@txtColumnName IS NOT NULL)
    BEGIN
        SET @txtColumnName =
        (
            SELECT MIN(QUOTENAME(COLUMN_NAME))
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA    = PARSENAME(@txtTableName, 2)
            AND TABLE_NAME  = PARSENAME(@txtTableName, 1)
            AND DATA_TYPE IN ('CHAR', 'VARCHAR', 'NCHAR', 'NVARCHAR')
            AND QUOTENAME(COLUMN_NAME) > @txtColumnName
        )

        IF @txtColumnName IS NOT NULL
        BEGIN
            INSERT INTO @Results
            EXEC
            (
                'SELECT ''' + @txtTableName + '.' + @txtColumnName + ''', LEFT(' + @txtColumnName + ', 3630) 
                 FROM ' + @txtTableName + ' (NOLOCK) ' +
                ' WHERE ' + @txtColumnName + ' LIKE ' + @txtValue2
            )
        END
    END 
END

SELECT txtColumnName, txtColumnValue FROM @Results
END

