USE [DeliveryBackOffice]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-07-22>
-- Description:	<Cambiar la ubicación en rack de una guía>
-- =============================================
CREATE PROCEDURE [dbo].[sps_set_sender_receiver]
		@FirstName NVARCHAR(100),
		@LastName NVARCHAR(100),
		@Address NVARCHAR(200),
		@Zone NVARCHAR(100),
		@Town NVARCHAR(100),
		@Department NVARCHAR(100),
		@Phone NVARCHAR(50),
		@SocialSecurityID NVARCHAR(200),
		@Email NVARCHAR(200),
		@CUI NVARCHAR(25),
		@Latitude NVARCHAR(40),
		@Longitude NVARCHAR(40),
		@EntityType TINYINT,
		@UserCreated NVARCHAR(50)
AS
BEGIN
	DECLARE @RInserted INT

	BEGIN TRANSACTION

		BEGIN TRY

			-- registrar nuevo sender / receiver
			INSERT INTO [DeliveryBackOffice].[dbo].[SenderReceiver] 
			([First_Name],[Last_Name],[Address],[Zone],[Town],[Department],[Phone],[Social_Security_ID],[Email],[CUI],[Latitude],[Longitude],[Entity_Type],[User_Created],[Date_Created]) 
			VALUES 
			(@FirstName,@LastName,@Address,@Zone,@Town,@Department,@Phone,@SocialSecurityID,@Email,@CUI,@Latitude,@Longitude,@EntityType,@UserCreated,GETDATE())

			SET @RInserted = @@ROWCOUNT

		END TRY

		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@CUI AS 'CUI'
			ROLLBACK TRANSACTION
		END CATCH;

		IF @@TRANCOUNT > 0
		BEGIN
			IF (@RInserted > 0)
				SELECT			  
					1 AS 'StatusCode',
					'Registro guardado correctamente' AS 'Description', 
					@@TRANCOUNT AS 'NumTransferID',
					@CUI AS 'CUI'
			ELSE
				SELECT			  
					0 AS 'StatusCode',
					'Registro no encontrado' AS 'Description', 
					0 AS 'NumTransferID',
					@CUI AS 'CUI'

			COMMIT TRANSACTION;			
		END
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@CUI AS 'CUI'
END
GO


