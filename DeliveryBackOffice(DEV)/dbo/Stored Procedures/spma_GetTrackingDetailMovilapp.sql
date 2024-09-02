-- =============================================
-- Author:		<Oscar,Rodriguez>
-- Create date: <2024-09-02>
-- Description:	<Devueve detalle de rastreo de guias para aplicacion movil de clientes>
-- =============================================
CREATE PROCEDURE [dbo].[spma_GetTrackingDetailMovilapp]
    -- Add the parameters for the stored procedure here
    @GuideSerie AS VARCHAR(2) = 'FD',
    @GuideNumber AS INT = 0,
    @IdCountry AS VARCHAR(2) = 'GT'
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here

    IF @GuideNumber > 0
    BEGIN
		SELECT TOP 1 do.Shipping_Date [dateDeliveredAprox],
				CONCAT(do.Receiver_FirstName,' ', do.Receiver_LastName) [receiver],
				dodrequired.DateCreated [requiredDate],
				ISNULL(dodrequired.RowStatus,0) [requiredStatus],
				ISNULL(dodrequired.StatusOrderId,0) [requiredCode],
				dodarrived.DateCreated [arrivedDate],
				ISNULL(dodarrived.RowStatus,0) [arrivedStatus],
				ISNULL(dodarrived.StatusOrderId,0) [arrivedCode],
				dodroute.DateCreated [routeDate],
				ISNULL(dodroute.RowStatus,0) [routeStatus],
				ISNULL(dodroute.StatusOrderId,0) [routeCode],
				doddelivered.DateCreated [deliveredDate],
				ISNULL(doddelivered.RowStatus,0) [deliveredStatus],
				ISNULL(doddelivered.StatusOrderId,0) [deliveredCode]
		FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderDetail dodrequired WITH(NOLOCK) 
				ON do.Guide_Serie = dodrequired.Guide_Serie 
				AND do.Guide_Number = dodrequired.Guide_Number
				AND dodrequired.StatusOrderId IN (1, 15)
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderDetail dodarrived WITH(NOLOCK) 
				ON do.Guide_Serie = dodarrived.Guide_Serie 
				AND do.Guide_Number = dodarrived.Guide_Number
				AND dodarrived.StatusOrderId IN (11)
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderDetail dodroute WITH(NOLOCK) 
				ON do.Guide_Serie = dodroute.Guide_Serie 
				AND do.Guide_Number = dodroute.Guide_Number
				AND dodroute.StatusOrderId IN (4)
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderDetail doddelivered WITH(NOLOCK) 
				ON do.Guide_Serie = doddelivered.Guide_Serie 
				AND do.Guide_Number = doddelivered.Guide_Number
				AND doddelivered.StatusOrderId IN (5)
		WHERE	do.Guide_Serie = @GuideSerie
				AND do.Guide_Number = @GuideNumber
				AND ISNULL(do.SenderCountryId,'GT') = @IdCountry
		ORDER BY dodrequired.DateCreated asc, dodarrived.DateCreated asc, dodroute.DateCreated desc;

    END;
    ELSE
    BEGIN
        SELECT '' [dateDeliveredAprox],
               '' [receiver],
               '' [requiredDate],
               0 [requiredStatus],
               0 [requiredCode],
               '' [arrivedDate],
               0 [arrivedStatus],
               0 [arrivedCode],
               '' [routeDate],
               0 [routeStatus],
               0 [routeCode],
               '' [deliveredDate],
               0 [deliveredStatus],
               0 [deliveredCode];
    END;
END;

