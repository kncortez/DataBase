USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sps_set_Confirmation_of_delivery]    Script Date: 25/06/2020 18:25:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Bidcar, Herrera>
-- Create date: <2020-06-12>
-- Description:	<Confirmar entrega de guía>
-- =============================================
CREATE PROCEDURE [dbo].[sps_set_Confirmation_of_delivery]
		@Guide_Serie AS VARCHAR(2), --guide serie
		@Guide_Number AS INT, --guide number
		@DateOfDelivery VARCHAR(50),--Date of delivery
		@NameOfReceiver VARCHAR(200), --Name of receiver
		@TokenId AS VARCHAR(50) --token user
AS
BEGIN
	DECLARE @StatusId tinyint = 5 --Status of delivery 
	DECLARE @ValidateOperation BIGINT	
	BEGIN TRANSACTION
		BEGIN TRY			
			-- Actualizar registro de guía a último estado 
			UPDATE DeliveryBackOffice.dbo.DeliveryOrder
			SET StatusOrderId = @StatusId, --Status of delivery 			
			NameOfReceiver = @NameOfReceiver
			WHERE Guide_Serie = @Guide_Serie AND Guide_Number = @Guide_Number			
			
			-- Insertar nuevo estado de guía en tabla histórica
			INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
			([Guide_Serie], [Guide_Number], [StatusOrderId], [UserCreated], [DateCreated],[DateCreatedInSystem])			
			select @Guide_Serie, @Guide_Number, @StatusId, @TokenId,CONVERT(Datetime,@DateOfDelivery, 120), GETDATE()
			WHERE EXISTS
			(
			 SELECT 1 
			 FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK)			 
			  WHERE Guide_Serie = @Guide_Serie AND Guide_Number = @Guide_Number
			)
			
			SET @ValidateOperation = COALESCE(@@ROWCOUNT,0)
					
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
			if (@ValidateOperation >0 )
			 BEGIN
			 SELECT			  
				1 AS 'StatusCode',
				'Registros guardados correctamente' AS 'Description', 
				@ValidateOperation AS 'NumTransferID'
			 
			 select top 10 Guide_Serie + CAST(Guide_Number as varchar) Guide,Ticket_Number Ticket, Receiver_FirstName + ' '+ Receiver_LastName Name, Courier_Route Route, convert(varchar, Dispatched_Date, 103) RouteDate 
			 from DeliveryBackOffice.dbo.DeliveryOrder
			 
			 where Guide_Serie = @Guide_Serie and Guide_Number = @Guide_Number

			 print 'REGISTER EXISTS ' + CAST(COALESCE(@ValidateOperation,0) as varchar)
			 END
			else
			BEGIN
			SELECT 
				0 AS 'StatusCode',
				'El registro no existe' AS 'Description', 
				@ValidateOperation AS 'NumTransferID'
			print 'REGISTER NOT EXISTS ' + CAST(COALESCE(@ValidateOperation,0) as varchar)
			END
			COMMIT TRANSACTION;			
		END
END
GO


