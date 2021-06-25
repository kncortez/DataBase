USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sps_proof_ondelivery_fd]    Script Date: 17/06/2021 14:49:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Aquino, César>
-- Create date: <2021-03-23>
-- Description:	<Registrar prueba de entrega en sitio <API Delivery >>
-- =============================================
ALTER PROCEDURE [dbo].[sps_proof_ondelivery_fd]
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@PhoneNumber NVARCHAR(50),
	@ReceiverName NVARCHAR(200),
	@PhotoDryB64 VARCHAR(MAX),
	@PhotoColdB64 VARCHAR(MAX),
	@Latitude NVARCHAR(20),
	@Longitude NVARCHAR(20),
	@Accuracy NVARCHAR(20)
	,@TblDetail AS TblPaymentList 	readonly
	,@FullPayment decimal(12,2) =0
	, @Token varchar(50)
	, @Signature varchar(300)
	,@CODPayment  decimal(12,2) =0
AS
BEGIN
	-- control de inserciones para transacción
	DECLARE @RInserted INT
	-- tabla temporal para actualizar registros encontrados
	DECLARE @Table AS TABLE (ID INT)
	-- control de inserción de imagen en tabla de fotografías
	DECLARE @ID_Photo INT
	-- variables auxiliares para conversión de imagen de base64 a varbinary
	DECLARE @PhotoDryVB VARBINARY(MAX)
	DECLARE @PhotoColdVB VARBINARY(MAX)
	-- variable para obtener el módulo de origen de los datos
	DECLARE @DataOriginId INT
	-- variable para setear el nombre del módulo del cuál se desea obtener su id
	DECLARE @ModName NVARCHAR(50)

	BEGIN TRANSACTION

		BEGIN TRY

			-- asignar valor a la variable ModName
			SET @ModName = 'Courier App'
			
			-- convertir base64 a varbinary
			SET @PhotoDryVB = (CAST(N'' AS xml).value('xs:base64Binary(sql:variable("@PhotoDryB64"))', 'varbinary(max)'))
			SET @PhotoColdVB = (CAST(N'' AS xml).value('xs:base64Binary(sql:variable("@PhotoColdB64"))', 'varbinary(max)'))

			-- buscar registros de tabla de entregas
			INSERT INTO @Table
			SELECT
				da.ID
			FROM DeliveryBackOffice.dbo.DeliveryAttempt da
				JOIN DeliveryBackOffice.dbo.SenderReceiver sr ON sr.ID = da.ID_Courier
			WHERE sr.Phone like '%' + @PhoneNumber + '%'
				AND da.Guide_Serie = @GuideSerie
				AND da.Guide_Number = @GuideNumber
				AND CONVERT(VARCHAR, da.Date_Created, 23) = CONVERT(VARCHAR, GETDATE(), 23)

			-- insertar foto y guardar ID para actualizar tabla de entregas
			INSERT INTO DeliveryBackOffice.dbo.DeliveryProof 
			(Guide_Serie, Guide_Number, Date_Photo, Proof_Dry, Proof_Cold,PathSignature)
			VALUES (@GuideSerie, @GuideNumber, GETDATE(), @PhotoDryVB, @PhotoColdVB,@Signature)
			SET @ID_Photo = SCOPE_IDENTITY()

			IF (@ID_Photo > 0)
			BEGIN
				-- actualizar tabla de entregas
				UPDATE DeliveryBackOffice.dbo.DeliveryAttempt SET Delivered = 1, ID_Proof = @ID_Photo, Latitude = @Latitude, Longitude = @Longitude, Accuracy = @Accuracy WHERE ID IN (SELECT ID FROM @Table)
			
			    declare @StatusId int =(  select top 1 isnull(StatusOrderId,1) from dbo.DeliveryOrder where Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber)

				if @StatusId != 5 -- estado etregado
					begin
						-- actualizar tabla de registro de guías electrónicas
						UPDATE DeliveryBackOffice.dbo.DeliveryOrder SET NameOfReceiver = @ReceiverName, StatusOrderId = 5 WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber
			
				-- registrar estado en tabla de checkpoints
						INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail (Guide_Serie, Guide_Number, StatusOrderId, UserCreated, DateCreated, DateCreatedInSystem, Observations, Temperature_Celsius)
						VALUES (@GuideSerie, @GuideNumber, 5, 'sps_proof_ondelivery',GETDATE(), GETDATE(), NULL, NULL)
						SET @RInserted = @@ROWCOUNT

						SELECT
							@DataOriginId = cm.ModIdModule
						FROM DeliveryBackOffice.dbo.CatModule cm
						WHERE cm.ModName = @ModName
						
						INSERT INTO DeliveryBackOffice.dbo.ProcessedGuideCOD (GuideSerie, GuideNumber, CourierManId, DataOriginId)
						SELECT
							@GuideSerie AS 'GuideSerie', 
							@GuideNumber AS 'GuideNumber',
							ltpod.IdCourierman AS 'CourierManId',
							@DataOriginId AS 'DataOriginId'
						FROM DeliveryBackOffice.dbo.LogTokenPOD ltpod
						WHERE ltpod.LogTokenPOD = @Token
					end
			END

			if (@FullPayment> 0 OR @CODPayment >0) -- si se intenta registrar un pago
				begin
					declare @PNumber varchar(20) = (select concat( @GuideSerie , @GuideNumber))
				-- Guardar Costos
					EXEC [dbo].[SetPaymentCost]
						@TypeProduct = 1, --1 = Guia electronica
						@ProductNumber = @PNumber,
						@TblDetail = @TblDetail,
						@FullPayment = @FullPayment,
						@TypeCharge = 1, -- 1 = costo de envío
						@Token =@Token
						,@CODPayment =@CODPayment
				end

		END TRY

		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + CAST(@GuideNumber AS VARCHAR) AS 'Guide'
			ROLLBACK TRANSACTION
		END CATCH;

		IF @@TRANCOUNT > 0
		BEGIN
			IF (@RInserted > 0)
				SELECT			  
					1 AS 'StatusCode',
					'Registro guardado correctamente' AS 'Description', 
					CONVERT(BIGINT, @@TRANCOUNT) AS 'NumTransferID',
					@GuideSerie + CAST(@GuideNumber AS VARCHAR) AS 'Guide'
			ELSE
				SELECT			  
					1 AS 'StatusCode',
					'Registro no encontrado' AS 'Description', 
					CONVERT(BIGINT,0) AS 'NumTransferID',
					@GuideSerie + CAST(@GuideNumber AS VARCHAR) AS 'Guide'

			COMMIT TRANSACTION;			
		END
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + CAST(@GuideNumber AS VARCHAR) AS 'Guide'
END



GO


