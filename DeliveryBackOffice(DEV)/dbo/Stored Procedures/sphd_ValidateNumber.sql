-- =============================================
-- Author:      <Edelman, Vásquez>
-- Create date: <2023-07-31>
-- Description: <Validar si existe número>
-- =============================================
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Update date: <2024-05-17>
-- Description: <Agregar filtro de pais>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_ValidateNumber]
(
 @Phone      NVARCHAR(50),
 @UniqueCode NVARCHAR(50),
 @idCountry  NVARCHAR(2) = NULL
)
AS
BEGIN
    BEGIN TRY
            IF (@UniqueCode='0')
            BEGIN
                 IF EXISTS(
                           SELECT TOP 1 1
                             FROM [DeliveryBackOffice].[dbo].[SenderReceiver]
                            WHERE Phone LIKE '%'+ @Phone + '%'
                              AND ((ISNULL(@idCountry,'') <> ''
                                   AND ISNULL(@idCountry,'') <> 'GT'
                                   AND IdCountry = @idCountry)
                                   OR
                                   (ISNULL(@idCountry,'') <> ''
                                    AND @idCountry = 'GT'
                                    AND IdCountry IS NULL)
                                   OR
                                   (ISNULL(@idCountry,'') = ''
                                    AND IdCountry IS NULL))
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
                             FROM [DeliveryBackOffice].[dbo].[SenderReceiver] 
                            WHERE Phone LIKE '%'+ @Phone + '%'
                              AND ((ISNULL(@idCountry,'') <> ''
                                  AND ISNULL(@idCountry,'') <> 'GT'
                                  AND IdCountry = @idCountry)
                                  OR
                                  (ISNULL(@idCountry,'') <> ''
                                   AND @idCountry = 'GT'
                                   AND IdCountry IS NULL)
                                  OR
                                  (ISNULL(@idCountry,'') = ''
                                   AND IdCountry IS NULL))
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