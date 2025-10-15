-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-11-24>
-- Description:	<Devuelve el listado de Direcciones asiganadas a una cuenta filtrado por nombres, CUI, correo y telefono>
-- =============================================

CREATE PROCEDURE [dbo].[FilterVisitPointByClientPortfolio]  
    @IdAccount INT,  
    @Token VARCHAR(50) = '',  
    @TextFilter NVARCHAR(100)  
AS  
BEGIN  
    -- SET NOCOUNT ON added to prevent extra result sets from  
    -- interfering with SELECT statements.  
    SET NOCOUNT ON;
    DECLARE @VisitPointId INT;
  
    SET @VisitPointId =  
    (  
        SELECT TOP 1  
               vp.IdVisitPointClient  
        FROM [dbo].RegisterUser usr WITH (NOLOCK)  
            LEFT JOIN [dbo].[RolByUserByAccount] rua WITH (NOLOCK)  
                ON rua.RuaIdUser = usr.UsrIdUser  
                   AND rua.RuaRowStatus = 1  
            INNER JOIN [dbo].Account ac WITH (NOLOCK)  
                ON ac.AccIdAccount = rua.RuaIdAccount  
                   AND ac.AccRowStatus = 1  
            INNER JOIN VisitPointByUser vp WITH (NOLOCK)  
                ON vp.RegisterUserID = usr.UsrIdUser  
        WHERE ac.AccIdAccount = @IdAccount  
          AND vp.RowStatus = 1  
    );  
  
    --SET STATISTICS TIME ON;  
    SELECT DISTINCT  
                   CONVERT(VARCHAR, vcp.IdVisitPointByClientPortfolio) [IdVisitPointByClientPortfolio]  
                  ,ISNULL(vcp.InternalCode, '') [InternalCode]  
                  ,CONVERT( NVARCHAR(50),ISNULL(vcp.FirstName,'')) [FirstName]  
                  ,ISNULL(CONVERT(VARCHAR,ISNULL(vcp.SecondName,'')),'') [SecondName]  
                  ,ISNULL(CONVERT(VARCHAR,ISNULL(vcp.LastName,'')),'') [LastName]  
                  ,ISNULL(CONVERT(VARCHAR,ISNULL(vcp.SecondLastName,'')),'') [SecondLastName]  
                  ,ISNULL(CONVERT(VARCHAR, vcp.NirPhone), '') [NirPhone]  
                  ,ISNULL(CONVERT(VARCHAR,ISNULL(vcp.Phone,'')),'') [Phone]  
                  ,ISNULL(CONVERT(VARCHAR(50), REPLACE(vcp.Email, '"', '')),'') [Email]  
                  ,ISNULL(CONVERT(VARCHAR, vcp.CUI),'') [CUI]  
                  ,ISNULL(CONVERT(VARCHAR, vcp.RowStatus), ' ') [Status]  
                  ,ISNULL(CONVERT(VARCHAR, vcp.TokenCreated), ' ') [Token]  
                  ,ISNULL(vcp.TaxId, ' ') [TaxId]  
                  ,REPLACE(ISNULL(vcp.ContactName, ' '), '"', '') [ContactName]  
    FROM DeliveryBackOffice.dbo.VisitPointByClientPortfolio vcp WITH (NOLOCK)  
    WHERE vcp.RowStatus = 1  
      AND vcp.VisitPointId = @VisitPointId  
      AND (  
           CONCAT(  
                     vcp.FirstName,  
                     ' ',  
                     vcp.SecondName,  
                     ' ',  
                     vcp.LastName,  
                     ' ',  
                     vcp.SecondLastName  
                 ) LIKE CONCAT('%', @TextFilter, '%')  
           OR vcp.CUI LIKE CONCAT('%', @TextFilter, '%')  
           OR vcp.Phone LIKE CONCAT('%', @TextFilter, '%')  
           OR vcp.Email LIKE CONCAT('%', @TextFilter, '%')  
          )  
  
    -- BILLING  
    SELECT  
          'BILLING'  
          ,CONVERT(VARCHAR, vcp.IdVisitPointByClientPortfolio) [IdVisitPointByClientPortfolio]  
          ,ISNULL(CONVERT(VARCHAR, SUB.BlpIdBilling), ' ') [IdBilling]  
          ,ISNULL(CONVERT(VARCHAR, SUB.BlpIdAccount),' ') [IdAccount]  
          ,ISNULL(CONVERT(VARCHAR, SUB.BlpName),' ') [Name]  
          ,ISNULL(CONVERT(VARCHAR, SUB.BlpAddress),'') [Address]  
          ,ISNULL(CONVERT(VARCHAR, SUB.BlpTaxId), ' ') [TaxId]  
          ,ISNULL(CONVERT(VARCHAR, SUB.NRC), ' ') [NRC]  
          ,ISNULL(CONVERT(VARCHAR, SUB.TypeIdentificationDocumentCode), ' ') [TypeIdentificationDocumentCode]  
          ,ISNULL(CONVERT(VARCHAR, SUB.IdDocument), ' ') [IdDocument]  
       ,ISNULL(CONVERT(VARCHAR, SUB.DistrictId), ' ') [DistrictId]  
          ,ISNULL(CONVERT(VARCHAR, SUB.StateId), ' ') [StateId]  
          ,ISNULL(CONVERT(VARCHAR, SUB.ActivityCode), ' ') [ActivityCode]  
          ,ISNULL(CONVERT(VARCHAR, SUB.Inv_type), ' ') [Inv_type]  
          ,ISNULL(CONVERT(VARCHAR, SUB.BlpRowStatus), ' ') [Status]  
          ,ISNULL(CONVERT(VARCHAR, SUB.BlpTokenCreated), ' ') [Token]  
    FROM DeliveryBackOffice.dbo.VisitPointByClientPortfolio vcp WITH (NOLOCK)  
        INNER JOIN BillingProfile SUB WITH (NOLOCK)  
            ON SUB.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio  
    WHERE vcp.RowStatus = 1  
      AND SUB.BlpRowStatus = 1  
      AND vcp.VisitPointId = @VisitPointId  
      AND (  
           CONCAT(  
                     vcp.FirstName,  
                     ' ',  
                     vcp.SecondName,  
                     ' ',  
                     vcp.LastName,  
                     ' ',  
                     vcp.SecondLastName  
                 ) LIKE CONCAT('%', @TextFilter, '%')  
           OR vcp.CUI LIKE CONCAT('%', @TextFilter, '%')  
           OR vcp.Phone LIKE CONCAT('%', @TextFilter, '%')  
           OR vcp.Email LIKE CONCAT('%', @TextFilter, '%')  
          )  
  
   -- COD  
    SELECT  
         'cod'  
         ,ISNULL(CONVERT(VARCHAR, SUB.VisitPointByClientPortfolioId),' ') [IdVisitPointByClientPortfolio]  
         ,ISNULL(CONVERT(VARCHAR, SUB.IdDeliveryFavCOD),' ') [Id]  
         ,ISNULL(CONVERT(VARCHAR, SUB.IdAccountFavCOD),' ') [IdAccount]  
         ,ISNULL(CONVERT(VARCHAR, SUB.IdBank),' ') [IdBank]  
         ,ISNULL(CONVERT(VARCHAR,(ISNULL(DB.Name,''))),'') [NameBank]  
         ,ISNULL(CONVERT(VARCHAR,(ISNULL(SUB.NameAccountFavCOD,''))),'') [NameAccount]  
         ,ISNULL(CONVERT(VARCHAR,SUB.TypeAccountFavCOD),'') [TypeAccount]  
         ,ISNULL(CONVERT(VARCHAR,SUB.DocumentIdFavCOD),'') [DocID]  
         ,ISNULL(CONVERT(VARCHAR,SUB.AliasFavCOD),' ') [Alias]  
         ,ISNULL(CONVERT(VARCHAR, SUB.TokenCreated), ' ') [Token]  
         ,ISNULL(CONVERT(VARCHAR, SUB.TokenUpdate), ' ') [TokenUpdate]  
         ,ISNULL(CONVERT(VARCHAR, SUB.NumberAccFavCOD), ' ') [NumberAcc]  
         ,ISNULL(CONVERT(VARCHAR, SUB.StatusFavCOD), ' ') [Status]  
    FROM DeliveryBackOffice.dbo.VisitPointByClientPortfolio vcp WITH (NOLOCK)  
        INNER JOIN DeliveryBackOffice.dbo.DeliveryFavCOD SUB WITH (NOLOCK)  
            ON SUB.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio  
        INNER JOIN dbo.DeliveryBank DB WITH (NOLOCK)   
            ON  SUB.StatusFavCOD = 1  
            AND DB.Id_bank = SUB.IdBank  
    WHERE vcp.RowStatus = 1  
      AND vcp.VisitPointId = @VisitPointId  
      AND (  
           CONCAT(  
                     vcp.FirstName,  
                     ' ',  
                     vcp.SecondName,  
                     ' ',  
                     vcp.LastName,  
                     ' ',  
                     vcp.SecondLastName  
                 ) LIKE CONCAT('%', @TextFilter, '%')  
           OR vcp.CUI LIKE CONCAT('%', @TextFilter, '%')  
           OR vcp.Phone LIKE CONCAT('%', @TextFilter, '%')  
           OR vcp.Email LIKE CONCAT('%', @TextFilter, '%')  
          )  
  
    -- Addresses  
    SELECT DISTINCT  
                  'ADDRESSES'  
                  ,ISNULL(CONVERT(VARCHAR, SUB.VisitPointByClientPortfolioId), ' ') [IdVisitPointByClientPortfolio]  
                  ,ISNULL(CONVERT(VARCHAR, SUB.UadIdAddress), ' ') [IdAddress]  
                  ,ISNULL(CONVERT(VARCHAR, SUB.UadIdTownship), ' ') [IdTownship]  
                  ,ISNULL(CONVERT(VARCHAR, pr.IdProvince), ' ') [IdProvince]  
                  ,ISNULL(CONVERT(VARCHAR, pr.ProvinceName), ' ') [Province]  
                  ,ISNULL(CONVERT(VARCHAR, tw.TownshipName), ' ') [Township]  
                  ,ISNULL(CONVERT(VARCHAR, tw.HeaderCode), ' ') [HeaderCode]  
                  ,ISNULL(CONVERT(VARCHAR, SUB.UadIdAccount), ' ') [IdAccount]  
                  ,ISNULL(CONVERT(VARCHAR, SUB.UadIdCountry), ' ') [IdCountry]  
                  ,REPLACE((ISNULL(SUB.UadFullName, '' )),'"','') [FullName]  
                  ,REPLACE((ISNULL(SUB.UadAddress1, '' )),'"','') [Address1]  
                  ,REPLACE((ISNULL(SUB.UadAddress2,'')),'"','') [Address2]  
                  ,REPLACE(ISNULL(SUB.UadNirPhone, ''),'"','') [NirPhone]  
                  ,REPLACE((ISNULL(SUB.UadPhone,'')),'"','') [Phone]  
                  ,REPLACE((ISNULL(SUB.UadAdditionalInstructions,'')),'"','') [AdditionalInstructions]  
                  ,ISNULL(CONVERT(VARCHAR, SUB.UadRowStatus), ' ') [Status]  
                  ,ISNULL(CONVERT(VARCHAR(100), SUB.UadTokenCreated), ' ') [Token]  
                  ,ISNULL(CONVERT(VARCHAR, SUB.UadIdSettlement), '') [IdSettlement]  
                  ,ISNULL(st.Settlement, '') [SettlementDescription]  
                  ,ISNULL(CONVERT(VARCHAR, SUB.UadIdDeliveryOption), ' ') [IdDeliveryOption]  
                  ,ISNULL(cdo.Name, ' ') [DescriptionDeliveryOption]  
                  ,CASE  
                       WHEN dsc.TDA = 1   
                       THEN 'TRUE'  
                       ELSE 'FALSE'  
                   END  [IsTDA]  
                  ,CASE  
                        WHEN dsc.SDD = 1 THEN  
                            'TRUE'  
                        ELSE  
                            'FALSE'  
                    END [HasSDD]  
                   ,ISNULL(dsc.Hub, '') [Hub]  
                   ,ISNULL(CONVERT(VARCHAR, SUB.IdCityPlace),'0') [IdCityPlace]  
    FROM DeliveryBackOffice.dbo.VisitPointByClientPortfolio vcp WITH (NOLOCK)  
        INNER JOIN DeliveryBackOffice.dbo.UserAddress SUB WITH (NOLOCK)  
            ON SUB.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio  
        LEFT JOIN DeliveryBackOffice.dbo.Township tw WITH (NOLOCK)  
            ON tw.IdTownship = SUB.UadIdTownship  
            AND tw.TownshipStatus = 1  
        LEFT JOIN DeliveryBackOffice.dbo.Province pr WITH (NOLOCK)  
            ON pr.IdProvince = tw.IdProvince  
            AND pr.ProvinceStatus = 1  
        LEFT JOIN DeliveryBackOffice.dbo.Settlement st WITH (NOLOCK)  
            ON st.IdSettlement = SUB.UadIdSettlement  
               AND st.SettlementSatus = 1  
        LEFT JOIN DeliveryBackOffice.dbo.CatDeliveryOptions cdo WITH (NOLOCK)  
            ON cdo.IdDeliveryOption = SUB.UadIdDeliveryOption  
            AND cdo.RowStatus = 1  
        LEFT JOIN DeliveryBackOffice.dbo.DumpServiceCoverage dsc WITH (NOLOCK)  
            ON dsc.IdSettlement = st.IdSettlement  
               AND dsc.RowStatus = 1  
    WHERE SUB.UadRowStatus = 1  
      AND vcp.RowStatus = 1  
      AND vcp.VisitPointId = @VisitPointId  
      AND (  
           CONCAT(  
                     vcp.FirstName,  
                     ' ',  
                     vcp.SecondName,  
                     ' ',  
                     vcp.LastName,  
                     ' ',  
                     vcp.SecondLastName  
                 ) LIKE CONCAT('%', @TextFilter, '%')  
           OR vcp.CUI LIKE CONCAT('%', @TextFilter, '%')  
           OR vcp.Phone LIKE CONCAT('%', @TextFilter, '%')  
           OR vcp.Email LIKE CONCAT('%', @TextFilter, '%')  
          )  
  
END;