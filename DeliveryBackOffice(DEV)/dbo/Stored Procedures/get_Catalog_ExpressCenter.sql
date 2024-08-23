-- =============================================
-- Author:		<Eduardo L�pez>
-- Create date: <22-03-2023>
-- Description:	<Obtener catalogo de Express Center disponibles para clientes de integraci�n>
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Create date: <2024-06-20>
-- Description: <Se agrega parametro para filtrar por pais, por defecto GT>
-- =============================================
CREATE PROCEDURE [dbo].[get_Catalog_ExpressCenter] 
@IdMerchant VARCHAR(100) = '',
@Idcountry VARCHAR(2) = 'GT'
AS
BEGIN
    DECLARE @jsonResult NVARCHAR(MAX);

    BEGIN
        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"Name":"' + DescriptionOfClient + '",' + '"IdTownship":"'
                                       + ISNULL(CONVERT(VARCHAR, TWS.IdTownship), '') + '",' + '"TownshipName":"'
                                       + ISNULL(TWS.TownshipDescription, '') + '",' + '"IdProvince":"'
                                       + ISNULL(CONVERT(VARCHAR, PRV.IdProvince), '') + '",' + '"ProvinceName":"'
                                       + ISNULL(PRV.ProvinceDescription, '') + '",' + '"Address":"'
                                       + ISNULL(VPC.Address, '') + '",' + '"HeaderCode":"' + ISNULL(TWS.HeaderCode, '')
                                       + '",' + '"SettlementDescription":"' + ISNULL(STL.Settlement, '') + '",'
                                       + '"IdSettlement":"' + ISNULL(CONVERT(NVARCHAR, STL.IdSettlement), '') + '",'
                                       + '"CodeOfReference":"' + ISNULL(CONVERT(NVARCHAR, VPC.CodeOfReference), '')
                                       + '"' + '}'
                                FROM DeliveryBackOffice.dbo.VisitPointClient     VPC WITH (NOLOCK)
                                    INNER JOIN DeliveryBackOffice.dbo.Settlement STL WITH (NOLOCK)
                                        ON VPC.IdSettlement = STL.IdSettlement
                                    INNER JOIN DeliveryBackOffice.dbo.Township   TWS WITH (NOLOCK)
                                        ON TWS.IdTownship = STL.IdTownship
                                    INNER JOIN DeliveryBackOffice.dbo.Province   PRV WITH (NOLOCK)
                                        ON PRV.IdProvince = TWS.IdProvince
                                WHERE (IdKindOfVPClient = 1 OR IdKindOfVPClient = 12)
                                      AND VPC.StatusClient = 1
                                      AND IIF(PRV.IdCountry IS NULL, 'GT', PRV.IdCountry) = @Idcountry
                                ORDER BY VPC.CodeOfReference
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)')
                          , 1
                          , 1
                          , ''
                        )
        );
    END;
    SELECT '[' + @jsonResult + ']' FormatJson;
END;