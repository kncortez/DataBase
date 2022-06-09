-- =============================================
-- Author:		Michael Espinoza
-- Create date: 2021-10-26
-- Description:	Insert or update an address on table UserAddress
-- =============================================
CREATE PROCEDURE [dbo].[spws_set_clientPortfolioAddress] 
	-- Add the parameters for the stored procedure here
	  @UadIdAddress INT = 0,
	  @UadIdTownship INT,
    @UadIdAccount BIGINT,
    @UadIdCountry VARCHAR(20),
    @UadFullName VARCHAR(50),
    @UadAddress1 nVARCHAR(600),
    @UadAddress2 VARCHAR(200),
    @UadNirPhone VARCHAR(10),
    @UadPhone VARCHAR(100),
    @UadAdditionalInstructions VARCHAR(250),
    @Token VARCHAR(100),
    @VisitPointByClientPortfolioId BIGINT,
    @UadIdSettlement BIGINT,
    @UadIdDeliveryOption BIGINT

AS

BEGIN

-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @jsonResult NVARCHAR(MAX);
  DECLARE @errorMessage NVARCHAR(100);

IF(@UadIdAddress = 0)

BEGIN

BEGIN TRANSACTION

BEGIN TRY

INSERT INTO [dbo].[UserAddress]
           (
           [UadIdTownship]
					,[UadIdAccount]
					,[UadIdCountry]
					,[UadFullName]
					,[UadAddress1]
					,[UadAddress2]
					,[UadNirPhone]
					,[UadPhone]
					,[UadAdditionalInstructions]
					,[UadRowStatus]
					,[UadTokenCreated]
					,[UadDateCreated]
					,[UadTokenUpdated]
					,[UadDateUpdated]
					,[CodeOfReference]
					,[IdCityPlace]
					,[VisitPointByClientPortfolioId]
					,[UadIdSettlement]
					,[UadIdDeliveryOption]
          )
     VALUES
           (
			@UadIdTownship ,
			@UadIdAccount ,
			@UadIdCountry ,
			@UadFullName,
			@UadAddress1,
			@UadAddress2,
			@UadNirPhone,
			@UadPhone,
			@UadAdditionalInstructions,
			1,
			@Token,
			GETDATE(),
      NULL,
      NULL,
			NULL,
      NULL,
			@VisitPointByClientPortfolioId ,
			@UadIdSettlement ,
			@UadIdDeliveryOption 
		   )

		   SET @UadIdAddress = SCOPE_IDENTITY();

		   SET @jsonResult = ISNULL((
				SELECT STUFF(
					(
						SELECT DISTINCT ',{ "IdAddress":"'  +  CONVERT(VARCHAR, @UadIdAddress)  + '",' +
											'"IdTownship":"' + CONVERT(VARCHAR, @UadIdTownship) + '",' +
											'"IdProvince":"' + ISNULL( CONVERT(VARCHAR, pr.IdProvince) , ' ') + '",' +
											'"Province":"' + ISNULL( CONVERT(VARCHAR, pr.ProvinceName) , ' ') + '",' +
											'"Township":"' + ISNULL( CONVERT(VARCHAR, tw.TownshipName) , ' ') + '",' +
											'"HeaderCode":"' + ISNULL( CONVERT(VARCHAR, tw.HeaderCode) , ' ') + '",' +
											'"IdAccount":"' + CONVERT(VARCHAR, @UadIdAccount) + '",' +
											'"IdCountry":"' + CONVERT(VARCHAR, @UadIdCountry) + '",' +
											'"FullName":"' +  dbo.fnt_String_Escape(ISNULL( REPLACE(@UadFullName,'"',''),'') , 'json') + '",' +
											'"Address1":"' +  dbo.fnt_String_Escape(ISNULL( REPLACE(@UadAddress1,'"',''), ' '),'json') + '",' +
											'"Address2":"' +  dbo.fnt_String_Escape(ISNULL( REPLACE(@UadAddress2,'"',''), ' '),'json') + '",' +
											'"NirPhone":"' +  dbo.fnt_String_Escape(ISNULL( CONVERT(VARCHAR, @UadNirPhone) , ' '),'json') + '",' +
											'"Phone":"' +  dbo.fnt_String_Escape(ISNULL( CONVERT(VARCHAR, @UadPhone) , ' '),'json') + '",' +
											'"AdditionalInstructions":"' +  dbo.fnt_String_Escape(ISNULL( CONVERT(VARCHAR, REPLACE(@UadAdditionalInstructions,'"','')) , ' '),'json') + '",' +
											'"Status":"' + ISNULL( CONVERT(VARCHAR, 1) , ' ') + '",' +
											'"Token":"' + ISNULL( CONVERT(VARCHAR, @Token) , ' ') + '",' +
											'"IdSettlement":"' + ISNULL( CONVERT(VARCHAR, @UadIdSettlement) , '') + '",' +
											'"SettlementDescription":"' + ISNULL( st.Settlement , '') + '",' +
											'"IdDeliveryOption":"' + ISNULL( CONVERT(VARCHAR, @UadIdDeliveryOption) , ' ') + '",' +
											'"DescriptionDeliveryOption":"' + ISNULL( cdo.Name , ' ') + '",' +
											'"IsTDA":"' + CASE WHEN dsc.TDA = 1 THEN 'TRUE' ELSE 'FALSE' END+ '",' +
											'"HasSDD":"' + CASE WHEN dsc.SDD = 1 THEN 'TRUE' ELSE 'FALSE' END+ '",' +
											'"Hub":"' + ISNULL(dsc.Hub,'') + '",' +
											'"IdVisitPointByClientPortfolio":"' +   ISNULL( CONVERT(VARCHAR, @VisitPointByClientPortfolioId) , ' ')  
											+'"}'
						FROM  Township tw  
						LEFT JOIN Province pr on pr.IdProvince = tw.IdProvince
						LEFT JOIN Settlement st ON st.IdSettlement = @UadIdSettlement AND st.SettlementSatus= 1
						LEFT JOIN CatDeliveryOptions cdo ON cdo.IdDeliveryOption = @UadIdDeliveryOption AND cdo.RowStatus = 1
						LEFT JOIN DeliveryBackOffice.dbo.DumpServiceCoverage dsc ON dsc.IdSettlement = st.IdSettlement AND dsc.RowStatus=1
						WHERE
						tw.IdTownship = @UadIdTownship
						
						FOR XML PATH('') 
					)
					, 1, 1, '' )
				),'')


END TRY

BEGIN CATCH	

  SET @errorMessage = (SELECT CAST(ERROR_MESSAGE() AS VARCHAR(MAX)) AS ResultMessage);

	SET @jsonResult = (
						SELECT STUFF(( 
							SELECT ',{"IdResult": 500,' 
									+ '"Message":"' + @errorMessage + '"}' 
							FOR XML PATH(''), TYPE ).value('.', 'VARCHAR(max)'),1,1,'') 
					   )

ROLLBACK TRANSACTION

END CATCH;

IF @@TRANCOUNT > 0 

BEGIN

COMMIT TRANSACTION;

END

END

ELSE

BEGIN

BEGIN TRANSACTION

BEGIN TRY

UPDATE [dbo].[UserAddress]
   SET [UadIdTownship] = @UadIdTownship
      ,[UadFullName] = @UadFullName
      ,[UadAddress1] = @UadAddress1
      ,[UadAddress2] = @UadAddress2
      ,[UadPhone] = @UadPhone
      ,[UadAdditionalInstructions] = @UadAdditionalInstructions
      ,[UadTokenUpdated] = @Token
      ,[UadDateUpdated] = GETDATE()
      ,[UadIdSettlement] = @UadIdSettlement
      ,[UadIdDeliveryOption] = @UadIdDeliveryOption
 WHERE UadIdAddress = @UadIdAddress AND VisitPointByClientPortfolioId = @VisitPointByClientPortfolioId


 SET @jsonResult = ISNULL((
				SELECT STUFF(
					(
						SELECT DISTINCT ',{ "IdAddress":"'  +  CONVERT(VARCHAR, @UadIdAddress)  + '",' +
											'"IdTownship":"' + CONVERT(VARCHAR, @UadIdTownship) + '",' +
											'"IdProvince":"' + ISNULL( CONVERT(VARCHAR, pr.IdProvince) , ' ') + '",' +
											'"Province":"' + ISNULL( CONVERT(VARCHAR, pr.ProvinceName) , ' ') + '",' +
											'"Township":"' + ISNULL( CONVERT(VARCHAR, tw.TownshipName) , ' ') + '",' +
											'"HeaderCode":"' + ISNULL( CONVERT(VARCHAR, tw.HeaderCode) , ' ') + '",' +
											'"IdAccount":"' + CONVERT(VARCHAR, @UadIdAccount) + '",' +
											'"IdCountry":"' + CONVERT(VARCHAR, @UadIdCountry) + '",' +
											'"FullName":"' +  dbo.fnt_String_Escape(ISNULL( REPLACE(@UadFullName,'"',''),'') , 'json') + '",' +
											'"Address1":"' +  dbo.fnt_String_Escape(ISNULL( REPLACE(@UadAddress1,'"',''), ' '),'json') + '",' +
											'"Address2":"' +  dbo.fnt_String_Escape(ISNULL( REPLACE(@UadAddress2,'"',''), ' '),'json') + '",' +
											'"NirPhone":"' +  dbo.fnt_String_Escape(ISNULL( CONVERT(VARCHAR, @UadNirPhone) , ' '),'json') + '",' +
											'"Phone":"' +  dbo.fnt_String_Escape(ISNULL( CONVERT(VARCHAR, @UadPhone) , ' '),'json') + '",' +
											'"AdditionalInstructions":"' +  dbo.fnt_String_Escape(ISNULL( CONVERT(VARCHAR, REPLACE(@UadAdditionalInstructions,'"','')) , ' '),'json') + '",' +
											'"Status":"' + ISNULL( CONVERT(VARCHAR, 1) , ' ') + '",' +
											'"Token":"' + ISNULL( CONVERT(VARCHAR, @Token) , ' ') + '",' +
											'"IdSettlement":"' + ISNULL( CONVERT(VARCHAR, @UadIdSettlement) , '') + '",' +
											'"SettlementDescription":"' + ISNULL( st.Settlement , '') + '",' +
											'"IdDeliveryOption":"' + ISNULL( CONVERT(VARCHAR, @UadIdDeliveryOption) , ' ') + '",' +
											'"DescriptionDeliveryOption":"' + ISNULL( cdo.Name , ' ') + '",' +
											'"IsTDA":"' + CASE WHEN dsc.TDA = 1 THEN 'TRUE' ELSE 'FALSE' END+ '",' +
											'"HasSDD":"' + CASE WHEN dsc.SDD = 1 THEN 'TRUE' ELSE 'FALSE' END+ '",' +
											'"Hub":"' + ISNULL(dsc.Hub,'') + '",' +
											'"IdVisitPointByClientPortfolio":"' +   ISNULL( CONVERT(VARCHAR, @VisitPointByClientPortfolioId) , ' ')  
											+'"}'
						FROM  Township tw  
						LEFT JOIN Province pr on pr.IdProvince = tw.IdProvince
						LEFT JOIN Settlement st ON st.IdSettlement = @UadIdSettlement AND st.SettlementSatus= 1
						LEFT JOIN CatDeliveryOptions cdo ON cdo.IdDeliveryOption = @UadIdDeliveryOption AND cdo.RowStatus = 1
						LEFT JOIN DeliveryBackOffice.dbo.DumpServiceCoverage dsc ON dsc.IdSettlement = st.IdSettlement AND dsc.RowStatus=1
						WHERE
						tw.IdTownship = @UadIdTownship
						
						FOR XML PATH('') 
					)
					, 1, 1, '' )
				),'')


END TRY

BEGIN CATCH	

  SET @errorMessage = (SELECT CAST(ERROR_MESSAGE() AS VARCHAR(MAX)) AS ResultMessage);

	SET @jsonResult = (
						SELECT STUFF(( 
							SELECT ',{"IdResult": 500,' 
									+ '"Message":"' + @errorMessage + '"}' 
							FOR XML PATH(''), TYPE ).value('.', 'VARCHAR(max)'),1,1,'') 
					   )

ROLLBACK TRANSACTION

END CATCH;

IF @@TRANCOUNT > 0 

BEGIN

COMMIT TRANSACTION;

END

END

SELECT ('[' + @jsonResult +  ']') jsonResult

END;
