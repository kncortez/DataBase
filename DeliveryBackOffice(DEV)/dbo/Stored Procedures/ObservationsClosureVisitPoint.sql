CREATE PROCEDURE [dbo].[ObservationsClosureVisitPoint]
	@StartDate datetime = null,
	@EndDate datetime = null,
	@VisitPointId INT = null,
	@IdCierre INT = null
AS
BEGIN
	SELECT 
		ACHVP.IdAccountingClosuresHeaderVisitPoint AS 'CierreGeneral',
		ISNULL(NULLIF(ACHVP.Observations, ''), 'No se tienen observaciones.') AS 'ObservacionesGeneral',
		ACHVP.DateCreated AS 'FechaGeneral',
		VPC.DescriptionOfClient AS 'PDVGeneral',
		RU.UsrNickName AS 'UsuarioGeneral'
	FROM DeliveryBackOffice.dbo.AccountingClosuresHeaderVisitPoint ACHVP
	INNER JOIN DeliveryBackOffice.dbo.RegisterUser RU
		ON RU.UsrIdUser = ACHVP.UserId
	INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC
		ON VPC.CodeOfReference = ACHVP.VisitPoint
	WHERE CONVERT(DATE, ACHVP.DateCreated) BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
	AND (@VisitPointId = -1 OR VPC.CodeOfReference = @VisitPointId)
	AND (@IdCierre IS NULL OR @IdCierre <= 0 OR ACHVP.IdAccountingClosuresHeaderVisitPoint = @IdCierre)
END
