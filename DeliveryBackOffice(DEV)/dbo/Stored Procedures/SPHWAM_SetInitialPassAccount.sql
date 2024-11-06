-- =============================================  
-- Author:  <Aylinne Recinos>  
-- Create date: <2024-11-06>  
-- Description: <Establece nueva contraseña desde la App Móvil>  
-- =============================================  
CREATE PROCEDURE [dbo].[SPHWAM_SetInitialPassAccount]  
 -- Add the parameters for the stored procedure here  
 @Password NVARCHAR(200),  
 @IdAccount  INT,
 @Token NVARCHAR(20)
AS  
BEGIN  
BEGIN TRY 
  DECLARE @UsrIdUser AS INT;
  DECLARE @Status AS NVARCHAR(1);
  SELECT @Status = AccConfirm 
          FROM Account 
          WHERE AccIdAccount = @IdAccount
  IF(@Status = 'V')
  BEGIN
    SELECT  @UsrIdUser = us.UsrIdUser
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
    BEGIN TRANSACTION  
        UPDATE RegisterUser
            SET UsrLastPassword = @Password, 
                UsrTokenUpdated = @Token,
                UsrDateUpdated = GETDATE()
        WHERE UsrIdUser = @UsrIdUser;
        UPDATE Account
            SET AccConfirm = 'C', 
                AccTokenUpdated = @Token,
                AccDateUpdated = GETDATE()
        WHERE AccIdAccount = @IdAccount;
      IF @@TRANCOUNT > 0 
      BEGIN  
        COMMIT TRANSACTION;  
        SELECT 1 AS [StatusCode], 'Cambio de contraseña exitoso' AS[MessageResponse] 
      END  
  END
  ELSE IF(@Status = 'C')
  BEGIN
    SELECT 0 AS [StatusCode], 'La cuenta ya se encuentra confirmada' AS[MessageResponse]
  END
   ELSE
  BEGIN
    SELECT 0 AS [StatusCode], 'La cuenta está pendiente de verificación' AS[MessageResponse]
  END
END TRY  
  BEGIN CATCH      
    SELECT 0 AS [StatusCode], 'No es posible realizar el cambio de contraseña' AS[MessageResponse]
    ROLLBACK TRANSACTION  
  END CATCH;  
END  
  