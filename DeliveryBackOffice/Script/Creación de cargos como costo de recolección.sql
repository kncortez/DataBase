	insert into DeliveryBackOffice.dbo.CatLanguage
	(Language,Abbreviation,RowStatus,TokenCreated,DateCreated)
	values
	('Spanish','ES',1,'SYS-BHERRERA',getdate())


	insert into DeliveryBackOffice.dbo.CatLanguage
	(Language,Abbreviation,RowStatus,TokenCreated,DateCreated)
	values
	('English','EN',1,'SYS-BHERRERA',getdate())

	select * from DeliveryBackOffice.dbo.CatLanguage

---------
insert into DeliveryBackOffice.dbo.CatGeneralLabel
(LabelCode,LabelDescription,LanguageId,RowStatus,TokenCreated,DateCreated)
values ('Portal_PickupRate','Pickup Rate',2,1,'SYS-BHERRERA',getdate())

insert into DeliveryBackOffice.dbo.CatGeneralLabel
(LabelCode,LabelDescription,LanguageId,RowStatus,TokenCreated,DateCreated)
values ('Portal_PickupRate','Costo de recolección',1,1,'SYS-BHERRERA',getdate())

select * from DeliveryBackOffice.dbo.CatGeneralLabel
-----

insert into DeliveryBackOffice.dbo.Unit
(UnitName,Prefix,TypeUnit,UnitStatus,TokenCreated,DateCreated)
values ('Porcentaje','Pct','Percentum',1,'SYS-BHERRERA',getdate())

insert into DeliveryBackOffice.dbo.Unit
(UnitName,Prefix,TypeUnit,UnitStatus,TokenCreated,DateCreated)
values ('Precio','Prc','Price',1,'SYS-BHERRERA',getdate())

select * from DeliveryBackOffice.dbo.Unit

-----
insert into DeliveryBackOffice.dbo.CatToCharge
(Name,Description,DescriptionLabel,Value,UnitId,CountryId,CurrencyId,RowStatus,TokenCreated,DateCreated)
values
('PickupRate','Costo de recolección estándar','Portal_PickupRate',15,6,'GT',1,1,'SYS-BHERRERA',getdate())

select * from DeliveryBackOffice.dbo.CatToCharge


