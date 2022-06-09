
CREATE PROCEDURE [dbo].[ObservationsClosureOperator]
	@StartDate datetime = null,
	@EndDate datetime = null,
	@VisitPointId INT = null,
	@IdCierre INT = null
AS
BEGIN

	IF(@VisitPointId > 0 AND @IdCierre > 0)
	BEGIN
		SELECT ACH.IdAccountingClosuresHeader 'Cierre',
			IIF((ACH.Observations IS NULL OR ACH.Observations = ''),'No se tienen observaciones.',ACH.Observations) 'Observaciones',
			ACH.DateCreated 'Fecha',
			VPC.DescriptionOfClient 'PDV',
			RU.UsrNickName 'Usuario'
		FROM  DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
		JOIN DeliveryBackOffice.dbo.RegisterUser RU
			ON RU.UsrIdUser = ACH.UserId
		JOIN DeliveryBackOffice.dbo.VisitPointClient VPC
			ON VPC.CodeOfReference = ACH.VisitPoint
			AND VPC.CodeOfReference = @VisitPointId
		WHERE CONVERT(DATE, ACH.DateCreated) BETWEEN  CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
			AND ACH.IdAccountingClosuresHeader = @IdCierre 
	END

	IF(@VisitPointId > 0 AND (@IdCierre <= 0 OR @IdCierre IS NULL))
	BEGIN
		SELECT ACH.IdAccountingClosuresHeader 'Cierre',
			IIF((ACH.Observations IS NULL OR ACH.Observations = ''),'No se tienen observaciones.',ACH.Observations) 'Observaciones',
			ACH.DateCreated 'Fecha',
			VPC.DescriptionOfClient 'PDV',
			RU.UsrNickName 'Usuario'
		FROM  DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
		JOIN DeliveryBackOffice.dbo.RegisterUser RU
			ON RU.UsrIdUser = ACH.UserId
		JOIN DeliveryBackOffice.dbo.VisitPointClient VPC
			ON VPC.CodeOfReference = ACH.VisitPoint
			AND VPC.CodeOfReference = @VisitPointId
		WHERE CONVERT(DATE, ACH.DateCreated) BETWEEN  CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
	END

	IF(@VisitPointId = -1 AND (@IdCierre <= 0 OR @IdCierre IS NULL))
	BEGIN
		SELECT ACH.IdAccountingClosuresHeader 'Cierre',
			IIF((ACH.Observations IS NULL OR ACH.Observations = ''),'No se tienen observaciones.',ACH.Observations) 'Observaciones',
			ACH.DateCreated 'Fecha',
			VPC.DescriptionOfClient 'PDV',
			RU.UsrNickName 'Usuario'
		FROM  DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
		JOIN DeliveryBackOffice.dbo.RegisterUser RU
			ON RU.UsrIdUser = ACH.UserId
		JOIN DeliveryBackOffice.dbo.VisitPointClient VPC
			ON VPC.CodeOfReference = ACH.VisitPoint
		WHERE CONVERT(DATE, ACH.DateCreated) BETWEEN  CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
	END

END