
-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-05-19>
-- Description:	<Description, Catálogo de personal a cargo rutas especiales TSE>
-- =============================================
CREATE PROCEDURE [dbo].[SpCatSenderReceiverEspecial]
@TypeName NVARCHAR(50)

AS
BEGIN	
SET NOCOUNT ON;

	SELECT 
		SR.ID,
		LTRIM(RTRIM(SR.First_Name +' '+ SR.Last_Name)) [Name]
	FROM [dbo].[SenderReceiver] SR WITH (NOLOCK)
	     INNER JOIN 
		 [dbo].[CatTypeSenderReceiver] TSR WITH (NOLOCK)
		 ON SR.CatTypeSenderReceiverId = TSR.IdCatTypeSenderReceiver
	WHERE  SR.Estatus = 1 AND TSR.TypeName LIKE '%'+@TypeName + '%'
	ORDER BY LTRIM(RTRIM(SR.First_Name +' '+ SR.Last_Name)) ASC
  
END