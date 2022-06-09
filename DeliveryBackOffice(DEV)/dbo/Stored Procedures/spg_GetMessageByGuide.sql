-- =============================================
-- Author: <Hernandez, Josselyn>/<Borja, Cesar>/<Bidcar,Herrera>
-- Create date: <2020-09-29>
-- Description:	<Obtiene mensajes de texto por gúia electrónica>
-- =============================================
CREATE PROCEDURE [dbo].[spg_GetMessageByGuide]
		@Guide AS VARCHAR(50) = '' --Serie y número de guía
AS
BEGIN

SELECT B.GuideSerie Guide
,DOR.Receiver_FirstName + '' + DOR.Receiver_LastName Name
,SUBSTRING(SMR.SMS_MSisdn,4,LEN(SMR.SMS_MSisdn)) Phone
,SMR.SMS_Message Message
  FROM [DeliveryBackOffice].[dbo].[GuidesBySMS] B
  join DeliveryBackOffice.dbo.SMS_Received SMR
  on SMR.SMS_ID =  B.SMSID
  join DeliveryBackOffice.dbo.DeliveryOrder DOR
   on DOR.Guide_Serie +  CAST(DOR.Guide_Number AS VARCHAR) = @Guide
  and B.GuideSerie +  CAST(B.GuideNumber AS VARCHAR) = @Guide

END