USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetSalePackageToDeactivate]    Script Date: 1/24/2023 14:06:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2023-01-24>
-- Description:	< Busqueda de membresias o subscripciones las cuales deben ser inactivadas >
-- =============================================

CREATE PROCEDURE [dbo].[GetSalePackageToDeactivate]
	@Token NVARCHAR(50) = 'SYS-HERMESCHARGESERVICE'
AS
BEGIN

	-- Variables estaticas globales
	DECLARE @SystemId INT = (SELECT TOP 1 CS.SysIdSystem FROM [DeliveryBackOffice].[dbo].[CatSystem] CS WITH(NOLOCK) WHERE CS.SysNameSystem = 'Hermes Charge Service' COLLATE Latin1_General_CI_AI AND CS.SysRowStatus = 1)

	DECLARE @InactiveStatus INT = (SELECT TOP 1 CSPS.IdCatSalesPackageStatus FROM [DeliveryBackOffice].[dbo].[CatSalesPackageStatus] CSPS WITH(NOLOCK) WHERE CSPS.SalesPackageStatusName = 'Inactiva' COLLATE Latin1_General_CI_AI);
	DECLARE @VoidStatus INT = (SELECT TOP 1 CSPS.IdCatSalesPackageStatus FROM [DeliveryBackOffice].[dbo].[CatSalesPackageStatus] CSPS WITH(NOLOCK) WHERE CSPS.SalesPackageStatusName = 'Anulada' COLLATE Latin1_General_CI_AI);
	
	DECLARE @SalesPackagePointsToDeactivate TABLE (
		SalesPackageId INT
	);

	DECLARE @SalesPackageToDeactivate TABLE (
		SalesPackageId INT,
		SalesPackageType NVARCHAR(20)
	);
	
	DECLARE @SalesPackageToVoid TABLE (
		SalesPackageId INT,
		SalesPackageType NVARCHAR(20)
	);

	BEGIN TRANSACTION
	BEGIN TRY

		-- Puntos forza por vencer
		INSERT INTO @SalesPackagePointsToDeactivate
			(SalesPackageId)
		SELECT
			MMSHP.IdMembership
		FROM
			[DeliveryBackOffice].[dbo].[Membership] MMSHP WITH(NOLOCK)
		WHERE
			MMSHP.PointsExpirationDate <= GETDATE()
			AND
			MMSHP.CatMembershipStatusId NOT IN (@InactiveStatus, @VoidStatus)
			AND
			MMSHP.RowStatus = 1;
		
		-- Paquetes por desactivar
		INSERT INTO @SalesPackageToDeactivate
			(SalesPackageId, SalesPackageType)
		SELECT
			MMSHP.IdMembership
			,'MEMBERSHIP'
		FROM
			[DeliveryBackOffice].[dbo].[Membership] MMSHP WITH(NOLOCK)
		WHERE
			MMSHP.ExpirationDate <= GETDATE()
			AND
			MMSHP.CatMembershipStatusId != @InactiveStatus
			AND
			MMSHP.RowStatus = 1;
			
		INSERT INTO @SalesPackageToDeactivate
			(SalesPackageId, SalesPackageType)
		SELECT
			SBSCTPN.IdSubscription
			,'SUBSCRIPTION'
		FROM
			[DeliveryBackOffice].[dbo].[Subscription] SBSCTPN WITH(NOLOCK)
		WHERE
			SBSCTPN.ExpirationDate <= GETDATE()
			AND
			SBSCTPN.CatSubscriptionStatusId != @InactiveStatus
			AND
			SBSCTPN.RowStatus = 1;

		-- Paquetes por anular
		INSERT INTO @SalesPackageToVoid
			(SalesPackageId, SalesPackageType)
		SELECT
			MMSHP.IdMembership
			,'MEMBERSHIP'
		FROM
			[DeliveryBackOffice].[dbo].[Membership] MMSHP WITH(NOLOCK)
		WHERE
			MMSHP.CatMembershipStatusId != @VoidStatus
			AND
			MMSHP.RowStatus = 0;
			
		INSERT INTO @SalesPackageToVoid
			(SalesPackageId, SalesPackageType)
		SELECT
			SBSCTPN.IdSubscription
			,'SUBSCRIPTION'
		FROM
			[DeliveryBackOffice].[dbo].[Subscription] SBSCTPN WITH(NOLOCK)
		WHERE
			SBSCTPN.CatSubscriptionStatusId != @VoidStatus
			AND
			SBSCTPN.RowStatus = 0;

		-- Expirar puntos
		IF(EXISTS(SELECT TOP 1 1 FROM @SalesPackagePointsToDeactivate))
		BEGIN
		
			UPDATE
				MMBSHP
			SET
				AccumulatedPoints = 0
				,AvailablePoints = 0
				,DateUpdated = GETDATE()
				,TokenUpdated = @Token
			FROM
				[DeliveryBackOffice].[dbo].[Membership] MMBSHP
				INNER JOIN
					@SalesPackagePointsToDeactivate SPPTD
					ON
						MMBSHP.IdMembership = SPPTD.SalesPackageId

		END

		-- Expirar membresias y suscripciones
		IF(EXISTS(SELECT TOP 1 1 FROM @SalesPackageToDeactivate))
		BEGIN

			UPDATE
				MMBSHP
			SET
				CatMembershipStatusId = @InactiveStatus
				,DateUpdated = GETDATE()
				,TokenUpdated = @Token
			FROM
				[DeliveryBackOffice].[dbo].[Membership] MMBSHP
				INNER JOIN
					@SalesPackageToDeactivate SPTD
					ON
						MMBSHP.IdMembership = SPTD.SalesPackageId
						AND
						SPTD.SalesPackageType = 'MEMBERSHIP' COLLATE Latin1_General_CI_AI
						
			UPDATE
				SBSCTPN
			SET
				CatSubscriptionStatusId = @InactiveStatus
				,DateUpdated = GETDATE()
				,TokenUpdated = @Token
			FROM
				[DeliveryBackOffice].[dbo].[Subscription] SBSCTPN
				INNER JOIN
					@SalesPackageToDeactivate SPTD
					ON
						SBSCTPN.IdSubscription = SPTD.SalesPackageId
						AND
						SPTD.SalesPackageType = 'SUBSCRIPTION' COLLATE Latin1_General_CI_AI

		END

		-- Anular membresias y suscripciones
		IF(EXISTS(SELECT TOP 1 1 FROM @SalesPackageToVoid))
		BEGIN

			UPDATE
				MMBSHP
			SET
				CatMembershipStatusId = @VoidStatus
				,DateUpdated = GETDATE()
				,TokenUpdated = @Token
			FROM
				[DeliveryBackOffice].[dbo].[Membership] MMBSHP
				INNER JOIN
					@SalesPackageToVoid SPTV
					ON
						MMBSHP.IdMembership = SPTV.SalesPackageId
						AND
						SPTV.SalesPackageType = 'MEMBERSHIP' COLLATE Latin1_General_CI_AI

			UPDATE
				SBSCTPN
			SET
				CatSubscriptionStatusId = @VoidStatus
				,DateUpdated = GETDATE()
				,TokenUpdated = @Token
			FROM
				[DeliveryBackOffice].[dbo].[Subscription] SBSCTPN
				INNER JOIN
					@SalesPackageToVoid SPTV
					ON
						SBSCTPN.IdSubscription = SPTV.SalesPackageId
						AND
						SPTV.SalesPackageType = 'SUBSCRIPTION' COLLATE Latin1_General_CI_AI

		END

		COMMIT TRANSACTION;

		SELECT
			1 'blnResult'

	END TRY
	BEGIN CATCH

		ROLLBACK TRANSACTION;

		SELECT
			0 'blnResult'

	END CATCH

END

