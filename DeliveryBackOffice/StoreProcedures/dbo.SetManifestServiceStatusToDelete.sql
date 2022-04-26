USE [DeliveryBackOffice]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Michael Espinoza>
-- Create date: <2022-04-25>
-- Description:	< Elimina una guia de un manifiesto >
-- =============================================

CREATE PROCEDURE [dbo].[SetManifestServiceStatusToDelete]
	@GuideSerie NVARCHAR(10), -- fecha de inicio de busqueda.
	@GuideNumber BIGINT, -- fecha de finalizacion de busqueda.
	@ManifestNumber BIGINT, -- ID de cuenta de usuario que consulta.
	@Token NVARCHAR(50) -- Token usuario que consulta.

AS

BEGIN

DECLARE @jsonResult NVARCHAR(MAX);

BEGIN TRANSACTION 

BEGIN TRY

UPDATE cmd
SET cmd.RowStatus = 0,
cmd.TokenUpdated = @Token,
cmd.DateUpdated = GETDATE()
FROM DeliveryBackOffice.dbo.CorporateManifestDetail cmd
WHERE cmd.ManifestId = @ManifestNumber 
AND cmd.GuideSerie = @GuideSerie 
AND  cmd.GuideNumber = @GuideNumber

END TRY

BEGIN CATCH

ROLLBACK TRANSACTION;

DECLARE @message NVARCHAR(MAX) = ERROR_MESSAGE();

SET @jsonResult = (SELECT STUFF(
						(
							select 
								',{									
								"Message":"' + @message + '",'+
								'"Status": 500'
								+ '}' 			
								FOR XML PATH(''), TYPE
						).value('.', 'varchar(max)'),1,1,''
						)
					)

END CATCH

IF(@@TRANCOUNT>0)

BEGIN

COMMIT TRANSACTION;

SET @jsonResult = (SELECT STUFF(
						(
							select 
								',{									
								"Message":"Manifiesto actualizado exitosamente.",'+
								'"Status": 200'
								+ '}' 			
								FOR XML PATH(''), TYPE
						).value('.', 'varchar(max)'),1,1,''
						)
					)


END

SELECT ('[' + @jsonResult +  ']') jsonResult

END;
