insert into TypeServiceManagment (Name, RowStatus,TokenCreated,DateCreated,TokenUpdated, DateUpdated)
values ('Recolección',1,'SYS_SYSTEM',GETDATE(),null, null)

insert into TypeServiceManagment (Name, RowStatus,TokenCreated,DateCreated,TokenUpdated, DateUpdated)
values ('Entrega',1,'SYS_SYSTEM',GETDATE(),null, null)

----------------------------------------------------------------------------------------------------------------------------------

insert into SubTypeServiceManagment (TypeServiceManagmentId, Name, RowStatus,TokenCreated,DateCreated,TokenUpdated, DateUpdated)
values (1,'Recolección',1,'SYS_SYSTEM',GETDATE(),null, null)


insert into SubTypeServiceManagment (TypeServiceManagmentId, Name, RowStatus,TokenCreated,DateCreated,TokenUpdated, DateUpdated)
values (2,'Entrega',1,'SYS_SYSTEM',GETDATE(),null, null)

insert into SubTypeServiceManagment (TypeServiceManagmentId, Name, RowStatus,TokenCreated,DateCreated,TokenUpdated, DateUpdated)
values (2,'Devolución',1,'SYS_SYSTEM',GETDATE(),null, null)

insert into SubTypeServiceManagment (TypeServiceManagmentId, Name, RowStatus,TokenCreated,DateCreated,TokenUpdated, DateUpdated)
values (2,'Linehauls',1,'SYS_SYSTEM',GETDATE(),null, null)



select * from  TypeServiceManagment

select * from  SubTypeServiceManagment


