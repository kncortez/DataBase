-- =============================================
-- Author:		<Author,Edelman Vásquez>
-- Create date: <Create Date,2022-04-04>
-- Description:	<Description,SP devuelve el último estado de una guía si este es Externo, para que el cliente pueda rastrearlo>
-- =============================================
CREATE PROCEDURE [dbo].[spfccGuideStatus] 
	-- Add the parameters for the stored procedure here
	@GuideNumber as INT 

AS
BEGIN
 Declare   @jsonOutput VARCHAR(MAX) = ''
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 SET @jsonOutput =  
  ( 
   SELECT ''+ STUFF(( 
select Top 1  
   ',{"GuideSerie":"' +  a.Guide_Serie, +'",'+
  '"GuideNumber":"' +  Convert(varchar,isnull(a.Guide_Number, 0)) +'",'+ 
  '"StatusOrderId":"' +  Convert(varchar,isnull( a.StatusOrderId,0)) +'",'+ 
  '"Description":"' +  b.OrderDescription,  +'",'+ 
  '"Status":"' + c.status,  +'",'+ 
  '"DataCreated":"' +  Convert(varchar,isnull(  a.DateCreated,  getdate()),121) +'"'+ 
   
   ' }}' +
 
    '' 
From dbo.DeliveryOrderDetail a     WITH (NOLOCK)
	Inner Join dbo.StatusOrder b   WITH (NOLOCK)
		On a.StatusOrderId = b.StatusOrderId
	Inner Join dbo.CatStatusType c WITH (NOLOCK)
		On b.CatStatusTypeId = c.IdCatStatusType
Where a.Guide_Number=@GuideNumber
      AND c.IdCatStatusType=2


	  
FOR XML PATH(''), TYPE 
  ) 
  .value('.', 'varchar(max)'),1,1,'' 
              ) + '' 
  ) 

  print @jsonOutput
 
  select  
  @jsonOutput
  FormatJson 
  
END
