
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-09-21>
-- Description:	< Obtiene información de link de recolección para poder ser procesada en landing page.>
-- =============================================
CREATE PROCEDURE [dbo].[GetVisitPointDataLinkInformation]
	@DataLinkToken NVARCHAR(50)
AS
BEGIN

	-- Variables de control de flujo
	DECLARE @CompletedLinkStatusId INT = (SELECT TOP 1 CDLS.IdCatDataLinkStatus FROM [DeliveryBackOffice].[dbo].[CatDataLinkStatus] CDLS WITH(NOLOCK) WHERE CDLS.DataLinkStatusName = 'Completado' AND CDLS.RowStatus = 1)

	-- Variables de respuesta
	DECLARE @DataLinkInfo AS TABLE (
		DataLinkId INT,
		AccountId BIGINT,
		VisitPointCode INT,

		VisitPointDescription NVARCHAR(100),
		VisitPointContact NVARCHAR(200),
		VisitPointPhone NVARCHAR(50),
		VisitPointEmail NVARCHAR(200),

		VisitPointDepartmentId INT,
		VisitPointDepartment NVARCHAR(100),
		VisitPointTownId INT,
		VisitPointTown NVARCHAR(100),
		VisitPointAddress NVARCHAR(600),

		VisitPointReferenceId INT,
		VisitPointReferenceName NVARCHAR(50),

		VisitPointZone NVARCHAR(50),
		VisitPointColony NVARCHAR(50),

		VisitPointSpecialInstructions NVARCHAR(200),
		
		VisitPointLatitude NVARCHAR(20),
		VisitPointLongitude NVARCHAR(20),

		IsOnlyVisitPoint BIT
	);

	BEGIN TRY

		INSERT INTO @DataLinkInfo
			(
				DataLinkId
				, AccountId
				, VisitPointCode
				, VisitPointDescription
				, VisitPointContact
				, VisitPointPhone
				, VisitPointEmail
				, VisitPointDepartmentId
				, VisitPointDepartment
				, VisitPointTownId
				, VisitPointTown
				, VisitPointAddress
				, VisitPointReferenceId
				, VisitPointReferenceName
				, VisitPointZone
				, VisitPointColony
				, VisitPointSpecialInstructions
				, VisitPointLatitude
				, VisitPointLongitude
				, IsOnlyVisitPoint
			)
		SELECT
			VPDL.IdVisitPointDataLink
			,VPDL.AccountId
			,VPC.CodeOfReference
			,ISNULL(VPC.DescriptionOfClient, VPDL.VisitPointName) 'DescriptionOfClient'
			,ISNULL(VPC.ContactName, VPDL.VisitPointName) 'ContactName'
			,ISNULL(VPC.Phone,VPDL.VisitPointPhone) 'Phone'
			,VPC.Email
			,Prv.IdProvince
			,VPC.Department
			,Twn.IdTownship
			,VPC.Town
			,VPC.[Address]
			,UA.IdCityPlace
			,CCP.CityPlace
			,VPC.[Zone]
			,''
			,UA.UadAdditionalInstructions
			,VPC.Latitude
			,VPC.Longitude
			,ISNULL(VPDL.IsOnlyVisitPoint, 0)
		FROM
			[DeliveryBackOffice].[dbo].[VisitPointDataLink] VPDL WITH(NOLOCK)
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK)
				ON
					VPDL.VisitPointId = VPC.CodeOfReference
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[Township] Twn WITH(NOLOCK)
				ON
					VPC.IdTownship = Twn.IdTownship
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[Province] Prv WITH(NOLOCK)
				ON
					Twn.IdProvince = Prv.IdProvince
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[UserAddress] UA WITH(NOLOCK)
				ON
					VPC.CodeOfReference = UA.CodeOfReference
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[CatCityPlace] CCP WITH(NOLOCK)
				ON
					UA.IdCityPlace = CCP.IdCityPlace
		WHERE
			VPDL.ServiceToken = @DataLinkToken
			AND
			VPDL.DataLinkStatusId NOT IN (@CompletedLinkStatusId) -- Si link esta en estado no operable
			AND
			(VPDL.ServiceTokenExpiration IS NULL OR VPDL.ServiceTokenExpiration >= GETDATE()) -- Si Link ha expirado por tiempo
			AND
			VPDL.RowStatus = 1 -- Si link sigue activo lógicamente

		IF (EXISTS (SELECT TOP 1 1 FROM @DataLinkInfo))
		BEGIN

			SELECT
				200 [blnResult],
				'DataLink valido' [resultMessage]

			SELECT
				DLI.DataLinkId
				, DLI.AccountId
				, DLI.VisitPointCode
				, DLI.VisitPointDescription
				, DLI.VisitPointContact
				, DLI.VisitPointPhone
				, DLI.VisitPointEmail
				, DLI.VisitPointDepartmentId
				, DLI.VisitPointDepartment
				, DLI.VisitPointTownId
				, DLI.VisitPointTown
				, DLI.VisitPointAddress
				, DLI.VisitPointSpecialInstructions
				, DLI.VisitPointReferenceId
				, DLI.VisitPointReferenceName
				, DLI.VisitPointZone
				, DLI.VisitPointColony
				, DLI.VisitPointLatitude
				, DLI.VisitPointLongitude
				, DLI.IsOnlyVisitPoint
			FROM
				@DataLinkInfo DLI

		END
		ELSE
		BEGIN

			SELECT
				404 [blnResult],
				'DataLink invalido' [resultMessage]

		END

	END TRY
	BEGIN CATCH

		SELECT
			500 [blnResult],
			ERROR_MESSAGE() [resultMessage]

	END CATCH

END