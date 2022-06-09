

CREATE FUNCTION [dbo].[fn_get_document_image_url]
    (
      @IdDoc VARCHAR(15)
    )
   returns VARCHAR(250)
as 

BEGIN

DECLARE @PATH VARCHAR(250)

	SELECT TOP 1
		@PATH=ISNULL(RTRIM(V.LastPath) + '\' + RTRIM(P.filepath),'')
	FROM HOP.HOP.DOCDATAPAGE P
	INNER JOIN HOP.HOP.REPOSITORIESVOLUMES V ON V.VolumeNum = P.logicalfolder AND v.RepNum=p.repnum
	INNER JOIN (
			-- BUSCAR EN TABLA DE VOUCHERS  (KeyItem2)
			/*SELECT D.*
			FROM   HOP.HOP.DOCDATA d ,
				HOP.HOP.KEYITEM2 ki2
			WHERE  
				(d.itemid = ki2.ITEMNUM AND ki2.KEYVALUECHAR = @IdDoc)
				AND d.status = 0
                            
				AND ( d.doctypeid IN ( 7 ) ) -- voucher y comprobante de entrega
			UNION*/
			-- BUSCAR EN TABLA DE COMPROBANTES (KeyItem4)
			SELECT D.*
			FROM   HOP.HOP.DOCDATA d ,
				HOP.HOP.KEYITEM4 ki4
			WHERE  
				(d.itemid = ki4.ITEMNUM AND ki4.KEYVALUECHAR = @IdDoc)
				AND d.status = 0
				AND ( d.doctypeid IN ( 12 ) ) -- voucher y comprobante de entrega
		) AS I ON I.itemid = P.itemid
	INNER JOIN HOP.HOP.DOCTYPES dt ON dt.DOCTYPEID = I.doctypeid 
	and dt.DOCTYPEID IN (/*7,*/12)

	-- remove physical path and replace it for predefined folder in webpage
	-- this: \\ecs-web01\HOPFiles\GT.BOVEDA\Copia1\V77\2898578.jpg
	-- for this: /DocImages/GT.BOVEDA/Copia1/V77/2898578.jpg
	SET @PATH = REPLACE(REPLACE(@PATH,'\\ecs-web01\HOPFiles\','/DocImages/'),'\','/')
	--SET @PATH = '\\reg-stg-epsilon\HOPFiles\GT.BOVEDA\Copia1\V77\2878940.jpg'
	
RETURN @PATH
END



