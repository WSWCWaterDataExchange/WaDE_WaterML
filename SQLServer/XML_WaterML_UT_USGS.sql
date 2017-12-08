/*

Adel Abdallah and Sara Larsen
October 2017

For more info on the logic of the code and maping WaDE to WaterML, please refer to 
xxxx


*/

-- it works for the USGS Water use terms 

/*
USE [WaDEwre]
GO

--orgid, usgs_wateruse_category,reportunitid

SELECT [wade_r].[XML_WaterML] (
   'utwre',
   'Water Use, Irrigation',
  '00-01-02'
  )

GO

*/
USE [WaDEwre]
GO
/****** Object:  UserDefinedFunction [wade_r].[XML_WaterML]    Script Date: 11/3/2017 10:26:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--orgid, usgs_wateruse_category,reportunitid
ALTER FUNCTION [wade_r].[XML_WaterML](@orgid varchar(10), @usgs_wateruse_category varchar(35), @reportunitid varchar(35))


  
  RETURNS xml 

BEGIN

DECLARE @tmp XML='';
WITH XMLNAMESPACES ('ReplaceMe' AS wml2)

SELECT @tmp=(SELECT 
		 A."REPORT_UNIT_ID" AS 'wml2:SiteCode',-- site code
 	     E."REPORTING_UNIT_NAME" AS "wml2:SiteName",--site name
  	     B."USGS_WaterUse_Category" AS 'wml2:VariableName',--Variable Name as classified by the USGS water uses
		 R."REPORTING_YEAR"	 AS 'wml2:Date', --Date
	     G."AMOUNT" AS "wml2:Value",-- Data value
		 B."VALUE" AS 'wml2:BeneficialUse',--LU_BENEFICIAL_USE
	     F."DATATYPE" AS "wml2:WaDEDataType",-- Data type in WadE ~ parameter
 	     CASE  
	  		WHEN G."CONSUMPTIVE_INDICATOR" ='N' OR
		      G."CONSUMPTIVE_INDICATOR" ='NULL'
			THEN 'Withdrawal'
		 ELSE 'Consumptive Use'
		 END AS "wml2:withdrawalORconsumptiveUse",-- Consumptive Use indicator
		  '40.0000' As "wml2:Latitude", -- hard coded for now. Later will estimate the centroid of 
    	  '-110.0000' As "wml2:Longitude",--hard coded for now
    	  'cumulative' As "wml2:AggregationStatistic",--AggregationStatistic
    	  '1' As "wml2:AggregationInterval",--AggregationInterval
    	  'year' As "wml2:AggregationIntervalUnit",--unit
 	      'Eestimated: check MethodLink' As "wml2:MethodType",--MethodType
		   C."VALUE" AS "wml2:FreshSalineIndicator",--FreshSalineIndicator
		   D."VALUE" AS "wml2:WaterSourceType",--SourceTypeName
    	   'acre feet' AS "wml2:VarUnits",-- variable unit 
    	   H."METHOD_LINK" As "wml2:MethodLink",--MethodLink
    	   H."METHOD_DESC" As "wml2:MethodDescription",--MethodDescription
    	   I."ORGANIZATION_NAME" As "wml2:Organization"--Organization

	FROM  
	
	WADE.SUMMARY_USE A 
	LEFT OUTER JOIN WADE.LU_BENEFICIAL_USE B 
	ON (A.BENEFICIAL_USE_ID=B.LU_SEQ_NO)
	
	LEFT JOIN WADE.LU_FRESH_SALINE_INDICATOR C
	ON (A.FRESH_SALINE_IND=C.LU_SEQ_NO)
	
	LEFT JOIN WADE.LU_SOURCE_TYPE D
	ON (A.SOURCE_TYPE=D.LU_SEQ_NO)

	LEFT OUTER JOIN "WADE"."REPORTING_UNIT" E 
	ON (E."REPORT_UNIT_ID" =A."REPORT_UNIT_ID" AND E."REPORT_ID"=A."REPORT_ID")

	LEFT OUTER JOIN "WADE_R"."CATALOG_SUMMARY" F
	ON (F."REPORT_UNIT_ID" =A."REPORT_UNIT_ID" AND F."REPORT_ID"=A."REPORT_ID")

	LEFT OUTER JOIN "WADE"."S_USE_AMOUNT" G 
	ON (G."REPORT_UNIT_ID" =A."REPORT_UNIT_ID" AND G."REPORT_ID"=A."REPORT_ID" AND G."SUMMARY_SEQ"=A."SUMMARY_SEQ" AND
	G."BENEFICIAL_USE_ID"=A."BENEFICIAL_USE_ID" )

   	LEFT OUTER JOIN "WADE"."METHODS" H  
   	ON (H."METHOD_ID" =G."METHOD_ID")
    	
	LEFT OUTER JOIN "WADE"."ORGANIZATION" I  
    ON (I."ORGANIZATION_ID" =A."ORGANIZATION_ID")	


	LEFT OUTER JOIN "WADE".REPORT R  
    ON (R."REPORT_ID"=E."REPORT_ID" AND R."ORGANIZATION_ID" =E."ORGANIZATION_ID")	


		
	WHERE A.ORGANIZATION_ID=@orgid AND B."USGS_WaterUse_Category"=@usgs_wateruse_category AND A.REPORT_UNIT_ID=@reportunitid 
			FOR XML PATH ('wml2:waterml2'));
		
RETURN(@tmp)
		
END
