-- =============================================
-- Author:      <Edelman, Vásquez>
-- Create date: <2023-07-31>
-- Description: <Validar si existe número>
-- =============================================
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Update date: <2024-05-17>
-- Description: <Agregar filtro de pais, por defecto GT>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_ValidateNumber]
(
 @Phone      NVARCHAR(50),
 @UniqueCode NVARCHAR(50),
 @IdCountry  NVARCHAR(2) = 'GT'
)
AS
BEGIN
    BEGIN TRY
            IF (@UniqueCode='0')
            BEGIN
                 IF EXISTS(
                           SELECT TOP 1 1
                             FROM [DeliveryBackOffice].[dbo].[SenderReceiver] WITH(NOLOCK)
                            WHERE Phone LIKE '%'+ @Phone + '%'
                              AND IIF(IdCountry IS NULL, 'GT', IdCountry) = @IdCountry
                          )
                 BEGIN
                      SELECT 0 AS 'StatusCode'
                 END
                 ELSE
                 BEGIN
                      SELECT 0 AS 'StatusCode'
                 END
            END
            ELSE
            BEGIN
                 IF EXISTS(
                           SELECT TOP 1 1
                             FROM [DeliveryBackOffice].[dbo].[SenderReceiver] WITH(NOLOCK)
                            WHERE Phone LIKE '%'+ @Phone + '%'
                              AND IIF(IdCountry IS NULL, 'GT', IdCountry) = @IdCountry
                          ) 
                 BEGIN
                      SELECT 0 AS 'StatusCode'
                 END
                 ELSE
                 BEGIN
                      SELECT 0 AS 'StatusCode'
                 END
            END
    END TRY
    BEGIN CATCH
              -- Bloque de código donde se manejan las excepciones
              SELECT ERROR_MESSAGE() AS ErrorMessage, 
                     ERROR_NUMBER() AS ErrorNumber;
   END CATCH
END