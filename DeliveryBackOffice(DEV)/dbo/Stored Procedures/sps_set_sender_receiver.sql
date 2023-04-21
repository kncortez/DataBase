USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[sps_set_sender_receiver]    Script Date: 21/04/2023 11:54:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-07-22>
-- Description:	<Cambiar la ubicación en rack de una guía>
-- =============================================
-- =============================================
-- Author:		<López, Marcos>
-- Create date: <2020-09-19>
-- Description:	<Control de insert y update>
-- =============================================
ALTER PROCEDURE [dbo].[sps_set_sender_receiver]
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
		@UserCreated NVARCHAR(50),
		@Estatus bit,
		@TypeId int=NULL,
		@HubId int=NULL
AS
BEGIN
	DECLARE @RInserted INT
	DECLARE @UniqueCode BIGINT 

	--Contador de datos
	DECLARE @Count INT
	SELECT @Count=COUNT(ID), @UniqueCode = MAX(UniqueCode) FROM [DeliveryBackOffice].[dbo].[SenderReceiver] WHERE CUI = @CUI

	BEGIN TRANSACTION

		BEGIN TRY
		    
			IF (@Count=0)
				BEGIN
					-- registrar nuevo sender / receiver

					-- Creación de código único
					SET @UniqueCode = ( SELECT
							ROUND(((9999999999 - 1111111111) * RAND() + 1111111111), 0))

					WHILE EXISTS (SELECT TOP 1
							1
						FROM SenderReceiver WITH (NOLOCK)
						WHERE UniqueCode = @UniqueCode)
					SET @UniqueCode = (SELECT
							ROUND(((9999999999 - 1111111111) * RAND() + 1111111111), 0))

					INSERT INTO [DeliveryBackOffice].[dbo].[SenderReceiver]
					([First_Name],[Last_Name],[Address],[Zone],[Town],[Department],[Phone],[Social_Security_ID],[Email],[CUI],[Latitude],[Longitude],[Entity_Type],[User_Created],[Date_Created],[Estatus],[CatTypeSenderReceiverId],[HubLogisticId],[UniqueCode]) 
					VALUES 
					(@FirstName,@LastName,@Address,@Zone,@Town,@Department,@Phone,@SocialSecurityID,@Email,@CUI,@Latitude,@Longitude,@EntityType,@UserCreated,GETDATE(),@Estatus,@TypeId,@HubId, @UniqueCode)

					SET @RInserted = @@ROWCOUNT
				END
			ELSE IF (@Count=1)
				BEGIN
					UPDATE [DeliveryBackOffice].[dbo].[SenderReceiver]
					SET [First_Name]=@FirstName, [Last_Name]=@LastName, [Address]=@Address, [Phone]=@Phone, [Entity_Type]=@EntityType, [Estatus]=@Estatus, [CatTypeSenderReceiverId]=@TypeId,[HubLogisticId]=@HubId
					WHERE [CUI]=@CUI
					SET @RInserted = @@ROWCOUNT
				END

		END TRY

		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@CUI AS 'CUI',
				'' 'UniqueCode'
			ROLLBACK TRANSACTION
		END CATCH;

		IF @@TRANCOUNT > 0
		BEGIN
			IF (@RInserted = 1)
				SELECT			  
					1 AS 'StatusCode',
					'Registro guardado correctamente' AS 'Description', 
					@@TRANCOUNT AS 'NumTransferID',
					@CUI AS 'CUI',
					@UniqueCode 'UniqueCode'
			ELSE
				SELECT			  
					0 AS 'StatusCode',
					'Cantidad de registros inconsistentes' AS 'Description', 
					@@TRANCOUNT AS 'NumTransferID',
					@CUI AS 'CUI',
					'' 'UniqueCode'

			COMMIT TRANSACTION;			
		END
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@CUI AS 'CUI',
				'' 'UniqueCode'
END