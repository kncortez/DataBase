-- =============================================
-- Author:		<Marco,Jimenez>
-- Create date: <2022-04-12>
-- Description:	<Stored Procedure para poder retornar el listado de horarios para un servicio proporcionado>
-- =============================================
--EXEC dbo.GetScheduleTimeList 'HermesWireTransfer'
CREATE PROCEDURE [dbo].[GetScheduleTimeList] @ServiceName AS VARCHAR(500)

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @cols AS NVARCHAR(MAX)
		   ,@query AS NVARCHAR(MAX)

	SELECT
		@cols = STUFF((SELECT
				',' + QUOTENAME(ServiceProcess)
			FROM ServicesConfig WITH (NOLOCK)
			WHERE ServiceName = @ServiceName
			AND RowStatus = 1
			GROUP BY ServiceProcess
					,IdServicesConfig
			ORDER BY IdServicesConfig
			FOR XML PATH (''), TYPE)
		.value('.', 'NVARCHAR(MAX)')
		, 1, 1, '')

	SET @query = N'SELECT ' + @cols + N' from 
             (
                select TimeSchedule, ServiceProcess
                from ServicesConfig WITH (NOLOCK)
            ) x
            pivot 
            (
                max(TimeSchedule)
                for ServiceProcess in (' + @cols + N')
            ) p '

	EXEC sp_executesql @query;



END