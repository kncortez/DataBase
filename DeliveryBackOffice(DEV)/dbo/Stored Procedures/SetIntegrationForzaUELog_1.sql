-- =============================================
-- Author:		<Tito Garcia>
-- Create date: <2025-07-03>
-- Description:	< Registrar errores en proceso de integración Forza y UE >
-- =============================================
-- Author:		<Tito Garcia>
-- Create date: <2025-07-29>
-- Description:	<Se agrega validación para verificar si ya existe el registro, si existe solo se actualiza>
-- =============================================
CREATE PROCEDURE [dbo].[SetIntegrationForzaUELog]
    @GuideSerie NVARCHAR(2),
    @GuideNumber INT,
    @Description NVARCHAR(MAX),
    @System NVARCHAR(50),
    @Token NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (
            SELECT 1 
            FROM [dbo].[IntegrationForzaUELog]
            WHERE GuideSerie = @GuideSerie
              AND GuideNumber = @GuideNumber
              AND [System] = @System
              AND RowStatus = 1
        )
        BEGIN
            UPDATE [dbo].[IntegrationForzaUELog]
            SET 
                [Description] = @Description,
                [TokenUpdated] = @Token,
                [DateUpdated] = GETDATE()
            WHERE GuideSerie = @GuideSerie
              AND GuideNumber = @GuideNumber
              AND [System] = @System
              AND RowStatus = 1;

            COMMIT TRANSACTION;

            SELECT
                CAST(1 AS BIT) AS blnResult,
                'Registro actualizado correctamente' AS resultMessage;
        END
        ELSE
        BEGIN
            INSERT INTO [dbo].[IntegrationForzaUELog]
               ([GuideSerie], [GuideNumber], [Description], [System],
                [RowStatus], [TokenCreated], [DateCreated],
                [TokenUpdated], [DateUpdated])
            VALUES
               (@GuideSerie, @GuideNumber, @Description, @System,
                1, @Token, GETDATE(),
                NULL, NULL);

            COMMIT TRANSACTION;

            SELECT
                CAST(1 AS BIT) AS blnResult,
                'Registro insertado correctamente' AS resultMessage;
        END

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        SELECT
            CAST(0 AS BIT) AS blnResult,
            ERROR_MESSAGE() AS resultMessage;
    END CATCH
END