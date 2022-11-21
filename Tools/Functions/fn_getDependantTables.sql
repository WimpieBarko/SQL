/*************************************************************************
            Use the following code sample to get result:

		SELECT * FROM ebs.fn_getDependantTables ('Table_Name')

*************************************************************************/

IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[ebs].[fn_getDependantTables]') AND [type] IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
  DROP FUNCTION [ebs].[fn_getDependantTables]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE FUNCTION ebs.fn_getDependantTables (@tableName VARCHAR(255))  
RETURNS TABLE  
AS  
RETURN   
(  
    SELECT SO_P.name as [parent_table],SC_P.name as [parent_column],'is a foreign key of' as [direction],SO_R.name as [referenced_table],SC_R.name as [referenced_column]
	FROM sys.foreign_key_columns FKC
	inner join sys.objects SO_P on SO_P.object_id = FKC.parent_object_id
	inner join sys.columns SC_P on (SC_P.object_id = FKC.parent_object_id) AND (SC_P.column_id = FKC.parent_column_id)
	inner join sys.objects SO_R on SO_R.object_id = FKC.referenced_object_id
	inner join sys.columns SC_R on (SC_R.object_id = FKC.referenced_object_id) AND (SC_R.column_id = FKC.referenced_column_id)
	WHERE
	((SO_P.name = @tableName) AND (SO_P.type = 'U'))
	OR
	((SO_R.name = @tableName) AND (SO_R.type = 'U'))
);  
		