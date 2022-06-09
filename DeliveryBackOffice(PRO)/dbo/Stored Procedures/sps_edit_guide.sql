

-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-10-14>
-- Description:	<Actualizar información de una guía>
-- =============================================
CREATE PROCEDURE [dbo].[sps_edit_guide]
		@GuideSerie AS VARCHAR(2),
		@GuideNumber AS INT,
		@Address NVARCHAR(600),
		@Phone NVARCHAR(100),
		@Zone NVARCHAR(100),
		@Town NVARCHAR(100),
		@Department NVARCHAR(100),
		@IsConfirmed BIT,
		@Token NVARCHAR(50),
		@Instructions NVARCHAR(200),
		@changeAddressBySMS BIT,
		@PreviousAddress NVARCHAR(200),
		@LstNameReceiver NVARCHAR(200),
		@LstPhoneReceiver NVARCHAR(200)
AS
BEGIN
	DECLARE @RModified INT

	BEGIN TRANSACTION

		BEGIN TRY
			BEGIN
				
				IF (@IsConfirmed = 1)
				BEGIN
					-- Actualizar datos para confirmación de entrega
					UPDATE DeliveryBackOffice.dbo.DeliveryOrder
					SET Receiver_Address = @Address,
						Receiver_Phone = @Phone,
						Receiver_Zone = @Zone,
						Receiver_Town = @Town,
						Receiver_Department = @Department,
						Receiver_Updated = 1,
						Contact_Confirmed = @IsConfirmed,
						User_Contact = @Token,
						Date_Contact = GETDATE(),
						Contact_Instructions = @Instructions,
						ID_ContactIncident = NULL, -- borrar el ID de incidencia
						Receiver_Alternant_Address = CASE WHEN @changeAddressBySMS = 1 THEN
													 @PreviousAddress
													 ELSE
													 Receiver_Alternant_Address END
					WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber
							
					SET @RModified = @@ROWCOUNT
				END
				ELSE
				BEGIN
					-- Actualizar datos para NO confirmación de entrega
					UPDATE DeliveryBackOffice.dbo.DeliveryOrder
					SET Receiver_Address = @Address,
						Receiver_Phone = @Phone,
						Receiver_Zone = @Zone,
						Receiver_Town = @Town,
						Receiver_Department = @Department,
						Receiver_Updated = 1,
						Contact_Confirmed = @IsConfirmed,
						User_Contact = @Token,
						Date_Contact = GETDATE(),
						Contact_Instructions = @Instructions,
						Receiver_Alternant_Address = CASE WHEN @changeAddressBySMS = 1 THEN
													 @PreviousAddress
													 ELSE
													 Receiver_Alternant_Address END
					WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber
							
					SET @RModified = @@ROWCOUNT
				END

				--Log cambio de dirección SMS
				if (@changeAddressBySMS=1)
				BEGIN					
					INSERT INTO SMS_UpdatedAddressLog
					([GuideSerie], [GuideNumber], [OriginalAddress], [UpdatedAddress], [NameReceiver], [PhoneReceiver], [Token], [DateCreated])
					values
					(@GuideSerie,@GuideNumber,@PreviousAddress,@Address,@LstNameReceiver,@LstPhoneReceiver,@Token,GETDATE())				
				END

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
