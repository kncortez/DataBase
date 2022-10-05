-- =============================================
-- Author:		<Alberto, Ixchop>
-- Create date: <09-09-2022>
-- Description:	<Extrae una guía de una preparación de ruta vigente>
-- =============================================
CREATE PROCEDURE spHM_ExtractGuidePreparation
	-- Add the parameters for the stored procedure here
	@GuideSerie AS NVARCHAR(2),
	@GuideNumber AS INT,
	@RouteId INT = NULL,
	@DatePreparation DATE = NULL,
	@RoutePreparationId INT = NULL,
	@Token AS NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;



	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.	
	DECLARE @RecordExist BIT=0;
	DECLARE @BelongsToRoute bit=0;
	DECLARE @Msg_error NVARCHAR(100)='';
	--DECLARE @RecordExist BIT=0;
	IF NOT ((@DatePreparation IS NOT NULL) AND (@RouteId IS NOT NULL)) AND @RoutePreparationId IS NULL
	BEGIN 
			SELECT
				0 'StatusCode'
			   ,'Parámetros inválidos' 'Description'
	END
	ELSE IF @RoutePreparationId IS NOT NULL
	BEGIN 
		--Verificando registros existentes para parámetro routeid
		SET @RecordExist= (SELECT TOP 1 1 FROM RoutePreparation RP WHERE RP.IdRoutePreparation=@RoutePreparationId);
		--Verificando SI LA GUÍA PERTENECE AL ROUTEPREPARATION
		SELECT TOP 1 @BelongsToRoute=1 FROM DBO.RoutePreparation RP 
			INNER JOIN DBO.RoutePreparationDetail RPD ON RPD.RoutePreparationId=RP.IdRoutePreparation
		WHERE RP.IdRoutePreparation =@RoutePreparationId
		AND RPD.Guide_Serie=@GuideSerie AND RPD.Guide_Number=@GuideNumber;
		set @Msg_error='La guía no se encuentra asociada a la preparación indicada'
						
		
	END
	ELSE
	BEGIN 
		--Verificando registros existentes para parámetros @RouteId y @Datepreparation
		SET @RecordExist= (SELECT TOP 1 1 FROM RoutePreparation WHERE CatRouteId = @RouteId AND DateRoutePreparation = @DatePreparation);
		--Verificando SI LA GUÍA PERTENECE AL ROUTEPREPARATION
		SELECT TOP 1 @BelongsToRoute=1,@RoutePreparationId = RP.IdRoutePreparation FROM DBO.RoutePreparation RP 
			INNER JOIN DBO.RoutePreparationDetail RPD ON RPD.RoutePreparationId=RP.IdRoutePreparation
		WHERE RP.DateRoutePreparation =@DatePreparation and RP.CatRouteId=@RouteId
		AND RPD.Guide_Serie=@GuideSerie AND RPD.Guide_Number=@GuideNumber;
		set @Msg_error='La guía no se encuentra asociada a la ruta y la fecha indicada'
	END
	

	IF @BelongsToRoute <> 1
	BEGIN 
		SELECT
			0 'StatusCode'
			,@Msg_error 'Description'
	END
	ELSE IF @RecordExist = 0 
	BEGIN
		SELECT
			0 'StatusCode'
			,'No se encontraron guías' 'Description'
	END
	ELSE
	IF @RecordExist <> 0
	BEGIN
		SELECT
			1 'StatusCode'
			,'Extracción de guía correcta' 'Description'

		--Anulando preparación de guías

		UPDATE RPDP
		SET     
			TokenUpdated=@Token,
			DateUpdated= GETDATE(),
			RowStatus = 0
		FROM [DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece] RPDP 
		INNER JOIN[DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD ON RPDP.RoutePreparationDetailId=RPD.IdRoutePreparationDetail
		INNER JOIN [DeliveryBackOffice].[dbo].[RoutePreparation] RP
			ON RP.IdRoutePreparation=RPD.RoutePreparationId
		WHERE RP.IdRoutePreparation=@RoutePreparationId;

		UPDATE RPD
		SET     
			UserProcess = NULL,
			IsOpenProcess = 0,
			RowStatus = 0,
			TokenUpdated=@Token,
			DateUpdated= GETDATE()
		FROM [DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD
		INNER JOIN [DeliveryBackOffice].[dbo].[RoutePreparation] RP
			ON RP.IdRoutePreparation=RPD.RoutePreparationId
		WHERE RP.IdRoutePreparation=@RoutePreparationId;

		--Ejecutando sp que reversa el estádo de la guía
		EXEC [dbo].[sphd_setReversal] @GuideSerie,@GuideNumber, 'Reversando guía por motivo de extacción de guía de una preparación de rutas de entrega en hermes móvil',@Token
		
           
	END




END