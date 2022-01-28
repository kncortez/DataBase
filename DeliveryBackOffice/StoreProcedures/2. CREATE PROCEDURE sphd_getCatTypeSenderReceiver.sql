SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Ixchop,Alberto>
-- Create date: <2022-01-28>
-- Description:	<Obtiene el catalogo de tipos de piloto>
-- =============================================
CREATE PROCEDURE sphd_getCatTypeSenderReceiver
AS
BEGIN
	SELECT 
		IdCatTypeSenderReceiver IdValue,
		TypeName NameValue
	FROM DBO.CatTypeSenderReceiver;
END
GO
