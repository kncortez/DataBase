-- =============================================
-- Author:		<Alberto,Ixchop>
-- Create date: <2021-12-22>
-- Description:	<Modifica los datos en el itinerario de puntos de visita>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_SetVisitPointItinerary]
	@Flag nvarchar(50),--Esta variable indica que dato se desea modificar
	@InitializationTimeOfVisit nvarchar(5)=NULL,
	@FinalizationTimeOfVisit nvarchar(5)=NULL,
	@RouteCodeID	int=NULL,
	@TokeUser nvarchar(50),
	@IdVPItinerary bigint,
	@OrderSequence int=NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	UPDATE  DBO.VisitPointItinerary SET
		InitializationTimeOfVisit=(case when (@Flag =('SCHEDULE')) then @InitializationTimeOfVisit else InitializationTimeOfVisit end),
		FinalizationTimeOfVisit=(case when (@Flag =('SCHEDULE')) then @FinalizationTimeOfVisit else FinalizationTimeOfVisit end),
		RouteCodeID=(case when (@Flag =('ROUTE')) then @RouteCodeID else RouteCodeID end),
		RowStatus=(case when (@Flag =('DELETE')) then 0 else RowStatus end),
		OrderSequence=(case when (@Flag =('ORDER')) then @OrderSequence else OrderSequence end),
		TokenUpdated=@TokeUser,
		DateUpdated=GETDATE()
	where IdVPItinerary=@IdVPItinerary;
	
END
