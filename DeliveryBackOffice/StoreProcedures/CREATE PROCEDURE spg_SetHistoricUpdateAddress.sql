SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Hernandez,Josselyn>
-- Create date: <2020-10-06,>
-- Description:	<Guarda informacion en la bitacora, cambia la direccion existente>
-- =============================================
CREATE PROCEDURE spg_SetHistoricUpdateAddress
		@Guide_Serie AS VARCHAR(2), --guide serie
		@Guide_Number AS INT, --guide number
		@unchanged_address VARCHAR(50),-- Old date of delivery
		@changed_address VARCHAR(50),--New date of delivery
		@Tokenid AS VARCHAR(50)    = 'ad1a2328ed27ea99622f68deae5d9976', --token user
		@name_receive as varchar(200), -- user name
		@receiver_phone as varchar(120) --phone receiver

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
					
	INSERT INTO [HISTORIC_UPDATEADDRESS]( token, name_receive, unchanged_address, changed_address, datetochange, receiver_phone) 
	VALUES (@Tokenid, @name_Receive, @unchanged_address, @changed_address, GETDATE(), @receiver_phone) 

	update  [DeliveryBackOffice].[dbo].[DeliveryOrder] SET Receiver_Alternant_Address = '', Receiver_Address = @changed_address


END
GO
