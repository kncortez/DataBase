/*
  Name:  dbo.tb_StringEncoding
Author: Marco Jiménez
  Date: 2021-03-17
*/

CREATE TABLE dbo.tb_StringEncoding
(
  StringToReplace nvarchar(10),
  StringReplacement nvarchar(10),
  EncodingType nvarchar(25)
  CONSTRAINT pk_StringEncoding PRIMARY KEY
  (EncodingType, StringToReplace)
)