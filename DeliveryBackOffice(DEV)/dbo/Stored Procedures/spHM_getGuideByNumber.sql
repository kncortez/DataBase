-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <12-07-2022>
-- Description:	<Get and validate a DeliveryOrder Guide by serie and number>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_getGuideByNumber]
	@GuideSerie AS NVARCHAR(25),
	@GuideNumber AS NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT	[DO].[Guide_Serie], 
			[DO].[Guide_Number],
			[DO].[Pieces_Dry],
			[DO].[Pieces_Cold],
			[DO].[ReceiverIdTownship],
			[DO].[Receiver_Town],
			[DO].[Receiver_Department],
			[DO].[Receiver_Address],
			[DO].[Receiver_Zone],
			COALESCE([DO].[HubDestinationId], 0) AS HubDestinationId,
			[HL].[HubAbbreviation],
			[DO].[StatusOrderId],
			[SO].[OrderDescription]
	FROM	[dbo].[DeliveryOrder] DO WITH(NOLOCK)
	LEFT JOIN [dbo].[HubLogistics] HL
		ON	[DO].[HubDestinationId] = [HL].[IdHubLogistic]
	INNER JOIN [dbo].[StatusOrder] SO
		ON [DO].[StatusOrderId] = [SO].[StatusOrderId]
		AND ([SO].[OrderDescription] = 'Recolectado' OR
			[SO].[OrderDescription] = 'Arribó a las instalaciones' OR
			[SO].[OrderDescription] = 'En inventario' OR
			[SO].[OrderDescription] = 'En Tránsito')
	WHERE	[DO].[Guide_Serie] = @GuideSerie
	AND		[DO].[Guide_Number] = @GuideNumber;
END