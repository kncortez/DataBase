-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2022-01-27>
-- Description:	<Description,SP actualziar km de camión>
-- =============================================
CREATE PROCEDURE [dbo].[spg_UpdateKmCatVehicle] 
@Unidad AS varchar(10),
@kms AS INT

AS
BEGIN

 BEGIN TRY


      UPDATE CatVehicle 
	  SET Kms = @kms 
	  WHERE UnitNumber = @Unidad
	  
	  SELECT RESULT = 1 ,'Transacción Exitosa' AS [DESCRIPTION]
 END TRY
BEGIN CATCH

 SELECT RESULT = 0 ,ERROR_MESSAGE() AS [DESCRIPTION]

END CATCH

END