CREATE procedure [dbo].[SPG_Insert_Destroy_GuidesList]
@GuideSerie NVARCHAR(2), 
@GuideNumber NVARCHAR(MAX),
@Token NVARCHAR(100)
as 
begin

declare @guias table (guia int)
insert into @guias
Select Item FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@GuideNumber,',')

declare @StatusOrderId INT = 30
--select * from @guias
--declare @vision int

--SELECT [Guide_Serie]
--      ,[Guide_Number]
--	  ,[Collect_OnDelivery]
--      ,[Manifest_Serie]
--      ,[Manifest_Number]
--      ,[DateCreated]
--      ,[StatusOrderId]
--      ,[Guide_Collected] 
--FROM [DeliveryBackOffice].[dbo].[DeliveryOrder]
----WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber
--WHERE Guide_Serie = @GuideSerie AND Guide_Number IN (Select Item FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@GuideNumber,','))

-- actualizar último status 
UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrder] SET StatusOrderId = @StatusOrderId WHERE Guide_Serie = @GuideSerie AND Guide_Number IN (Select Item FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@GuideNumber,','))

-- insertar status histórico
WHILE (select top 1 guia from @guias) > 0
begin 
	--set @vision = (select top 1 guia from @guias)
	--print @vision
	INSERT INTO [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] VALUES (@GuideSerie,(select top 1 guia  from @guias),@StatusOrderId,@Token,GETDATE(),GETDATE(),NULL,NULL,NULL,1)
	delete from @guias where guia = (select top 1 guia from @guias)
	--set @vision = (select top 1 guia from @guias)
	--print @vision
END
END
--SELECT [Guide_Serie]
--      ,[Guide_Number]
--	  ,[Collect_OnDelivery]
--      ,[Manifest_Serie]
--      ,[Manifest_Number]
--      ,[DateCreated]
--      ,[StatusOrderId]
--      ,[Guide_Collected] 
--FROM [DeliveryBackOffice].[dbo].[DeliveryOrder]
--WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber

--SELECT * FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]
--WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber