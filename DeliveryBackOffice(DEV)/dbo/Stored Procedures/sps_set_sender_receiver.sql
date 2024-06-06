-- =============================================
-- Author:      <Cano, Carlos>
-- Create date: <2020-07-22>
-- Description: <Cambiar la ubicación en rack de una guía>
-- =============================================
-- =============================================
-- Author:      <López, Marcos>
-- Create date: <2020-09-19>
-- Description: <Control de insert y update>
-- =============================================
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Update date: <2024-05-19>
-- Description: <Agregar filtro por pais, por defecto guardara GT>
-- =============================================
create procedure [dbo].[sps_set_sender_receiver]
		@FirstName nvarchar(100),
		@LastName nvarchar(100),
		@Address nvarchar(200),
		@Zone nvarchar(100),
		@Town nvarchar(100),
		@Department nvarchar(100),
		@Phone nvarchar(50),
		@SocialSecurityID nvarchar(200),
		@Email nvarchar(200),
		@CUI nvarchar(25),
		@Latitude nvarchar(40),
		@Longitude nvarchar(40),
		@EntityType tinyint,
		@UserCreated nvarchar(50),
		@Estatus bit,
		@TypeId int=NULL,
		@HubId int=NULL,
        @IdCountry NVARCHAR(2) = 'GT'
AS
BEGIN
	DECLARE @RInserted INT
	DECLARE @UniqueCode BIGINT 

	--Contador de datos
	DECLARE @Count INT

    SELECT @Count=COUNT(ID), @UniqueCode = MAX(UniqueCode) 
      FROM [DeliveryBackOffice].[dbo].[SenderReceiver] WITH(NOLOCK)
     WHERE CUI = @CUI
       AND IIF(IdCountry IS NULL, 'GT', IdCountry) = @IdCountry

    DECLARE @EmailFound INT = (SELECT COUNT(1) 
                                 FROM SenderReceiver WITH(NOLOCK)
                                WHERE CUI <> @CUI 
                                  AND Email = @Email)

	BEGIN TRANSACTION

		BEGIN TRY
		    
			IF (@Count=0 AND @EmailFound = 0)
				BEGIN
					-- registrar nuevo sender / receiver

					-- Creación de código único
					SET @UniqueCode = ( SELECT
							ROUND(((9999999999 - 1111111111) * RAND() + 1111111111), 0))

					WHILE EXISTS (SELECT TOP 1
							1
						FROM SenderReceiver WITH (NOLOCK)
						WHERE UniqueCode = CAST(@UniqueCode AS NVARCHAR(50)))
					SET @UniqueCode = (SELECT ROUND(((9999999999 - 1111111111) * RAND() + 1111111111), 0))

                    INSERT INTO [DeliveryBackOffice].[dbo].[SenderReceiver]
                                ([First_Name],[Last_Name],[Address],[Zone],[Town],[Department],[Phone],[Social_Security_ID],[Email],[CUI],[Latitude],[Longitude],[Entity_Type],[User_Created],[Date_Created],[Estatus],[CatTypeSenderReceiverId],[HubLogisticId],[UniqueCode],IdCountry)
                    VALUES (@FirstName,@LastName,@Address,@Zone,@Town,@Department,@Phone,@SocialSecurityID,@Email,@CUI,@Latitude,@Longitude,@EntityType,@UserCreated,GETDATE(),@Estatus,@TypeId,@HubId, @UniqueCode,@IdCountry)

					SET @RInserted = @@ROWCOUNT
				END
			ELSE IF (@Count=1 AND @EmailFound = 0)
				BEGIN
					UPDATE [DeliveryBackOffice].[dbo].[SenderReceiver]
					SET [First_Name]=@FirstName, [Last_Name]=@LastName, [Address]=@Address, [Phone]=@Phone, [Entity_Type]=@EntityType, [Estatus]=@Estatus, [CatTypeSenderReceiverId]=@TypeId,[HubLogisticId]=@HubId, Email=@Email
					WHERE [CUI]=@CUI
                      AND IIF(IdCountry IS NULL, 'GT', IdCountry) = @IdCountry
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

			INSERT INTO [DeliveryBackOffice].[dbo].[RoutePreparationLogError]
			(
			    [ErrorDescription],
			    [ErrorNumber],
			    [ErrorProcedure],
			    [ErrorLine],
			    [GuideSerie],
			    [GuideNumber],
			    [TokenCreated],
			    [DateCreated]
			)
			VALUES
			(   
				ERROR_MESSAGE(),     -- ErrorDescription - varchar(300)
			    NULL,     -- ErrorNumber - int
			    NULL,     -- ErrorProcedure - varchar(100)
			    ERROR_LINE(),     -- ErrorLine - int
			    NULL,     -- GuideSerie - nvarchar(2)
			    NULL,     -- GuideNumber - int
			    ERROR_PROCEDURE(),       -- TokenCreated - varchar(50)
			    GETDATE() -- DateCreated - datetime
			    )
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
				IF (@EmailFound = 0)
					SELECT			  
						0 AS 'StatusCode',
						'Cantidad de registros inconsistentes' AS 'Description', 
						@@TRANCOUNT AS 'NumTransferID',
						@CUI AS 'CUI',
						'' 'UniqueCode'
				ELSE 
					SELECT			  
						0 AS 'StatusCode',
						'Correo electrónico ya registrado, por favor escriba otro correo.' AS 'Description', 
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