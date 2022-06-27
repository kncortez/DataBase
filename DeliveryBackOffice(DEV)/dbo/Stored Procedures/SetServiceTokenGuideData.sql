-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-01-03>
-- Description:	< Actualiza información de servicio para guía.>
-- =============================================
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-01-03>
-- Description:	< Se remueve el poder modificar departamento y municipio ya que puede causar revalorizaciones. >
-- =============================================
CREATE PROCEDURE [dbo].[SetServiceTokenGuideData]
	@GuideSerie NVARCHAR(2) = '',
	@GuideNumber INT = -1,
	@GuideToken NVARCHAR(50),
	@Latitude DECIMAL(18,15),
	@Longitude DECIMAL(18,15),
	@StartTime NVARCHAR(20),
	@EndTime NVARCHAR(20),

	@NewProvince NVARCHAR(100) = '',
	@NewTown NVARCHAR(100) = '',
	@NewZone NVARCHAR(100) = '',
	@NewAddress NVARCHAR(600) = '',
	@NewTownshipID INT = -1,
	@NewSettlementID BIGINT = -1
AS
BEGIN
	-- Variables de control de flujo
	DECLARE @IsDelivery AS BIT = 0;
	DECLARE @IsPickup AS BIT = 0;
	DECLARE @IsVisitPoint AS BIT = 0;
	DECLARE @VisitPointExists AS BIT = 0;

	-- Variables de control de cambios
	DECLARE @UpdatedSDFG BIT = 0;
	DECLARE @UpdatedDO BIT = 0;
	DECLARE @UpdatedVPC BIT = 0;

	-- Variables de respuesta
	DECLARE @jsonResult NVARCHAR(MAX);

	SET @IsDelivery = (
		SELECT [IsDelivery] 
		FROM [dbo].[ServiceDataForGuide] SDFG WITH(NOLOCK)
		WHERE SDFG.GuideToken = @GuideToken
	);
	IF (@IsDelivery = 1) -- Servicio es de entrega
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY
			UPDATE [dbo].[ServiceDataForGuide]
			SET 
				DateUsed = GETDATE(),
				Latitude = @Latitude,
				Longitude = @Longitude,
				ProviderModule = (SELECT [ModIdModule] FROM [CatModule] WHERE [ModName]LIKE'%Landing Delivery Page%'),
				TokenUpdated = 'SYS-HERMESROUTESLanding',
				DateUpdated = GETDATE()
			FROM [dbo].[ServiceDataForGuide] SDFG
			INNER JOIN [dbo].[DeliveryOrder] DO WITH(NOLOCK)
			ON DO.Guide_Serie = SDFG.GuideSerie AND DO.Guide_Number = SDFG.GuideNumber
			WHERE SDFG.GuideToken = @GuideToken
			AND DO.StatusOrderId IN (1,2,10,11,15) -- Solicitado, Recolectado, En ruta, En Inventario, Arribó a las instalaciones, Generado

			IF @@ROWCOUNT > 0
			BEGIN
				SET @UpdatedSDFG = 1
			END
		
			-- Si se altera la dirección del servicio 
			IF(/*ISNULL(@NewProvince,'')!='' AND ISNULL(@NewTown,'')!='' AND*/ ISNULL(@NewAddress,'')!='' /*AND ISNULL(@NewTownshipID,-1)!=-1*/ )
			BEGIN
				UPDATE [dbo].[DeliveryOrder]
				SET 
					Receiver_Address = @NewAddress
					,Receiver_Zone = IIF( ISNULL(@NewZone,'')!='', @NewZone, Receiver_Zone )
				FROM [dbo].[ServiceDataForGuide] SDFG
				INNER JOIN [dbo].[DeliveryOrder] DO WITH(NOLOCK)
				ON DO.Guide_Serie = SDFG.GuideSerie AND DO.Guide_Number = SDFG.GuideNumber
				WHERE SDFG.GuideToken = @GuideToken
				AND SDFG.IsDelivery = 1

				IF @@ROWCOUNT > 0
				BEGIN
					SET @UpdatedDO = 1
				END
			END

			IF (@@TRANCOUNT > 0 AND @UpdatedSDFG = 1)
			BEGIN
				COMMIT TRANSACTION;
				set @jsonResult =(
									SELECT STUFF(( 
									SELECT ',{"IdResult":200,' 
									+ '"Success":"Exito ingresando datos de entrega."}' 
									FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),1,1,'') )
				select ('[' + @jsonResult +  ']') jsonResult 
			END
			ELSE
			BEGIN
				set @jsonResult =(
									SELECT STUFF(( 
									SELECT '{{"IdResult":500,' 
									+ '"Error":"No se actualizaron los datos"}' 
									FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),1,1,'') )
				select ('[' + @jsonResult +  ']') jsonResultError 
				ROLLBACK TRANSACTION;
			END

		END TRY
		BEGIN CATCH
			set @jsonResult =(
								SELECT STUFF(( 
								SELECT '{{"IdResult":500,' 
								+ '"Error":"'+ERROR_MESSAGE()+'"}' 
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,'') )
			select ('[' + @jsonResult +  ']') jsonResultError 
			ROLLBACK TRANSACTION;
		END CATCH
	END
	ELSE
	BEGIN

		/* OTROS FLUJOS - POR IMPLEMENTAR */
		set @jsonResult =(
							SELECT STUFF(( 
							SELECT '{{"IdResult":500,' 
							+ '"Error":"No se actualizaron los datos"}' 
							FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)'),1,1,'') )
		select ('[' + @jsonResult +  ']') jsonResultError 

	END
END