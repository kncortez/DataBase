-- =============================================
-- Author:		<Edelman, Vásquez>
-- Create date: <2022-12-13>
-- Description:	<SP obtener hub de destino de ruta linehauls>
-- =============================================
CREATE  PROCEDURE [dbo].[SPHD_GetHubDestiny]
@Idstation as int,
@IdRoute as int

AS
BEGIN

	SET NOCOUNT ON;
	BEGIN TRANSACTION 
	BEGIN TRY

			SELECT distinct CS.HubLogisticId,
			   CS.IdStation, 
			   CS.StationName,
			   HL.HubAbbreviation, 
			   HL.HubName,
			   LC.IdRoute,
			   CR.CodeRoute,
			   LC.IdHubOrigin,
			  (Select HubAbbreviation 
			   From [dbo].[HubLogistics] WITH (NOLOCK)
			   Where IdHubLogistic= LC.IdHubDestination) AS HubDestiny
			FROM [dbo].[CatStation] CS WITH (NOLOCK)
				INNER JOIN 
				 [dbo].[HubLogistics] HL WITH (NOLOCK)
			ON CS.HubLogisticId= HL.IdHubLogistic
				INNER JOIN 
				[dbo].[CatLinehaul] LC WITH (NOLOCK)
			ON HL.IdHubLogistic = LC.IdHubOrigin
				INNER JOIN 
				[dbo].[CatRoute] CR WITH (NOLOCK)
			ON LC.IdRoute = CR.IdRoute
			WHERE  CS.IdStation   = @Idstation  AND 
				   LC.IdRoute  = @IdRoute AND
				   CR.RowStatus   = 1  AND 
				   LC.RowStatus   = 1  AND 
				   CR.IdTypeRoute = 2
			ORDER BY LC.IdRoute

			COMMIT TRANSACTION

  END TRY
   BEGIN CATCH
	ROLLBACK TRANSACTION
		SELECT Result=0, ERROR_MESSAGE() AS [ErrorMessage];
   END CATCH

END