-- =============================================
-- Author:		<Author,,Edelman Vásquez>
-- Create date: <Create Date,2022-07-14>
-- Description:	<Description, revisión de membresia o suscripción previo a compra>
-- =============================================
-- =============================================
-- Author:		<Author,,Edelman Vásquez>
-- Create date: <Create Date,2023-07-05>
-- Description:	<Description, quitar restricción que valdia que la suscripción ya este adquirida>
-- =============================================
CREATE PROCEDURE [dbo].[SPHWPRevisarMembresia]
    -- Add the parameters for the stored procedure here
    @IdAcount AS BIGINT ---- user
  , @IdSalePackage AS INT
  , @TypeSalePackage AS NVARCHAR(20) = 'MEMBERSHIP'
AS
BEGIN

    SET NOCOUNT ON;

    -- Variables estaticas "globales"
    DECLARE @ActiveStatus INT =
            (
                SELECT TOP 1
                       CSPS.IdCatSalesPackageStatus
                FROM [DeliveryBackOffice].[dbo].[CatSalesPackageStatus] CSPS WITH (NOLOCK)
                WHERE CSPS.SalesPackageStatusName = 'Activa' COLLATE Latin1_General_CI_AI
            );

    -- Variables de control de flujo
    DECLARE @Credencial INT = 0;
    DECLARE @ActiveMembershipId INT = 0;
    DECLARE @IdActiveSalePackage INT = 0;

    IF (@TypeSalePackage = 'MEMBERSHIP' COLLATE Latin1_General_CI_AI)
    BEGIN

        SELECT TOP 1
               @Credencial          = 1
             , @IdActiveSalePackage = mmbrshp.IdMembership
        FROM [DeliveryBackOffice].[dbo].[Membership] mmbrshp WITH (NOLOCK)
        WHERE mmbrshp.AccountId = @IdAcount
              AND mmbrshp.RowStatus = 1
              AND mmbrshp.CatMembershipStatusId = @ActiveStatus
              AND mmbrshp.CatMembershipId = @IdSalePackage;

    END;
    ELSE IF (@TypeSalePackage = 'SUBSCRIPTION' COLLATE Latin1_General_CI_AI)
    BEGIN



        SET @Credencial = 1;



    END;

    IF (ISNULL(@Credencial, 0) = 0)
        SET @Credencial = 0;
    IF (ISNULL(@IdActiveSalePackage, 0) = 0)
        SET @IdActiveSalePackage = 0;

    -- Variables de control de flujo
    DECLARE @JsonResponse NVARCHAR(MAX) = N'';

    IF (@Credencial > 0)
    BEGIN

        SET @JsonResponse =
        (
            SELECT STUFF((
                             SELECT '{{"IdResult":200,' + '"Message":"Es posible la adquisición." }'
                             FOR XML PATH(''), TYPE
                         ).value('.', 'varchar(max)')
                       , 1
                       , 1
                       , ''
                        )
        );

    END;
    ELSE
    BEGIN

        SET @JsonResponse =
        (
            SELECT STUFF((
                             SELECT '{{"IdResult":200,' + '"Message":"Es posible la adquicición." }'
                             FOR XML PATH(''), TYPE
                         ).value('.', 'varchar(max)')
                       , 1
                       , 1
                       , ''
                        )
        );

    END;

    IF (@JsonResponse IS NULL)
    BEGIN

        SET @JsonResponse =
        (
            SELECT STUFF((
                             SELECT '{{"IdResult":500,' + '"Message":"No es posible la adquicición" }'
                             FOR XML PATH(''), TYPE
                         ).value('.', 'varchar(max)')
                       , 1
                       , 1
                       , ''
                        )
        );

    END;

    SELECT ('[' + @JsonResponse + ']') JsonOutput;

END;