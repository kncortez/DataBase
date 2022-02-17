/*
  Name:  Configuration for tb_StringEncoding
Author: Marco Jiménez
  Date: 2021-03-17
*/

INSERT INTO dbo.tb_StringEncoding(StringToReplace, StringReplacement, EncodingType)
VALUES   ( '"', '\"', 'json')
       , ('/', '\/', 'json')
       , ('{', '\{', 'json') 
       , ('}', '\}', 'json');
GO