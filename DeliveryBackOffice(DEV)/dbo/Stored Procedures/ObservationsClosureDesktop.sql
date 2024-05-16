CREATE PROCEDURE [dbo].[ObservationsClosureDesktop]
	@StartDate datetime = null,
	@EndDate datetime = null,
	@VisitPointId NVARCHAR(MAX) = null,
	@IdCierre NVARCHAR(MAX) = null,
	@IdAccount NVARCHAR(MAX) = null
AS
BEGIN
	DECLARE @tblVisitPointId TABLE(
		CodeOfReference int
	)
	INSERT INTO @tblVisitPointId
	SELECT
		SUBSTRING(Item, 1, LEN(Item)) ItemNumber
	FROM DeliveryBackOffice.dbo.SplitUnlimited(@VisitPointId, ',')
	DECLARE @tblIdCierre TABLE(
		CierreId int
	)
	INSERT INTO @tblIdCierre
	SELECT
		SUBSTRING(Item, 1, LEN(Item)) ItemNumber
	FROM DeliveryBackOffice.dbo.SplitUnlimited(@IdCierre, ',')
	DECLARE @tblIdAccount TABLE(
		AccountId int
	)
	INSERT INTO @tblIdAccount
	SELECT
		SUBSTRING(Item, 1, LEN(Item)) ItemNumber
	FROM DeliveryBackOffice.dbo.SplitUnlimited(@IdAccount, ',')
	SELECT ACHVP.IdAccountingClosuresHeaderVisitPoint 'CierreGeneral',
		ISNULL(NULLIF(ACHVP.Observations, ''), 'No se tienen observaciones.') AS 'ObservacionesGeneral',
		ACHVP.DateCreated 'FechaGeneral',
		VPC.DescriptionOfClient 'PDVGeneral',
		RU.UsrNickName 'UsuarioGeneral'
	FROM  DeliveryBackOffice.dbo.AccountingClosuresHeaderVisitPoint ACHVP
	INNER JOIN DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
		ON ACHVP.IdAccountingClosuresHeaderVisitPoint = ACH.AccountingClosuresHeaderVisitPointId
	INNER JOIN DeliveryBackOffice.dbo.RegisterUser RU
		ON RU.UsrIdUser = ACHVP.UserId
	INNER JOIN DeliveryBackOffice.dbo.RolByUserByAccount RBUBA
		ON RU.UsrIdUser = RBUBA.RuaIdUser
	INNER JOIN DeliveryBackOffice.dbo.Account A
		ON A.AccIdAccount = RBUBA.RuaIdAccount
	INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC
		ON VPC.CodeOfReference = ACHVP.VisitPoint
	WHERE CONVERT(DATE, ACHVP.DateCreated) BETWEEN  CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
		AND (RBUBA.RuaIdAccount IN (SELECT AccountId FROM @tblIdAccount) OR @IdAccount = '-1')
		AND (ACH.IdAccountingClosuresHeader IN (SELECT CierreId FROM @tblIdCierre) OR @IdCierre = '-1')
		AND (ACH.VisitPoint IN (SELECT CodeOfReference FROM @tblVisitPointId) OR @VisitPointId = '-1')
END