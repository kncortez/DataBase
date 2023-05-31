--USE DeliveryBackOffice
-- =============================================
-- Author:		<Jerson Ochoa>
-- Create date: <18-04-2023>
-- Description:	<Set rowStatus = 0 in removed services from SimpliRoute>
-- =============================================
create procedure [dbo].[spSR_RemoveOutdatedSimpliPickupService]
	@SimpliRouteServiceId INT,
	@Token NVARCHAR(100)
as
begin
	set nocount on;

    BEGIN TRANSACTION
		BEGIN TRY

			UPDATE		[EPPSL]
			SET			[EPPSL].[RowStatus] = 0,
						[EPPSL].[IsInExternalPlatform] = 0,
						[EPPSL].[TokenUpdated] = @Token,
						[EPPSL].[DateUpdated] = SYSDATETIME()
			FROM		[dbo].[ExternalPlatformPickupServiceLog] EPPSL
			INNER JOIN	[dbo].[ExtPlatformService] EPS
				ON		[EPPSL].[ServiceManagementId] = [EPS].[Reference]
				AND		[EPS].[IdService] = @SimpliRouteServiceId;

			UPDATE		[dbo].[ExtPlatformService]
			SET			[RowStatus] = 0,
						[TokenUpdated] = @Token,
						[DateUpdated] = SYSDATETIME()
			WHERE		[IdService] = @SimpliRouteServiceId;

			SELECT	1 [spResult], 'Registro ha sido desactivado con éxito' [spMessage];

			COMMIT TRANSACTION;

		END TRY
		BEGIN CATCH
			SELECT 0 [spResult],
				   ERROR_NUMBER() AS [ErrorNumber],
				   ERROR_SEVERITY() AS [ErrorSeverity],
				   ERROR_STATE() AS [ErrorState],
				   ERROR_PROCEDURE() AS [ErrorProcedure],
				   ERROR_LINE() AS [ErrorLine],
				   ERROR_MESSAGE() AS [spMessage];
			ROLLBACK TRANSACTION;
		END CATCH
END