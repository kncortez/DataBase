

-- =============================================
-- Author:		<Michael Espinoza>
-- Create date: <2022-04-01>
-- Description:	< Genera un manifiesto, actualiza el numero de manifiesto un grupo de guias>
-- =============================================

CREATE PROCEDURE [dbo].[GetManifestFromGuidesGroup]
    @GuidesGroup TblGuides READONLY, -- tabla de guias.
    @Token NVARCHAR(50),             -- Token usuario que consulta.
    @CodeOfReference INT,            -- Codigo de referencia de punto de visita.
    @IdAccount BIGINT
AS
BEGIN

    BEGIN TRANSACTION;

    BEGIN TRY

        DECLARE @ManifestSerie VARCHAR(10) = 'FM';
        DECLARE @ManifestNumber BIGINT;

        --Insert into table CorporateManifest--

        INSERT INTO [dbo].[CorporateManifest]
        (
            [ManifestSerie],
            [AccountId],
            [CodeOfReferenceId],
            [ManifestURL],
            [RowStatus],
            [TokenCreated],
            [DateCreated],
            [TokenUpdated],
            [DateUpdated]
        )
        VALUES
        (@ManifestSerie, @IdAccount, @CodeOfReference, NULL, 1, @Token, GETDATE(), NULL, NULL);

        DECLARE @IdManifest AS BIGINT = SCOPE_IDENTITY();

        SET @ManifestNumber = @IdManifest;

        --Insert into table CorporateManifestDetail for each guide in the group--

        INSERT INTO [dbo].[CorporateManifestDetail]
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
               gp.Guide_Serie,
               gp.Guide_Number,
               @Token,
               GETDATE(),
               NULL,
               NULL,
               1
        FROM @GuidesGroup gp;

    END TRY
    BEGIN CATCH

        ROLLBACK TRANSACTION;

        SELECT 500 'ErrorID',
               ERROR_MESSAGE() AS 'Error';

    END CATCH;

    IF @@TRANCOUNT > 0
    BEGIN

        COMMIT TRANSACTION;

        SELECT @IdManifest AS 'IdManifest',
               @ManifestSerie AS 'Manifest_Serie',
               @ManifestNumber AS 'Manifest_Number',
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
            INNER JOIN @GuidesGroup gp
                ON gp.Guide_Serie = do.Guide_Serie
                   AND gp.Guide_Number = do.Guide_Number;

        SELECT CONCAT(dop.GuideSerie, dop.GuideNumber, '-', dop.NoPiece) AS 'Piece',
               CONCAT(do.Receiver_FirstName, ' ', do.Receiver_LastName) AS 'ReceiverName',
               LEFT(do.Receiver_Address, 200) AS 'ReceiverAddress'
        FROM DeliveryBackOffice.dbo.DeliveryOrderPiece dop WITH (NOLOCK)
            INNER JOIN @GuidesGroup gp
                ON gp.Guide_Serie = dop.GuideSerie
                   AND gp.Guide_Number = dop.GuideNumber
            INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                ON do.Guide_Serie = dop.GuideSerie
                   AND do.Guide_Number = dop.GuideNumber
        ORDER BY dop.GuideNumber ASC;

    END;

END;
