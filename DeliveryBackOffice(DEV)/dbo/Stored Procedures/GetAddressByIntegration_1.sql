-- =============================================
-- Author:      <Daniel, Ramirez>
-- Create date: <2024-06-20>
-- Description: <Listado de puntos de visita por cliente>
-- =============================================
CREATE PROCEDURE [dbo].[GetAddressByIntegration] 
(
 @Idcountry VARCHAR(2) = 'GT',
 @CodeApp   NVARCHAR(50)
)
AS
BEGIN
    -- Variables de control
    DECLARE @IdCustomer         INT;

    SET @IdCustomer =
    (
     SELECT TOP 1
            eco.IdCustomer
       FROM DeliveryBackOffice.[dbo].[Ecommerce] eco WITH (NOLOCK)
      WHERE eco.UserKey = @CodeApp
        AND eco.IdCountry = @Idcountry
        AND eco.EcommerceStatus = 'TRUE'
    );

    SELECT CodeOfReference,
           DescriptionOfClient,
           [Address],
           CASE 
               WHEN vpc.Phone LIKE '(%' THEN
                   TRANSLATE(SUBSTRING(vpc.Phone, CHARINDEX(')', vpc.Phone) + 1, LEN(vpc.Phone)), '()- ', '    ')
               ELSE 
                   TRANSLATE(vpc.Phone, '()- ', '    ')
           END AS Phone,
           CASE
               WHEN vpc.Phone LIKE '(%' THEN
                   SUBSTRING(vpc.Phone, PATINDEX('%[0-9]%', vpc.Phone), PATINDEX('%[^0-9]%', SUBSTRING(vpc.Phone, PATINDEX('%[0-9]%', vpc.Phone), 10)) - 1)
               ELSE NULL
           END AS NirPhone,
           Latitude,
           Longitude,
           CASE 
               WHEN [Zone] IS NULL 
                    OR LTRIM(RTRIM([Zone])) = ''
                    OR ISNUMERIC([Zone]) = 0
                    THEN '0'
               ELSE [Zone]
           END AS [Zone]
      FROM dbo.VisitPointClient vpc WITH(NOLOCK)
     WHERE vpc.CustomerID = @IdCustomer
       AND StatusClient = 1
       AND CountryId = @Idcountry
END;