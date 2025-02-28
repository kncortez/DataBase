-- =============================================  
-- Author:  <Aylinne Recinos>  
-- Create date: <2025-01-20>  
-- Description: <App Móvil - Método para obtener calificación del destinatario al cual se envío el paquete>  
-- =============================================  
CREATE PROCEDURE [dbo].[SPHW_GetQualifyServiceSender]   
@GuideSerie NVARCHAR(4),  
@GuideNumber INT,  
@Token NVARCHAR(50),  
@Score INT,  
@IdSystem INT,
@IsGoodCommunication BIT,
@IsGoodReceiver BIT  
AS  
BEGIN  
BEGIN TRY  
  BEGIN TRANSACTION;  
  DECLARE @IdQualify INT;
  DECLARE @ScoreReceiver INT;
  -- Validar la longitud de la descripción         
  SELECT @IdQualify = IdScoreGuide,
         @ScoreReceiver = ScoreReceiver 
  FROM DeliveryBackOffice.dbo.ScoreServiceGuide WITH(NOLOCK)  
  WHERE GuideSerie = @GuideSerie AND GuideNumber = @GuideNumber

  IF (@IdQualify IS NOT NULL AND @ScoreReceiver IS NOT NULL)    
    BEGIN     
        SELECT  401 as [IdResult]     , 'La guía ya cuenta con una calificación.' AS [Message];    
    END;    
    ELSE    
    BEGIN     
        IF (@Score < 1 OR @Score > 5)     
        BEGIN      
            SELECT  403 as [IdResult]      , 'La calificación debe ser un número entero entre 1 a 5.' AS [Message];     
        END;     
        ELSE     
        BEGIN
          IF(@IdQualify IS NOT NULL)
          BEGIN
            UPDATE ScoreServiceGuide
            SET ScoreReceiver = CAST(@Score AS DECIMAL(5,2)),
                IsGoodCommunication = @IsGoodCommunication,
                IsGoodReceiver = @IsGoodReceiver,
                UserUpdated = @Token,
                DateUpdated = GETDATE()
            WHERE IdScoreGuide = @IdQualify
            SELECT  200 as [IdResult], '¡Gracias por tu opinión! Nos ayuda a mejorar.' AS [Message];
          END
          ELSE
          BEGIN      
            -- Insertar el registro en la tabla ScoreServiceGuide      
            INSERT INTO ScoreServiceGuide (GuideSerie, GuideNumber, IdSystem, RowStatus, UserCreated, DateCreated, UserUpdated, DateUpdated, IsGoodCommunication, IsGoodReceiver, ScoreReceiver)
            VALUES (@GuideSerie, @GuideNumber, @IdSystem, 1, @Token,       GETDATE(), NULL, NULL, @IsGoodCommunication, @IsGoodReceiver, CAST(@Score AS DECIMAL(5,2)));       
            SELECT  200 as [IdResult], '¡Gracias por tu opinión! Nos ayuda a mejorar.' AS [Message];
          END
        END;  
  END;               
  COMMIT TRANSACTION;  
END TRY  
BEGIN CATCH  
 -- Revertir la transacción en caso de error     IF @@TRANCOUNT > 0     BEGIN         ROLLBACK TRANSACTION;     END  
  
    DECLARE @ErrorMessage NVARCHAR(4000);  
    SELECT @ErrorMessage = ERROR_MESSAGE();  
    PRINT 'Error: ' + @ErrorMessage;  
END CATCH;  
END;