-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2024-04-12>
-- Description:	<Método para guardar el registro del reclamo>
-- =============================================

CREATE PROCEDURE [dbo].[SP_CreateComplaint]
@GuideSerie NVARCHAR (2),
@GuideNumber INT,
@Name  NVARCHAR (200),
@Email  NVARCHAR (100),
@Identification NVARCHAR (20),
@Phone NVARCHAR (50),
@DateDelivery DATETIME,
@Reason INT,
@Description NVARCHAR (80),
@PackageAmmount NVARCHAR (20),
@NameBankAccount NVARCHAR (80),
@BankAccount NVARCHAR (50),
@TypeAccount INT,
@Bank INT,
@CountryId NVARCHAR (2),
@StatusComplaint INT,
@Token NVARCHAR(20)
AS
BEGIN  
    BEGIN TRY
    IF EXISTS(SELECT TOP 1 1 FROM DeliveryOrder WITH(NOLOCK) WHERE Guide_Number = @GuideNumber AND Guide_Serie = @GuideSerie)
    BEGIN
        DECLARE @DateValidation NVARCHAR(10) = (SELECT FORMAT (Preparation_Date, 'dd-MM-yyyy') FROM DeliveryOrder WHERE Guide_Number = @GuideNumber AND Guide_Serie = @GuideSerie)
        DECLARE @DateComplaintValidation NVARCHAR(10) = (SELECT FORMAT (@DateDelivery, 'dd-MM-yyyy'))

        IF(@DateValidation = @DateComplaintValidation)
        BEGIN
            BEGIN TRANSACTION
            INSERT INTO [dbo].[Complaint] 
            (
                [GuideSerie],
                [GuideNumber],
                [Name],              
                [Email],             
                [Identification],    
                [Phone],             
                [DateDelivery],
                [Reason],            
                [Description],       
                [PackageAmmount],    
                [NameBankAccount],   
                [BankAccount],       
                [TypeAccount],       
                [Bank],              
                [CountryId],         
                [StatusComplaint],   
                [TokenCreated],
                [DateCreated]
            ) VALUES
            (
                @GuideSerie,
                @GuideNumber,
                @Name,
                @Email,
                @Identification,
                @Phone,
                @DateDelivery,
                @Reason,
                @Description,
                @PackageAmmount,
                @NameBankAccount,
                @BankAccount,
                @TypeAccount,
                @Bank,
                @CountryId,
                @StatusComplaint,
                @Token,
                GETDATE()
            )
            IF @@TRANCOUNT > 0 
	        BEGIN  
	            COMMIT TRANSACTION;  
	            SELECT 1 AS [StatusCode], 'Registro de reclamo exitoso' AS [MessageResponse] 
            END
        END
        ELSE
        BEGIN
            SELECT 0 AS [StatusCode], 'La fecha de envío no coincide con la fecha ingresada' AS [MessageResponse] 
        END
    END
    ELSE
    BEGIN
        SELECT 0 AS [StatusCode], 'No se encontraron resultados para la guía solicitada' AS [MessageResponse] 
    END
   END TRY
BEGIN CATCH
    SELECT 0 AS [StatusCode], ERROR_MESSAGE() AS [MessageResponse] 
	ROLLBACK TRANSACTION
END CATCH;
END ;