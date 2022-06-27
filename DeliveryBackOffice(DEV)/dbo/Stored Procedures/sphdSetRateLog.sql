
-- =============================================
-- Author:      <Sazo,Cesar>
-- Create date: <29/01/2022>
-- Description: <Almacenamos los log de cambios en tarifarios.>
-- =============================================

CREATE PROCEDURE [dbo].[sphdSetRateLog]
      @IdCustomer INT = 0
      ,@CodeOfReference INT = 0 
      ,@TokenCreated NVARCHAR(50) = ''
      ,@ModuleCreated NVARCHAR(100) = ''
      ,@OriginalRateId INT = 0
      ,@NewRateId INT = 0
AS
BEGIN
      IF(@IdCustomer <= -1)
            BEGIN
            INSERT INTO [dbo].[RateLog]
                                       ([TokenCreated]
                                       ,[ModuleCreated]
                                       ,[DateCreated]
                                       ,[NewRateHeaderId])
                              VALUES
                                       (@TokenCreated
                                       ,@ModuleCreated
                                       ,GETDATE()
                                       ,(SELECT
                                               TOP 1 RheId
                                         FROM dbo.RateHeader
                                         ORDER BY RheDateCreated DESC))
            END
      ELSE
            BEGIN
                  IF(@OriginalRateId <= 0 OR @OriginalRateId IS NULL)
                        BEGIN
                              INSERT INTO [dbo].[RateLog]
                                       ([IdCustomer]
                                       ,[CodeOfReference]
                                       ,[TokenCreated]
                                       ,[ModuleCreated]
                                       ,[DateCreated]
                                       ,[NewRateHeaderId])
                              VALUES
                                       (@IdCustomer
                                       ,@CodeOfReference
                                       ,@TokenCreated
                                       ,@ModuleCreated
                                       ,GETDATE()
                                       ,@NewRateId)
                        END
                  ELSE
                        BEGIN
                              INSERT INTO [dbo].[RateLog]
                                       ([IdCustomer]
                                       ,[CodeOfReference]
                                       ,[TokenCreated]
                                       ,[ModuleCreated]
                                       ,[DateCreated]
                                       ,[OriginalRateHeaderId]
                                       ,[NewRateHeaderId])
                              VALUES
                                       (@IdCustomer
                                       ,@CodeOfReference
                                       ,@TokenCreated
                                       ,@ModuleCreated
                                       ,GETDATE()
                                       ,@OriginalRateId
                                       ,@NewRateId)
                        END
            END
END