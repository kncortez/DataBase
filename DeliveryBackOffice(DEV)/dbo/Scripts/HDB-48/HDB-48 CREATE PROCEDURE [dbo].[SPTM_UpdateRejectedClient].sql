USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[sps_set_Return_of_delivery]    Script Date: 1/25/2023 09:41:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2023-01-25>
-- Description:	< Proceso para actualizar usuarios generados desde portal de telemercadeo que no cumplieron metas previo a fecha de corte >
-- =============================================
CREATE PROCEDURE [dbo].[SPTM_UpdateRejectedClient]
AS
BEGIN
	
	DECLARE @IndividualCustomer INT = (SELECT TOP 1 CT.IdCustomerType FROM [DeliveryBackOffice].[dbo].[CustomerType] CT WITH(NOLOCK) WHERE CT.[Description] = 'INDIVIDUAL' COLLATE Latin1_General_CI_AI);
	DECLARE @PYMESBusiness INT = (SELECT TOP 1 CTOB.IdTypeOfBusiness FROM [DeliveryBackOffice].[dbo].[CatTypeOfBusiness] CTOB WITH(NOLOCK) WHERE CTOB.TypeOfBusinessName = 'PYMES' COLLATE Latin1_General_CI_AI);

	DECLARE @ModernBusiness INT = (
		SELECT
			TOP 1
				CTOB.IdTypeOfBusiness
		FROM
			[DeliveryBackOffice].[dbo].[CatTypeOfBusiness] CTOB WITH(NOLOCK)
		WHERE
			CTOB.TypeOfBusinessName = 'CANAL MODERNO' COLLATE Latin1_General_CI_AI)

	DECLARE @VoidStatus INT = (SELECT TOP 1 SO.StatusOrderId FROM [DeliveryBackOffice].[dbo].[StatusOrder] SO WITH(NOLOCK) WHERE SO.OrderDescription = 'Anulado' COLLATE Latin1_General_CI_AI);
	
	IF OBJECT_ID('tempdb.dbo.#CustomerCandidates', 'U') IS NOT NULL
        DROP TABLE #CustomerCandidates;

	CREATE TABLE #CustomerCandidates(
		IdCustomer INT,
		CutOffDate DATETIME,
		GoalQuantity INT,
		TotalGuidesToDate INT
	);

	--DECLARE @CustomerCandidates TABLE(
	--	IdCustomer INT,
	--	CutOffDate DATETIME,
	--	GoalQuantity INT,
	--	TotalGuidesToDate INT
	--);


	CREATE NONCLUSTERED INDEX TMP_IDX_CUstomerCandidates_Customer ON #CustomerCandidates (IdCustomer)
	CREATE NONCLUSTERED INDEX TMP_IDX_CUstomerCandidates_GuidesToDate ON #CustomerCandidates (CutOffDate, GoalQuantity, TotalGuidesToDate)

	BEGIN TRANSACTION
	BEGIN TRY

		INSERT INTO #CustomerCandidates
			(
				IdCustomer,
				CutOffDate,
				GoalQuantity,
				TotalGuidesToDate
			)
		SELECT
			Cu.IdCustomer
			,Cu.CutOffDate
			,Cu.CustomerGoalQuantity
			,ISNULL(GuideAmountBeforeCut.TotalGuides, 0) 'TotalGuides'
		FROM
			[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
			OUTER APPLY (
				SELECT
					TOP 1
						COUNT(DISTINCT DO.Guide_Number) 'TotalGuides'
				FROM
					[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
				WHERE
					DO.IdCustomer = Cu.IdCustomer
					AND
					DO.StatusOrderId NOT IN (@VoidStatus)
					AND
					DO.DateCreated <= Cu.CutOffDate
				GROUP BY
					DO.IdCustomer
			) GuideAmountBeforeCut
		WHERE
			Cu.IdCustomerType = @IndividualCustomer
			AND
			ISNULL(Cu.TypeOfBusinessID, 0) = @PYMESBusiness
			AND
			Cu.CatTMSalesPersonId IS NOT NULL
			AND
			Cu.UpgradeDate IS NULL

		UPDATE
			Cu
		SET
			TypeOfBusinessID = @ModernBusiness,
			CatTMSalesPersonId = NULL,
			CutOffDate = NULL,
			CustomerGoalQuantity = NULL,
			DateUpdated = GETDATE(),
			TokenUpdated = 'SYS-TELEMARKETING'
		FROM
			[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
			INNER JOIN
				#CustomerCandidates CC
				ON
					Cu.IdCustomer = CC.IdCustomer
		WHERE
			CC.CutOffDate <= GETDATE()
			AND
			CC.TotalGuidesToDate < CC.GoalQuantity

		COMMIT TRANSACTION;
			
	END TRY
	BEGIN CATCH

		ROLLBACK TRANSACTION;

		INSERT INTO [DeliveryBackOffice].[dbo].[RoutePreparationLogError]
			(DateCreated, TokenCreated, ErrorProcedure, ErrorDescription, ErrorLine)
		VALUES
			(GETDATE(), 'SYS-TELEMARKETING', ERROR_PROCEDURE(), ERROR_MESSAGE(), ERROR_LINE())

	END CATCH

	IF OBJECT_ID('tempdb.dbo.#CustomerCandidates', 'U') IS NOT NULL
        DROP TABLE #CustomerCandidates;

END
