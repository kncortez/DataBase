USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spws_SetTermsAndConditions]    Script Date: 9/03/2022 17:50:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alejandro,Rodríguez>
-- Create date: <2022-02-24>
-- Update date: <2022-02-24>
-- Description:	<Terminos y condiciones por usuario>
-- =============================================

ALTER PROCEDURE [dbo].[spws_SetTermsAndConditions]
    -- Add the parameters for the stored procedure here
    @Username VARCHAR(200),
    @IdAccount BIGINT,
    @Token VARCHAR(50),
    @TAC VARCHAR(10)
AS

BEGIN
	DECLARE @jsonResult NVARCHAR(MAX);
	DECLARE @IdResult INT;

	-- Determina si el usuario ya existe en la tabla
	DECLARE @IdTAC INT = (SELECT IdTACByUser FROM [dbo].[TermsAndConditionsByUser]
						   WHERE IdAccount = @IdAccount);
	-- Guarda el ID de los términos y condiciones actuales
	DECLARE @ActualTerms INT = (SELECT IdTAC FROM [dbo].[TermsAndConditions]
								WHERE RowStatus = 1)

	-- No existe				
	IF (@IdTAC IS NULL)
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY
			INSERT INTO [dbo].[TermsAndConditionsByUser]
				([TACId]
				,[IdAccount]
				,[TAC]
				,[RowStatus]
				,[TokenCreated]
				,[DateCreated]
				,[TokenUpdated]
				,[DateUpdated])
			VALUES
				((SELECT IdTAC FROM [dbo].[TermsAndConditions] 
				WHERE RowStatus = 1)
				,@IdAccount
				,1
				,1
				,@Token
				,GETDATE()
				,NULL
				,NULL)

		END TRY

		BEGIN CATCH
			SET @jsonResult =
			(
				SELECT STUFF(
				(
					SELECT ',{"IdResult":500,' + '"Message":"' + ERROR_MESSAGE() + '"}' FOR XML PATH(''), TYPE
				).value('.', 'varchar(max)'), 1, 1, '')
			);

			ROLLBACK TRANSACTION;
		END CATCH

		IF @@TRANCOUNT > 0
		BEGIN
			COMMIT TRANSACTION;

			SET @jsonResult =
			(
				SELECT STUFF(
				(
					SELECT ',{"IdResult":200, "Message":"Registro almacenado correctamente."}' FOR XML PATH(''), TYPE
				).value('.', 'varchar(max)'), 1, 1, '')
			);
		END
	END

	-- Ya ha aceptado términos y condiciones con anterioridad
	IF(@IdTAC IS NOT NULL)
	BEGIN
		
		-- Variable que determina si los términos aceptados son los actuales
		DECLARE @ActualTAC INT = (SELECT TAC FROM [dbo].[TermsAndConditionsByUser]
								WHERE IdTACByUser = @IdTAC
									AND TACId = @ActualTerms)
		
		-- No ha aceptado los términos actuales					
		IF(@ActualTAC IS NULL)
		BEGIN

			BEGIN TRANSACTION
			BEGIN TRY
				UPDATE [dbo].[TermsAndConditionsByUser]
				SET TACId = @ActualTerms
					,DateUpdated = GETDATE()
					,TokenUpdated = @Token
				WHERE IdTACByUser = @IdTAC
			END TRY

			BEGIN CATCH
				SET @jsonResult =
				(
					SELECT STUFF(
					(
						SELECT ',{"IdResult":500,' + '"Message":"' + ERROR_MESSAGE() + '"}' FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'), 1, 1, '')
				);
			END CATCH

			IF @@TRANCOUNT > 0
			BEGIN
				COMMIT TRANSACTION;

				SET @jsonResult =
				(
					SELECT STUFF(
					(
						SELECT ',{"IdResult":200, "Message":"Registro actualizado correctamente."}' FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'), 1, 1, '')
				);
			END

		END

		-- Ya ha aceptado los términos actuales
		ELSE
		BEGIN
			SET @jsonResult =
           (
				SELECT STUFF(
				(
					SELECT ',{"IdResult":200, "Message":"El registro ya existe."}' FOR XML PATH(''), TYPE
				).value('.', 'varchar(max)'), 1, 1, '')
		   );
		END
		   
	END

	SELECT  
               ('[' + @jsonResult + ']') jsonResult;

END;

