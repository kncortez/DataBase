-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-11-15>
-- Description:	<SP muestra las series disponibles de contenedores linehauls>
-- =============================================
CREATE PROCEDURE [dbo].[SPHM_SerieContainerLinehauls] 
	
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT TypeContainerName +' '+ TypeContainerSerie [Description], 
	       TypeContainerSerie [Serie]
	FROM [DeliveryBackOffice].[dbo].[CatTypeContainer] CTC WITH(NOLOCK)
	WHERE CTC.RowStatus=1
  
END