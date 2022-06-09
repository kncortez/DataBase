

-- =============================================
-- Author:		<Alberto,Ixchop>
-- Create date: <2021-12-09>
-- Description:	<Actualizar información desde la ventana de alertas>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_EditGuideForAlert]
		@GuideSerie AS VARCHAR(2),
		@GuideNumber AS INT,
		@SenderAddress NVARCHAR(200),
		@SenderPhone NVARCHAR(50),
		@SenderIndications NVARCHAR(1500),
		@ReceiverAddress NVARCHAR(600),
		@ReceiverPhone NVARCHAR(100),
		@ReceiverIndications NVARCHAR(1500),
		@tokenuser NVARCHAR(50)		

AS
BEGIN
	DECLARE @RModified INT

	BEGIN TRANSACTION

		BEGIN TRY
			BEGIN				
					-- Actualizar datos para confirmación de entrega
					UPDATE DeliveryBackOffice.dbo.DeliveryOrder
					SET Receiver_Address = @ReceiverAddress,
						Receiver_Phone = @ReceiverPhone,
						--User_Contact = @Token,
						--Date_Contact = GETDATE(),
						IndicationsToSendDestination=@ReceiverIndications,
						Sender_Address=@SenderAddress,
						Sender_Phone=@SenderPhone,
						IndicationsToSendOrigin=@SenderIndications,
						TokenUpdated=@tokenuser,
						DateUpdated=GETDATE()						
					WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber
							
					SET @RModified = @@ROWCOUNT



			END				
		END TRY

		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide'
			ROLLBACK TRANSACTION
		END CATCH;

		IF @@TRANCOUNT > 0
		BEGIN
			IF (@RModified > 0)
				SELECT			  
					1 AS 'StatusCode',
					'Registro guardado correctamente' AS 'Description', 
					@@TRANCOUNT AS 'NumTransferID',
					@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide'
			ELSE
				SELECT			  
					0 AS 'StatusCode',
					'Registro no encontrado' AS 'Description', 
					0 AS 'NumTransferID',
					@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide'

			COMMIT TRANSACTION;			
		END
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide'
END
