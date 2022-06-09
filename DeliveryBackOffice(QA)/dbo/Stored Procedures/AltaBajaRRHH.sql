-- crear función para llamar mas tarde
CREATE procedure [dbo].[AltaBajaRRHH] 
as
-- declarar 1 semana atrasada
declare @fechaini date = (SELECT DATEADD(day,-7,cast(GETDATE() as date)))
declare @fechafin date = (SELECT DATEADD(day,-1,cast(GETDATE() as date)))

-- select statement
SELECT [PerFirstName] AS 'NOMBRES'
      ,[PerLastName] AS 'APELLIDOS'
      ,[PerGender] AS 'GENERO'
      ,[PerNationality] AS 'NACIONALIDAD'
      ,[PerDateCreated] AS 'FECHA_ALTA'
	  ,ru.UsrEmail AS 'EMAIL'
	  --,ru.UsrIdUser
	  --,a.AccIdAccount
	  --,a.IdCustomer
	  --,do.Guide_Serie
	  --,do.Guide_Number
	  --,do.StatusOrderId
	  ,COUNT(do.guide_number) as 'CANTIDAD_GUIAS_OPERADAS'
  FROM [DeliveryBackOffice].[dbo].[Person] p
  JOIN [DeliveryBackOffice].[dbo].[RegisterUser] ru on ru.UsrIdPerson = p.PerIdPerson
  JOIN [DeliveryBackOffice].[dbo].[RolByUserByAccount] rbuba on rbuba.RuaIdUser = ru.UsrIdUser
  JOIN [DeliveryBackOffice].[dbo].[Account] a on a.AccIdAccount = rbuba.RuaIdAccount
  LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] do on do.IdCustomer = a.IdCustomer and do.StatusOrderId NOT IN (7) -- anuladas
  where p.perdatecreated between @fechaini and @fechafin
  and do.StatusOrderId NOT IN (7,15) -- anuladas, generadas
group by PerFirstName,PerLastName,PerGender,PerNationality,PerDateCreated,ru.UsrEmail
  order by PerDateCreated
