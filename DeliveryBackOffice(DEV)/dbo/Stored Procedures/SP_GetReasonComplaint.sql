-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2024-05-12>
-- Description:	<Método para consultar el catalogo de razones de reclamo>
-- =============================================

ALTER PROCEDURE [dbo].[SP_GetReasonComplaint]
@CountryId NVARCHAR(2)
AS
BEGIN  
    SELECT  [ReasonComplaintId],
            [Description]
    FROM [dbo].[ReasonComplaint] WITH(NOLOCK) WHERE CountryId = @CountryId
END ;