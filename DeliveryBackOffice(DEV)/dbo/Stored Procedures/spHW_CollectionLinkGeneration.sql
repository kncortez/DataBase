-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-09-19>
-- Description:	<Método para generación de Link de recolección y envíarlo vía Whatsaap>
-- =============================================
CREATE PROCEDURE [dbo].[spHW_CollectionLinkGeneration]

	@VisitPointCodeOfReference AS INT=null,
	@AccountId AS BIGINT,
	@Token NVARCHAR(50),
	@VisitPointPhone NVARCHAR(50),
	@VisitPointName NVARCHAR(100),
	@IsOnlyVisitPoint BIT = 0

AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @GeneratedLinkStatusId INT = (SELECT TOP 1 CDLS.IdCatDataLinkStatus FROM [DeliveryBackOffice].[dbo].[CatDataLinkStatus] CDLS WITH(NOLOCK) WHERE CDLS.DataLinkStatusName = 'Generado' COLLATE Latin1_General_CI_AI AND CDLS.RowStatus = 1);
	DECLARE @CompletedLinkStatusId INT = (SELECT TOP 1 CDLS.IdCatDataLinkStatus FROM [DeliveryBackOffice].[dbo].[CatDataLinkStatus] CDLS WITH(NOLOCK) WHERE CDLS.DataLinkStatusName = 'Completado' COLLATE Latin1_General_CI_AI AND CDLS.RowStatus = 1);

	DECLARE @PickupLinkBase NVARCHAR(500) = '';

	DECLARE @ResponseData AS TABLE (
		PickupToken NVARCHAR(50),
		DataLinkId BIGINT
	);

	BEGIN TRANSACTION
	BEGIN TRY

		IF @VisitPointCodeOfReference IS NOT NULL AND @AccountId IS NOT NULL 
			AND ( EXISTS (SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[VisitPointDataLink] VPDL WITH(NOLOCK) WHERE VPDL.AccountId = @AccountId AND VPDL.VisitPointId = @VisitPointCodeOfReference AND VPDL.DataLinkStatusId != @CompletedLinkStatusId AND VPDL.RowStatus = 1)  )
		BEGIN

			INSERT INTO @ResponseData
				(PickupToken, DataLinkId)
			SELECT
				TOP 1
					VPDL.ServiceToken, VPDL.IdVisitPointDataLink
			FROM
				[DeliveryBackOffice].[dbo].[VisitPointDataLink] VPDL WITH(NOLOCK)
			WHERE
				VPDL.AccountId = @AccountId 
				AND 
				VPDL.VisitPointId = @VisitPointCodeOfReference 
				AND 
				VPDL.DataLinkStatusId != @CompletedLinkStatusId 
				AND 
				VPDL.RowStatus = 1
			ORDER BY
				VPDL.DateCreated DESC

			IF( EXISTS(SELECT TOP 1 1 FROM @ResponseData))
			BEGIN
	
		COMMIT TRANSACTION;

				SELECT
					TOP 1
						200 [StatusCode],
						CONCAT(@PickupLinkBase, RP.PickupToken) [Description]
				FROM
					@ResponseData RP 

			END
			ELSE
			BEGIN
	
		ROLLBACK TRANSACTION;

				SELECT
					404 [StatusCode],
					'Link no encontrado' [Description]

			END

		END
		ELSE IF @VisitPointCodeOfReference IS NULL AND @AccountId IS NOT NULL 
			AND ( EXISTS (SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[VisitPointDataLink] VPDL WITH(NOLOCK) WHERE VPDL.AccountId = @AccountId AND VPDL.VisitPointId IS NULL AND VPDL.DataLinkStatusId != @CompletedLinkStatusId AND VPDL.RowStatus = 1)  )
		BEGIN

			INSERT INTO @ResponseData
				(PickupToken, DataLinkId)
			SELECT
				TOP 1
					VPDL.ServiceToken, VPDL.IdVisitPointDataLink
			FROM
				[DeliveryBackOffice].[dbo].[VisitPointDataLink] VPDL WITH(NOLOCK)
			WHERE
				VPDL.AccountId = @AccountId 
				AND 
				VPDL.VisitPointId IS NULL 
				AND 
				VPDL.DataLinkStatusId != @CompletedLinkStatusId 
				AND 
				VPDL.RowStatus = 1
			ORDER BY
				VPDL.DateCreated DESC

			IF( EXISTS(SELECT TOP 1 1 FROM @ResponseData))
			BEGIN
	
		COMMIT TRANSACTION;

				SELECT
					TOP 1
						200 [StatusCode],
						CONCAT(@PickupLinkBase, RP.PickupToken) [Description]
				FROM
					@ResponseData RP 

			END
			ELSE
			BEGIN
	
		ROLLBACK TRANSACTION;

				SELECT
					404 [StatusCode],
					'Link no encontrado' [Description]

			END

		END
		ELSE
		BEGIN

			IF (@VisitPointCodeOfReference IS NOT NULL AND @AccountId IS NOT NULL )
				OR (@VisitPointPhone IS NOT NULL AND @VisitPointName IS NOT NULL)
				OR (@VisitPointCodeOfReference IS NULL AND @AccountId IS NOT NULL AND @VisitPointPhone IS NOT NULL AND @VisitPointName IS NOT NULL)
				INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointDataLink]
					(
						AccountId
						, VisitPointId
						, DataLinkStatusId
						, ServiceToken
						, ServiceTokenExpiration
						, TokenCreated
						, DateCreated
						, VisitPointPhone
						, VisitPointName
						, IsOnlyVisitPoint
					)
				OUTPUT inserted.ServiceToken, inserted.IdVisitPointDataLink INTO @ResponseData (PickupToken, DataLinkId)
				VALUES
					(
						@AccountId
						, @VisitPointCodeOfReference
						, @GeneratedLinkStatusId
						, CONVERT(VARCHAR(32), HASHBYTES('MD5', CONCAT(RIGHT(CONCAT('0000000000',ISNULL(@AccountId, @VisitPointPhone)), 10), RIGHT(CONCAT('0000000000', ISNULL(@VisitPointCodeOfReference, @VisitPointPhone)), 10), CONVERT(NVARCHAR, GETDATE(), 25))), 2)
						, DATEADD(DAY, 30, GETDATE())
						, @Token
						, GETDATE()
						, @VisitPointPhone
						, @VisitPointName
						, @IsOnlyVisitPoint
					)

			IF( EXISTS(SELECT TOP 1 1 FROM @ResponseData))
			BEGIN
	
		COMMIT TRANSACTION;

				SELECT
					TOP 1
						200 [StatusCode],
						CONCAT(@PickupLinkBase, RP.PickupToken) [Description]
				FROM
					@ResponseData RP 

			END
			ELSE
			BEGIN
	
		ROLLBACK TRANSACTION;

				SELECT
					404 [StatusCode],
					'Link no encontrado' [Description]

			END

		END

	END TRY
	BEGIN CATCH

		ROLLBACK TRANSACTION;

		SELECT
			500 [StatusCode],
			ERROR_MESSAGE() [Description]

	END CATCH

END