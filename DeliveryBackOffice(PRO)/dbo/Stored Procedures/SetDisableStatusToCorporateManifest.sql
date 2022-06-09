

-- =============================================
-- Author:		<Michael Espinoza>
-- Create date: <2022-04-08>
-- Description:	<Anula un manifiesto corporativo Hermes Web>
-- =============================================

CREATE PROCEDURE [dbo].[SetDisableStatusToCorporateManifest]
    @IdManifest BIGINT, -- Id de manifiesto
    @Token NVARCHAR(50) -- Token de usuario que consulta

AS
BEGIN

    DECLARE @jsonResult NVARCHAR(MAX);
    DECLARE @Counter BIGINT;
    BEGIN TRANSACTION;

    BEGIN TRY

        UPDATE cmd
        SET cmd.RowStatus = 0,
            cmd.TokenUpdated = @Token,
            cmd.DateUpdated = GETDATE()
        FROM DeliveryBackOffice.dbo.CorporateManifestDetail cmd
        WHERE cmd.ManifestId = @IdManifest;

        UPDATE cm
        SET cm.RowStatus = 0,
            cm.TokenUpdated = @Token,
            cm.DateUpdated = GETDATE()
        FROM DeliveryBackOffice.dbo.CorporateManifest cm
        WHERE cm.IdManifest = @IdManifest;

        SET @Counter =
        (
            SELECT @@ROWCOUNT
        );

    END TRY
    BEGIN CATCH

        ROLLBACK TRANSACTION;

        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{									
								"Message":"' + ERROR_MESSAGE() + '",' + '"Status": 500' + '}'
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );

    END CATCH;

    IF (@@TRANCOUNT > 0)
    BEGIN
        COMMIT TRANSACTION;

        IF (@Counter <= 0)
        BEGIN
            SET @jsonResult =
            (
                SELECT STUFF(
                                (
                                    SELECT ',{									
								"Message":"Número de manifiesto no existente.",' + '"Status": 400' + '}'
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)'),
                                1,
                                1,
                                ''
                            )
            );
        END;
        ELSE
        BEGIN
            SET @jsonResult =
            (
                SELECT STUFF(
                                (
                                    SELECT ',{									
								"Message":"Manifiesto anulado exitosamente.",' + '"Status": 200' + '}'
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)'),
                                1,
                                1,
                                ''
                            )
            );
        END;
    END;


    SELECT ('[' + @jsonResult + ']') jsonResult;

END;
