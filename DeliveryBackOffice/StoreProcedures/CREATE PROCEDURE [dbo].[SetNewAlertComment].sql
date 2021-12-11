USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[SetNewAlertComment]    Script Date: 09/12/2021 21:44:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2021-12-09>
-- Description:	< Ingresa comentarios respecto a una alerta >
-- =============================================
CREATE PROCEDURE [dbo].[SetNewAlertComment]
	@IdInternalUser INT,
	@UserNameInternalUser NVARCHAR(50),
	@TokenUser NVARCHAR(50),
	@Comment NVARCHAR(200),
	@IdAlert INT
AS
BEGIN

	DECLARE @InsertedComment INT = -1;

	BEGIN TRANSACTION
		BEGIN TRY
			INSERT INTO
			[DeliveryBackOffice].[dbo].[DeliveryOrderAlertDetail] 
			(author, username, comment, DeliveryOrderAlertId, RowStatus, TokenCreated, DateCreated)
			VALUES
			( @IdInternalUser, @UserNameInternalUser, @Comment, @IdAlert, 1, @TokenUser, GETDATE() )

			SET @InsertedComment = SCOPE_IDENTITY();
			
		END TRY
		BEGIN CATCH
			SELECT
				0 'IdStatus'
				,ERROR_MESSAGE() 'Description'
			ROLLBACK TRANSACTION
		END CATCH

		IF(@InsertedComment > 0)
		BEGIN
			SELECT
				1 'IdStatus'
				,'Comentarío ingresado' 'Description'
				,@InsertedComment 'IdComment'
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			SELECT
				0 'IdStatus'
				,'No se ingreso el comentarío' 'Description'
			ROLLBACK TRANSACTION
		END

	-- END TRANSACTION

END
GO


