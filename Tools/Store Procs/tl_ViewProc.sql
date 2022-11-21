--====================================================================================================--
--==  File Name: spf_SetCount_Grant                                                                 ==--
--==  File Type: Store Procedure                                                                    ==--
--==  Desc     : This store procedure will print out SP with required changes                       ==--
--==  Example  : EXEC spf_SetCount_Grant 'EBS-WIMPIEN','Everest_Master','2019'                      ==--                                                                                 
--====================================================================================================--

IF OBJECT_ID('dbo.tl_ViewProc', 'P') IS NOT NULL
BEGIN
	PRINT '[DROP]:[Droppig the following store procedure {tl_ViewProc}]'
	DROP PROCEDURE [dbo].[tl_ViewProc]
END
GO

PRINT '[CREATE]:[Creating the following store procedure {tl_ViewProc}]'
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[tl_ViewProc] (
	@objname NVARCHAR(776),
	@columnname SYSNAME = NULL
)
WITH EXECUTE AS N'dbo'
AS

SET NOCOUNT ON

DECLARE @dbname SYSNAME
,@objid	INT
,@BlankSpaceAdded   INT
,@BasePos       INT
,@CurrentPos    INT
,@TextLength    INT
,@LineId        INT
,@AddOnLen      INT
,@LFCR          INT --lengths of line feed carriage return
,@DefinedLength INT

/* NOTE: Length of @SyscomText is 4000 to replace the length of
** text column in syscomments.
** lengths on @Line, #CommentText Text column and
** value for @DefinedLength are all 255. These need to all have
** the same values. 255 was SELECTed in order for the max length
** display using down level clients
*/
,@SyscomText	NVARCHAR(MAX)
,@Line          NVARCHAR(MAX)

SELECT @DefinedLength = 4000 -- Modify this to see where it cuts off
SELECT @BlankSpaceAdded = 0 /*Keeps track of blank spaces at end of lines. Note Len function ignores
                             trailing blank spaces*/
CREATE TABLE #CommentText
(LineId	INT
 ,Text  NVARCHAR(MAX))

/*
**  Make sure the @objname is local to the current database.
*/
SELECT @dbname = parsename(@objname,3)
if @dbname is null
	SELECT @dbname = db_name()
else if @dbname <> db_name()
        begin
                raiserror(15250,-1,-1)
                return (1)
        end

/*
**  See if @objname exists.
*/
SELECT @objid = object_id(@objname)
if (@objid is null)
        begin
		raiserror(15009,-1,-1,@objname,@dbname)
		return (1)
        end

-- If second parameter was given.
if ( @columnname is not null)
    begin
        -- Check if it is a table
        if (SELECT count(*) from sys.objects where object_id = @objid and type in ('S ','U ','TF'))=0
            begin
                raiserror(15218,-1,-1,@objname)
                return(1)
            end
        -- check if it is a correct column name
        if ((SELECT 'count'=count(*) from sys.columns where name = @columnname and object_id = @objid) =0)
            begin
                raiserror(15645,-1,-1,@columnname)
                return(1)
            end
    if (ColumnProperty(@objid, @columnname, 'IsComputed') = 0)
		begin
			raiserror(15646,-1,-1,@columnname)
			return(1)
		end

        declare ms_crs_syscom  CURSOR LOCAL
        FOR SELECT text from syscomments where id = @objid and encrypted = 0 and number =
                        (SELECT column_id from sys.columns where name = @columnname and object_id = @objid)
                        order by number,colid
        FOR READ ONLY

    end
else if @objid < 0	-- Handle system-objects
	begin
		-- Check count of rows with text data
		if (SELECT count(*) from master.sys.syscomments where id = @objid and text is not null) = 0
			begin
				raiserror(15197,-1,-1,@objname)
				return (1)
			end
			
		declare ms_crs_syscom CURSOR LOCAL FOR SELECT text from master.sys.syscomments where id = @objid
			ORDER BY number, colid FOR READ ONLY
	end
else
    begin
        /*
        **  Find out how many lines of text are coming back,
        **  and return if there are none.
        */
        if (SELECT count(*) from syscomments c, sysobjects o where o.xtype not in ('S', 'U')
            and o.id = c.id and o.id = @objid) = 0
                begin
                        raiserror(15197,-1,-1,@objname)
                        return (1)
                end

        if (SELECT count(*) from syscomments where id = @objid and encrypted = 0) = 0
                begin
                        raiserror(15471,-1,-1,@objname)
                        return (0)
                end

		declare ms_crs_syscom  CURSOR LOCAL
		FOR SELECT text from syscomments where id = @objid and encrypted = 0
				ORDER BY number, colid
		FOR READ ONLY

    end

/*
**  else get the text.
*/
SELECT @LFCR = 2
SELECT @LineId = 1


OPEN ms_crs_syscom

FETCH NEXT from ms_crs_syscom INTo @SyscomText

WHILE @@fetch_status >= 0
begin

    SELECT  @BasePos    = 1
    SELECT  @CurrentPos = 1
    SELECT  @TextLength = LEN(@SyscomText)

    WHILE @CurrentPos  != 0
    begin
        --Looking for end of line followed by carriage return
        SELECT @CurrentPos =   CHARINDEX(char(13)+char(10), @SyscomText, @BasePos)

        --If carriage return found
        IF @CurrentPos != 0
        begin
            /*If new value for @Lines length will be > then the
            **set length then insert current contents of @line
            **and proceed.
            */
            while (isnull(LEN(@Line),0) + @BlankSpaceAdded + @CurrentPos-@BasePos + @LFCR) > @DefinedLength
            begin
                SELECT @AddOnLen = @DefinedLength-(isnull(LEN(@Line),0) + @BlankSpaceAdded)
                INSERT #CommentText VALUES
                ( @LineId,
                  isnull(@Line, N'') + isnull(SUBSTRING(@SyscomText, @BasePos, @AddOnLen), N''))
                SELECT @Line = NULL, @LineId = @LineId + 1,
                       @BasePos = @BasePos + @AddOnLen, @BlankSpaceAdded = 0
            end
            SELECT @Line    = isnull(@Line, N'') + isnull(SUBSTRING(@SyscomText, @BasePos, @CurrentPos-@BasePos + @LFCR), N'')
            SELECT @BasePos = @CurrentPos+2
            INSERT #CommentText VALUES( @LineId, @Line )
            SELECT @LineId = @LineId + 1
            SELECT @Line = NULL
        end
        else
        --else carriage return not found
        begin
            IF @BasePos <= @TextLength
            begin
                /*If new value for @Lines length will be > then the
                **defined length
                */
                while (isnull(LEN(@Line),0) + @BlankSpaceAdded + @TextLength-@BasePos+1 ) > @DefinedLength
                begin
                    SELECT @AddOnLen = @DefinedLength - (isnull(LEN(@Line),0) + @BlankSpaceAdded)
                    INSERT #CommentText VALUES
                    ( @LineId,
                      isnull(@Line, N'') + isnull(SUBSTRING(@SyscomText, @BasePos, @AddOnLen), N''))
                    SELECT @Line = NULL, @LineId = @LineId + 1,
                        @BasePos = @BasePos + @AddOnLen, @BlankSpaceAdded = 0
                end
                SELECT @Line = isnull(@Line, N'') + isnull(SUBSTRING(@SyscomText, @BasePos, @TextLength-@BasePos+1 ), N'')
                if LEN(@Line) < @DefinedLength and charindex(' ', @SyscomText, @TextLength+1 ) > 0
                begin
                    SELECT @Line = @Line + ' ', @BlankSpaceAdded = 1
                end
            end
        end
    end

	FETCH NEXT from ms_crs_syscom INTo @SyscomText
end

IF @Line is NOT NULL
    INSERT #CommentText VALUES( @LineId, @Line )

SELECT Text from #CommentText order by LineId

CLOSE  ms_crs_syscom
DEALLOCATE 	ms_crs_syscom

DROP TABLE 	#CommentText

return (0) -- tl_helptext

GO

GRANT EXECUTE ON ebs.tl_ViewProc TO everestsa
GO
