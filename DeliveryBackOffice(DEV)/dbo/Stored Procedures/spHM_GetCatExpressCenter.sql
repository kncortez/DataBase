-- =============================================
-- Author:		<Alberto, Ixchop>  
-- Create date: <11-10-2022>
-- Description:	<Obtiene el catalogo de ExpressCenter en API movil>
-- =============================================
CREATE PROCEDURE spHM_GetCatExpressCenter
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @TranCounter INT;  
    SET @TranCounter = @@TRANCOUNT;  
    IF @TranCounter > 0  
        SAVE TRANSACTION SPClosureSettlementUnifiedRoutes
    ELSE  
		BEGIN TRANSACTION;  

	BEGIN TRY

		SELECT			  
			1 AS 'StatusCode',
			'Registros obtenidos' AS 'Description';
		SELECT 
			DescriptionOfClient 'Name',
			ContactName 'ContactName',
			Phone 'Phone',
			Email 'Email',
			TWS.IdTownship 'IdTownship',
			TWS.TownshipDescription 'TownshipDescription',
			PRV.IdProvince 'IdProvince',
			PRV.ProvinceDescription 'ProvinceDescription',
			TWS.HeaderCode 'HeaderCode',
			VPC.Address 'Address',
			STL.Settlement 'Settlement',
			STL.IdSettlement 'IdSettlement',
			VPC.CodeOfReference 'CodeOfReference'
		FROM DeliveryBackOffice.dbo.VisitPointClient VPC WITH(NOLOCK)
			JOIN DeliveryBackOffice.dbo.Settlement STL WITH(NOLOCK)
				ON VPC.IdSettlement = STL.IdSettlement 
			JOIN DeliveryBackOffice.dbo.Township TWS WITH(NOLOCK)
				ON TWS.IdTownship = STL.IdTownship
			JOIN DeliveryBackOffice.dbo.Province PRV WITH(NOLOCK)
				ON PRV.IdProvince = TWS.IdProvince
		WHERE IdKindOfVPClient = 1
		AND VPC.StatusClient=1;

		IF @TranCounter = 0  
			COMMIT TRANSACTION; 
	END TRY
	BEGIN CATCH
        IF @TranCounter = 0  
            ROLLBACK TRANSACTION;  
        ELSE IF XACT_STATE() <> -1  
                ROLLBACK TRANSACTION SPClosureSettlementUnifiedRoutes;  
		SELECT			  
			0 AS 'StatusCode',
			ERROR_MESSAGE() AS 'Description';
	END CATCH

	
END