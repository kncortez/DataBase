CREATE PROCEDURE [dbo].[ObservationsClosureVisitPointOperator]
	@StartDate datetime = null,
	@EndDate datetime = null,
	@VisitPointId INT = null,
	@IdCierre INT = null
AS
BEGIN
	SELECT 
		ACH.IdAccountingClosuresHeader AS 'CierreOperador',
		ISNULL(NULLIF(ACH.Observations, ''), 'No se tienen observaciones.') AS 'ObservacionesOperador',
		ACH.DateCreated AS 'FechaOperador',
		VPC.DescriptionOfClient AS 'PDVOperador',
		RU.UsrNickName AS 'UsuarioOperador'
	FROM DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
	JOIN DeliveryBackOffice.dbo.AccountingClosuresHeaderVisitPoint ACHVP
		ON ACHVP.IdAccountingClosuresHeaderVisitPoint = ACH.AccountingClosuresHeaderVisitPointId
	JOIN DeliveryBackOffice.dbo.RegisterUser RU
		ON RU.UsrIdUser = ACH.UserId
	JOIN DeliveryBackOffice.dbo.VisitPointClient VPC
		ON VPC.CodeOfReference = ACH.VisitPoint
	WHERE CONVERT(DATE, ACH.DateCreated) BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
	AND (@VisitPointId = -1 OR VPC.CodeOfReference = @VisitPointId)
	AND (@IdCierre IS NULL OR @IdCierre <= 0 OR ACH.AccountingClosuresHeaderVisitPointId = @IdCierre)
END
