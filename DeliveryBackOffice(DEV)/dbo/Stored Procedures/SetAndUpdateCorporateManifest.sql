

-- =============================================
-- Author:		<Michael Espinoza>
-- Create date: <2022-04-20>
-- Description:	<Actualiza un manifiesto, remueve y agrega guias segun necesidad>
-- =============================================

CREATE PROCEDURE [dbo].[SetAndUpdateCorporateManifest]
    @IdManifest BIGINT,  -- Id de manifiesto
    @ManifestSerie NVARCHAR(2),
    @Token NVARCHAR(50), -- Token de usuario que consulta
    @CodeOfReference INT,
    @servicesToAdd TblCorporateManifestServices READONLY,
    @servicesToRemove TblCorporateManifestServices READONLY
AS
BEGIN

    BEGIN TRANSACTION;

    BEGIN TRY

        IF ((SELECT COUNT(*) FROM @servicesToRemove) > 0)
        BEGIN

            UPDATE cmd
            SET cmd.RowStatus = 0,
                cmd.TokenUpdated = @Token,
                cmd.DateUpdated = GETDATE()
            FROM DeliveryBackOffice.dbo.CorporateManifestDetail cmd
                JOIN @servicesToRemove sr
                    ON sr.GuideSerie = cmd.GuideSerie
                       AND sr.GuideNumber = cmd.GuideNumber
            WHERE cmd.ManifestId = @IdManifest;

        END;

        IF ((SELECT COUNT(*)FROM @servicesToAdd) > 0)
        BEGIN

            INSERT INTO DeliveryBackOffice.dbo.CorporateManifestDetail
            (
                [ManifestId],
                [GuideSerie],
                [GuideNumber],
                [TokenCreated],
                [DateCreated],
                [TokenUpdated],
                [DateUpdated],
                [RowStatus]
            )
            SELECT @IdManifest,
                   sta.GuideSerie,
                   sta.GuideNumber,
                   @Token,
                   GETDATE(),
                   NULL,
                   NULL,
                   1
            FROM @servicesToAdd sta
            WHERE NOT EXISTS
            (
                SELECT cmd.GuideNumber
                FROM DeliveryBackOffice.dbo.CorporateManifestDetail cmd
                WHERE cmd.GuideSerie = sta.GuideSerie 
					  AND cmd.GuideNumber = sta.GuideNumber
                      AND cmd.RowStatus = 1
            );

        END;

        UPDATE cm
        SET cm.TokenUpdated = @Token,
            cm.DateCreated = GETDATE()
        FROM DeliveryBackOffice.dbo.CorporateManifest cm
        WHERE cm.IdManifest = @IdManifest
              AND cm.ManifestSerie = @ManifestSerie;

    END TRY
    BEGIN CATCH

        ROLLBACK TRANSACTION;

        SELECT 500 'ErrorID',
               ERROR_MESSAGE() AS 'Error';

    END CATCH;

    IF (@@TRANCOUNT > 0)
    BEGIN
        COMMIT TRANSACTION;

        SELECT @IdManifest AS 'IdManifest',
               @ManifestSerie AS 'Manifest_Serie',
               @IdManifest AS 'Manifest_Number',
               vpc.DescriptionOfClient AS 'Sender_FirstName',
               vpc.Address AS 'Sender_Address',
               ISNULL(vpc.Zone, '') AS 'Sender_Zone',
               vpc.Town AS 'Sender_Town',
               vpc.Department AS 'Sender_Department',
               0 AS 'Consolidated_Number',
               ISNULL(vpc.Email, '') AS 'Sender_Email'
        FROM DeliveryBackOffice.dbo.VisitPointClient vpc
        WHERE vpc.CodeOfReference = @CodeOfReference;

        SELECT COUNT(*) AS 'GuidesCounter',
               SUM(ISNULL(do.Pieces_Cold, 0)) AS 'PiecesColdCounter',
               SUM(ISNULL(do.Pieces_Dry, 0)) AS 'PiecesDryCounter',
               SUM(ISNULL(do.Pieces_Cold, 0) + ISNULL(do.Pieces_Dry, 0)) AS 'TotalPieces'
        FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
            JOIN DeliveryBackOffice.dbo.CorporateManifestDetail cmd
                ON cmd.GuideSerie = do.Guide_Serie
                   AND cmd.GuideNumber = do.Guide_Number
                   AND cmd.RowStatus = 1
                   AND cmd.ManifestId = @IdManifest
        WHERE do.Sender_ID = @CodeOfReference;

        SELECT CONCAT(dop.GuideSerie, dop.GuideNumber, '-', dop.NoPiece) AS 'Piece',
               CONCAT(do.Receiver_FirstName, ' ', do.Receiver_LastName) AS 'ReceiverName',
               LEFT(do.Receiver_Address, 200) AS 'ReceiverAddress'
        FROM DeliveryBackOffice.dbo.DeliveryOrderPiece dop WITH (NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.CorporateManifestDetail cmd
                ON cmd.GuideSerie = dop.GuideSerie
                   AND cmd.GuideNumber = dop.GuideNumber
                   AND cmd.RowStatus = 1
            INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                ON do.Guide_Serie = dop.GuideSerie
                   AND do.Guide_Number = dop.GuideNumber
        WHERE cmd.ManifestId = @IdManifest
        ORDER BY dop.GuideNumber ASC;


    END;


END;