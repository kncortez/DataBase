-- =============================================  
-- Author:  <Aylinne Recinos>  
-- Create date: <2025-01-14>  
-- Description: <App Móvil - Método para obtener calificación de servicio en tracking.>  
-- =============================================  
CREATE PROCEDURE [dbo].[SPHW_GetQualifyServiceApp]   
@GuideSerie NVARCHAR(4),  
@GuideNumber INT,  
@Token NVARCHAR(50),  
@Score INT,  
@Comment NVARCHAR(255) = NULL, 
@IdSystem INT,
@IsOnTime BIT,
@IsGoodConditions BIT,
@IsGoodSender BIT  
AS  
BEGIN  
BEGIN TRY  
  BEGIN TRANSACTION;  
  
  -- Validar la longitud de la descripción         
  IF LEN(@Comment) > 250         
  BEGIN             
    SELECT  402 as [IdResult]    , 'El comentario excede la longitud permitida de 250 caracteres.' AS [Message];         
  END;   
  ELSE   
  BEGIN    
    IF EXISTS(SELECT 1 FROM DeliveryBackOffice.dbo.ScoreServiceGuide WITH(NOLOCK)  
                WHERE GuideSerie = @GuideSerie AND GuideNumber = @GuideNumber)    
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
        BEGIN      -- Insertar el registro en la tabla ScoreServiceGuide      
            INSERT INTO ScoreServiceGuide (Score, GuideSerie, GuideNumber, Comment, IdSystem, RowStatus, UserCreated, DateCreated, UserUpdated, DateUpdated, IsOnTime, IsGoodConditions, IsGoodSender)
            VALUES (CAST(@Score AS DECIMAL(5,2)), @GuideSerie, @GuideNumber, @Comment, @IdSystem, 1, @Token,       GETDATE(), NULL, NULL, @IsOnTime, @IsGoodConditions, @IsGoodSender);       
            SELECT  200 as [IdResult], '¡Gracias por tu opinión! Nos ayuda a mejorar.' AS [Message];
        END;  
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