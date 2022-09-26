-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-08-30>
-- Description:	<SP para mostrar tipos catálogo  de actas>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_CatTypeAct]
	
AS
BEGIN
	
	SET NOCOUNT ON;

SELECT  IdCatTypeAct,
        ActName,
		ActDescription
FROM DBO.CatTypeAct WITH (NOLOCK)
where RowStatus = 1
END