-- =============================================
-- Author:      <Daniel Ramirez>
-- Create date: <2024-11-19>
-- Description: <Devuelve los puntos de visita relacionados a un cliente corporativo>
-- =============================================
-- Author:      <Tito García>
-- Update date: <2024-11-28>
-- Description: <Se agrega consulta para obtener los datos de facturación del cliente>
-- =============================================
-- Author:      <Brandon Pedroza>
-- Update date: <2025-06-12>
-- Description: <Facturacion SV - Se obtienen datos de cliente para facturar en El Salvador>
--=============================================
-- Author:      <Cristian Azurdia>
-- Update date: <2025-07-30>
-- Description: <Facturacion SV - Manejo de clientes corporativos nuevos>
--=============================================
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
                 AND ISNULL(cs.CountryID,'GT') = @IdCountry
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
                       AND ISNULL(cs.CountryID,'GT') = @IdCountry

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
                        IIF(bcsvf.[StateCode] IS NULL,1, 0) [IsNew]
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
                                    PHONE
                            FROM DeliveryBackOffice.dbo.BillingCustomerBySV WITH(NOLOCK)
                            LEFT JOIN dbo.DistrictByBillingSV DIS           WITH(NOLOCK)
                               ON DistrictId = DIS.Id
                            LEFT JOIN dbo.CatEconomicActivityBySV CAT       WITH(NOLOCK)
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
                                   NULL PHONE
                            FROM DeliveryBackOffice.dbo.VisitPointClient vpc                    WITH(NOLOCK)
                            INNER JOIN DeliveryBackOffice.dbo.TownshipDistrictByBillingSV tdbsv WITH(NOLOCK)
                            ON tdbsv.TownshipId = vpc.IdTownship
                            LEFT JOIN dbo.DistrictByBillingSV DIS                               WITH(NOLOCK)
                            ON tdbsv.DistrictId = DIS.Id
                            WHERE cs.IdCustomer = vpc.CustomerID
                        ) vpcf
                    WHERE (cs.IdCustomer = @IdCustomer
                        OR cs.SAPCardCode = @SAPCardCode)
                        AND cust.IdCustomerType = 1
                        AND ISNULL(cs.CountryID,'GT') = @IdCountry

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
                 AND ISNULL(cs.CountryID,'GT') <> @IdCountry
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
                 AND ISNULL(cs.CountryID,'GT') = @IdCountry
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
                 AND ISNULL(cs.CountryID,'GT') <> @IdCountry
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