-- =============================================
-- Author:		<Bidcar Herrera>
-- Create date: <2020-07-11>
-- Description:	<Cambiar el estado de una lista de guías>
-- =============================================
CREATE PROCEDURE [dbo].[spg_set_EditGuide]
        @guide AS VARCHAR(50),
		@value AS VARCHAR(600), 
		@type AS VARCHAR(200), 
		@TokenId AS VARCHAR(50)		
AS
BEGIN

	BEGIN TRANSACTION


		BEGIN TRY
		 IF (@type = 'Address')
          BEGIN
		    update DeliveryBackOffice.dbo.DeliveryOrder
			set DateUpdated = getdate()
			,TokenUpdated = @TokenId
			,Receiver_Updated  = 1
			,Receiver_Address = @value
			where Guide_Serie = substring(@guide,1,2)
			and Guide_Number = substring(@guide,3,LEN(@guide))
          END		 	
		  else IF (@type = 'Receiver_Phone')
          BEGIN
		    update DeliveryBackOffice.dbo.DeliveryOrder
			set DateUpdated = getdate()
			,TokenUpdated = @TokenId
			,Receiver_Updated  = 1
			,Receiver_Phone = left(@value,200)
			where Guide_Serie = substring(@guide,1,2)
			and Guide_Number = substring(@guide,3,LEN(@guide))
          END
		  else IF (@type = 'Zone')
          BEGIN
		    update DeliveryBackOffice.dbo.DeliveryOrder
			set DateUpdated = getdate()
			,TokenUpdated = @TokenId
			,Receiver_Updated  = 1
			,Receiver_Zone = left(@value,200)
			where Guide_Serie = substring(@guide,1,2)
			and Guide_Number = substring(@guide,3,LEN(@guide))
          END
		  else IF (@type = 'Town')
          BEGIN
		    update DeliveryBackOffice.dbo.DeliveryOrder
			set DateUpdated = getdate()
			,TokenUpdated = @TokenId
			,Receiver_Updated  = 1
			,Receiver_Town = left(@value,200)
			where Guide_Serie = substring(@guide,1,2)
			and Guide_Number = substring(@guide,3,LEN(@guide))
          END
		  else IF (@type = 'Department')
          BEGIN
		    update DeliveryBackOffice.dbo.DeliveryOrder
			set DateUpdated = getdate()
			,TokenUpdated = @TokenId
			,Receiver_Updated  = 1
			,Receiver_Department = left(@value,200)
			where Guide_Serie = substring(@guide,1,2)
			and Guide_Number = substring(@guide,3,LEN(@guide))
          END

		END TRY

		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID'
			ROLLBACK TRANSACTION
		END CATCH;

		IF @@TRANCOUNT > 0
		BEGIN
				SELECT			  
					1 AS 'StatusCode',
					'Registros guardados correctamente' AS 'Description', 
					0 AS 'NumTransferID'

			COMMIT TRANSACTION;			
		END
END
