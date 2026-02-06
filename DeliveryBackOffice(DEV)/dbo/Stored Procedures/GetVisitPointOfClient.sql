/* =================================================
   SP:        [dbo].[GetVisitPointOfClient]
   Propósito: Devolver los puntos de visita relacionados a un cliente corporativo.
   Autor:     Daniel Ramirez
   Historia:  HR-2103
   Fecha:     2024-11-19
===== CHANGELOG ============================
2025-11-03 | Historia/épica: FDAPI-4922 | Autor: Cristian Azurdia |
2025-06-12 | Historia/épica: FDAPI-4083 | Autor: Brandon Pedroza |
2024-11-28 | Historia/épica: FDD-1441 | Autor: Tito García  |
2024-11-19 | Historia/épica: FDD-4021 | Autor: Daniel Ramirez  |
2024-11-19 | Historia/épica: FDD-1433 | Autor: Daniel Ramirez  |
=========================================== */

CREATE PROCEDURE [dbo].[GetVisitPointOfClient]
(
 @IdCustomer   INT,
 @SAPCardCode  NVARCHAR(100),
 @IdCountry    NVARCHAR(2)
)
AS
BEGIN
    BEGIN TRY

        -- Validar y eliminar la tabla temporal si ya existe
        IF OBJECT_ID('tempdb..#VisitPoints') IS NOT NULL
            DROP TABLE #VisitPoints;

        -- Crear tabla temporal
        CREATE TABLE #VisitPoints (
                 IdVisitPointClient INT,
                 DescriptionOfClient NVARCHAR(200)
        );

        IF EXISTS (
              SELECT TOP 1 1
                FROM Customer cs WITH(NOLOCK)
                     INNER JOIN DeliveryBackOffice.dbo.CustomerType cust WITH(NOLOCK)
                           ON cs.IdCustomerType = cust.IdCustomerType
               WHERE (cs.IdCustomer = @IdCustomer
                     OR cs.SAPCardCode = @SAPCardCode)
                 AND cust.IdCustomerType = 1
                 AND cs.CountryID = @IdCountry
        )
        BEGIN
                INSERT INTO #VisitPoints (IdVisitPointClient, DescriptionOfClient)
                SELECT vsp.IdVisitPointClient,
                       vsp.DescriptionOfClient
                  FROM DeliveryBackOffice.dbo.VisitPointClient vsp WITH(NOLOCK)
                       INNER JOIN DeliveryBackOffice.dbo.Customer cs WITH(NOLOCK) 
                             ON vsp.CustomerID = cs.IdCustomer
                       INNER JOIN DeliveryBackOffice.dbo.CustomerType cust WITH(NOLOCK)
                             ON cs.IdCustomerType = cust.IdCustomerType
                 WHERE (cs.IdCustomer = @IdCustomer
                       OR cs.SAPCardCode = @SAPCardCode)
                       AND cust.IdCustomerType = 1
                       AND cs.CountryID = @IdCountry

                -- Validar si hay registros en la tabla temporal
                IF EXISTS (SELECT TOP 1 1 
                             FROM #VisitPoints)
                BEGIN
                    SELECT 1 AS StatusCode, 
                           'Puntos de visita obtenidos exitosamente' AS StatusMessage;

                    SELECT *
                    FROM #VisitPoints
                    ORDER BY DescriptionOfClient ASC;

                    SELECT
                        cs.Name AS CompanyName,
                        cs.InvoiceName,
                        cs.TaxIdentificationNumber,
                        cs.FiscalAddress,
                        cs.InvoiceEmail,
                        IIF(bcsvf.StateCode IS NULL, vpcf.StateCode, bcsvf.StateCode) [CodeState],
                        IIF(bcsvf.CodeDistrict IS NULL, vpcf.CodeDistrict, bcsvf.CodeDistrict) [CodeDistrict],
                        IIF(bcsvf.CodeActivity IS NULL, vpcf.CodeActivity, bcsvf.CodeActivity) [CodeActivity],
                        IIF(bcsvf.[Description] IS NULL, vpcf.[Description], bcsvf.[Description]) [Description],
                        IIF(bcsvf.[NRC] IS NULL, vpcf.[NRC], bcsvf.[NRC]) [NRC],
                        IIF(bcsvf.[Phone] IS NULL, vpcf.[Phone], bcsvf.[Phone]) [Phone],
                        IIF(bcsvf.[TypeIdentificationDocumentCode] IS NULL, vpcf.[TypeIdentificationDocumentCode], bcsvf.[TypeIdentificationDocumentCode]) [TypeIdentificationDocumentCode],
                        IIF(bcsvf.[IdDocument] IS NULL, vpcf.[IdDocument], bcsvf.[IdDocument]) [IdDocument],
                        IIF(bcsvf.[Inv_type] IS NULL, vpcf.[Inv_type], bcsvf.[Inv_type]) [Inv_type],
                        IIF(bcsvf.[Inv_type] IS NULL,1, 0) [isNew]
                    FROM DeliveryBackOffice.dbo.Customer cs WITH(NOLOCK) 
                        INNER JOIN DeliveryBackOffice.dbo.CustomerType cust WITH(NOLOCK)
                            ON cs.IdCustomerType = cust.IdCustomerType
                        OUTER APPLY (
                            SELECT  IdCustomer,
                                    DIS.StateCode,
                                    DIS.CodeDistrict,
                                    CAT.CodeActivity,
                                    CAT.[Description],
                                    NRC,
                                    PHONE,
                                    TypeIdentificationDocumentCode,
                                    IdDocument,
                                    Inv_type
                            FROM DeliveryBackOffice.dbo.BillingCustomerBySV WITH(NOLOCK)
                            LEFT JOIN dbo.DistrictByBillingSV DIS WITH(NOLOCK)
                               ON DistrictId = DIS.Id
                            LEFT JOIN dbo.CatEconomicActivityBySV CAT WITH(NOLOCK)
                               ON ActivityId = CAT.Id
                            WHERE cs.IdCustomer = IdCustomer
                        ) bcsvf
                        OUTER APPLY (
                            SELECT top 1
                                   vpc.CustomerID,
                                   DIS.StateCode,
                                   DIS.CodeDistrict,
                                   NULL CodeActivity,
                                   NULL [Description],
                                   NULL NRC,
                                   NULL PHONE,
                                   NULL TypeIdentificationDocumentCode,
                                   NULL IdDocument,
                                   NULL Inv_type
                            FROM DeliveryBackOffice.dbo.VisitPointClient vpc WITH(NOLOCK)
                            INNER JOIN DeliveryBackOffice.dbo.TownshipDistrictByBillingSV tdbsv WITH(NOLOCK)
                            ON tdbsv.TownshipId = vpc.IdTownship
                            LEFT JOIN dbo.DistrictByBillingSV DIS WITH(NOLOCK)
                            ON tdbsv.DistrictId = DIS.Id
                            WHERE cs.IdCustomer = vpc.CustomerID
                        ) vpcf                        
                    WHERE (cs.IdCustomer = @IdCustomer
                        OR cs.SAPCardCode = @SAPCardCode)
                        AND cust.IdCustomerType = 1
                        AND cs.CountryID = @IdCountry


                    IF(@IdCountry = 'HN')
                    BEGIN
                            SELECT Id_lote
                                 , TypeDocument
                            FROM InvoiceBatchHeader WITH(NOLOCK)
                            WHERE [Status] = 1
                              AND [Enable] = 1
                              AND [RowStatus] = 1
                    END

                END
                ELSE
                BEGIN
                    SELECT 0 AS StatusCode, 
                           'El cliente no tiene puntos de visita asociados' AS StatusMessage;

                END
        END

        IF EXISTS(
              SELECT TOP 1 1
                FROM Customer cs WITH(NOLOCK)
                     INNER JOIN DeliveryBackOffice.dbo.CustomerType cust WITH(NOLOCK)
                           ON cs.IdCustomerType = cust.IdCustomerType
               WHERE (cs.IdCustomer = @IdCustomer
                     OR cs.SAPCardCode = @SAPCardCode)
                 AND cust.IdCustomerType = 1
                 AND cs.CountryID <> @IdCountry
        )
        BEGIN 
                SELECT 0 AS StatusCode, 
               ' Cliente pertenece a otro pais ' AS StatusMessage
        END

        IF EXISTS(
              SELECT TOP 1 1
                FROM Customer cs WITH(NOLOCK)
                     INNER JOIN DeliveryBackOffice.dbo.CustomerType cust WITH(NOLOCK)
                           ON cs.IdCustomerType = cust.IdCustomerType
               WHERE (cs.IdCustomer = @IdCustomer
                     OR cs.SAPCardCode = @SAPCardCode)
                 AND cust.IdCustomerType <> 1
                 AND cs.CountryID = @IdCountry
        )
        BEGIN 
                SELECT 0 AS StatusCode, 
               ' Cliente no es corporativo ' AS StatusMessage
        END

        IF EXISTS(
              SELECT TOP 1 1
                FROM Customer cs WITH(NOLOCK)
                     INNER JOIN DeliveryBackOffice.dbo.CustomerType cust WITH(NOLOCK)
                           ON cs.IdCustomerType = cust.IdCustomerType
               WHERE (cs.IdCustomer = @IdCustomer
                     OR cs.SAPCardCode = @SAPCardCode)
                 AND cust.IdCustomerType <> 1
                 AND cs.CountryID <> @IdCountry
        )
        BEGIN 
                SELECT 0 AS StatusCode, 
               ' Cliente pertenece a otro país ' AS StatusMessage
        END

    END TRY
    BEGIN CATCH
            SELECT 0 AS StatusCode, 
                   'Ha ocurrido un error en el proceso' AS StatusMessage
    END CATCH

    -- Validar y eliminar la tabla temporal si ya existe
    IF OBJECT_ID('tempdb..#VisitPoints') IS NOT NULL
        DROP TABLE #VisitPoints;
END