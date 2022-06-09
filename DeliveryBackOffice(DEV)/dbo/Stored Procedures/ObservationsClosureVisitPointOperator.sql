
CREATE PROCEDURE [dbo].[ObservationsClosureVisitPointOperator]
	@StartDate datetime = null,
	@EndDate datetime = null,
	@VisitPointId INT = null,
	@IdCierre INT = null
AS
BEGIN

	IF(@VisitPointId > 0 AND @IdCierre > 0)
	BEGIN
		SELECT ACH.IdAccountingClosuresHeader 'CierreOperador',
			IIF((ACH.Observations IS NULL OR ACH.Observations = ''),'No se tienen observaciones.',ACH.Observations) 'ObservacionesOperador',
			ACH.DateCreated 'FechaOperador',
			VPC.DescriptionOfClient 'PDVOperador',
			RU.UsrNickName 'UsuarioOperador'
		FROM  DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
		JOIN DeliveryBackOffice.dbo.RegisterUser RU
			ON RU.UsrIdUser = ACH.UserId
		JOIN DeliveryBackOffice.dbo.VisitPointClient VPC
			ON VPC.CodeOfReference = ACH.VisitPoint
			AND VPC.CodeOfReference = @VisitPointId
		WHERE CONVERT(DATE, ACH.DateCreated) BETWEEN  CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
			AND ACH.AccountingClosuresHeaderVisitPointId = @IdCierre 
	END

	IF(@VisitPointId > 0 AND (@IdCierre <= 0 OR @IdCierre IS NULL))
	BEGIN
		SELECT ACH.IdAccountingClosuresHeader 'CierreOperador',
			IIF((ACH.Observations IS NULL OR ACH.Observations = ''),'No se tienen observaciones.',ACH.Observations) 'ObservacionesOperador',
			ACH.DateCreated 'FechaOperador',
			VPC.DescriptionOfClient 'PDVOperador',
			RU.UsrNickName 'UsuarioOperador'
		FROM  DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
		JOIN DeliveryBackOffice.dbo.AccountingClosuresHeaderVisitPoint ACHVP
			ON ACHVP.IdAccountingClosuresHeaderVisitPoint = ACH.AccountingClosuresHeaderVisitPointId
		JOIN DeliveryBackOffice.dbo.RegisterUser RU
			ON RU.UsrIdUser = ACH.UserId
		JOIN DeliveryBackOffice.dbo.VisitPointClient VPC
			ON VPC.CodeOfReference = ACH.VisitPoint
			AND VPC.CodeOfReference = @VisitPointId
		WHERE CONVERT(DATE, ACH.DateCreated) BETWEEN  CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
	END

	IF(@VisitPointId = -1 AND (@IdCierre <= 0 OR @IdCierre IS NULL))
	BEGIN
		SELECT ACH.IdAccountingClosuresHeader 'CierreOperador',
			IIF((ACH.Observations IS NULL OR ACH.Observations = ''),'No se tienen observaciones.',ACH.Observations) 'ObservacionesOperador',
			ACH.DateCreated 'FechaOperador',
			VPC.DescriptionOfClient 'PDVOperador',
			RU.UsrNickName 'UsuarioOperador'
		FROM  DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
		JOIN DeliveryBackOffice.dbo.AccountingClosuresHeaderVisitPoint ACHVP
			ON ACHVP.IdAccountingClosuresHeaderVisitPoint = ACH.AccountingClosuresHeaderVisitPointId
		JOIN DeliveryBackOffice.dbo.RegisterUser RU
			ON RU.UsrIdUser = ACH.UserId
		JOIN DeliveryBackOffice.dbo.VisitPointClient VPC
			ON VPC.CodeOfReference = ACH.VisitPoint
		WHERE CONVERT(DATE, ACH.DateCreated) BETWEEN  CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
	END

END