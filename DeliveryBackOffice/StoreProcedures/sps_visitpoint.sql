USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sps_customer]    Script Date: 29/10/2020 11:11:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-10-29>
-- Description:	<Crea / actualiza información de un punto de venta>
-- =============================================
ALTER PROCEDURE [dbo].[sps_visitpoint]
	@IdToken NVARCHAR(50),
	@IdHermes INT, -- si es cero se hace update de los valores recibidos
	@Name NVARCHAR(100),
	@IdDenarius INT,
	@IdCustomer INT,
	@Address NVARCHAR(200),
	@Zone NVARCHAR(2),
	@Town NVARCHAR(100),
	@Department NVARCHAR(100),
	@Phone NVARCHAR(50),
	@Contact NVARCHAR(200),
	@Status BIT
AS
BEGIN
	DECLARE @Result_ID INT
	DECLARE @NewVisitpoint_ID INT
	DECLARE @IdCountry NVARCHAR(2)

	BEGIN TRANSACTION

		BEGIN TRY
			   
			-- insertar nuevo punto de venta
			IF (@IdHermes = 0)
			BEGIN
				
				-- Get new visitpoint id for current insert
				SET @NewVisitpoint_ID = (SELECT MAX(CodeOfReference) + 1 FROM [DeliveryBackOffice].[dbo].[VisitPointClient])
			
				-- Get country id for current insert
				SET @IdCountry = (SELECT [SSN_IdCountry] FROM [DenariusUser_Dev].[dbo].[LGN_LogByToken] WHERE SSN_IdToken = @IdToken)

				INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient]
					([CodeOfReference]
					,[DescriptionOfClient]
					,[StatusClient]
					,[CountryId]
					,[VisitPointId]
					,[TokenCreated]
					,[DateCreated]
					,[TokenUpdated]
					,[DateUpdated]
					,[CustomerID]
					,[Address]
					,[Zone]
					,[Town]
					,[Department]
					,[Phone]
					,[ContactName])
				VALUES
					(@NewVisitpoint_ID
					,@Name
					,@Status
					,@IdCountry
					,@IdDenarius
					,@IdToken
					,GETDATE()
					,NULL
					,NULL
					,@IdCustomer
					,@Address
					,@Zone
					,@Town
					,@Department
					,@Phone
					,@Contact)

				SET @Result_ID = SCOPE_IDENTITY()

			END
			-- actualizar información de puntos de venta existente
			ELSE
			BEGIN
				UPDATE [DeliveryBackOffice].[dbo].[VisitPointClient]
				SET DescriptionOfClient = @Name
					,[StatusClient] = @Status
					,[VisitPointId] = @IdDenarius
					,[TokenUpdated] = @IdToken
					,[DateUpdated] = GETDATE()
					,[Address] = @Address
					,[Zone] = @Zone
					,[Town] = @Town
					,[Department] = @Department
					,[Phone] = @Phone
					,[ContactName] = @Contact
				WHERE CodeOfReference = @IdHermes

				IF (@@ROWCOUNT > 0)
					SET @Result_ID = @IdHermes
				ELSE
					SET @Result_ID = 0
			END

		END TRY

		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				0 AS 'ID_Visitpoint'
			ROLLBACK TRANSACTION
		END CATCH;

		IF @@TRANCOUNT > 0
		BEGIN
			IF (@Result_ID > 0)
				SELECT			  
					1 AS 'StatusCode',
					'Registro guardado correctamente' AS 'Description', 
					CONVERT(BIGINT, @@TRANCOUNT) AS 'NumTransferID',
					@Result_ID AS 'ID_Visitpoint'
			ELSE
				SELECT			  
					0 AS 'StatusCode',
					'Registro no encontrado' AS 'Description', 
					CONVERT(BIGINT,0) AS 'NumTransferID',
					0 AS 'ID_Visitpoint'

			COMMIT TRANSACTION;			
		END
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				0 AS 'ID_Visitpoint'
END
GO


