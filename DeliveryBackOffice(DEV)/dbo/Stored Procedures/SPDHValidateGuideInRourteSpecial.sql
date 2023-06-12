-- =============================================
-- Author:		<Author,Edelman Vásquez>
-- Create date: <Create Date: 2023-05-28>
-- Description:	<Description, Validar que >
-- =============================================
CREATE PROCEDURE [dbo].[SPDHValidateGuideInRourteSpecial]
@GuideSerie Nvarchar(2),
@GuideNumber Int
AS
BEGIN
	SET NOCOUNT ON;

	IF (EXISTS(SELECT TOP 1 1
	                 FROM [dbo].[TSERoutePreparationHeader]  RPH WITH(NOLOCK)
					 INNER JOIN 
					      [dbo].[TSERoutePreparationDetail] RPD WITH(NOLOCK)
					ON RPH.IDTSERoutePreparationHeader =  RPD.TSERoutePreparationHeaderID
					WHERE RPD.GuideSerie = @GuideSerie  AND 	RPD.GuideNumber = @GuideNumber AND RPD.Rowstatus=1 )
		)
					BEGIN

							SELECT 1 Result

					END
					ELSE
					  BEGIN

							SELECT 0 Result
					
					 END
	
	END