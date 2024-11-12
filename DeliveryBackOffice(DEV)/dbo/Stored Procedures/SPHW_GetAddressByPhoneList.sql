-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2024-10-31>
-- Description:	<Link de Entrega - Obtiene informacion de direcciones por telefono y nirphone>
-- =============================================

CREATE PROCEDURE [dbo].[SPHW_GetAddressByPhoneList]
    @Phone NVARCHAR(10),
    @Nirphone NVARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validación de la longitud de @Phone
    IF LEN(@Phone) < 6
    BEGIN
    SELECT DISTINCT RIGHT(UA.UadPhone,8)	AS 'Phone',
		   RIGHT(UA.UadNirPhone, 3)			AS 'Nirphone',
		   UA.IdCityPlace					AS 'IdCityPlace',
           ISNULL(VPC.IdSettlement,
					UA.UadIdSettlement)		AS 'IdSettlement',
           ISNULL(CONF.[Zone],'0')		AS 'Zone',
           ISNULL(CONF.Neighborhood, '')	AS 'Neighborhood',
           UA.UadAddress1					AS 'Address',
           UA.UadAdditionalInstructions		AS 'AdditionalInstructions'
    FROM UserAddress UA
        INNER JOIN VisitPointClient VPC
            ON UA.CodeOfReference = VPC.CodeOfReference
        LEFT JOIN ConfirmedAddress CONF WITH (NOLOCK)
            ON CONF.NirPhone = UA.UadNirPhone
               AND CONF.Phone = UA.UadPhone
               AND CONF.AccountId = UA.UadIdAccount
    WHERE UA.UadPhone = @Phone
          AND RIGHT(UA.UadNirPhone, 3) = @Nirphone;
		RETURN;
    END

    SELECT DISTINCT RIGHT(UA.UadPhone,8)	AS 'Phone',
		   RIGHT(UA.UadNirPhone, 3)			AS 'Nirphone',
		   UA.IdCityPlace					AS 'IdCityPlace',
           ISNULL(VPC.IdSettlement,
					UA.UadIdSettlement)		AS 'IdSettlement',
           ISNULL(CONF.[Zone],'0')		AS 'Zone',
           ISNULL(CONF.Neighborhood, '')	AS 'Neighborhood',
           UA.UadAddress1					AS 'Address',
           UA.UadAdditionalInstructions		AS 'AdditionalInstructions'
    FROM UserAddress UA
        INNER JOIN VisitPointClient VPC
            ON UA.CodeOfReference = VPC.CodeOfReference
        LEFT JOIN ConfirmedAddress CONF WITH (NOLOCK)
            ON CONF.NirPhone = UA.UadNirPhone
               AND CONF.Phone = UA.UadPhone
               AND CONF.AccountId = UA.UadIdAccount
               AND CONF.TownshipId = UA.UadIdTownship
    WHERE UA.UadPhone LIKE '%' + @Phone + '%'
          AND RIGHT(UA.UadNirPhone, 3) = @Nirphone
		  AND ( VPC.IdSettlement IS NOT NULL OR UA.UadIdSettlement IS NOT NULL)
		   
END
