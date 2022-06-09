-- =============================================
-- Author:		<Marco Jimenez>
-- Create date: <2021-01-17>
-- Description:	<sspws_get_SMTP>
-- =============================================


CREATE PROCEDURE [dbo].[spws_get_SMTP]
AS
BEGIN
	SET NOCOUNT ON;
	
	
DECLARE @cols AS NVARCHAR(MAX),
    @query  AS NVARCHAR(MAX)

select @cols = STUFF((SELECT ',' + QUOTENAME(Name) 
                    from ConfigParams
					WHERE Name IN ('EmailFrom','Host','Port','Password')
                    group by Name,ConfigParamsId
                    order by Name,ConfigParamsId
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'')

set @query = N'SELECT ' + @cols + N' from 
             (
                select Value, Name
                from ConfigParams
            ) x
            pivot 
            (
                max(value)
                for Name in (' + @cols + N')
            ) p '

exec sp_executesql @query;
	
END



/*
EmailFrom
Host
Port
Password
*/