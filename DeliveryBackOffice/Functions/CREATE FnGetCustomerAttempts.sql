USE [DeliveryBackOffice]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FnGetCustomerAttempts](
	@IdSender INT,
    @IdCustomer INT
)
RETURNS INT
AS
BEGIN

	--Variable para almacenar la cantidad de intentos de entrega de un cliente
	DECLARE @Attempts INT
	--Variable para almacenar el tipo de cliente que genera la guía
	DECLARE @TipoCliente INT
	--Variable para almacenar el tipo de tarifario del cliente
	DECLARE @Tarifario INT

	--Verifica que exista IdSender y IdCustomer no exista
	IF ((@IdSender IS NOT NULL AND @IdSender != 0) AND (@IdCustomer IS NULL OR @IdCustomer = 0))
	BEGIN 

		--Asigna el IdCustomer
		SET @IdCustomer = (SELECT CustomerID FROM DeliveryBackOffice.dbo.VisitPointClient
						   WHERE CodeOfReference = @IdSender)

		--Selecciona el tipo de cliente que es
		SET @TipoCliente = (SELECT IdCustomerType FROM DeliveryBackOffice.dbo.Customer
							WHERE IdCustomer = @IdCustomer)

		--Cliente corporativo
		IF (@TipoCliente = 1)
		BEGIN

			SET @Tarifario = (SELECT RbcIdRate FROM DeliveryBackOffice.dbo.RatebyCustomer
							  WHERE RbcIdCustomer = @IdCustomer AND RbcRowStatus = 1 AND RbcCodeOfReference = @IdSender)

			--Si no existe tarifario en corporativo, toma el del cliente
			IF (@Tarifario IS NULL OR @Tarifario = 0)
			BEGIN

				SET @Tarifario = (SELECT RbcIdRate FROM DeliveryBackOffice.dbo.RatebyCustomer
								  WHERE RbcIdCustomer = @IdCustomer AND RbcRowStatus = 1)
			END

			SET @Attempts = (SELECT Attempt FROM DeliveryBackOffice.dbo.RateHeader
							 WHERE RheId = @Tarifario)

		END

		--Los demás clientes
		ELSE
		BEGIN

			SET @Attempts = 2

		END
	END

	--Verifica que vengan ambos datos
    ELSE IF ((@IdSender != 0 AND @IdSender IS NOT NULL) AND (@IdCustomer != 0 AND @IdCustomer IS NOT NULL))
	BEGIN

		--Selecciona el tipo de cliente que es
		SET @TipoCliente = (SELECT IdCustomerType FROM DeliveryBackOffice.dbo.Customer
							WHERE IdCustomer = @IdCustomer)

		--Cliente corporativo
		IF (@TipoCliente = 1)
		BEGIN

			SET @Tarifario = (SELECT RbcIdRate FROM DeliveryBackOffice.dbo.RatebyCustomer
							  WHERE RbcIdCustomer = @IdCustomer AND RbcRowStatus = 1 AND RbcCodeOfReference = @IdSender)

			--Si no existe tarifario en corporativo, toma el del cliente
			IF (@Tarifario IS NULL OR @Tarifario = 0)
			BEGIN

				SET @Tarifario = (SELECT RbcIdRate FROM DeliveryBackOffice.dbo.RatebyCustomer
								  WHERE RbcIdCustomer = @IdCustomer AND RbcRowStatus = 1)
			END

			SET @Attempts = (SELECT Attempt FROM DeliveryBackOffice.dbo.RateHeader
							 WHERE RheId = @Tarifario)

		END

		--Los demás clientes
		ELSE
		BEGIN

			SET @Attempts = 2

		END

	END		

	--Caso en el que exista IdCustomer pero no IdSender
	ELSE IF ((@IdSender = 0 OR @IdSender IS NULL) AND (@IdCustomer != 0 AND @IdCustomer IS NOT NULL))
	BEGIN

		--Ya que no se cuenta con un IdSender, solo es posible tomar el tarifario del cliente

		SET @Tarifario = (SELECT RbcIdRate FROM DeliveryBackOffice.dbo.RatebyCustomer
								  WHERE RbcIdCustomer = @IdCustomer AND RbcRowStatus = 1 AND RbcCodeOfReference IS NULL)
		
		--Verifica que el cliente si cuente con tarifario
		IF (@Tarifario IS NULL OR @Tarifario = 0)
		BEGIN

			SET @Attempts = (SELECT Attempt FROM DeliveryBackOffice.dbo.RateHeader
							 WHERE RheId = @Tarifario)

		END

		--Valor por defecto
		ELSE
		BEGIN

			SET @Attempts = 2

		END

	END
    
	RETURN @Attempts
 
END