-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-05-19>
-- Description:	<Description, Catálogo de personal a cargo rutas especiales TSE>
-- =============================================
CREATE PROCEDURE [dbo].[SpCatSenderReceiverEspecial]
@TypeName Nvarchar(50)

AS
BEGIN	
SET NOCOUNT ON;

	Select 
		SR.ID,
		SR.First_Name +' '+ SR.Last_Name [Name]
	From [dbo].[SenderReceiver] SR WITH (NOLOCK)
	     INNER JOIN 
		 [dbo].[CatTypeSenderReceiver] TSR WITH (NOLOCK)
		 ON SR.CatTypeSenderReceiverId = TSR.IdCatTypeSenderReceiver
	Where  SR.Estatus = 1 AND TSR.TypeName Not In ('SUPERVISOR DE RUTA','JEFE DE RUTA','CUSTODIO')
	ORDER BY SR.First_Name +' '+ SR.Last_Name ASC
  
END