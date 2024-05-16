CREATE PROCEDURE [dbo].[ObservationsClosureOperator]
	@StartDate datetime = null,
	@EndDate datetime = null,
	@VisitPointId INT = null,
	@IdCierre INT = null
AS
BEGIN
	SELECT
		ACH.IdAccountingClosuresHeader AS 'Cierre',
		ISNULL(NULLIF(ACH.Observations, ''), 'No se tienen observaciones.') AS 'Observaciones',
		ACH.DateCreated AS 'Fecha',
		VPC.DescriptionOfClient AS 'PDV',
		RU.UsrNickName AS 'Usuario'
	FROM DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
	INNER JOIN DeliveryBackOffice.dbo.RegisterUser RU
		ON RU.UsrIdUser = ACH.UserId
	INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC
		ON VPC.CodeOfReference = ACH.VisitPoint
	WHERE CONVERT(DATE, ACH.DateCreated) BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
	AND (@VisitPointId = -1 OR VPC.CodeOfReference = @VisitPointId)
	AND (@IdCierre IS NULL OR @IdCierre <= 0 OR ACH.IdAccountingClosuresHeader = @IdCierre)
END