----Scrip para insertar el catalogo de los Wizards
 insert into [dbo].[CatWizard] (NameWiz, DescriptionWiz, StatusWiz, DateCreate,TokenCreate )
 values('Facturacion', 'Asistente para agregar el perfil de facturacion del usuario', 1,  GETDATE() ,'SYS-SYSTEM');
  insert into [dbo].[CatWizard] (NameWiz, DescriptionWiz, StatusWiz, DateCreate,TokenCreate )
 values('Direcciones', 'Asistente para agregar direcciones en el portal', 1,  GETDATE() ,'SYS-SYSTEM');
  insert into [dbo].[CatWizard] (NameWiz, DescriptionWiz, StatusWiz, DateCreate,TokenCreate )
 values('COD', 'Asistente para agregar COD en el portal', 1,  GETDATE() ,'SYS-SYSTEM');
 select * from [dbo].[CatWizard]
