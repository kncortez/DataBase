-- =============================================
-- Author:		<Tito Garcia>
-- Create date: <2025-07-03>
-- Description:	< Registrar errores en proceso de integración Forza y UE >
-- =============================================
CREATE PROCEDURE [dbo].[SetIntegrationForzaUELog]
    @GuideSerie NVARCHAR(2),
    @GuideNumber INT,
    @Description nvarchar(max),
	@System NVARCHAR(50),
	@Token NVARCHAR(50)
AS 
BEGIN

    SET NOCOUNT ON

    BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @InsertedData AS TABLE (
			InsertedId BIGINT
		)

		INSERT INTO [dbo].[IntegrationForzaUELog]
           ([GuideSerie]
           ,[GuideNumber]
           ,[Description]
           ,[System]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
		OUTPUT inserted.IdIntegrationForzaUELog INTO @InsertedData(InsertedId)
		VALUES
           (@GuideSerie
           ,@GuideNumber
           ,@Description
           ,@System
           ,1
           ,@Token
           ,GETDATE()
           ,NULL
           ,NULL)

		IF ( EXISTS (SELECT TOP 1 1 FROM @InsertedData) )
		BEGIN

			COMMIT TRANSACTION;

			SELECT
				CAST(1 AS BIT) [blnResult],
				'Exito al registrar' [resultMessage]

		END
		ELSE
		BEGIN

			ROLLBACK TRANSACTION;
			
			SELECT
				CAST(0 AS BIT) [blnResult],
				'Error al registrar' [resultMessage]

		END
	END TRY
	BEGIN CATCH

		ROLLBACK TRANSACTION;
		
		SELECT
			CAST(0 AS BIT) [blnResult],
			ERROR_MESSAGE() [resultMessage]

	END CATCH

END