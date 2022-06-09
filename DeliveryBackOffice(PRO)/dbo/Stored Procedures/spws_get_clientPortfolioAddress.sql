-- =============================================
-- Author:		<Michael Espinoza>
-- Create date: <2021-10-25>
-- Description:	<Returns the address of a user that was previously saved on client's portfolio>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_clientPortfolioAddress]
	-- Add the parameters for the stored procedure here
  
	@IdVisitPointByClientPortfolio INT, 
	@IdAddress INT,
  @Token NVARCHAR(100) = ''

AS

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @jsonResult NVARCHAR(MAX) = '';

	BEGIN TRY

	SET @jsonResult = ISNULL((
		SELECT STUFF(
			(
				SELECT DISTINCT ',{ "IdAddress":"'  +  ISNULL( CONVERT(VARCHAR, SUB.UadIdAddress) , ' ')  + '",' +
									'"IdTownship":"' + ISNULL( CONVERT(VARCHAR, SUB.UadIdTownship) , ' ') + '",' +
									'"IdProvince":"' + ISNULL( CONVERT(VARCHAR, pr.IdProvince) , ' ') + '",' +
									'"Province":"' + ISNULL( CONVERT(VARCHAR, pr.ProvinceName) , ' ') + '",' +
									'"Township":"' + ISNULL( CONVERT(VARCHAR, tw.TownshipName) , ' ') + '",' +
									'"HeaderCode":"' + ISNULL( CONVERT(VARCHAR, tw.HeaderCode) , ' ') + '",' +
									'"IdAccount":"' + ISNULL( CONVERT(VARCHAR, SUB.UadIdAccount) , ' ') + '",' +
									'"IdCountry":"' + ISNULL( CONVERT(VARCHAR, SUB.UadIdCountry) , ' ') + '",' +
									'"FullName":"' +  dbo.fnt_String_Escape(ISNULL( CONVERT(VARCHAR, REPLACE(SUB.UadFullName,'"','')),'') , 'json') + '",' +
									'"Address1":"' +  dbo.fnt_String_Escape(ISNULL( REPLACE(SUB.UadAddress1,'"',''), ' '),'json') + '",' +
									'"Address2":"' +  dbo.fnt_String_Escape(ISNULL( REPLACE(SUB.UadAddress2,'"',''), ' '),'json') + '",' +
									'"NirPhone":"' +  dbo.fnt_String_Escape(ISNULL( CONVERT(VARCHAR, SUB.UadNirPhone) , ' '),'json') + '",' +
									'"Phone":"' +  dbo.fnt_String_Escape(ISNULL( CONVERT(VARCHAR, SUB.UadPhone) , ' '),'json') + '",' +
									'"AdditionalInstructions":"' +  dbo.fnt_String_Escape(ISNULL( CONVERT(VARCHAR, REPLACE(SUB.UadAdditionalInstructions,'"','')) , ' '),'json') + '",' +
									'"Status":"' + ISNULL( CONVERT(VARCHAR, SUB.UadRowStatus) , ' ') + '",' +
									'"Token":"' + ISNULL( CONVERT(VARCHAR, SUB.UadTokenCreated) , ' ') + '",' +
									'"IdSettlement":"' + ISNULL( CONVERT(VARCHAR, SUB.UadIdSettlement) , '') + '",' +
									'"SettlementDescription":"' + ISNULL( st.Settlement , '') + '",' +
									'"IdDeliveryOption":"' + ISNULL( CONVERT(VARCHAR, SUB.UadIdDeliveryOption) , ' ') + '",' +
									'"DescriptionDeliveryOption":"' + ISNULL( cdo.Name , ' ') + '",' +
									'"IsTDA":"' + CASE WHEN dsc.TDA = 1 THEN 'TRUE' ELSE 'FALSE' END+ '",' +
									'"HasSDD":"' + CASE WHEN dsc.SDD = 1 THEN 'TRUE' ELSE 'FALSE' END+ '",' +
									'"Hub":"' + ISNULL(dsc.Hub,'') + '",' +
									'"IdVisitPointByClientPortfolio":"' +   ISNULL( CONVERT(VARCHAR, SUB.VisitPointByClientPortfolioId) , ' ')  
									+'"}'
				FROM UserAddress SUB
				RIGHT JOIN Township tw on tw.IdTownship = SUB.UadIdTownship
				RIGHT JOIN Province pr on pr.IdProvince = tw.IdProvince
                LEFT JOIN Settlement st ON st.IdSettlement = SUB.UadIdSettlement AND st.SettlementSatus= 1
                LEFT JOIN CatDeliveryOptions cdo ON cdo.IdDeliveryOption = SUB.UadIdDeliveryOption
                LEFT JOIN DeliveryBackOffice.dbo.DumpServiceCoverage dsc ON dsc.IdSettlement = st.IdSettlement AND dsc.RowStatus=1
				WHERE
				SUB.VisitPointByClientPortfolioId = @IdVisitPointByClientPortfolio
				AND
				SUB.UadIdAddress = @IdAddress
				AND SUB.UadRowStatus= 1
				FOR XML PATH('') 
			)
			, 1, 1, '' )
		),'')



    IF ( LEN(@jsonResult) = 0 )

    BEGIN

        -- ERROR messages for internal purposes ---------------

    --    SELECT 'Error' AS message,
				--'FALSE'	blnResult,
				--CAST(-1 AS VARCHAR(5)) IdResult,
				--CAST(500 AS VARCHAR(5)) StatusResult

        -------------------------------------------------------
        SET @jsonResult = (
								SELECT STUFF(( 
								SELECT ',{"IdResult": 400,' 
								+ '"Message":"No se encontraron registros."}' 
								FOR XML PATH(''), TYPE
								).value('.', 'VARCHAR(max)'),1,1,''
									  ) 
							)

    END
	
	END TRY

	BEGIN CATCH

				DECLARE @errorMessage NVARCHAR(100) = (SELECT CAST(ERROR_MESSAGE() AS VARCHAR(MAX)) AS ResultMessage);

        -- ERROR messages for internal purposes ---------------

        DECLARE @xmltmp xml = (
        SELECT 'Error' ,
				'FALSE'	,
				CAST(-1 AS VARCHAR(5)) ,
				CAST(500 AS VARCHAR(5)) ,
				CAST(ERROR_NUMBER() AS VARCHAR) ,
				CAST(ERROR_SEVERITY() AS VARCHAR) ,
				CAST(ERROR_STATE() AS VARCHAR) ,
				CAST(ERROR_PROCEDURE() AS VARCHAR) ,
				CAST(ERROR_LINE() AS VARCHAR) ,
				CAST(ERROR_MESSAGE() AS VARCHAR(MAX))
        FOR XML PATH(''), TYPE
        )
        PRINT CONVERT(NVARCHAR(MAX), @xmltmp)
        -------------------------------------------------------
								-- retornar mensaje de error
							SET @jsonResult = (
								SELECT STUFF(( 
								SELECT ',{"IdResult": 500,' 
								+ '"Message":"' + @errorMessage + '"}' 
								FOR XML PATH(''), TYPE
								).value('.', 'VARCHAR(max)'),1,1,''
									  ) 
							)

	END CATCH

	SELECT ('[' + @jsonResult +  ']') jsonResult

END;
