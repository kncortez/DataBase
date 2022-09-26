
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
	DECLARE @CompletedLinkStatusId INT = (SELECT TOP 1 CDLS.IdCatDataLinkStatus FROM [DeliveryBackOffice].[dbo].[CatDataLinkStatus] CDLS WITH(NOLOCK) WHERE CDLS.DataLinkStatusName = 'Completado' COLLATE Latin1_General_CI_AI AND CDLS.RowStatus = 1)

	-- Variables de respuesta
	DECLARE @DataLinkInfo AS TABLE (
		DataLinkId INT,
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
		
		VisitPointLatitude NVARCHAR(20),
		VisitPointLongitude NVARCHAR(20)
	);

	BEGIN TRY

		INSERT INTO @DataLinkInfo
			(
				DataLinkId
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
				, VisitPointLatitude
				, VisitPointLongitude
			)
		SELECT
			VPDL.IdVisitPointDataLink
			,VPC.CodeOfReference
			,VPC.DescriptionOfClient
			,VPC.ContactName
			,VPC.Phone
			,VPC.Email
			,Prv.IdProvince
			,VPC.Department
			,Twn.IdTownship
			,VPC.Town
			,VPC.[Address]
			,VPC.Latitude
			,VPC.Longitude
		FROM
			[DeliveryBackOffice].[dbo].[VisitPointDataLink] VPDL WITH(NOLOCK)
			INNER JOIN
				[DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK)
				ON
					VPDL.VisitPointId = VPC.CodeOfReference
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[Province] Prv WITH(NOLOCK)
				ON
					VPC.Department = Prv.ProvinceName COLLATE Latin1_General_CI_AI
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[Township] Twn WITH(NOLOCK)
				ON
					VPC.Town = Twn.TownshipName COLLATE Latin1_General_CI_AI
		WHERE
			VPDL.ServiceToken = @DataLinkToken
			AND
			VPDL.DataLinkStatusId NOT IN (@CompletedLinkStatusId) -- Si link esta en estado no operable
			AND
			(VPDL.ServiceTokenExpiration IS NULL OR VPDL.ServiceTokenExpiration <= GETDATE()) -- Si Link ha expirado por tiempo
			AND
			VPDL.RowStatus = 1 -- Si link sigue activo lógicamente

		IF (EXISTS (SELECT TOP 1 1 FROM @DataLinkInfo))
		BEGIN

			SELECT
				200 [blnResult],
				'DataLink valido' [resultMessage]

			SELECT
				DLI.DataLinkId
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
				, DLI.VisitPointLatitude
				, DLI.VisitPointLongitude
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