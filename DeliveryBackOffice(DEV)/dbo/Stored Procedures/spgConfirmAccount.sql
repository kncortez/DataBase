-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spgConfirmAccount]
 @Mode INT = 1 --1 Consulta, 2--Edición
,@Mail varchar(100) = ''
,@IdAccount BIGINT = NULL
,@TokenUpdated varchar(50) 
,@DateIni DATETIME 
AS
BEGIN
 if (@Mode = 1) --consulta
 BEGIN
 --   select UNO.UsrIdUser,Dos.RuaIdAccount,TRES.AccConfirm,UNO.UsrEmail,* from DeliveryBackOffice.dbo.RegisterUser UNO
 --   join DeliveryBackOffice.dbo.RolByUserByAccount DOS on UNO.UsrIdUser = DOS.RuaIdUser
	--join DeliveryBackOffice.dbo.Account TRES on TRES.AccIdAccount = DOS.RuaIdAccount
	--where UsrEmail like '%' + @Mail +'%'
	
 SELECT AccConfirm,AccTokenUpdated,AccDateUpdated,
 * FROM  DeliveryBackOffice.dbo.Account
 WHERE AccConfirm = 'P'
 AND AccDateCreated >= @DateIni--'2021-08-01'

 END
 ELSE
 BEGIN
  PRINT 'EDICION'   

  if (LEN(@TokenUpdated)> 0)
  BEGIN
   --   update DeliveryBackOffice.dbo.Account
   --set AccConfirm = 'C'
   --, AccTokenUpdated = @TokenUpdated
   --, AccDateUpdated = getdate()
   --where AccIdAccount = @IdAccount 
     update DeliveryBackOffice.dbo.Account
   set AccConfirm = 'C'
   , AccTokenUpdated = @TokenUpdated
   , AccDateUpdated = getdate()
   where AccDateCreated >= @DateIni--'2021-08-01'
   AND AccConfirm = 'P'
  END
  ELSE
  BEGIN
   select 'Favor ingrese token'
  END



 END
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[spgConfirmAccount] TO [cvaldes]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[spgConfirmAccount] TO [cixtetela]
    AS [dbo];

