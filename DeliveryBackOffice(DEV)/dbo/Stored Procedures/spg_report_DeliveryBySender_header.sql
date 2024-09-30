-- =============================================
-- Author:		<Bidcar Herrera>
-- Create date: <21/10/2020>
-- Description:	<Reporte por manifiesto declarado>
-- =============================================
-- Modified:	<Brandon Pedroza>
-- Create date: <17/06/2024>
-- Description:	<Se agrega parametro para filtrar courier por pais>
-- =============================================
CREATE PROCEDURE [dbo].[spg_report_DeliveryBySender_header]
    @StartDate DATE = '2020-10-03'
  , @EndDate DATE = '2020-11-05'
  , @IdCountry AS NVARCHAR(2) = 'GT'
AS
BEGIN
    IF OBJECT_ID('tempdb..#ListRoutes') IS NOT NULL
    BEGIN
        DROP TABLE #ListRoutes;
    END;

    SELECT Guide_Serie
         , Guide_Number
         , StatusOrderId
         , DateCreated
    INTO #ListRoutes
    FROM DeliveryBackOffice.dbo.DeliveryOrderDetail WITH (NOLOCK)
    WHERE StatusOrderId = 4
          AND CONVERT(DATE, DateCreated)
          BETWEEN @StartDate AND @EndDate;
    --and CONVERT(VARCHAR, DateCreated, 23) >= CONVERT(VARCHAR, @StartDate, 23)
    --and CONVERT(VARCHAR, DateCreated, 23) <= CONVERT(VARCHAR, @EndDate, 23)

    SELECT DISTINCT
           Sender.ID
         , ISNULL(Sender.First_Name, '') + ' ' + ISNULL(Sender.Last_Name, '') SenderName
         , Sender.CUI
    FROM DeliveryBackOffice.dbo.DeliveryAttempt          Att WITH (NOLOCK)
        INNER JOIN #ListRoutes                           lstr
            ON Att.Guide_Serie = lstr.Guide_Serie
               AND Att.Guide_Number = lstr.Guide_Number
        INNER JOIN DeliveryBackOffice.dbo.SenderReceiver Sender WITH (NOLOCK)
            ON Att.ID_Courier = Sender.ID
	WHERE ISNULL(Sender.IdCountry, 'GT') = @IdCountry;

END;