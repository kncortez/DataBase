
-- =============================================
-- Author:		<Alberto Ixchop>
-- Create date: <08-09-2022>
-- Description:	<Busca una guía dentro de una preparación de ruta de entrega>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_GetGuidesRoutePreparation]
	-- Add the parameters for the stored procedure here
	@Serie	NVARCHAR(2)
	,@Number INT
	,@RouteId INT = NULL
	,@DatePreparation DATE = NULL
	,@RoutePreparationId INT = NULL
	,@Reference NVARCHAR(150)=''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.	
	DECLARE @RecordExist BIT=0;
	DECLARE @BelongsToRoute bit=0;
	DECLARE @Msg_error NVARCHAR(100)='';

     IF(@Number=0)
		BEGIN
		
			SELECT TOP 1 @Number = Guide_Number
				From [dbo].[DeliveryOrder] WITH(NOLOCK)
					WHERE Ticket_Number = @Reference
		END;


	--DECLARE @RecordExist BIT=0;
	IF NOT ((@DatePreparation IS NOT NULL) AND (@RouteId IS NOT NULL)) AND @RoutePreparationId IS NULL
	BEGIN 
			SELECT
				2 'StatusCode'
			   ,'Invalid parameters' 'Description'
	END
	ELSE IF @RoutePreparationId IS NOT NULL
	BEGIN 
		--Verificando registros existentes para parámetro routeid
		SET @RecordExist= (SELECT TOP 1 1 FROM RoutePreparation RP WITH(NOLOCK) WHERE RP.IdRoutePreparation=@RoutePreparationId);
		--Verificando SI LA GUÍA PERTENECE AL ROUTEPREPARATION
		SELECT TOP 1 @BelongsToRoute=1 FROM DBO.RoutePreparation RP WITH(NOLOCK)
			INNER JOIN DBO.RoutePreparationDetail RPD WITH(NOLOCK)
			ON RPD.RoutePreparationId=RP.IdRoutePreparation
		WHERE RP.IdRoutePreparation =@RoutePreparationId
		AND RPD.Guide_Serie=@Serie AND RPD.Guide_Number=@Number;
		set @Msg_error='La guía no se encuentra asociada a la preparación indicada'
						
		
	END
	ELSE
	BEGIN 
		--Verificando registros existentes para parámetros @RouteId y @Datepreparation
		SET @RecordExist= (SELECT TOP 1 1 FROM RoutePreparation  WITH(NOLOCK) WHERE CatRouteId = @RouteId AND DateRoutePreparation = @DatePreparation);
		--Verificando SI LA GUÍA PERTENECE AL ROUTEPREPARATION
		SELECT TOP 1 @BelongsToRoute=1 FROM DBO.RoutePreparation RP WITH(NOLOCK)
			INNER JOIN DBO.RoutePreparationDetail RPD  WITH(NOLOCK)
			ON RPD.RoutePreparationId=RP.IdRoutePreparation
		WHERE RP.DateRoutePreparation =@DatePreparation and RP.CatRouteId=@RouteId
		AND RPD.Guide_Serie=@Serie AND RPD.Guide_Number=@Number;
		set @Msg_error='La guía no se encuentra asociada ruta y la fecha indicada'
	END
	

	IF @BelongsToRoute <> 1
	BEGIN 
		SELECT
			2 'StatusCode'
			,@Msg_error 'Description'
	END
	ELSE IF @RecordExist = 0 
	BEGIN
		SELECT
			2 'StatusCode'
			,'No se encontraron guías' 'Description'
	END
	ELSE
	IF @RecordExist <> 0
	BEGIN
		--TABLE 0 respuesta
		SELECT
			1 'StatusCode'
		   ,'Successfull' 'Description'
		--TABLE 1 Información de las guías en preparación de la ruta
		SELECT
			rpd.IdRoutePreparationDetail 'IdRoutePreparationDetail'
			,rpd.Guide_Serie 'GuideSerie'
			,rpd.Guide_Number 'GuideNumber'
			,COUNT(1) 'Pieces'
			,COALESCE(do.Pieces_Dry, 0) + COALESCE(do.Pieces_Cold, 0) 'PiecesTotal'
			,do.Receiver_Department 'Department'
			,do.Receiver_Town 'Town'
			,do.Receiver_Address 'Address'
			,rpd.GuideOrder 'GuideOrder'
		FROM RoutePreparation rp  WITH(NOLOCK)
		INNER JOIN RoutePreparationDetail rpd  WITH(NOLOCK)
			ON rpd.RoutePreparationId = rp.IdRoutePreparation				
		INNER JOIN RoutePreparationDetailPiece rpdp  WITH(NOLOCK)
			ON rpdp.RoutePreparationDetailId = rpd.IdRoutePreparationDetail				
		INNER JOIN DeliveryOrder do WITH(NOLOCK)
			ON rpd.Guide_Serie = do.Guide_Serie
				AND rpd.Guide_Number = do.Guide_Number
		WHERE 		
		(
			(@RoutePreparationId IS NOT NULL AND rp.IdRoutePreparation=@RoutePreparationId)
			OR
			(@RoutePreparationId IS NULL AND rp.CatRouteId = @RouteId AND rp.DateRoutePreparation = @DatePreparation)
		)
		AND rpd.Guide_Serie = @Serie AND RPD.Guide_Number=@Number
		AND rp.RowStatus = 1
		AND rpd.RowStatus = 1
		AND rpdp.RowStatus = 1
		GROUP BY IdRoutePreparationDetail
				,rpd.Guide_Serie
				,rpd.Guide_Number
				,do.Pieces_Dry
				,do.Pieces_Cold
				,do.Receiver_Department
				,do.Receiver_Town
				,do.Receiver_Address
				,rpd.GuideOrder
		ORDER BY COALESCE(rpd.GuideOrder, 999999) ASC ;
		--TABLE 2 Información de las piezas de la guía en preparación
		SELECT			
			rpd.Guide_Serie 'GuideSerie'
			,rpd.Guide_Number 'GuideNumber'
			,rpdp.PieceNumber 'PieceNumber'
			,rpdp.PieceType 'IsDry'
			,ISNULL(AD.ActId,0) 'ActCode'
		FROM RoutePreparation rp  WITH(NOLOCK)
		INNER JOIN RoutePreparationDetail rpd  WITH(NOLOCK)
			ON rpd.RoutePreparationId = rp.IdRoutePreparation				
		INNER JOIN RoutePreparationDetailPiece rpdp  WITH(NOLOCK)
			ON rpdp.RoutePreparationDetailId = rpd.IdRoutePreparationDetail				
		LEFT JOIN DBO.ActDetail AD WITH(NOLOCK)
					ON AD.GuideSerie=rpd.Guide_Serie
					AND AD.GuideNumber=RPD.Guide_Number
		WHERE 
		(
			(@RoutePreparationId IS NOT NULL AND rp.IdRoutePreparation=@RoutePreparationId)
			OR
			(@RoutePreparationId IS NULL AND rp.CatRouteId = @RouteId AND rp.DateRoutePreparation = @DatePreparation)
		)		
		AND
		rpd.Guide_Serie = @Serie AND RPD.Guide_Number=@Number
		AND rpd.RowStatus = 1
		AND rpdp.RowStatus = 1
		GROUP BY rpd.Guide_Serie
				,rpd.Guide_Number
				,rpdp.PieceNumber
				,rpdp.PieceType
				,AD.ActId;
		

		
	END


	




END