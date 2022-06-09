
-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2021-06-23>
--Description:	<Obtener el detalle del memorandum en horario y ruta de visita al punto de servicio>
-- =============================================
CREATE PROCEDURE [dbo].[sphdGetDetailMemorandumVP]
    -- Add the parameters for the stored procedure here
    @IdVisitPoint AS INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
    IF OBJECT_ID('tempdb.dbo.#Schedule', 'U') IS NOT NULL
        DROP TABLE #Schedule;
    --DECLARE @IdVisitPoint AS INT = 160103

    SELECT vpi.IdVPItinerary,
           vpi.DayOfVisit,
           vpi.InitializationTimeOfVisit + '-' + vpi.FinalizationTimeOfVisit [Horario],
           rout.CodeRoute,
           vpi.RouteCodeID,
           1 Submitted
    INTO #Schedule
    FROM dbo.VisitPointClient vpc
        LEFT JOIN dbo.VisitPointConfiguration vpf
            ON vpf.VisitPointID = vpc.CodeOfReference
               AND vpf.RowStatus = 'TRUE'
        LEFT JOIN dbo.VisitPointFrequency vfq
            ON vfq.VPConfigurationID = vpf.IdVPConfiguration
               AND vfq.RowStatus = 'TRUE'
        LEFT JOIN dbo.VisitPointItinerary vpi
            ON vpi.VPFrequencyID = vfq.IdVPFrequency
               AND vpi.RowStatus = 'TRUE'
        LEFT JOIN dbo.CatRoute rout
            ON rout.IdRoute = vpi.RouteCodeID
    WHERE vpc.CodeOfReference = @IdVisitPoint
    ORDER BY vpi.DayOfVisit;

    SELECT *
    FROM
    (
        SELECT sch.Horario,
               sch.CodeRoute,
               sch.RouteCodeID,
               sch.DayOfVisit,
               sch.Submitted
        FROM #Schedule sch
    ) AS SourceTable
    PIVOT
    (
        AVG(RouteCodeID)
        FOR DayOfVisit IN ([1], [2], [3], [4], [5], [6], [7])
    ) AS PivotTable
    WHERE PivotTable.Horario IS NOT NULL;

END;
