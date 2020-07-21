BEGIN TRANSACTION
    BEGIN TRY
--Restriction por usaurio
--select * from dbo.LGN_Restriction LRT
--where RST_IdSystem = 13

 insert into DenariusUser_Dev.dbo.LGN_Rol
 ([LGN_Name], [LGN_Description], [LGN_StatusRol], [LGN_IdSystem], [LGN_CreationDate], [LGN_CreationToken], [LGN_AdminClients], [LGN_AdminBrothers], [LGN_AdminHierarchicaly])
values
('CONFIRMADOR DE ENTREGA - FORZA DELIVERY','CONFIRMA ENTREGAS, FORZA DELIVERY',1,13,getdate(),'SYS-BHERRERA',0,0,0)

DECLARE @RolConfirmationOfDelivery AS INT
select @RolConfirmationOfDelivery = MAX(LGN_IdRol) from DenariusUser_Dev.dbo.LGN_Rol WITH(nolock)
select @RolConfirmationOfDelivery

--select top 10 * from DenariusUser_Dev.dbo.LGN_RolByUserByRegion
--where RUR_IdRol in (1866,1867)

--Asignar roles de Delivery a usuarios
INSERT INTO DenariusUser_Dev.dbo.LGN_RolByUserByRegion
([RUR_IdRol], [RUR_IdUser], [RUR_IdStation], [RUR_IdCountry], [RUR_Username], [RUR_Status])
VALUES (@RolConfirmationOfDelivery,100051,-1,'GT','carlos.cano',1)

INSERT INTO DenariusUser_Dev.dbo.LGN_RolByUserByRegion
([RUR_IdRol], [RUR_IdUser], [RUR_IdStation], [RUR_IdCountry], [RUR_Username], [RUR_Status])
VALUES (@RolConfirmationOfDelivery,100088,-1,'GT','edwin.ramirez',1)

INSERT INTO DenariusUser_Dev.dbo.LGN_RolByUserByRegion
([RUR_IdRol], [RUR_IdUser], [RUR_IdStation], [RUR_IdCountry], [RUR_Username], [RUR_Status])
VALUES (@RolConfirmationOfDelivery,103492,-1,'GT','bidcar.herrera',1)

--Creación de módulos
--select top 10 * from DenariusUser_Dev.dbo.LGN_Module
--where MDL_IdModule in (550,551)

DECLARE @ModuleConfirmationOfDelivery AS INT
select @ModuleConfirmationOfDelivery = MAX(MDL_IdModule)+1 from DenariusUser_Dev.dbo.LGN_Module

select @ModuleConfirmationOfDelivery


--SELECT * FROM DenariusUser_Dev.dbo.LGN_Module
--order by 1 desc

insert DenariusUser_Dev.dbo.LGN_Module
([MDL_IdModule], [MDL_Name], [MDL_IdModuleParent], [MDL_AuthPath], [MDL_Description], [MDL_Order], [MDL_Metadata], [MDL_Visible], [MDL_KeyWord])
values (@ModuleConfirmationOfDelivery,'Confirmación de entrega',NULL,'FormConfirmationOfDelivery.cs','Confirmación de entrega',1,NULL,1,NULL)

--select top 10 * from DenariusUser_Dev.dbo.LGN_ModuleByRolBySystem
--where MRS_IdSystem = 13
--Asignar módulos a los roles
insert into DenariusUser_Dev.dbo.LGN_ModuleByRolBySystem
values (@ModuleConfirmationOfDelivery,@RolConfirmationOfDelivery,13,1)

insert into DenariusUser_Dev.dbo.LGN_ModuleByRolBySystem
values (0,@RolConfirmationOfDelivery,13,1)

      SELECT
        1 [blnResult],
        '' AS [ErrorNumber],
        '' AS [ErrorSeverity],
        '' AS [ErrorState],
        '' AS [ErrorProcedure],
        '' AS [ErrorLine],
        '' AS [ErrorMessage];

    END TRY
    BEGIN CATCH
      SELECT
        0 [blnResult],
        ERROR_NUMBER() AS [ErrorNumber],
        ERROR_SEVERITY() AS [ErrorSeverity],
        ERROR_STATE() AS [ErrorState],
        ERROR_PROCEDURE() AS [ErrorProcedure],
        ERROR_LINE() AS [ErrorLine],
        ERROR_MESSAGE() AS [ErrorMessage];
      IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    END CATCH;

      IF @@TRANCOUNT > 0
      COMMIT TRANSACTION;


