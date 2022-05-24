USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[ObservationsClosureDesktopOperator]    Script Date: 24/05/2022 16:22:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[ObservationsClosureDesktopOperator]
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

	SELECT ACH.IdAccountingClosuresHeader 'CierreOperador',
		IIF((ACH.Observations IS NULL OR ACH.Observations = ''),'No se tienen observaciones.',ACH.Observations) 'ObservacionesOperador',
		ACH.DateCreated 'FechaOperador',
		VPC.DescriptionOfClient 'PDVOperador',
		RU.UsrNickName 'UsuarioOperador'
	FROM  DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
	JOIN DeliveryBackOffice.dbo.RegisterUser RU
		ON RU.UsrIdUser = ACH.UserId
	JOIN DeliveryBackOffice.dbo.RolByUserByAccount RBUBA
		ON RU.UsrIdUser = RBUBA.RuaIdUser
	JOIN DeliveryBackOffice.dbo.Account A
		ON A.AccIdAccount = RBUBA.RuaIdAccount
	JOIN DeliveryBackOffice.dbo.VisitPointClient VPC
		ON VPC.CodeOfReference = ACH.VisitPoint
	WHERE CONVERT(DATE, ACH.DateCreated) BETWEEN  CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
		AND (RBUBA.RuaIdAccount IN (SELECT AccountId FROM @tblIdAccount) OR @IdAccount = '-1')
		AND (ACH.IdAccountingClosuresHeader IN (SELECT CierreId FROM @tblIdCierre) OR @IdCierre = '-1')
		AND (ACH.VisitPoint IN (SELECT CodeOfReference FROM @tblVisitPointId) OR @VisitPointId = '-1')
	ORDER BY ACH.DateCreated
END