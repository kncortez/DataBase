-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-08-5>
-- Description:	<obtener piezas de guía para generar, Actas de justificación piezas faltantes rutas Linehauls>
-- =============================================
-- Modified:	<Brandon Pedroza>
-- Create date: <2024-06-05>
-- Description:	<Se agrega parametro para filtrar filtrar guias por pais de origen>
-- =============================================
CREATE PROCEDURE [dbo].[GetActPieceGuideLinehauls]

@IdActa AS  INT,
@IdCountry AS NVARCHAR(2) = 'GT'
	
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT 
		B.GuideSerie + CAST(B.GuideNumber AS VARCHAR) +'-'+ CAST(C.PieceNumber AS varchar) AS Guide,
		ISNULL(
		(SELECT Hubname FROM DBO.HubLogistics WHERE IdHubLogistic = DO.HubOriginId),'N/D') AS HubOrigen,
		DO.Sender_FirstName +' '+ DO.Sender_LastName AS Remitente
		,ISNULL((SELECT Hubname FROM DBO.HubLogistics WHERE IdHubLogistic = DO.HubDestinationId),'N/D') AS HubDestination
		,ISNULL(DO.Receiver_FirstName +' '+ DO.Receiver_LastName,'N/D') AS Destinatario
		,CASE 
		 WHEN C.RowStatus = 1 THEN 'Activo'
		 ELSE  'Inactivo' END AS Estado
	FROM 
		[DeliveryBackOffice].[dbo].[Act]  A WITH (NOLOCK) 
			INNER JOIN 
		[DeliveryBackOffice].[dbo].[ActDetail] B WITH (NOLOCK)
				ON  A.IdAct = B.ActId
			INNER JOIN
		[DeliveryBackOffice].[dbo].[ActDetailPiece] C WITH (NOLOCK)
				ON	B.IdActDetail = C.ActDetailId
			INNER  JOIN
		[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
		        ON  B.GuideSerie = DO.Guide_Serie AND B.GuideNumber = DO.Guide_Number			
    WHERE B.ActId= @IdActa 
		AND B.RowStatus=1
        AND IIF(DO.SenderCountryId IS NULL, 'GT', DO.SenderCountryId)= @IdCountry          	

END