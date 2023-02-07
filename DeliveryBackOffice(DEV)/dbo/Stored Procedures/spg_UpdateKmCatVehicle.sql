-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2022-01-27>
-- Description:	<Description,SP actualziar km de camión y registro de bitacora>
-- =============================================
CREATE PROCEDURE [dbo].[spg_UpdateKmCatVehicle] 
@Unidad AS varchar(10),
@kms AS INT,
@Observacion AS nvarchar(500),
@Token AS nvarchar(50)

AS
BEGIN

 BEGIN TRY


      UPDATE [dbo].[CatVehicle] 
	  SET Kms = @kms 
	  WHERE UnitNumber = @Unidad

	  INSERT INTO [dbo].[VehicleLog] (Unidad,
	                                  Kms, 
	                                  Observacion, 
									  TokenCreate, 
									  DateCreate
									  )
				Values(@Unidad,
				       @kms,
					   @Observacion,
					   @Token,
					   GETDATE()
				
				      )
	  
	  SELECT RESULT = 1 ,'Transacción Exitosa' AS [DESCRIPTION]
 END TRY
BEGIN CATCH

 SELECT RESULT = 0 ,ERROR_MESSAGE() AS [DESCRIPTION]

END CATCH

END