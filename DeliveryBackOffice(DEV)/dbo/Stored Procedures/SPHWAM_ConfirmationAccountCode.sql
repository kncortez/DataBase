-- =============================================  
-- Author:  <Aylinne Recinos>  
-- Create date: <2024-11-04>  
-- Description: <Confirma código de 4 dígitos desde la App Móvil>  
-- =============================================  
CREATE PROCEDURE [dbo].[SPHWAM_ConfirmationAccountCode]  
 -- Add the parameters for the stored procedure here  
 @Code NVARCHAR(50),  
 @IdAccount  INT,
 @Token NVARCHAR(20)
AS  
BEGIN  
BEGIN TRY 
  DECLARE @CodeTemporal AS NVARCHAR(50);
  DECLARE @IsConfirmed AS NVARCHAR(1);
  SELECT @IsConfirmed = AccConfirm 
          FROM Account 
          WHERE AccIdAccount = @IdAccount
  IF(@IsConfirmed = 'V')
  BEGIN 
    SELECT 0 AS [StatusCode], 'El codigo ya fue verificado' AS[MessageResponse]
  END
  ELSE IF(@IsConfirmed = 'P')
  BEGIN
    SELECT  @CodeTemporal = UsrCodeVerif
        FROM RegisterUser   us WITH (NOLOCK)  
			INNER JOIN [dbo].Person               pe WITH (NOLOCK)  
				ON pe.PerIdPerson = us.UsrIdPerson  
			INNER JOIN [dbo].[RolByUserByAccount] rua WITH (NOLOCK)  
				ON rua.RuaIdUser = us.UsrIdUser  
			INNER JOIN [dbo].CatRol               ro WITH (NOLOCK)  
				ON ro.RolIdRol = rua.RuaIdRol  
			INNER JOIN [dbo].Account              ac WITH (NOLOCK)  
				ON ac.AccIdAccount = rua.RuaIdAccount  
			INNER JOIN [dbo].CatTypeAccount       ta WITH (NOLOCK)  
				ON ta.TacIdTypeAccount = ac.AccIdTypeAccount  
        WHERE ac.AccIdAccount = @IdAccount
    IF(@Code = @CodeTemporal) 
    BEGIN  
      BEGIN TRANSACTION  
        UPDATE Account
            SET AccConfirm = 'V', 
                AccTokenUpdated = @Token,
                AccDateUpdated = GETDATE()
        WHERE AccIdAccount = @IdAccount;
      IF @@TRANCOUNT > 0 
      BEGIN  
        COMMIT TRANSACTION;  
        SELECT 1 AS [StatusCode], 'Verificación exitosa' AS[MessageResponse] 
      END  
    END  
    ELSE -- el codigo de verificacion no coincide
    BEGIN  
      SELECT 0 AS [StatusCode], 'El código de verificación no coincide' AS[MessageResponse]
    END  
  END
  ELSE
  BEGIN
    SELECT 0 AS [StatusCode], 'La cuenta ya se encuentra confirmada' AS[MessageResponse]
  END
END TRY  
  BEGIN CATCH      
    SELECT 0 AS [StatusCode], 'No es posible confirmar la cuenta' AS[MessageResponse]
    ROLLBACK TRANSACTION  
  END CATCH;  
END  
  