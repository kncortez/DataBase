USE [DeliveryBackOffice]
GO
/****** Object:  UserDefinedFunction [dbo].[FnGetCustomerAttempts]    Script Date: 22/03/2022 09:49:51 ******/
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
		SET @IdCustomer = (SELECT TOP 1
								CustomerID
							FROM DeliveryBackOffice.dbo.VisitPointClient
							WHERE CodeOfReference = @IdSender)

		--Selecciona el tipo de cliente que es
		SET @TipoCliente = (SELECT TOP 1
								IdCustomerType
							FROM DeliveryBackOffice.dbo.Customer
							WHERE IdCustomer = @IdCustomer)

		--Cliente corporativo
		IF (@TipoCliente = 1)
		BEGIN

			IF EXISTS
			(
				SELECT
					rbc.RbcIdRate
				FROM dbo.RateByCustomer rbc
				WHERE rbc.RbcIdCustomer = @IdCustomer
				AND rbc.RbcRowStatus = 1
				AND rbc.RbcCodeOfReference = @IdSender
			)
			BEGIN
				SET @Tarifario = (SELECT
									  RbcIdRate
								  FROM DeliveryBackOffice.dbo.RatebyCustomer
								  WHERE RbcIdCustomer = @IdCustomer
								  AND RbcRowStatus = 1
								  AND RbcCodeOfReference = @IdSender)
			END
			ELSE
			BEGIN
				SET @Tarifario = (SELECT
									  RbcIdRate
								  FROM DeliveryBackOffice.dbo.RatebyCustomer
								  WHERE RbcIdCustomer = @IdCustomer
								  AND RbcRowStatus = 1
								  AND RbcCodeOfReference = NULL)
			END

			SET @Attempts = (SELECT
								Attempt
							FROM DeliveryBackOffice.dbo.RateHeader
							WHERE RheId = @Tarifario)

		END		
		ELSE--Los demás clientes
		BEGIN

			SET @Attempts = 2

		END
	END

	--Verifica que vengan ambos datos
    ELSE IF ((@IdSender != 0 AND @IdSender IS NOT NULL) AND (@IdCustomer != 0 AND @IdCustomer IS NOT NULL))
	BEGIN

		--Selecciona el tipo de cliente que es
		SET @TipoCliente = (SELECT  TOP 1
								IdCustomerType
							FROM DeliveryBackOffice.dbo.Customer
							WHERE IdCustomer = @IdCustomer)

		--Cliente corporativo
		IF (@TipoCliente = 1)
		BEGIN

			IF EXISTS
			(
				SELECT
					rbc.RbcIdRate
				FROM dbo.RateByCustomer rbc
				WHERE rbc.RbcIdCustomer = @IdCustomer
				AND rbc.RbcRowStatus = 1
				AND rbc.RbcCodeOfReference = @IdSender
			)
			BEGIN
				SET @Tarifario = (SELECT
									  RbcIdRate
								  FROM DeliveryBackOffice.dbo.RatebyCustomer
								  WHERE RbcIdCustomer = @IdCustomer
								  AND RbcRowStatus = 1
								  AND RbcCodeOfReference = @IdSender)
			END
			ELSE
			BEGIN
				SET @Tarifario = (SELECT
									  RbcIdRate
								  FROM DeliveryBackOffice.dbo.RatebyCustomer
								  WHERE RbcIdCustomer = @IdCustomer
								  AND RbcRowStatus = 1
								  AND RbcCodeOfReference = NULL)
			END

			SET @Attempts = (SELECT
								Attempt
							FROM DeliveryBackOffice.dbo.RateHeader
							WHERE RheId = @Tarifario)

		END
		
		ELSE--Los demás clientes
		BEGIN

			SET @Attempts = 2

		END

	END
    
	RETURN @Attempts
 
END