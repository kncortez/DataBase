-- =============================================
-- Author:		<Sazo, Cesar>
-- Create date: <26/01/2022>
-- Description:	<Asignar tarifa por punto de visita>
-- =============================================
CREATE PROCEDURE [dbo].[spgAssignRatePerVPC]
	@CodeOfReference AS INT = 0
	,@IdRate         AS INT = 0
	,@Token          AS NVARCHAR(50) = ''
AS
BEGIN

DECLARE @IdRatebyCustomerAssigment AS BIGINT = -1

IF (@Token ='' AND LEN(@Token)<=0)
BEGIN
    SELECT 'FALSE' [blnResult],
		CAST(@IdRatebyCustomerAssigment AS VARCHAR(50)) [IdRCAResult],
		CAST(412 AS VARCHAR(50)) [IdResult],
		'' AS [ErrorNumber],
		'' AS [ErrorSeverity],
		'' AS [ErrorState],
		'' AS [ErrorProcedure],
		'' AS [ErrorLine],
		'Parámetro ' + '"Token"' + ' Obligatorio' AS [Message]
RETURN 0
END

IF (@IdRate <= 0 )
BEGIN
  SELECT 'FALSE' [blnResult],
		CAST(@IdRatebyCustomerAssigment AS VARCHAR(50)) [IdRCAResult],
		CAST(412 AS VARCHAR(50)) [IdResult],
		'' AS [ErrorNumber],
		'' AS [ErrorSeverity],
		'' AS [ErrorState],
		'' AS [ErrorProcedure],
		'' AS [ErrorLine],
		'Parámetro ' + '"IdRate"' + ' Obligatorio' AS [Message]
RETURN 0
END

IF (@CodeOfReference <= 0 )
BEGIN
 SELECT 'FALSE' [blnResult],
		CAST(@IdRatebyCustomerAssigment AS VARCHAR(50)) [IdRCAResult],
		CAST(412 AS VARCHAR(50)) [IdResult],
		'' AS [ErrorNumber],
		'' AS [ErrorSeverity],
		'' AS [ErrorState],
		'' AS [ErrorProcedure],
		'' AS [ErrorLine],
		'Parámetro ' + '"CodeOfReference"' + ' Obligatorio' AS [Message]
RETURN 0
END

BEGIN TRANSACTION
	BEGIN TRY

	--validar si existe mismo idcliente y idrate activo NO HACER NADA
	SET @IdRatebyCustomerAssigment  = (SELECT TOP (1) rbc.RbcId
										FROM dbo.RatebyCustomer rbc 
										WHERE  rbc.RbcRowStatus = 'TRUE'
										AND rbc.RbcIdRate = @IdRate
										AND rbc.RbcCodeOfReference = @CodeOfReference
										ORDER BY rbc.RbcTokenCreated DESC )
	
	SET @IdRatebyCustomerAssigment = ISNULL(@IdRatebyCustomerAssigment,-1)

	--SINO EXISTE  SE ACTUALIZA Y SE CREA ASIGNACION
	IF (@IdRatebyCustomerAssigment < 0)
	BEGIN

		--Guardamos el log del nuevo registro a ingresar
		DECLARE @IdCustomer_SP INT = (SELECT TOP 1 vpc.CustomerID
									 FROM dbo.VisitPointClient vpc
									 WHERE CodeOfReference = @CodeOfReference
									 AND StatusClient = 1)
		DECLARE @CodeOfReference_SP INT = @CodeOfReference
		DECLARE @OriginalRateId_SP INT = (SELECT TOP (1) rbc.RbcIdRate
											FROM dbo.RatebyCustomer rbc 
											WHERE  rbc.RbcRowStatus = 'TRUE'
											AND rbc.RbcCodeOfReference = @CodeOfReference )
		DECLARE @NewRateId_SP INT = @IdRate

		IF (@OriginalRateId_SP <= 0)
			BEGIN
				SET @OriginalRateId_SP = NULL
			END

		EXECUTE [dbo].[sphdSetRateLog] 
		   @IdCustomer = @IdCustomer_SP
		  ,@CodeOfReference = @CodeOfReference_SP
		  ,@TokenCreated = @Token
		  ,@ModuleCreated = 'Puntos de visita'
		  ,@OriginalRateId = @OriginalRateId_SP
		  ,@NewRateId = @NewRateId_SP
		--Fin guardar log del nuevo registro

		--Deshabilitar antiguas asignaciones
		UPDATE DeliveryBackOffice.dbo.RatebyCustomer
		SET RbcRowStatus = 0
		,RbcTokenUpdated = @Token
		,RbcDateUpdated = GETDATE()
		WHERE RbcCodeOfReference = @CodeOfReference

		--Nueva asignaciòn
		INSERT INTO DeliveryBackOffice.dbo.RatebyCustomer
		([RbcIdRate], [RbcIdCustomer], [RbcRowStatus], [RbcTokenCreated], [RbcDateCreated],[RbcCodeOfReference])
		VALUES
		(@IdRate,@IdCustomer_SP,1,@Token,GETDATE(),@CodeOfReference)

		SET @IdRatebyCustomerAssigment =  SCOPE_IDENTITY()
	END 


END TRY
	BEGIN CATCH		
				SELECT 'FALSE'	[blnResult]
				,-1 [IdRCAResult]
				,CAST(500 AS VARCHAR(5)) [IdResult]
				,CAST(ERROR_NUMBER() AS VARCHAR) AS [ErrorNumber]
				,CAST(ERROR_SEVERITY() AS VARCHAR) AS [ErrorSeverity]
				,CAST(ERROR_STATE() AS VARCHAR) AS [ErrorState]
				,CAST(ERROR_PROCEDURE() AS VARCHAR) AS [ErrorProcedure]
				,CAST(ERROR_LINE() AS VARCHAR) AS [ErrorLine]  
				,CAST(ERROR_MESSAGE() AS VARCHAR) AS [Message]
		ROLLBACK TRANSACTION
	END CATCH;
	IF @@TRANCOUNT > 0 
		BEGIN
			COMMIT TRANSACTION;
				SELECT 'TRUE' [blnResult],
					CAST(@IdRatebyCustomerAssigment AS VARCHAR(50)) [IdRCAResult],
					CAST(200 AS VARCHAR(50)) [IdResult],
					'' AS [ErrorNumber],
					'' AS [ErrorSeverity],
					'' AS [ErrorState],
					'' AS [ErrorProcedure],
					'' AS [ErrorLine],
					'Success - Asignación exitosa' AS [Message]
		END
	ELSE
	 BEGIN
		SELECT 'FALSE' [blnResult],
					CAST(@IdRatebyCustomerAssigment AS VARCHAR(50)) [IdRCAResult],
					CAST(500 AS VARCHAR(50)) [IdResult],
					'' AS [ErrorNumber],
					'' AS [ErrorSeverity],
					'' AS [ErrorState],
					'' AS [ErrorProcedure],
					'' AS [ErrorLine],
					'Error al generar asignación' AS [Message]
	 END
END