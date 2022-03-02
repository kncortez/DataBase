USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spws_SetTermnsAndConditions]    Script Date: 1/03/2022 11:24:10 ******/
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

CREATE PROCEDURE [dbo].[spws_SetTermnsAndConditions]
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
	-- No existe				
	IF (@IdTAC IS NULL)
	BEGIN
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

		   -- Devuelve estado correcto al momento de insertar el registro
		   SET @IdResult = 200;
		   SET @jsonResult =
           (
				SELECT STUFF(
				(
					SELECT '{"IdResult":' + CAST(@IdResult AS VARCHAR(3)) + ',' + '"Message":"Registro de términos y condiciones éxitoso."}' FOR XML PATH(''), TYPE
				).value('.', 'varchar(max)'), 1, 1, '')
		   );
	END

	ELSE
	BEGIN
		SET @IdResult = 500;
		   SET @jsonResult =
           (
				SELECT STUFF(
				(
					SELECT '{"IdResult":' + CAST(@IdResult AS VARCHAR(3)) + ',' + '"Message":"Ya existe el registro"}' FOR XML PATH(''), TYPE
				).value('.', 'varchar(max)'), 1, 1, '')
		   );
	END

	SELECT @IdResult AS IdResult, 
               ('[{' + @jsonResult + ']') jsonResult;

END;