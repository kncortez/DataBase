
-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-07-24>
-- Description:	<Devuelve todos los registros de la ubicación y guía en cuestión>
-- =============================================
-- Modified:	<Pedroza, Brandon>
-- Create date: <2024-06-06>
-- Description:	<Se agrega paramtro para filtrar guias por pais de origen>
-- =============================================
-- Modified:	<Pedroza, Brandon>
-- Create date: <2024-06-27>
-- Description:	<Se agrega condicion para validar si la guia es domestica o internacional>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_warehouse]
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@RackPosition NVARCHAR(30),
	@IsReturn BIT = 0,
	@IdCountry AS NVARCHAR(2) = 'GT'
AS
BEGIN

  -- get all warehouse records
  -- Si es del modulo de devoluciones
  IF @IsReturn = 1
  BEGIN
	  SELECT w.[Id]
		  ,w.[Rack_Position]
		  ,w.[Guide_Serie]
		  ,w.[Guide_Number]
		  ,w.[Dry]
		  ,w.[Cold]
		  ,w.[Active]
		  --,do.Pieces_Dry AS Total_Pieces_Dry
		  --,do.Pieces_Cold AS Total_Pieces_Cold
	  FROM [DeliveryBackOffice].[dbo].[Warehouse] w WITH(NOLOCK)
	  INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] do WITH(NOLOCK) ON do.Guide_Serie = w.Guide_Serie AND do.Guide_Number = w.Guide_Number
	  WHERE 
	  ((w.Guide_Serie = @GuideSerie AND w.Guide_Number = @GuideNumber AND w.Active = 1 AND w.IsReturn = 1)
	  OR (w.Rack_Position = @RackPosition AND w.Active = 1) )
	  AND (ISNULL(do.GuideType,'DOM')='INT' OR (ISNULL(do.SenderCountryId,'GT')=@IdCountry AND ISNULL(do.GuideType,'DOM')='DOM'))
	END
	ELSE
	BEGIN
		SELECT w.[Id]
		  ,w.[Rack_Position]
		  ,w.[Guide_Serie]
		  ,w.[Guide_Number]
		  ,w.[Dry]
		  ,w.[Cold]
		  ,w.[Active]
		  --,do.Pieces_Dry AS Total_Pieces_Dry
		  --,do.Pieces_Cold AS Total_Pieces_Cold
	  FROM [DeliveryBackOffice].[dbo].[Warehouse] w WITH(NOLOCK)
	  INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] do WITH(NOLOCK) ON do.Guide_Serie = w.Guide_Serie AND do.Guide_Number = w.Guide_Number
	  WHERE 
	  ((w.Guide_Serie = @GuideSerie AND w.Guide_Number = @GuideNumber AND w.Active = 1 AND (w.IsReturn IS NULL OR w.IsReturn = 0))
	  OR (w.Rack_Position = @RackPosition AND w.Active = 1) )
	  AND (ISNULL(do.GuideType,'DOM')='INT' OR (ISNULL(do.SenderCountryId,'GT')=@IdCountry AND ISNULL(do.GuideType,'DOM')='DOM'))
	END

  -- get all pieces for guide (waybill)
  SELECT 
	 do.Guide_Serie
	,do.Guide_Number
	,do.Pieces_Dry as Total_Pieces_Dry
	,do.Pieces_Cold as Total_Pieces_Cold
	,so.OrderDescription
	,IIF(do.StatusOrderId IN (22,5,23,14,7), 0, 1) IsValid
  FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] do WITH (NOLOCK)
  INNER JOIN StatusOrder so
	ON so.StatusOrderId = do.StatusOrderId
  WHERE do.Guide_Serie = @GuideSerie AND do.Guide_Number = @GuideNumber
  AND (ISNULL(do.GuideType,'DOM')='INT' OR (ISNULL(do.SenderCountryId,'GT')=@IdCountry AND ISNULL(do.GuideType,'DOM')='DOM'))
  
  ---devuelve respuesta si la guia pertenece a otro pais
  SELECT 
	1 AS 'StatusCode', 
	'La guía '+ @GuideSerie + convert(nvarchar,@GuideNumber)+ ' pertenece a otro país' AS 'Description', 
	@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
	@RackPosition AS 'RackPosition'
	FROM DeliveryOrder WITH(NOLOCK)
	WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber
	AND ISNULL(SenderCountryId,'GT')<>@IdCountry AND ISNULL(GuideType,'DOM')='DOM'

END