
CREATE PROCEDURE Support_InsertDeliveryOrderPieces
    @GuideSerie NVARCHAR(10),   -- <<-- Nueva variable para la serie
    @GuideNumber BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Pieces INT;
    DECLARE @Counter INT = 1;
    DECLARE @StatusOrderId INT;

    -- Validamos que exista la guía y obtenemos el número de piezas
    IF NOT EXISTS (
        SELECT 1
        FROM deliveryorder WITH (NOLOCK)
        WHERE Guide_Number = @GuideNumber
          AND Guide_Serie = @GuideSerie
    )
    BEGIN
        RAISERROR('La guía no existe en deliveryorder con la serie indicada', 16, 1);
        RETURN;
    END;

    -- Obtenemos la cantidad de piezas y el StatusOrderId de la guía
    SELECT 
        @Pieces = Pieces_Dry,
        @StatusOrderId = StatusOrderId
    FROM deliveryorder WITH (NOLOCK)
    WHERE Guide_Number = @GuideNumber
      AND Guide_Serie = @GuideSerie;

    -- Si la guía existe pero no tiene piezas, no hacemos nada
    IF @Pieces IS NULL OR @Pieces <= 0
    BEGIN
        RAISERROR('La guía existe pero no tiene piezas configuradas', 16, 1);
        RETURN;
    END;

    -- Insertamos tantas piezas como indique Pieces_Dry
    WHILE @Counter <= @Pieces
    BEGIN
        INSERT INTO deliveryorderpiece (
            GuideSerie
            , GuideNumber
            , PiecePhysicalWeight
            , PieceHeight
            , PieceWidth
            , PieceLength
            , PieceWeight
            , Detail
            , Currency
            , Amount
            , DateCreated
            , PieceUpdated
            , DateUpdated
            , fragile
            , IsPickup
            , NoPiece
            , PieceHeightCheck
            , PieceWidthCheck
            , PieceLengthCheck
            , MassWeight
            , volumetricWeight
            , CategoryCheck
            , IsDry
            , StatusOrderId
            , CodeOfSeller
            , ParcelCode
            , ExternalPieceId
            , TokenRegistrationExternalCode
            , DateRegistrationExternalCode
            , AccountIdRegistrationExternalCode
            , IdStatusGuideByContainer
            , IsNewInContainer
        )
        VALUES (
            @GuideSerie        -- ahora se toma del parámetro
            , @GuideNumber     
            , 2.64             
            , 30.00            
            , 20.00            
            , 10.00            
            , 1.00             
            , 'Caja 10x20x30'  
            , 'GTQ'            
            , 0.00             
            , GETDATE()        
            , NULL             
            , NULL             
            , 0                
            , 1                
            , @Counter         
            , NULL             
            , NULL             
            , NULL             
            , NULL             
            , NULL             
            , NULL             
            , 1                
            , @StatusOrderId   
            , NULL             
            , NULL             
            , NULL             
            , NULL             
            , NULL             
            , NULL             
            , NULL             
            , NULL             
        );

        SET @Counter = @Counter + 1;
    END;
END;
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[Support_InsertDeliveryOrderPieces] TO [cdeleon]
    AS [dbo];

