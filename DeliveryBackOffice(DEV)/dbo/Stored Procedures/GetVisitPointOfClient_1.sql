
-- =============================================
-- Author:      <Daniel Ramirez>
-- Create date: <2024-11-19>
-- Description: <Devuelve los puntos de visita relacionados a un cliente corporativo>
-- =============================================
-- Author:      <Tito García>
-- Update date: <2024-11-28>
-- Description: <Se agrega consulta para obtener los datos de facturación del cliente>
-- =============================================
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
						cs.InvoiceEmail
					FROM DeliveryBackOffice.dbo.Customer cs WITH(NOLOCK) 
						INNER JOIN DeliveryBackOffice.dbo.CustomerType cust WITH(NOLOCK)
							ON cs.IdCustomerType = cust.IdCustomerType
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