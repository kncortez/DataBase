
CREATE PROCEDURE dbo.SupportSetConfigurationExcGuides 
@GuideDate DATE
AS
BEGIN

    SELECT ord.DateCreated,
           ORD.Guide_Serie,
           ORD.Guide_Number,
           ORD.IdDeliveryOption,
           COP.Name,
           VPC.DescriptionOfClient,
           ST.OrderDescription
    FROM dbo.DeliveryOrder ORD WITH (NOLOCK)
        INNER JOIN dbo.VisitPointClient VPC WITH (NOLOCK)
            ON VPC.CodeOfReference = ORD.Receiver_ID
               AND VPC.IdKindOfVPClient = 1
               AND VPC.IdKindOfVPBusiness = 8
               AND VPC.StatusClient = 1
        INNER JOIN dbo.CatDeliveryOptions COP
            ON COP.IdDeliveryOption = ORD.IdDeliveryOption
        INNER JOIN dbo.StatusOrder ST
            ON ST.StatusOrderId = ORD.StatusOrderId
               AND ST.CatCheckpointTypeId != 3
    WHERE CONVERT(DATE, ORD.DateCreated) = @GuideDate
          AND ORD.IdDeliveryOption != 3;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE ORD
        SET ORD.Receiver_ID = 0
        FROM dbo.DeliveryOrder ORD WITH (NOLOCK)
            INNER JOIN dbo.VisitPointClient VPC WITH (NOLOCK)
                ON VPC.CodeOfReference = ORD.Receiver_ID
                   AND VPC.IdKindOfVPClient = 1
                   AND VPC.IdKindOfVPBusiness = 8
                   AND VPC.StatusClient = 1
        WHERE CONVERT(DATE, ORD.DateCreated) = @GuideDate
              AND ORD.IdDeliveryOption != 3;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH

        ROLLBACK TRANSACTION;

        SELECT ERROR_LINE(),
               ERROR_MESSAGE(),
               ERROR_NUMBER(),
               ERROR_PROCEDURE(),
               ERROR_STATE();
    END CATCH;

END;
GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[SupportSetConfigurationExcGuides] TO [cvaldes]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SupportSetConfigurationExcGuides] TO [ebarrios]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[SupportSetConfigurationExcGuides] TO [cvaldes]
    AS [dbo];

