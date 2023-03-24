-- =============================================
-- Author:		<Jerson Ochoa>
-- Create date: <16-02-2023>
-- Description:	<Get incidence data for dashboard>
-- =============================================
-- Author:		<Jerson Ochoa>
-- Update date: <21-03-2023>
-- Description:	<Update params and flags for denied services>
-- =============================================
CREATE PROCEDURE [dbo].[spHW_GetIncidenceDashboardData]
	@UserId AS INT, -- RegisterUserId
	@CourierId AS INT = NULL,
	@DateStart AS DATE = NULL,
	@DateEnd AS DATE = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @StatusOrderIdFailed AS INT;
	DECLARE @StatusOrderIdIncidence AS INT;
	DECLARE @UserHubsList AS TABLE ([ID] INT);
	DECLARE @ConfOfIncList AS TABLE ([DateCreated] DATETIME,
									 [GuideNumber] INT,
									 [ConfirmationOfIncidenceId] INT,
									 [FirstName] NVARCHAR(100),
									 [LastName] NVARCHAR(100),
									 [IdCourier] INT);
	DECLARE @GeneralData AS TABLE (	[ID] INT,
									[IdCourier] INT,
									[FirstName] NVARCHAR(100),
									[LastName] NVARCHAR(100),
									[CatTypeConfirmationOfIncidenceId] INT,
									[CatTypeConfirmationOfIncidenceName] NVARCHAR(100),
									[IsValid] BIT,
									[IsConfirmed] BIT,
									[IsDenied] BIT,
									[StatusOrderId] INT,
									[LastStatusOrderId] INT,
									[OrderDescription] NVARCHAR(100));

	-- Date validations
	IF (@DateStart IS NULL)
		BEGIN
			SET  @DateStart = SYSDATETIME();
		END

	IF (@DateEnd IS NULL)
		BEGIN
			SET @DateEnd = DATEADD(DAY, 7, @DateStart);
		END

	IF (@DateEnd < @DateStart) 
		BEGIN
			SELECT 0 [spResult], 'El rango de fechas NO es válido.' [spMessage];
			RETURN;
		END

	SET @StatusOrderIdFailed = (SELECT [SO].[StatusOrderId]
								FROM	[dbo].[StatusOrder] SO
								WHERE	[SO].[OrderDescription] = 'Intento de entrega fallida');

	SET @StatusOrderIdIncidence = (	SELECT [SO].[StatusOrderId]
									FROM	[dbo].[StatusOrder] SO
									WHERE	[SO].[OrderDescription] = 'Incidencia en ruta');

	INSERT INTO @UserHubsList ([ID])
	SELECT		[HLU].[HubLogisticId]
	FROM		[dbo].[HubLogisticByUser] HLU
	WHERE		[HLU].[UserId] = @UserId;

	INSERT INTO @ConfOfIncList(	[DateCreated],
								[GuideNumber],
								[ConfirmationOfIncidenceId],
								[FirstName],
								[LastName],
								[IdCourier])
	SELECT		[DAT].[Date_Created],
				[DAT].[Guide_Number],
				[DAT].[ConfirmationOfIncidenceId],
				[SRE].[First_Name],
				[SRE].[Last_Name],
				[DAT].[ID_Courier]
	FROM		[dbo].[DeliveryAttempt] DAT WITH(NOLOCK)
	INNER JOIN	[dbo].[SenderReceiver] SRE 
		ON		[DAT].[ID_Courier] = [SRE].[ID]
		AND		[SRE].[HubLogisticId] IN (SELECT ID FROM @UserHubsList)
	WHERE		CONVERT(DATE, [DAT].[Date_Created]) BETWEEN @DateStart AND @DateEnd
		AND		((@CourierId IS NULL) OR ([DAT].[ID_Courier] = @CourierId))
		AND		[DAT].[ConfirmationOfIncidenceId] IS NOT NULL
	GROUP BY	[DAT].[Date_Created] , [DAT].[Guide_Number], [DAT].[ConfirmationOfIncidenceId], [SRE].[First_Name], [SRE].[Last_Name], [DAT].[ID_Courier]
	ORDER BY	[DAT].[ConfirmationOfIncidenceId] ;

	INSERT INTO @GeneralData
	SELECT		[CIL].[ConfirmationOfIncidenceId],
				[CIL].[IdCourier],
				[CIL].[FirstName],
				[CIL].[LastName],
				[COI].[CatTypeConfirmationOfIncidenceId],
				[TCI].[Name],
				[COI].[IsValid],
				[COI].[IsConfirmed],
				[COI].[IsDenied],
				[COI].[StatusOrderId],
				[COI].[LastStatusOrderId],
				[SOR].[OrderDescription]
	FROM		[dbo].[ConfirmationOfIncidence] COI
	INNER JOIN	@ConfOfIncList CIL
		ON		[COI].[IdConfirmationOfIncidence] = [CIL].[ConfirmationOfIncidenceId]
	INNER JOIN	[dbo].[StatusOrder] SOR
		ON		[COI].[StatusOrderId] = [SOR].[StatusOrderId]
	INNER JOIN	[dbo].[CatTypeConfirmationOfIncidence] TCI
		ON		[COI].[CatTypeConfirmationOfIncidenceId] = [TCI].[IdCatTypeConfirmationOfIncidence]
	WHERE		[COI].[RowStatus] = 1;

	SELECT		[GDA].[IdCourier],
				[GDA].[FirstName],
				[GDA].[LastName],
				(SELECT COUNT([GD].[ID]) FROM @GeneralData GD WHERE [GD].[StatusOrderId] = @StatusOrderIdFailed AND [GD].[IdCourier] = [GDA].[IdCourier])														[FailedVisitsCount],
				(SELECT COUNT([GD].[ID]) FROM @GeneralData GD WHERE [GD].[LastStatusOrderId] = @StatusOrderIdFailed AND [GD].[IdCourier] = [GDA].[IdCourier] AND [GD].[IsDenied] = 1)							[FailedVisitsDenied],
				(SELECT COUNT([GD].[ID]) FROM @GeneralData GD WHERE [GD].[StatusOrderId] = @StatusOrderIdFailed AND [GD].[IdCourier] = [GDA].[IdCourier] AND [GD].[IsConfirmed] = 1 AND [GD].[IsDenied] = 0)	[FailedVisitsConfirmed],
				(SELECT COUNT([GD].[ID]) FROM @GeneralData GD WHERE [GD].[StatusOrderId] = @StatusOrderIdFailed AND [GD].[IdCourier] = [GDA].[IdCourier] AND [GD].[IsConfirmed] = 0 AND [GD].[IsDenied] = 0)	[FailedVisitsNotConfirmed],
				(SELECT COUNT([GD].[ID]) FROM @GeneralData GD WHERE [GD].[StatusOrderId] = @StatusOrderIdIncidence AND [GD].[IdCourier] = [GDA].[IdCourier])													[IncidenceVisitsCount],
				(SELECT COUNT([GD].[ID]) FROM @GeneralData GD WHERE [GD].[LastStatusOrderId] = @StatusOrderIdIncidence AND [GD].[IdCourier] = [GDA].[IdCourier] AND [GD].[IsDenied] = 1)						[IncidenceVisitsDenied],
				(SELECT COUNT([GD].[ID]) FROM @GeneralData GD WHERE [GD].[StatusOrderId] = @StatusOrderIdIncidence AND [GD].[IdCourier] = [GDA].[IdCourier] AND [GD].[IsConfirmed] = 1 AND [GD].[IsDenied] = 0)	[IncidenceVisitsConfirmed],
				(SELECT COUNT([GD].[ID]) FROM @GeneralData GD WHERE [GD].[StatusOrderId] = @StatusOrderIdIncidence AND [GD].[IdCourier] = [GDA].[IdCourier] AND [GD].[IsConfirmed] = 0 AND [GD].[IsDenied] = 0)	[IncidenceVisitsNotConfirmed]
	FROM		@GeneralData GDA
	GROUP BY	[GDA].[IdCourier], [GDA].[FirstName], [GDA].[LastName];

	SELECT		(SELECT COUNT([GD].[ID]) FROM @GeneralData GD WHERE ([GD].[StatusOrderId] = @StatusOrderIdFailed OR [GD].[StatusOrderId] = @StatusOrderIdIncidence))	[FailedAndIncidenceCountTotal],
				(SELECT COUNT([GD].[ID]) FROM @GeneralData GD WHERE [GD].[StatusOrderId] = @StatusOrderIdFailed)														[FailedVisitsCountTotal],
				(SELECT COUNT([GD].[ID]) FROM @GeneralData GD WHERE [GD].[LastStatusOrderId] = @StatusOrderIdFailed AND [GD].[IsDenied] = 1)							[FailedVisitsDeniedTotal],
				(SELECT COUNT([GD].[ID]) FROM @GeneralData GD WHERE [GD].[StatusOrderId] = @StatusOrderIdFailed AND [GD].[IsConfirmed] = 1 AND [GD].[IsDenied] = 0)		[FailedVisitsConfirmedTotal],
				(SELECT COUNT([GD].[ID]) FROM @GeneralData GD WHERE [GD].[StatusOrderId] = @StatusOrderIdFailed AND [GD].[IsConfirmed] = 0 AND [GD].[IsDenied] = 0)		[FailedVisitsNotConfirmedTotal],
				(SELECT COUNT([GD].[ID]) FROM @GeneralData GD WHERE [GD].[StatusOrderId] = @StatusOrderIdIncidence)														[IncidenceVisitsCountTotal],
				(SELECT COUNT([GD].[ID]) FROM @GeneralData GD WHERE [GD].[LastStatusOrderId] = @StatusOrderIdIncidence AND [GD].[IsDenied] = 1)							[IncidenceVisitsDeniedTotal],
				(SELECT COUNT([GD].[ID]) FROM @GeneralData GD WHERE [GD].[StatusOrderId] = @StatusOrderIdIncidence AND [GD].[IsConfirmed] = 1 AND [GD].[IsDenied] = 0)	[IncidenceVisitsConfirmedTotal],
				(SELECT COUNT([GD].[ID]) FROM @GeneralData GD WHERE [GD].[StatusOrderId] = @StatusOrderIdIncidence AND [GD].[IsConfirmed] = 0 AND [GD].[IsDenied] = 0)	[IncidenceVisitsNotConfirmedTotal];
END