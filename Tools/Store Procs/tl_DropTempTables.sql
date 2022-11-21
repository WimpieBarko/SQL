IF EXISTS(SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'tl_DropTempTables')  AND OBJECTPROPERTY(ID, N'IsProcedure') = 1)
BEGIN
	PRINT '[DROP]:[Dropping the stored procedure tl_droptemptables]';
	DROP PROCEDURE tl_DropTempTables;
END
GO

PRINT '[CREATE]:[Creating the stored procedure tl_droptemptables]';
GO
CREATE PROCEDURE dbo.tl_DropTempTables
AS
-- drop all #temp tables for current session
BEGIN
DECLARE @txtDynamicSQL VARCHAR(60),
				@txtName VARCHAR(60)

DECLARE cr_dtt CURSOR
    FOR SELECT  SUBSTRING(t.name, 1, CHARINDEX('___', t.name) - 1)
        FROM    tempdb.sys.tables AS t
        WHERE   t.name LIKE '#%[_][_][_]%'
                AND t.[object_id] = OBJECT_ID('tempdb..' + SUBSTRING(t.name, 1, CHARINDEX('___', t.name) - 1))
OPEN cr_dtt
FETCH NEXT FROM cr_dtt INTO @txtName
WHILE @@fetch_status <> -1
    BEGIN
        SELECT  @txtDynamicSQL = 'DROP TABLE ' + @txtName
        
        EXEC ( @txtDynamicSQL )
        
        fetch next from cr_dtt into @txtName
    END
CLOSE cr_dtt
DEALLOCATE cr_dtt
END 
GO


