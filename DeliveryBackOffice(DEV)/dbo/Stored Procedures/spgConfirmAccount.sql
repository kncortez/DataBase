-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE spgConfirmAccount
 @Mode int --1 Consulta, 2--Edición
,@Mail varchar(100)
,@IdAccount bigint
,@TokenUpdated varchar(50)
AS
BEGIN
 if (@Mode = 1) --consulta
 BEGIN
    select UNO.UsrIdUser,Dos.RuaIdAccount,TRES.AccConfirm,UNO.UsrEmail,* from DeliveryBackOffice.dbo.RegisterUser UNO
    join DeliveryBackOffice.dbo.RolByUserByAccount DOS on UNO.UsrIdUser = DOS.RuaIdUser
	join DeliveryBackOffice.dbo.Account TRES on TRES.AccIdAccount = DOS.RuaIdAccount
	where UsrEmail like '%' + @Mail +'%'

 END
 ELSE
 BEGIN
  PRINT 'EDICION'   

  if (LEN(@TokenUpdated)> 0)
  BEGIN
      update DeliveryBackOffice.dbo.Account
   set AccConfirm = 'C'
   , AccTokenUpdated = @TokenUpdated
   , AccDateUpdated = getdate()
   where AccIdAccount = @IdAccount 
  END
  ELSE
  BEGIN
   select 'Favor ingrese token'
  END



 END
END
