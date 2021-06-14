USE [DeliveryBackOffice]
GO

alter table dbo.UserAddress ADD
            VisitPointByClientPortfolioId int null
go

USE [DeliveryBackOffice]
GO

alter table dbo.BillingProfile ADD
            VisitPointByClientPortfolioId int null
go


USE [DeliveryBackOffice]
GO
alter table dbo.DeliveryFavCOD ADD
            VisitPointByClientPortfolioId int null
go

select * from dbo.DeliveryFavCOD
select * from dbo.BillingProfile
select * from dbo.UserAddress