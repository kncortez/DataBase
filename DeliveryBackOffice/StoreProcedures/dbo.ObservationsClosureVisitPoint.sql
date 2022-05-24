USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[ObservationsClosureVisitPoint]    Script Date: 24/05/2022 16:24:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[ObservationsClosureVisitPoint]
	@StartDate datetime = null,
	@EndDate datetime = null,
	@VisitPointId INT = null,
	@IdCierre INT = null
AS
BEGIN

	IF(@VisitPointId > 0 AND @IdCierre > 0)
	BEGIN
		SELECT ACHVP.IdAccountingClosuresHeaderVisitPoint 'CierreGeneral',
			IIF((ACHVP.Observations IS NULL OR ACHVP.Observations = ''),'No se tienen observaciones.',ACHVP.Observations) 'ObservacionesGeneral',
			ACHVP.DateCreated 'FechaGeneral',
			VPC.DescriptionOfClient 'PDVGeneral',
			RU.UsrNickName 'UsuarioGeneral'
		FROM  DeliveryBackOffice.dbo.AccountingClosuresHeaderVisitPoint ACHVP
		JOIN DeliveryBackOffice.dbo.RegisterUser RU
			ON RU.UsrIdUser = ACHVP.UserId
		JOIN DeliveryBackOffice.dbo.VisitPointClient VPC
			ON VPC.CodeOfReference = ACHVP.VisitPoint
			AND VPC.CodeOfReference = @VisitPointId
		WHERE CONVERT(DATE, ACHVP.DateCreated) BETWEEN  CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
			AND ACHVP.IdAccountingClosuresHeaderVisitPoint = @IdCierre 
	END

	IF(@VisitPointId > 0 AND (@IdCierre <= 0 OR @IdCierre IS NULL))
	BEGIN
		SELECT ACHVP.IdAccountingClosuresHeaderVisitPoint 'CierreGeneral',
			IIF((ACHVP.Observations IS NULL OR ACHVP.Observations = ''),'No se tienen observaciones.',ACHVP.Observations) 'ObservacionesGeneral',
			ACHVP.DateCreated 'FechaGeneral',
			VPC.DescriptionOfClient 'PDVGeneral',
			RU.UsrNickName 'UsuarioGeneral'
		FROM  DeliveryBackOffice.dbo.AccountingClosuresHeaderVisitPoint ACHVP
		JOIN DeliveryBackOffice.dbo.RegisterUser RU
			ON RU.UsrIdUser = ACHVP.UserId
		JOIN DeliveryBackOffice.dbo.VisitPointClient VPC
			ON VPC.CodeOfReference = ACHVP.VisitPoint
			AND VPC.CodeOfReference = @VisitPointId
		WHERE CONVERT(DATE, ACHVP.DateCreated) BETWEEN  CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
	END

	IF(@VisitPointId = -1 AND (@IdCierre <= 0 OR @IdCierre IS NULL))
	BEGIN
		SELECT ACHVP.IdAccountingClosuresHeaderVisitPoint 'CierreGeneral',
			IIF((ACHVP.Observations IS NULL OR ACHVP.Observations = ''),'No se tienen observaciones.',ACHVP.Observations) 'ObservacionesGeneral',
			ACHVP.DateCreated 'FechaGeneral',
			VPC.DescriptionOfClient 'PDVGeneral',
			RU.UsrNickName 'UsuarioGeneral'
		FROM  DeliveryBackOffice.dbo.AccountingClosuresHeaderVisitPoint ACHVP
		JOIN DeliveryBackOffice.dbo.RegisterUser RU
			ON RU.UsrIdUser = ACHVP.UserId
		JOIN DeliveryBackOffice.dbo.VisitPointClient VPC
			ON VPC.CodeOfReference = ACHVP.VisitPoint
		WHERE CONVERT(DATE, ACHVP.DateCreated) BETWEEN  CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
	END

END