SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnNumbersOnly]
   (  @InParam   varchar(500) )
   RETURNS varchar(500)
AS
   BEGIN
      IF patindex( '%[^0-9]%', @InParam ) > 0
         BEGIN
            WHILE patindex( '%[^0-9]%', @InParam ) > 0
               BEGIN
                  SET @InParam = Stuff( @InParam, patindex( '%[^0-9]%', @InParam), 1, '' )  
               END 
         END
      RETURN @InParam
   END
GO


