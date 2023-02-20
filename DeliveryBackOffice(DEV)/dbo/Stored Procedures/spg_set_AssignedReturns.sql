-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2021-04-12>
-- Description:	<Devuelve información para mostrar listado de guías seleccionadas>
-- =============================================
CREATE PROCEDURE [dbo].[spg_set_AssignedReturns]
    @Token AS VARCHAR(50) = 'ad1a2328ed27ea99622f68deae5d9976',
    @Rol AS BIGINT = 1,
    @ListGuides AS VARCHAR(MAX) = '',
    @Route AS VARCHAR(100) = '',
    @Courier AS VARCHAR(100) = '',
    @DateAssigned AS VARCHAR(50) = '' --dd/MM/yyyy

AS
BEGIN


CREATE TABLE  #listGuides (ItemSerie NVARCHAR(2),ItemNumber int )

INSERT INTO #listGuides
(
    ItemSerie,
    ItemNumber
)
    SELECT SUBSTRING(Item, 1, 2) ItemSerie,
           SUBSTRING(Item, 3, LEN(Item)) ItemNumber
  --  INTO #listGuides
    FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@ListGuides, ',');

	 CREATE NONCLUSTERED INDEX IX_SettlementList_#listGuides
            ON #listGuides (ItemSerie,ItemNumber);

    UPDATE Table_A
    SET Table_A.Courier_Route = @Route,
        Table_A.Courier_Name = @Courier,
        Table_A.Dispatched_Date = GETDATE(),
        Table_A.Dispatched_Token = @Token,
        Table_A.StatusOrderId = 17 --Fuera para entrega
    FROM DeliveryBackOffice.dbo.DeliveryOrder AS Table_A WITH(NOLOCK)
        INNER JOIN #listGuides AS Table_B
            ON Table_A.Guide_Serie = Table_B.ItemSerie
               AND Table_A.Guide_Number = Table_B.ItemNumber;


    ---Update a la tabla de piezas del status de todas las piezas de la guia.
    DECLARE @validate INT =
            (
                SELECT COUNT(NoPiece)
                FROM DeliveryOrderPiece WITH(NOLOCK)
                WHERE GuideNumber IN
                      (
                          SELECT GuideNumber FROM #listGuides
                      )
                      AND GuideSerie IN
                          (
                              SELECT GuideSerie FROM #listGuides
                          )
            );

    IF (@validate > 0)
    BEGIN
        UPDATE DeliveryOrderPiece
        SET StatusOrderId = 17
        FROM DeliveryBackOffice.dbo.DeliveryOrderPiece Dop WITH(NOLOCK)
            INNER JOIN #listGuides AS Table_B
                ON Dop.GuideSerie = Table_B.ItemSerie
                   AND Dop.GuideNumber = Table_B.ItemNumber;
    END;

    -- INSERTAR CHECKPOINT INICIAL EN TABLA HISTÓRICA

    INSERT [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]
    (
        [Guide_Serie],
        [Guide_Number],
        [StatusOrderId],
        [UserCreated],
        [DateCreated],
        [DateCreatedInSystem]
    )
    SELECT Table_A.Guide_Serie,
           Table_A.Guide_Number,
           17,
           @Token,
           GETDATE(),
           GETDATE()
    FROM DeliveryBackOffice.dbo.DeliveryOrder Table_A WITH(NOLOCK)
        INNER JOIN #listGuides AS Table_B
            ON Table_A.Guide_Serie = Table_B.ItemSerie
               AND Table_A.Guide_Number = Table_B.ItemNumber;

   IF @@ROWCOUNT > 0
        SELECT 1 AS Result;

END;

