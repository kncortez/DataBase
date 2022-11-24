-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-11-15>
-- Description:	<SP agregar nuevo contenedor rutas linehauls>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_NewContainerLinehauls]
@Serie AS NVARCHAR(10),
@Numero AS NVARCHAR(200),
@Descripcion AS NVARCHAR(200),
@Token AS NVARCHAR(50)
AS
BEGIN
	
	DECLARE @CatTypeContainerId INT = (SELECT ctc.IdCatTypeContainer FROM [dbo].[CatTypeContainer]  ctc WITH (NOLOCK) WHERE ctc.TypeContainerSerie=@Serie)
	DECLARE @Result AS INT 
	BEGIN TRANSACTION
	BEGIN TRY

			IF(NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[Container] WITH (NOLOCK) WHERE ContainerDescription = @Serie+@Numero) )
			BEGIN
			INSERT INTO [dbo].[Container] (CatTypeContainerId,	
										   ContainerNumber,	
										   ContainerDescription,	
										   RowStatus,
										   TokenCreated,
										   DateCreated
										   )
						   VALUES(
								@CatTypeContainerId,
								@Numero,
								@Descripcion,
								1,
								@TOKEN,
								GETDATE()
				   
				   
						   )

			SET @Result=1;
			END 
			   ELSE
				  BEGIN

					 SET @Result=2;
				  END

			 COMMIT TRANSACTION
	  

		END TRY
		BEGIN CATCH
			 ROLLBACK
			SET @Result=0;

	END CATCH
	 
	 SELECT Result=@Result
    
END