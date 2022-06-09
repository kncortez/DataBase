-- =============================================
-- Author:		<Marco,Jimenez>
-- Create date: <2022-04-12>
-- Description:	<Stored Procedure para poder retornar el listado de horarios para un servicio proporcionado>
-- =============================================
--EXEC dbo.GetServiceExecutionSchedule 'HermesWireTransfer'
CREATE PROCEDURE [dbo].[GetScheduleTimeList] 
@ServiceName AS VARCHAR(500)

AS
BEGIN
	SET NOCOUNT ON;





		DECLARE @cols AS NVARCHAR(MAX),
    @query  AS NVARCHAR(MAX)

select @cols = STUFF((SELECT ',' + QUOTENAME(ServiceProcess) 
                    from ServicesConfig WITH (NOLOCK)
					WHERE 
					ServiceName = @ServiceName
		            AND RowStatus = 1
                    group by ServiceProcess, IdServicesConfig
                    order by IdServicesConfig
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'')

set @query = N'SELECT ' + @cols + N' from 
             (
                select TimeSchedule, ServiceProcess
                from ServicesConfig WITH (NOLOCK)
            ) x
            pivot 
            (
                max(TimeSchedule)
                for ServiceProcess in (' + @cols + N')
            ) p '

exec sp_executesql @query;		


	
END