


-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2021-08-18>
-- Description:	< Recupera datos de guías para ingresar a una plataforma externa, las cuales no han sido procesadas para ingreso a Simpliroute >
-- =============================================
-- =============================================
-- Author:		<Andres,Ruiz>
-- Modification date: <2021-10-08>
-- Description:	< Actualización para tomar en cuenta tipo de visita en Simpliroute y mejora en forma de datos obtenidos >
-- =============================================
-- =============================================
-- Author:		<Andres,Ruiz>
-- Modification date: <2022-01-04>
-- Description:	< Actualización para generar JSON a enviar a Simpliroute, cambios en datos >
-- =============================================
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-02-15>
-- Description:	< Mejoras en manejo de busqueda historica de ubicaciones y optimizaciones de SP >
-- =============================================

CREATE PROCEDURE [dbo].[GetGuidesForExternalTool]
    @Guides TblGuides READONLY,
    @Departamento NVARCHAR(50) = 'Guatemala'
AS
BEGIN

    DECLARE @jsonResult NVARCHAR(MAX);

    --Manejo de clientes Business to business
    DECLARE @B2BIdSegment INT =
            (
                SELECT TOP 1
                       CBS.IdBusinessSegment
                FROM [DeliveryBackOffice].[dbo].[CatBusinessSegment] CBS WITH(NOLOCK)
                WHERE CBS.BusinessSegmentName LIKE '%B2B%'
            );
			
	-- Manejo de configuraciones
	DECLARE @AreProvincesConfigurated BIT = 0;
	DECLARE @AreTownshipsConfigurated BIT = 0;
	DECLARE @AreZonesConfigurated BIT = 0;

    -- Limpieza de servicios que estan siendo procesados
    DECLARE @AcceptedGuides AS TABLE
    (
        GuideSerie NVARCHAR(2),
        GuideNumber INT,
        SenderID INT,
        IdCustomer INT,
        ReceiverID INT,
        ReceiverFirstName NVARCHAR(100),
        ReceiverLastName NVARCHAR(100),
        ReceiverEmail NVARCHAR(200),
        ReceiverSocialSecurityID NVARCHAR(200),
        ReceiverPhone NVARCHAR(100),
        ReceiverAlternantFullName NVARCHAR(200),
        ReceiverAddress NVARCHAR(600),
        ReceiverTownshipId INT,
        ReceiverTown NVARCHAR(100),
        ReceiverDepartment NVARCHAR(100),
        IndicationsToSendDestination NVARCHAR(1500),
        PackageType TINYINT,
        IsCollect BIT,
        PriceShippment DECIMAL(14, 2),
        CollectOnDelivery DECIMAL(14, 2),
        PiecesDry INT,
        PiecesCold INT,
        TypeService NVARCHAR(3),
        IdDeliveryOption INT
    );

    BEGIN TRANSACTION;
    BEGIN TRY
		-- Revisar existencia de configuración
		SET @AreProvincesConfigurated = ISNULL((
			SELECT
				TOP 1
					1
			FROM
				[DeliveryBackOffice].[dbo].[ServiceProvinceConfiguration] SPC
			WHERE
				SPC.CatConfigurableServiceId = 1
				AND
				SPC.RowStatus = 1
		),0)
		SET @AreTownshipsConfigurated = ISNULL((
			SELECT
				TOP 1
					1
			FROM
				[DeliveryBackOffice].[dbo].[ServiceTownshipConfiguration] STC
			WHERE
				STC.CatConfigurableServiceId = 1
				AND
				STC.RowStatus = 1
		),0)
		SET @AreZonesConfigurated = ISNULL((
			SELECT
				TOP 1
					1
			FROM
				[DeliveryBackOffice].[dbo].[ServiceZoneConfiguration] SZC
			WHERE
				SZC.CatConfigurableServiceId = 1
				AND
				SZC.RowStatus = 1
		),0)

        -- Liberar intentos viejos de traslado de guías
        UPDATE EPSL
        SET RowStatus = 0,
            TokenUpdated = 'SYS-HERMESROUTES',
            DateUpdated = GETDATE()
        FROM [DeliveryBackOffice].[dbo].[ExternalPlatformServiceLog] EPSL
        WHERE EPSL.DateCreated <= DATEADD(MINUTE, -60, GETDATE())
              AND EPSL.RowStatus = 1
              AND CAST(EPSL.DateCreated AS DATE) = CAST(GETDATE() AS DATE);

        -- Bloquear guías para manejo de concurrencia
		DECLARE @PreparationDay DATETIME = GETDATE()
        INSERT INTO [DeliveryBackOffice].[dbo].[ExternalPlatformServiceLog]
        (
            ExternalPlatformId,
            GuideSerie,
            GuideNumber,
            RowStatus,
            TokenCreated,
            DateCreated
        )
        OUTPUT inserted.GuideSerie,
               inserted.GuideNumber
        INTO @AcceptedGuides
        (
            GuideSerie,
            GuideNumber
        )
        SELECT DISTINCT
               2,
               GT.Guide_Serie,
               GT.Guide_Number,
               1,
               'SYS-HERMESROUTES',
               @PreparationDay
        FROM @Guides GT
            JOIN DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
                ON DOR.Guide_Serie = GT.Guide_Serie
                   AND DOR.Guide_Number = GT.Guide_Number
                   AND DOR.Receiver_Department = @Departamento
            LEFT JOIN [DeliveryBackOffice].[dbo].[ExternalPlatformServiceLog] EPSL WITH(NOLOCK)
                ON GT.Guide_Serie = EPSL.GuideSerie
                   AND GT.Guide_Number = EPSL.GuideNumber
                   AND EPSL.RowStatus = 1
                   AND CAST(EPSL.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
			JOIN
				[DeliveryBackOffice].[dbo].[Province] P WITH(NOLOCK)
				ON
					DOR.Receiver_Department = P.ProvinceName 
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[ServiceProvinceConfiguration] SPC WITH(NOLOCK)
				ON
					P.IdProvince = SPC.ProvinceId
					AND
					SPC.RowStatus = 1
			JOIN
				[DeliveryBackOffice].[dbo].[Township] TMun WITH(NOLOCK)
				ON
					DOR.Receiver_Town = TMun.TownshipName 
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[ServiceTownshipConfiguration] STC WITH(NOLOCK)
				ON
					TMun.IdTownship = STC.TownshipId
					AND
					STC.RowStatus = 1
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[ServiceZoneConfiguration] SZC WITH(NOLOCK)
				ON
					TMun.IdTownship = SZC.TownshipId
					AND
					DOR.Receiver_Zone = SZC.Zone
					AND
					SZC.RowStatus = 1
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[ServiceZoneConfiguration] SZCZero WITH(NOLOCK)
				ON
					STC.TownshipId = SZCZero.TownshipId
					AND
					SZCZero.Zone = 0
					AND
					SZCZero.RowStatus = 1
        WHERE EPSL.IdExternalPlatformServiceLog IS NULL
				AND -- Valores configurables desde base de datos
				SPC.IdServiceProvinceConfiguration IS NOT NULL
				AND
				(
					@AreTownshipsConfigurated = 0
					OR
					STC.IdServiceTownshipConfiguration IS NOT NULL
				)
				AND
				(
					@AreZonesConfigurated = 0
					OR
					SZC.IdServiceZoneConfiguration IS NOT NULL
					OR
					SZCZero.IdServiceZoneConfiguration IS NOT NULL
				)

        UPDATE AG
        SET AG.SenderID = DOR.Sender_ID,
            AG.IdCustomer = DOR.IdCustomer,
            AG.ReceiverID = DOR.Receiver_ID,
            AG.ReceiverFirstName = DOR.Receiver_FirstName,
            AG.ReceiverLastName = DOR.Receiver_LastName,
            AG.ReceiverEmail = DOR.Receiver_Email,
            AG.ReceiverSocialSecurityID = DOR.Receiver_SocialSecurity_ID,
            AG.ReceiverPhone = REPLACE(
                                          REPLACE(REPLACE(REPLACE(DOR.Receiver_Phone, '-', ''), ' ', ''), '(', ''),
                                          ')',
                                          ''
                                      ),
            AG.ReceiverAlternantFullName = DOR.Receiver_Alternant_FullName,
            AG.ReceiverAddress = DeliveryBackOffice.dbo.FnFixAddressExternalPlatformService(
                                                                                               DOR.Receiver_Address,
                                                                                               DOR.Receiver_Department,
                                                                                               DOR.Receiver_Town
                                                                                           ),
            AG.ReceiverTownshipId = DOR.ReceiverIdTownship,
            AG.ReceiverTown = DOR.Receiver_Town,
            AG.ReceiverDepartment = DOR.Receiver_Department,
            AG.IndicationsToSendDestination = DOR.IndicationsToSendDestination,
            AG.PackageType = DOR.Package_Type,
            AG.IsCollect = DOR.IsCollect,
            AG.PriceShippment = DOR.PriceShippment,
            AG.CollectOnDelivery = DOR.Collect_OnDelivery,
            AG.PiecesDry = DOR.Pieces_Dry,
            AG.PiecesCold = DOR.Pieces_Cold,
            AG.TypeService = DOR.TypeService,
            AG.IdDeliveryOption = DOR.IdDeliveryOption
        FROM @AcceptedGuides AG
            JOIN DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
                ON DOR.Guide_Serie = AG.GuideSerie
                   AND DOR.Guide_Number = AG.GuideNumber;

        --- Obtención de datos para traslado
        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT DISTINCT
                                       REPLACE(
                                                  ',{'
                                                  + +IIF(EPS.IdService IS NULL,
                                                   '',
                                                   '"id"' + ':' + CAST(EPS.IdService AS NVARCHAR) + ',') + +'"title"'
                                                  + ':' + '"'
                                                  + CAST(dbo.fn_ReplaceSpecialCharsForJSON(CONCAT(
                                                                                                     AG.GuideSerie,
                                                                                                     AG.GuideNumber,
                                                                                                     ' ',
                                                                                                     LTRIM(RTRIM(CONCAT(
                                                                                                                           AG.ReceiverFirstName,
                                                                                                                           ' ',
                                                                                                                           ISNULL(
                                                                                                                                     AG.ReceiverLastName,
                                                                                                                                     ''
                                                                                                                                 )
                                                                                                                       )
                                                                                                                )
                                                                                                          )
                                                                                                 )
                                                                                          ) AS NVARCHAR) + '"'
                                                  + ',' + '"address"' + ':' + '"'
                                                  + REPLACE(
                                                               REPLACE(
                                                                          dbo.fn_ReplaceSpecialCharsForJSON(AG.ReceiverAddress),
                                                                          CHAR(13),
                                                                          ''
                                                                      ),
                                                               CHAR(10),
                                                               ''
                                                           ) + '"' + ',' + '"planned_date"' + ':' + '"'
                                                  + CONVERT(VARCHAR, GETDATE(), 23) + '"' + ','
                                                  + (CASE
                                                         WHEN ISNULL(SDFG.Latitude, 0) <> 0
                                                              AND ISNULL(SDFG.Longitude, 0) <> 0 THEN
                                                             '"latitude"' + ':'
                                                             + SUBSTRING(CONVERT(NVARCHAR(20), SDFG.Latitude), 1, 9) + ','
                                                             +
                                                  --'"latitude"' + ':' +  LTRIM(RTRIM(SDFG.Latitude )) + ',' +
                                                  +'"longitude"'
                                                             + ':'
                                                             + SUBSTRING(CONVERT(NVARCHAR(20), SDFG.Longitude), 1, 10)
                                                             + ','
                                                         ---+ '"longitude"' + ':' +  LTRIM(RTRIM(SDFG.Longitude)) + ',' 
                                                         WHEN ISNULL(
                                                                        LTRIM(RTRIM(dbo.fn_ReplaceSpecialCharsForJSON(SSHL.Latitud))),
                                                                        ''
                                                                    ) <> ''
                                                              AND ISNULL(
                                                                            LTRIM(RTRIM(dbo.fn_ReplaceSpecialCharsForJSON(SSHL.Longitude))),
                                                                            ''
                                                                        ) <> '' THEN
                                                             '"latitude"' + ':'
                                                             + SUBSTRING(LTRIM(RTRIM(SSHL.Latitud)), 1, 9) + ',' +
                                                  --	'"latitude"' + ':' + LTRIM(RTRIM(SSHL.Latitude))+ ',' +
                                                  +'"longitude"'
                                                             + ':' + SUBSTRING(LTRIM(RTRIM(SSHL.Longitude)), 1, 10) + ','
                                                         --	+ '"longitude"' + ':' + LTRIM(RTRIM(SSHL.Longitude))  + ',' 
                                                         WHEN EXISTS
                                                              (
                                                                  SELECT TOP 1
                                                                         1
                                                                  FROM DeliveryBackOffice.dbo.LocationRecord PHL1
                                                                  WHERE AG.ReceiverPhone LIKE '%' + PHL1.Phone + '%'
                                                              ) THEN
                                                         (
                                                             SELECT TOP 1
                                                                    '"latitude"' + ':'
                                                                    + SUBSTRING(LTRIM(RTRIM(PHL.Latitud)), 1, 9) + ','
                                                                    + +'"longitude"' + ':'
                                                                    + SUBSTRING(LTRIM(RTRIM(PHL.Longitude)), 1, 10) + ','
                                                             FROM DeliveryBackOffice.dbo.LocationRecord PHL
                                                             WHERE AG.ReceiverPhone LIKE '%' + PHL.Phone + '%'
                                                         )
                                                         /*WHEN ISNULL(LTRIM(RTRIM(dbo.fn_ReplaceSpecialCharsForJSON(VPCr.Latitude))),'') <> '' AND ISNULL(LTRIM(RTRIM(dbo.fn_ReplaceSpecialCharsForJSON(VPCr.Longitude))),'') <> '' THEN
											'"latitude"' + ':' + CONVERT(NVARCHAR(9),LTRIM(RTRIM(VPCr.Latitude)))+ ',' +
											+ '"longitude"' + ':' + CONVERT(NVARCHAR(9),LTRIM(RTRIM(VPCr.Longitude)))  + ',' */
                                                         ELSE
                                                             ''
                                                     END
                                                    ) + +'"contact_name"' + ':' + '"'
                                                  + LTRIM(RTRIM(dbo.fn_ReplaceSpecialCharsForJSON(CONCAT(
                                                                                                            AG.ReceiverFirstName,
                                                                                                            ' ',
                                                                                                            ISNULL(
                                                                                                                      AG.ReceiverLastName,
                                                                                                                      ''
                                                                                                                  )
                                                                                                        )
                                                                                                 )
                                                               )
                                                         ) + '"' + ','
                                                  + '"skills_required"' + ':' + '[' + '"'
                                                  + RTRIM(LTRIM(ISNULL(DSCtwsrid.Hub, DSCtwsrtwn.Hub))) + '"' + ']' + ','
                                                  + '"skills_optional"' + ':' + '['
                                                  + IIF(AG.PackageType = 2, '"Sobre"', '') + ']' + ',' + '"load"' + ':'
                                                  + CONVERT(
                                                               NVARCHAR(10),
                                                               IIF(AG.PackageType = 2,
                                                                   0,
                                                                   ((CASE
                                                                         WHEN ISNULL(DOP.CheckedVolume, 0) > 0 AND ISNULL(DOP.CheckedVolume, 0) > ISNULL(DOP.ClientVolume, 0) THEN
                                                                             DOP.CheckedVolume
                                                                         WHEN ISNULL(DOP.ClientVolume, 0) > 0 AND ISNULL(DOP.ClientVolume, 0) > ISNULL(DOP.CheckedVolume, 0) THEN
                                                                             DOP.ClientVolume
                                                                         ELSE
                                                                             0.006 -- (30cm x 20cm x 10cm) / 1000000cm
                                                                     END
                                                                    )
                                                                   ))
                                                           )
                                                  + ','
                                                  --+ '"load_2"' + ':' + CONVERT( NVARCHAR(10),IIF(AG.PackageType = 2, 0, ( SUM( ISNULL(ISNULL(DOP.volumetricWeight, DOP.MassWeight), 0) ) ) ) ) + ','
                                                  + IIF(AG.PackageType = 2, CONCAT('"load_3":', AG.PiecesDry, ','), '')
                                                  + ( -- 1 = Domingo | 7 = Sabado 
                                                  CASE
                                                      WHEN DATEPART(DW, GETDATE()) = 7 THEN
                                                  (CASE
                                                       -- Ventanas gestionadas de forma manual
                                                       WHEN SDFG.StartTime IS NOT NULL THEN
                                                           +'"window_start"' + ':' + '"'
                                                           + CONVERT(NVARCHAR, SDFG.StartTime, 108) + '"' + ','
                                                           + '"window_end"' + ':' + '"'
                                                           + CONVERT(NVARCHAR, SDFG.EndTime, 108) + '"' + ','
                                                       -- Business to business
                                                       WHEN (ISNULL(
                                                                       ISNULL(
                                                                                 Cu.BusinessSegmentID,
                                                                                 CuVPC.BusinessSegmentID
                                                                             ),
                                                                       0
                                                                   ) = @B2BIdSegment
                                                            ) THEN
                                                           +'"window_start"' + ':' + '"08:00"' + ',' + '"window_end"'
                                                           + ':' + '"11:00"' + ','
                                                       ELSE
                                                  (CASE
                                                       -- manejo de centros comerciales
                                                       WHEN AG.ReceiverAddress LIKE '%cc %'  THEN
                                                           +'"window_start"' + ':' + '"08:00"' + ',' + '"window_end"'
                                                           + ':' + '"10:00"' + ','
                                                       WHEN AG.ReceiverAddress LIKE '%centro comercial%'  THEN
                                                           +'"window_start"' + ':' + '"08:00"' + ',' + '"window_end"'
                                                           + ':' + '"10:00"' + ','
                                                       WHEN AG.ReceiverAddress LIKE '%c.c.%'  THEN
                                                           +'"window_start"' + ':' + '"08:00"' + ',' + '"window_end"'
                                                           + ':' + '"10:00"' + ','
                                                       WHEN AG.ReceiverAddress LIKE '%c.c%'  THEN
                                                           +'"window_start"' + ':' + '"08:00"' + ',' + '"window_end"'
                                                           + ':' + '"10:00"' + ','
                                                       -- Ventanas de menor prioridad
                                                       WHEN AG.TypeService = 'SDD' THEN
                                                           +'"window_start"' + ':' + '"08:00"' + ',' + '"window_end"'
                                                           + ':' + '"21:00"' + ','
                                                       WHEN ISNULL(AG.IdDeliveryOption, 0) = 3 THEN
                                                           +'"window_start"' + ':' + '"08:00"' + ',' + '"window_end"'
                                                           + ':' + '"13:00"' + ','
                                                       ELSE
                                                           +'"window_start"' + ':' + '"08:00"' + ',' + '"window_end"'
                                                           + ':' + '"18:00"' + ','
                                                   END
                                                  )
                                                   END
                                                  )
                                                      ELSE
                                                  (CASE
                                                       -- Ventanas gestionadas de forma manual
                                                       WHEN SDFG.StartTime IS NOT NULL THEN
                                                           +'"window_start"' + ':' + '"'
                                                           + CONVERT(NVARCHAR, SDFG.StartTime, 108) + '"' + ','
                                                           + '"window_end"' + ':' + '"'
                                                           + CONVERT(NVARCHAR, SDFG.EndTime, 108) + '"' + ','
                                                       -- Business to business
                                                       WHEN (ISNULL(
                                                                       ISNULL(
                                                                                 Cu.BusinessSegmentID,
                                                                                 CuVPC.BusinessSegmentID
                                                                             ),
                                                                       0
                                                                   ) = @B2BIdSegment
                                                            ) THEN
                                                           +'"window_start"' + ':' + '"08:00"' + ',' + '"window_end"'
                                                           + ':' + '"11:00"' + ','
                                                       ELSE
                                                  (CASE
                                                       -- manejo de centros comerciales
                                                       WHEN AG.ReceiverAddress LIKE '%cc %' THEN
                                                           +'"window_start"' + ':' + '"08:00"' + ',' + '"window_end"'
                                                           + ':' + '"10:00"' + ','
                                                       WHEN AG.ReceiverAddress LIKE '%centro comercial%' THEN
                                                           +'"window_start"' + ':' + '"08:00"' + ',' + '"window_end"'
                                                           + ':' + '"10:00"' + ','
                                                       WHEN AG.ReceiverAddress LIKE '%c.c.%' THEN
                                                           +'"window_start"' + ':' + '"08:00"' + ',' + '"window_end"'
                                                           + ':' + '"10:00"' + ','
                                                       WHEN AG.ReceiverAddress LIKE '%c.c%' THEN
                                                           +'"window_start"' + ':' + '"08:00"' + ',' + '"window_end"'
                                                           + ':' + '"10:00"' + ','
                                                       -- Ventanas de menor prioridad
                                                       WHEN AG.TypeService = 'SDD' THEN
                                                           +'"window_start"' + ':' + '"08:00"' + ',' + '"window_end"'
                                                           + ':' + '"21:00"' + ','
                                                       WHEN ISNULL(AG.IdDeliveryOption, 0) = 3 THEN
                                                           +'"window_start"' + ':' + '"08:00"' + ',' + '"window_end"'
                                                           + ':' + '"17:00"' + ','
                                                       ELSE
                                                           +'"window_start"' + ':' + '"08:00"' + ',' + '"window_end"'
                                                           + ':' + '"18:00"' + ','
                                                   END
                                                  ) + '"window_start"' + ':' + '"08:00"' + ',' + '"window_end"' + ':'
                                                  + '"18:00"' + ','
                                                   END
                                                  )
                                                  END
                                                    )
                                                  + +IIF(SDFG.StartTime2 IS NOT NULL,
                                                         '"window_start_2"' + ':' + '"'
                                                         + CONVERT(NVARCHAR, SDFG.StartTime2, 108) + '"' + ','
                                                         + '"window_end_2"' + ':' + '"'
                                                         + CONVERT(NVARCHAR, SDFG.EndTime2, 108) + '"' + ',',
                                                         '') + + (CASE
                                                                      WHEN AG.TypeService = 'SDD' THEN -- SDD
                                                                          +'"priority_level"' + ':' + '3' + ','
                                                                      WHEN AG.TypeService = 'TDA' THEN -- TDA
                                                                          +'"priority_level"' + ':' + '5' + ','
                                                                      ELSE
                                                                          +'"priority_level"' + ':' + '4' + ','
                                                                  END
                                                                 ) + '"duration"' + ':' + '"00:10:00"' + ','
                                                  + '"reference"' + ':' + '"' + CONCAT(AG.GuideSerie, AG.GuideNumber)
                                                  + '"' + ',' + '"notes"' + ':' + '"' + 'Dirección: '
                                                  + REPLACE(
                                                               REPLACE(
                                                                          dbo.fn_ReplaceSpecialCharsForJSON(AG.ReceiverAddress),
                                                                          CHAR(13),
                                                                          ''
                                                                      ),
                                                               CHAR(10),
                                                               ''
                                                           )
                                                  + +IIF(ISNULL(AG.IndicationsToSendDestination, '') <> '',
                                                         CHAR(13) + CHAR(10) + 'Instrucciones adicionales: '
                                                         + LTRIM(RTRIM(dbo.fn_ReplaceSpecialCharsForJSON(ISNULL(
                                                                                                                   AG.IndicationsToSendDestination,
                                                                                                                   ''
                                                                                                               )
                                                                                                        )
                                                                      )
                                                                ),
                                                         '') + '"' + ','
                                                  + (CASE
                                                         WHEN AG.SenderID IN
                                                              (
                                                                  SELECT CodeOfReference
                                                                  FROM DeliveryBackOffice.dbo.VisitPointClient
                                                                  WHERE CustomerID = 1
                                                              ) THEN
                                                             '"extra_field_values"' + ':' + '{' + +'"AlternantName"' + ':'
                                                             + '"'
                                                             + LTRIM(RTRIM(dbo.fn_ReplaceSpecialCharsForJSON(ISNULL(
                                                                                                                       AG.ReceiverAlternantFullName,
                                                                                                                       ''
                                                                                                                   )
                                                                                                            )
                                                                          )
                                                                    )
                                                             + '"' + ',' + '"TotalDryPieces"' + ':'
                                                             + CAST(AG.PiecesDry AS NVARCHAR) + ',' + '"TotalColdPieces"'
                                                             + ':' + CAST(AG.PiecesCold AS NVARCHAR) + '}' + ','
                                                             + '"visit_type"' + ':' + '"IGSS"'                           -- Por cambiar si es necesario trasladar esta data a BD | Se reemplaza durante el proceso
                                                         WHEN ISNULL(AG.IdDeliveryOption, 0) = 3 THEN
                                                             '"extra_field_values"' + ':' + '{' + +'"AlternantName"' + ':'
                                                             + '"'
                                                             + LTRIM(RTRIM(dbo.fn_ReplaceSpecialCharsForJSON(ISNULL(
                                                                                                                       AG.ReceiverAlternantFullName,
                                                                                                                       ''
                                                                                                                   )
                                                                                                            )
                                                                          )
                                                                    )
                                                             + '"' + ',' + '"TotalDryPieces"' + ':'
                                                             + CAST(AG.PiecesDry AS NVARCHAR) + ',' + '"TotalColdPieces"'
                                                             + ':' + CAST(AG.PiecesCold AS NVARCHAR) + '}' + ','
                                                             + '"visit_type"' + ':' + '"ExpressCenter"'                  -- Por cambiar si es necesario trasladar esta data a BD | Se reemplaza durante el proceso
                                                         WHEN ISNULL(AG.IsCollect, 0) = 1 THEN
                                                             '"extra_field_values"' + ':' + '{' + +'"AlternantName"' + ':'
                                                             + '"'
                                                             + LTRIM(RTRIM(dbo.fn_ReplaceSpecialCharsForJSON(ISNULL(
                                                                                                                       AG.ReceiverAlternantFullName,
                                                                                                                       ''
                                                                                                                   )
                                                                                                            )
                                                                          )
                                                                    )
                                                             + '"' + ',' + '"TotalDryPieces"' + ':'
                                                             + CAST(AG.PiecesDry AS NVARCHAR) + ',' + '"TotalColdPieces"'
                                                             + ':' + CAST(AG.PiecesCold AS NVARCHAR) + ','
                                                             + '"TaxPlayerNumber"' + ':' + '"CF"' + ','
                                                             + '"TaxPlayerName"' + ':' + '"CONSUMIAG FINAL"' + ','
                                                             + '"TaxPlayerAddress"' + ':' + '"'
                                                             + REPLACE(
                                                                          REPLACE(
                                                                                     dbo.fn_ReplaceSpecialCharsForJSON(AG.ReceiverAddress),
                                                                                     CHAR(13),
                                                                                     ''
                                                                                 ),
                                                                          CHAR(10),
                                                                          ''
                                                                      ) + '"' + ',' + '"TaxPlayerMail"' + ':' + '"'
                                                             + LTRIM(RTRIM(dbo.fn_ReplaceSpecialCharsForJSON(ISNULL(
                                                                                                                       AG.ReceiverEmail,
                                                                                                                       ''
                                                                                                                   )
                                                                                                            )
                                                                          )
                                                                    )
                                                             + '"' + ',' + '"TotalCharge"' + ':'
                                                             + CAST((IIF(ISNULL(AG.IsCollect, 0) = 1,
                                                                      ISNULL(AG.PriceShippment, 0),
                                                                      0) + ISNULL(AG.CollectOnDelivery, 0)
                                                                    ) AS NVARCHAR)
                                                             + ',' + '"ServiceCharge"' + ':'
                                                             + CAST(IIF(ISNULL(AG.IsCollect, 0) = 1,
                                                                     ISNULL(AG.PriceShippment, 0),
                                                                     0) AS NVARCHAR) + ',' + '"CoDCharge"' + ':'
                                                             + CAST(ISNULL(AG.CollectOnDelivery, 0) AS NVARCHAR) + ','
                                                             + '"CollectCoD"' + ':'
                                                             + (CASE
                                                                    WHEN ISNULL(AG.CollectOnDelivery, 0) > 0 THEN
                                                                        'true'
                                                                    ELSE
                                                                        'false'
                                                                END
                                                               ) + '}' + ',' + '"visit_type"' + ':' + '"ConFacturación"' -- Por cambiar si es necesario trasladar esta data a BD | Se reemplaza durante el proceso
                                                         ELSE
                                                             '"extra_field_values"' + ':' + '{' + +'"AlternantName"' + ':'
                                                             + '"'
                                                             + LTRIM(RTRIM(dbo.fn_ReplaceSpecialCharsForJSON(ISNULL(
                                                                                                                       AG.ReceiverAlternantFullName,
                                                                                                                       ''
                                                                                                                   )
                                                                                                            )
                                                                          )
                                                                    )
                                                             + '"' + ',' + '"TotalDryPieces"' + ':'
                                                             + CAST(AG.PiecesDry AS NVARCHAR) + ',' + '"TotalColdPieces"'
                                                             + ':' + CAST(AG.PiecesCold AS NVARCHAR) + ','
                                                             + '"TotalCharge"' + ':'
                                                             + CAST((IIF(ISNULL(AG.IsCollect, 0) = 1,
                                                                      ISNULL(AG.PriceShippment, 0),
                                                                      0) + ISNULL(AG.CollectOnDelivery, 0)
                                                                    ) AS NVARCHAR)
                                                             + ',' + '"ServiceCharge"' + ':'
                                                             + CAST(IIF(ISNULL(AG.IsCollect, 0) = 1,
                                                                     ISNULL(AG.PriceShippment, 0),
                                                                     0) AS NVARCHAR) + ',' + '"CoDCharge"' + ':'
                                                             + CAST(ISNULL(AG.CollectOnDelivery, 0) AS NVARCHAR) + ','
                                                             + '"CollectCoD"' + ':'
                                                             + (CASE
                                                                    WHEN ISNULL(AG.CollectOnDelivery, 0) > 0 THEN
                                                                        'true'
                                                                    ELSE
                                                                        'false'
                                                                END
                                                               ) + '}' + ',' + '"visit_type"' + ':' + '"SinFacturación"' -- Por cambiar si es necesario trasladar esta data a BD | Se reemplaza durante el proceso
                                                     END
                                                    ) + '}',
                                                  CHAR(31),
                                                  ''
                                              )
                                FROM @AcceptedGuides AG
                                    JOIN
                                    (
                                        SELECT DOPA.GuideSerie,
                                               DOPA.GuideNumber,
                                               SUM(ISNULL(DOPA.PieceHeightCheck, 0)
                                                   * ISNULL(DOPA.PieceLengthCheck, 0)
                                                   * ISNULL(DOPA.PieceWidthCheck, 0)
                                                  ) / 1000000 'CheckedVolume',
                                               SUM(ISNULL(DOPA.PieceHeight, 0) 
												   * ISNULL(DOPA.PieceLength, 0)
                                                   * ISNULL(DOPA.PieceWidth, 0)
                                                  ) / 1000000 'ClientVolume'
                                        FROM DeliveryBackOffice.dbo.DeliveryOrderPiece DOPA WITH (NOLOCK)
                                        GROUP BY DOPA.GuideSerie,
                                                 DOPA.GuideNumber
                                    ) DOP
                                        ON DOP.GuideSerie = AG.GuideSerie
                                           AND DOP.GuideNumber = AG.GuideNumber
                                    LEFT JOIN DeliveryBackOffice.dbo.Township TWSrid
                                        ON TWSrid.IdTownship = AG.ReceiverTownshipId
                                    LEFT JOIN DeliveryBackOffice.dbo.Township TWSrtwn
                                        ON TWSrtwn.TownshipName LIKE '%' + AG.ReceiverTown
                                                                     + '%' 
                                    LEFT JOIN
                                    (
                                        SELECT DSC.HeaderCode HeaderCode,
                                               MAX(DSC.Hub) Hub
                                        FROM DeliveryBackOffice.dbo.DumpServiceCoverage DSC
                                        GROUP BY DSC.HeaderCode
                                    ) DSCtwsrid
                                        ON TWSrid.HeaderCode = DSCtwsrid.HeaderCode
                                    LEFT JOIN
                                    (
                                        SELECT DSC.HeaderCode HeaderCode,
                                               MAX(DSC.Hub) Hub
                                        FROM DeliveryBackOffice.dbo.DumpServiceCoverage DSC
                                        GROUP BY DSC.HeaderCode
                                    ) DSCtwsrtwn
                                        ON TWSrtwn.HeaderCode = DSCtwsrtwn.HeaderCode
                                    LEFT JOIN DeliveryBackOffice.dbo.ServiceDataForGuide SDFG WITH (NOLOCK)
                                        ON AG.GuideSerie = SDFG.GuideSerie
                                           AND AG.GuideNumber = SDFG.GuideNumber
                                           AND SDFG.IsDelivery = 1
                                    LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPCr
                                        ON VPCr.CodeOfReference = AG.ReceiverID
                                    LEFT JOIN DeliveryBackOffice.dbo.ExtPlatServiceRelationshipWithGuide EXPSRG
                                        ON AG.GuideSerie = EXPSRG.GuideSerie
                                           AND AG.GuideNumber = EXPSRG.GuideNumber
                                           AND CAST(EXPSRG.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
                                           AND EXPSRG.RowStatus = 1
                                    LEFT JOIN DeliveryBackOffice.dbo.ExtPlatformService EPS
                                        ON EXPSRG.ExtPlatServiceId = EPS.IdExtPlatformService
                                    LEFT JOIN DeliveryBackOffice.dbo.LocationRecord SSHL
                                        ON AG.ReceiverSocialSecurityID = SSHL.SocialSecurityId
                                    LEFT JOIN -- Manejo de clientes B2B (Business to business)
                                    [DeliveryBackOffice].[dbo].[VisitPointClient] VPCs
                                        ON AG.SenderID = VPCs.CodeOfReference
                                    LEFT JOIN [DeliveryBackOffice].[dbo].[Customer] CuVPC
                                        ON VPCs.CustomerID = CuVPC.IdCustomer
                                    LEFT JOIN [DeliveryBackOffice].[dbo].[Customer] Cu
                                        ON AG.IdCustomer = Cu.IdCustomer
                                GROUP BY AG.GuideSerie,
                                         AG.GuideNumber,
                                         EPS.IdService,
                                         AG.IdCustomer,
                                         AG.ReceiverFirstName,
                                         AG.ReceiverLastName,
                                         AG.ReceiverAlternantFullName,
                                         AG.ReceiverAddress,
                                         AG.ReceiverDepartment,
                                         AG.ReceiverTown,
                                         DSCtwsrid.Hub,
                                         DSCtwsrtwn.Hub,
                                         AG.IndicationsToSendDestination,
                                         AG.SenderID,
                                         AG.IdDeliveryOption,
                                         AG.ReceiverEmail,
                                         AG.ReceiverPhone,
                                         AG.PiecesDry,
                                         AG.PiecesCold,
                                         AG.PackageType,
                                         ISNULL(Cu.BusinessSegmentID, CuVPC.BusinessSegmentID),
                                         PriceShippment,
                                         AG.CollectOnDelivery,
                                         IsCollect,
                                         TypeService,
                                         DOP.CheckedVolume,
                                         DOP.ClientVolume,
                                         SSHL.Latitud,
                                         SSHL.Longitude,
                                         SDFG.Latitude,
                                         SDFG.Longitude,
                                         /*,VPCr.Latitude
								,VPCr.Longitude*/
                                         StartTime,
                                         EndTime,
                                         StartTime2,
                                         EndTime2
                                --ORDER BY CONCAT (DOR.Guide_Serie, DOR.Guide_Number) ASC
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
        IF @jsonResult IS NULL
        BEGIN
            SET @jsonResult =
            (
                SELECT STUFF(
                                (
                                    SELECT ',{"IdResult":204,' + '"Message":" No se encontraron registros"}'
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)'),
                                1,
                                1,
                                ''
                            )
            );

            --EXEC [DeliveryBackOffice].[dbo].[SetExternalPlatformUpdatedServiceData] @TblSimplirouteVisits = @AcceptedGuides , @ExternalPlatform = 2, @ServiceInputType = 1, @UserToken = 'SYS-HERMESROUTES'

            UPDATE EPSL
            SET EPSL.RowStatus = 0,
                EPSL.TokenUpdated = 'SYS-HERMESROUTES',
                EPSL.DateUpdated = GETDATE()
            FROM [DeliveryBackOffice].[dbo].[ExternalPlatformServiceLog] EPSL
                JOIN @AcceptedGuides TSV
                    ON EPSL.GuideSerie = TSV.GuideSerie
                       AND EPSL.GuideNumber = TSV.GuideNumber;

        END;
        IF (@@TRANCOUNT > 0) COMMIT TRANSACTION;

        SELECT ('[' + @jsonResult + ']') jsonResultError;

    END TRY
    BEGIN CATCH

        SELECT 0 [blnResult],
               ERROR_NUMBER() AS [ErrorNumber],
               ERROR_SEVERITY() AS [ErrorSeverity],
               ERROR_STATE() AS [ErrorState],
               ERROR_PROCEDURE() AS [ErrorProcedure],
               ERROR_LINE() AS [ErrorLine],
               ERROR_MESSAGE() AS [ErrorMessage];

        ROLLBACK TRANSACTION;
    END CATCH;
END;
