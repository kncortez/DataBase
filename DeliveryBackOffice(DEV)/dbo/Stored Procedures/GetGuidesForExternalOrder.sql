
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2021-08-18>
-- Description:	< Recupera datos de guías para realizar la optimización de rutas basado en las guías a procesar >
-- =============================================

CREATE PROCEDURE [dbo].[GetGuidesForExternalOrder]
    @Guides TblGuides READONLY
AS
BEGIN

	DECLARE @TransactionResult BIT = 1;
    DECLARE @jsonResult NVARCHAR(MAX);

    --Manejo de clientes Business to business
    DECLARE @B2BIdSegment INT =
            (
                SELECT TOP 1
                       CBS.IdBusinessSegment
                FROM [DeliveryBackOffice].[dbo].[CatBusinessSegment] CBS WITH(NOLOCK)
                WHERE CBS.BusinessSegmentName LIKE '%B2B%'
            );

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
        ReceiverSocialSecurityID NVARCHAR(200),
        ReceiverPhone NVARCHAR(100),
        ReceiverAddress NVARCHAR(600),
        ReceiverTownshipId INT,
        ReceiverTown NVARCHAR(100),
		TotalPieces INT,
        TypeService NVARCHAR(3),
        IdDeliveryOption INT,
        HasAlert BIT DEFAULT 0,
		INDEX TEMP_NNC_INDEX (GuideSerie, GuideNumber)
    );

    BEGIN TRY

        -- Bloquear guías para manejo de concurrencia
		DECLARE @PreparationDay DATETIME = GETDATE()

        INSERT INTO 
			@AcceptedGuides
        (
            GuideSerie,
            GuideNumber
        )
        SELECT
			DISTINCT
               GT.Guide_Serie,
               GT.Guide_Number
        FROM @Guides GT

        UPDATE AG
        SET AG.SenderID = DOR.Sender_ID,
            AG.IdCustomer = DOR.IdCustomer,
            AG.ReceiverID = DOR.Receiver_ID,
            AG.ReceiverFirstName = DOR.Receiver_FirstName,
            AG.ReceiverLastName = DOR.Receiver_LastName,
            AG.ReceiverSocialSecurityID = DOR.Receiver_SocialSecurity_ID,
            AG.ReceiverPhone = REPLACE( REPLACE(REPLACE(REPLACE(DOR.Receiver_Phone, '-', ''), ' ', ''), '(', ''), ')', '' ),
            AG.ReceiverAddress = DeliveryBackOffice.dbo.FnFixAddressExternalPlatformService( DOR.Receiver_Address, DOR.Receiver_Department, DOR.Receiver_Town),
            AG.ReceiverTownshipId = DOR.ReceiverIdTownship,
            AG.ReceiverTown = DOR.Receiver_Town,
			AG.TotalPieces = (DOR.Pieces_Dry + DOR.Pieces_Cold),
            AG.TypeService = DOR.TypeService,
            AG.IdDeliveryOption = DOR.IdDeliveryOption,
			AG.HasAlert = ISNULL(
				(
					SELECT 
						TOP 1 
							1 
					FROM 
						DeliveryBackOffice.dbo.DeliveryOrderAlert DOA WITH(NOLOCK)
					WHERE DOA.GuideSerie = AG.GuideSerie AND DOA.GuideNumber = AG.GuideNumber AND DOA.ServiceTypeId = 3 AND DOA.RowStatus = 1 ),0)
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
												  + '"ident"' + ':' + '"' + CAST(dbo.fn_ReplaceSpecialCharsForJSON(CONCAT(AG.GuideSerie,AG.GuideNumber)) AS NVARCHAR) + '"'+ ',' 
												  + '"address"' + ':' + '"' + REPLACE( REPLACE( dbo.fn_ReplaceSpecialCharsForJSON(AG.ReceiverAddress), CHAR(13), '' ), CHAR(10), '' ) + '"' + ',' 
                                                  + (CASE
                                                         WHEN ISNULL(SDFG.Latitude, 0) <> 0 AND ISNULL(SDFG.Longitude, 0) <> 0 THEN
                                                             '"lat"' + ':' + SUBSTRING(CONVERT(NVARCHAR(20), SDFG.Latitude), 1, 9) + ',' +
			                                                 +'"lat"' + ':' + SUBSTRING(CONVERT(NVARCHAR(20), SDFG.Longitude), 1, 10)  + ','
                                                         WHEN ISNULL(LTRIM(RTRIM(dbo.fn_ReplaceSpecialCharsForJSON(SSHL.Latitud))),'') <> ''
                                                              AND ISNULL(LTRIM(RTRIM(dbo.fn_ReplaceSpecialCharsForJSON(SSHL.Longitude))),'' ) <> '' THEN
                                                             '"lat"' + ':' + SUBSTRING(LTRIM(RTRIM(SSHL.Latitud)), 1, 9) + ',' +
															 +'"lat"' + ':' + SUBSTRING(LTRIM(RTRIM(SSHL.Longitude)), 1, 10) + ','
                                                         WHEN EXISTS (
                                                                  SELECT TOP 1 1
                                                                  FROM DeliveryBackOffice.dbo.LocationRecord PHL1 WITH(NOLOCK)
                                                                  WHERE AG.ReceiverPhone LIKE '%' + PHL1.Phone + '%'
                                                              ) THEN
                                                         (
                                                             SELECT TOP 1
                                                                    '"lat"' + ':' + SUBSTRING(LTRIM(RTRIM(PHL.Latitud)), 1, 9) + ',' +
																	+'"lat"' + ':' + SUBSTRING(LTRIM(RTRIM(PHL.Longitude)), 1, 10) + ','
                                                             FROM DeliveryBackOffice.dbo.LocationRecord PHL WITH(NOLOCK)
                                                             WHERE AG.ReceiverPhone LIKE '%' + PHL.Phone + '%'
                                                         )
                                                         WHEN  ISNULL(LTRIM(RTRIM(dbo.fn_ReplaceSpecialCharsForJSON(VPCr.Latitude))),'') <> '' 
																AND ISNULL(LTRIM(RTRIM(dbo.fn_ReplaceSpecialCharsForJSON(VPCr.Longitude))),'') <> '' THEN
															'"lat"' + ':'  + SUBSTRING(LTRIM(RTRIM(VPCr.Latitude)), 1, 9)+ ',' +
															+ '"lat"' + ':'  + SUBSTRING(LTRIM(RTRIM(VPCr.Longitude)), 1, 10)  + ',' 
                                                         ELSE
                                                             '"lat"' + ':0,' +
			                                                 +'"lat"' + ':0,'
                                                     END
                                                    ) 
												  + '"duration"' + ':' + '"' + CAST( (10 + (AG.TotalPieces - 1)) AS NVARCHAR)+'"' + ','
												  + '"load"' + ':' + '1' + ','
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
														   WHEN (ISNULL( ISNULL( Cu.BusinessSegmentID, CuVPC.BusinessSegmentID ),  0 ) = @B2BIdSegment ) THEN
															   +'"window_start"' + ':' + '"08:00"' + ',' 
															   + '"window_end"' + ':' + '"11:00"' + ','
														   ELSE
													  (CASE
														   -- manejo de centros comerciales
														   WHEN AG.ReceiverAddress LIKE '%cc %' COLLATE Latin1_General_CI_AI THEN
															   +'"window_start"' + ':' + '"08:00"' + ','
															   + '"window_end"' + ':' + '"10:00"' + ','
														   WHEN AG.ReceiverAddress LIKE '%centro comercial%' COLLATE Latin1_General_CI_AI THEN
															   +'"window_start"' + ':' + '"08:00"' + ',' + '"window_end"'
															   + ':' + '"10:00"' + ','
														   WHEN AG.ReceiverAddress LIKE '%c.c.%' COLLATE Latin1_General_CI_AI THEN
															   +'"window_start"' + ':' + '"08:00"' + ',' + '"window_end"'
															   + ':' + '"10:00"' + ','
														   WHEN AG.ReceiverAddress LIKE '%c.c%' COLLATE Latin1_General_CI_AI THEN
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
													  (
														CASE
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
															  (
																CASE
																   -- manejo de centros comerciales
																   WHEN AG.ReceiverAddress LIKE '%cc %' COLLATE Latin1_General_CI_AI THEN
																	   +'"window_start"' + ':' + '"08:00"' + ',' + '"window_end"'
																	   + ':' + '"10:00"' + ','
																   WHEN AG.ReceiverAddress LIKE '%centro comercial%' COLLATE Latin1_General_CI_AI THEN
																	   +'"window_start"' + ':' + '"08:00"' + ',' + '"window_end"'
																	   + ':' + '"10:00"' + ','
																   WHEN AG.ReceiverAddress LIKE '%c.c.%' COLLATE Latin1_General_CI_AI THEN
																	   +'"window_start"' + ':' + '"08:00"' + ',' + '"window_end"'
																	   + ':' + '"10:00"' + ','
																   WHEN AG.ReceiverAddress LIKE '%c.c%' COLLATE Latin1_General_CI_AI THEN
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
															  ) 
														  + '"window_start"' + ':' + '"08:00"' + ',' + '"window_end"' + ':'
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
                                                         '') + 
												  + (CASE
														WHEN (AG.HasAlert = 1) THEN
                                                            +'"priority_level"' + ':' + '3' + ','
                                                        WHEN AG.TypeService = 'SDD' THEN -- SDD
                                                            +'"priority_level"' + ':' + '3' + ','
                                                        WHEN AG.TypeService = 'TDA' THEN -- TDA
                                                            +'"priority_level"' + ':' + '5' + ','
                                                        ELSE
                                                            +'"priority_level"' + ':' + '4' + ','
                                                    END
                                                    ) 
                                                  + '}',
                                                  CHAR(31),
                                                  ''
                                              )
                                FROM @AcceptedGuides AG
                                    LEFT JOIN DeliveryBackOffice.dbo.Township TWSrid
                                        ON TWSrid.IdTownship = AG.ReceiverTownshipId
                                    LEFT JOIN DeliveryBackOffice.dbo.Township TWSrtwn
                                        ON TWSrtwn.TownshipName LIKE '%' + AG.ReceiverTown + '%' COLLATE Latin1_General_CI_AI
                                    LEFT JOIN DeliveryBackOffice.dbo.ServiceDataForGuide SDFG WITH (NOLOCK)
                                        ON AG.GuideSerie = SDFG.GuideSerie
                                           AND AG.GuideNumber = SDFG.GuideNumber
                                           AND SDFG.IsDelivery = 1
                                    LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPCr
                                        ON VPCr.CodeOfReference = AG.ReceiverID
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
										 AG.TotalPieces,
										 AG.HasAlert,
                                         AG.ReceiverAddress,
                                         AG.IdDeliveryOption,
                                         AG.ReceiverPhone,
                                         ISNULL(Cu.BusinessSegmentID, CuVPC.BusinessSegmentID),
                                         TypeService,
                                         SSHL.Latitud,
                                         SSHL.Longitude,
                                         SDFG.Latitude,
                                         SDFG.Longitude,
                                         VPCr.Latitude,
										 VPCr.Longitude,
                                         StartTime,
                                         EndTime,
                                         StartTime2,
                                         EndTime2
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

			SET @TransactionResult = 0;

        END;

        SELECT @TransactionResult [blnResult],
			('[' + @jsonResult + ']') jsonResultError;

    END TRY
    BEGIN CATCH

		SET @TransactionResult = 0;

        SELECT @TransactionResult [blnResult],
               ERROR_NUMBER() AS [ErrorNumber],
               ERROR_SEVERITY() AS [ErrorSeverity],
               ERROR_STATE() AS [ErrorState],
               ERROR_PROCEDURE() AS [ErrorProcedure],
               ERROR_LINE() AS [ErrorLine],
               ERROR_MESSAGE() AS [ErrorMessage];
    END CATCH;
END;