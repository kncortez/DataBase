-- =============================================
-- Author:		<Bidcar Herrera>
-- Create date: <2023-07-24>
-- Description:	<Tipos de suscripciones para un cliente>
-- =============================================
CREATE PROCEDURE [dbo].[ClientSubscriptionFetcher]
	@IdAccount INT = 0
AS
BEGIN
    BEGIN TRY
		  SELECT '1'                              'StatusCode'
             , 'Datos obtenidos correctamente.' 'Description';
			 
		 
		 --%Descuento

	DECLARE  @ActiveProducts  TABLE 
	(
		StatusId INT,
		CatProductCategoryId INT,
		ProductId INT,
		ProductName NVARCHAR(50),
		ProductDescription NVARCHAR(300),
		IncludeCollect INT
	);	
	INSERT INTO @ActiveProducts
	EXEC ClientSubscriptionFetcher_Data
	@IdAccount=@IdAccount

	IF NOT EXISTS( SELECT 1 FROM @ActiveProducts WHERE StatusId<>1)
	BEGIN 
		SELECT 
			CatProductCategoryId AS CatTypeSubscriptionId,
			ProductId AS IdSubscription,
			ProductName AS SubscriptionName,
			ProductDescription AS SubscriptionDescription,
			IncludeCollect AS IncludeCollect
		FROM @ActiveProducts	
	END
	ELSE
	BEGIN
        SELECT '-1'            'StatusCode'
             ,ProductDescription 'Description'
			FROM  @ActiveProducts;
	END


		
    END TRY
    BEGIN CATCH

        SELECT '-1'            'StatusCode'
             , ERROR_MESSAGE() 'Description';
    END CATCH;
END;