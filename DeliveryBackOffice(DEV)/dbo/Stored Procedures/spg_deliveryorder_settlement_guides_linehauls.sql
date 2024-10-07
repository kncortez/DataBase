
-- =============================================
-- Author:		<Andres,Ruiz>
-- Update date: <2022-07-26>
-- Description:	< Mejora de rendimiento del SP, adicionando WITH(NOLOCK) y especificando tipos de JOIN >
-- =============================================
-- Modified:	<Brandon, Pedroza>
-- Update date: <2024-06-10>
-- Description:	<Se devuelve la moneda segun el pais de origen de la guia>
-- =============================================
CREATE PROCEDURE [dbo].[spg_deliveryorder_settlement_guides_linehauls] @IdManifest INT
AS
BEGIN

    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @temp TABLE
    (
        Guide_Code NVARCHAR(MAX),
        Pieces_Cold INT,
        Pieces_Dry INT,
        Receiver_Fullname NVARCHAR(201),
        Receiver_Address NVARCHAR(600),
        Receiver_Zone NVARCHAR(100),
        Receiver_Town NVARCHAR(100),
        Receiver_Departament NVARCHAR(100),
        Preparation_Date NVARCHAR(50),
        Shipping_Date NVARCHAR(50),
        Max_Date NVARCHAR(50),
        Receiver_Phone NVARCHAR(100),
        Rack_Position NVARCHAR(MAX),
        Collect_on_Delivery DECIMAL(16, 2),
		Collect_on_DeliveryStr NVARCHAR(50)
    );

    INSERT INTO @temp
    SELECT PC.GuideSerie + CAST(PC.GuideNumber AS VARCHAR(50)) + '-' + CAST(PC.NoPiece AS VARCHAR(10)) AS Guide_Code,
           CASE
               WHEN ISNULL(PC.IsDry, 0) = 0 THEN
                   1
               ELSE
                   0
           END AS Pieces_Cold,
           CASE
               WHEN ISNULL(PC.IsDry, 0) = 1 THEN
                   PC.IsDry
               ELSE
                   0
           END AS Pieces_Dry,
           ISNULL(DO.Receiver_FirstName, '') + ' ' + ISNULL(DO.Receiver_LastName, '') AS Receiver_Fullname,
           DO.Receiver_Address AS Receiver_Address,
           CONVERT(VARCHAR, ISNULL(DO.Receiver_Zone, 0)) AS Receiver_Zone,
           DO.Receiver_Town AS Receiver_Town,
           DO.Receiver_Department AS Receiver_Departament,
           CONVERT(VARCHAR, DO.Preparation_Date, 103) + ' ' + CONVERT(VARCHAR(5), DO.Preparation_Date, 108) AS Preparation_Date,
           CONVERT(VARCHAR, DO.Shipping_Date, 103) AS Shipping_Date,
           ISNULL(CONVERT(VARCHAR, DO.Delivery_Max_Date, 103), '') AS Max_Date,
           DO.Receiver_Phone AS Receiver_Phone,
           '0' AS Rack_Position,
           --,Collect_OnDelivery
           (CASE
                WHEN ISNULL(DO.Collect_OnDelivery, 0) != 0 THEN --do.IsCollect = 'TRUE' then 
                    --CAST(CAST((isnull(do.Collect_OnDelivery,0.00) + isnull(do.PriceShippment,0.00)) AS DECIMAL) as VARCHAR) 
                    CAST((ISNULL(DO.Collect_OnDelivery, 0.00) + ISNULL(DO.PriceShippment, 0.00)) AS VARCHAR)
                ELSE
                    '0.00'
            END
           ) AS Collect_OnDelivery,
		   CONCAT(CASE
					WHEN DO.SenderCountryId ='HN' THEN 'L'
					ELSE 'Q'
					END, CASE
                WHEN ISNULL(DO.Collect_OnDelivery, 0) != 0 THEN --do.IsCollect = 'TRUE' then 
                    --CAST(CAST((isnull(do.Collect_OnDelivery,0.00) + isnull(do.PriceShippment,0.00)) AS DECIMAL) as VARCHAR) 
                    CAST((ISNULL(DO.Collect_OnDelivery, 0.00) + ISNULL(DO.PriceShippment, 0.00)) AS VARCHAR)
                ELSE
                    '0.00'
            END
           ) AS Collect_OnDeliveryStr
    FROM DeliveryBackOffice.dbo.ServiceManagement sm WITH (NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.PieceByService pbs WITH (NOLOCK)
            ON sm.IdServiceManagement = pbs.ServiceManagmentId
            AND pbs.ServiceManagmentId = sm.IdServiceManagement
        INNER JOIN DeliveryBackOffice.dbo.SettlementByPickup sbp WITH (NOLOCK)
            ON sbp.ServiceManagmentId = sm.IdServiceManagement
        INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece PC WITH (NOLOCK)
            ON pbs.GuidePieceId = PC.GuidePiece
        INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder DO WITH (NOLOCK)
            ON DO.Guide_Serie = PC.GuideSerie
               AND DO.Guide_Number = PC.GuideNumber
    WHERE sbp.SubTypeServiceManagmentId = 4
      AND sbp.SequenceCode = @IdManifest;

    SELECT Tmp.Guide_Code,
           Tmp.Pieces_Cold,
           Tmp.Pieces_Dry,
           Tmp.Receiver_Fullname,
           Tmp.Receiver_Address,
           Tmp.Receiver_Zone,
           Tmp.Receiver_Town,
           Tmp.Receiver_Departament,
           Tmp.Preparation_Date,
           Tmp.Shipping_Date,
           Tmp.Max_Date,
           Tmp.Receiver_Phone,
           Tmp.Rack_Position,
           Tmp.Collect_on_Delivery,
		   Tmp.Collect_on_DeliveryStr
    FROM @temp Tmp
    ORDER BY Receiver_Departament ASC,
             Receiver_Town ASC,
             Receiver_Zone ASC,
             Receiver_Address ASC;

END;