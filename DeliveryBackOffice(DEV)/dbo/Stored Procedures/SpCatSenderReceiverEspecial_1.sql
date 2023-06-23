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
			LTRIM(RTRIM(SR.First_Name +' '+ SR.Last_Name)) [Name]
		From [dbo].[SenderReceiver] SR WITH (NOLOCK)
		Where  SR.Estatus = 1
		ORDER BY LTRIM(RTRIM(SR.First_Name +' '+ SR.Last_Name)) ASC
  
END