-- =============================================
-- Author:		<Cristian Suazo>
-- Update date: <2025-01-09>
-- Description:	<Valida si el estado del Customer esta activo >
-- =============================================
CREATE PROCEDURE [dbo].[GetCustomerStatus]
    @IdCustomer INT,
    @CodeOfReference INT
AS
BEGIN
    BEGIN TRY

        DECLARE @CustomerType INT = (
                                        SELECT IdCustomerType
                                        FROM CustomerType WITH (NOLOCK)
                                        WHERE Description = 'CORPORATIVO'
                                    )

        IF EXISTS
        (
            SELECT TOP 1
                1
            FROM Customer WITH (NOLOCK)
            WHERE IdCustomer = @IdCustomer
                  AND IdCustomerType = @CustomerType
        )
        BEGIN

            IF EXISTS
            (
                SELECT TOP 1
                    1
                FROM Customer CU WITH (NOLOCK)
                    INNER JOIN VisitPointClient VP WITH (NOLOCK)
                        ON CU.IdCustomer = VP.CustomerID
                WHERE CU.IdCustomer = @IdCustomer
                      AND VP.CodeOfReference = @CodeOfReference
                      AND VP.StatusClient = 1
                      AND ISNULL(RowSatus, 0) = 1
            )
            BEGIN
                SELECT 1 AS StatusCode,
                       'Id Customer activo' AS Description
            END
            ELSE
            BEGIN
                SELECT 0 AS StatusCode,
                       'El Id del customer no esta activo' AS Description
            END
        END
        ELSE
        BEGIN
            SELECT 1 AS StatusCode,
                   'El customer no es corporativo'
        END
    END TRY
    BEGIN CATCH
        SELECT 0 AS StatusCode,
               ERROR_MESSAGE() AS Description,
               ERROR_LINE() AS ErrorLine
    END CATCH
END