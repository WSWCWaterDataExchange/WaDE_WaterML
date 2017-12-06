-- Function: "WADE_R"."XML_WaterML_USEME"(character varying, character varying, character varying)

-- DROP FUNCTION "WADE_R"."XML_WaterML_USEME"(character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION "WADE_R"."XML_WaterML_USEME"(
    IN loctxt character varying,
    IN orgid character varying,
    IN datatype character varying,
    OUT text_output xml)
  RETURNS xml AS
$BODY$

DECLARE

namespace character varying;


BEGIN

namespace:='http://www.opengis.net/waterml/2.0';


-- multiple If statements to loop over each data type and return xml of its specific output. 
-- The only difference between each retruned xml is in metadata columns

-- Data type = USE
IF datatype = 'USE' THEN


text_output:=(SELECT STRING_AGG
	(XMLELEMENT
	  (name "wml2:WaDEWaterML", XMLATTRIBUTES(namespace as "xmlns:wml2"),
	  	XMLCONCAT(XMLFOREST
	  	    (
    	  	     '' AS "wml2:USGSSiteType",--site type as classified by the USGS water uses
	  	     E."REPORTING_UNIT_NAME" AS "wml2:SiteName",--site name
		     A."REPORT_UNIT_ID" AS "wml2:SiteCode",-- site code
      		     (SELECT CONCAT(F."DATATYPE",'--',B."VALUE",'--',D."VALUE")) As "wml2:VariableName",--Variable Name
		     A."REPORT_ID" AS "wml2:Date", --Date
		     G."AMOUNT" AS "wml2:Value",-- Data value
		     'acre feet' AS "wml2:VarUnits",-- variable unit 
     		     F."DATATYPE" AS "wml2:WaDEDataType",-- Data type in WadE ~ parameter
		     B."VALUE" AS "wml2:BeneficialUse",--LU_BENEFICIAL_USE
    		     C."VALUE" AS "wml2:FreshSalineIndicator",--FreshSalineIndicator
		     D."VALUE" AS "wml2:WaterSourceType",--SourceTypeName
		     '40.0000' As "wml2:Latitude", -- hard coded for now. Later will estimate the centroid of 
    		     '-110.0000' As "wml2:Longitude",--hard coded for now
    		     'cumulative' As "wml2:AggregationStatistic",--AggregationStatistic
    		     '1' As "wml2:AggregationInterval",--AggregationInterval
    		     'year' As "wml2:AggregationIntervalUnit",--unit
    		     I."ORGANIZATION_NAME" As "wml2:Organization",--Organization
    		     'http://wade.westernstateswater.org/wade-by-location/' As "wml2:SourceLink",--SourceLink
    		     'Eestimated: check MethodLink' As "wml2:MethodType",--MethodType
    		     H."METHOD_LINK" As "wml2:MethodLink",--MethodLink
    		     H."METHOD_DESC" As "wml2:MethodDescription"--MethodDescription

		     )
			 )
           )::text,''                         
	 )

	FROM 

	"WADE"."SUMMARY_USE" A 
	LEFT OUTER JOIN "WADE"."LU_BENEFICIAL_USE" B 
	ON (A."BENEFICIAL_USE_ID"=B."LU_SEQ_NO") 

	LEFT OUTER JOIN "WADE"."LU_FRESH_SALINE_INDICATOR" C 
	ON (A."FRESH_SALINE_IND"=C."LU_SEQ_NO")

	LEFT OUTER JOIN "WADE"."LU_SOURCE_TYPE" D 
	ON (A."SOURCE_TYPE"=D."LU_SEQ_NO")

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
	
	WHERE A."ORGANIZATION_ID"=orgid AND A."REPORT_UNIT_ID"=loctxt AND F."DATATYPE"=datatype 
	GROUP BY "DATATYPE");

-- Data type = SUPPLY
ELSEIF datatype = 'SUPPLY' THEN



text_output:=(SELECT STRING_AGG
	(XMLELEMENT
	  (name "wml2:WaDEWaterML", XMLATTRIBUTES(namespace as "xmlns:wml2"),
	  	XMLCONCAT(XMLFOREST
	  	    (
    	  	     '' AS "wml2:USGSSiteType",--site type as classified by the USGS water uses
	  	     F."REPORTING_UNIT_NAME" AS "wml2:SiteName",--site name
		     A."REPORT_UNIT_ID" AS "wml2:SiteCode",-- site code
      		     --(SELECT CONCAT(F."DATATYPE",'--',B."VALUE",'--',D."VALUE")) As "wml2:VariableName",--Variable Name
		     A."REPORT_ID" AS "wml2:Date", --Date
		     A."AMOUNT" AS "wml2:Value",-- Data value
		     'acre feet' AS "wml2:VarUnits",-- variable unit 
     		     D."DATATYPE" AS "wml2:WaDEDataType",-- Data type in WadE ~ parameter
     		     H."VALUE" AS "wml2:WaterSupplyType",-- WaterSupplyType
		     '40.0000' As "wml2:Latitude", -- hard coded for now. Later will estimate the centroid of 
    		     '-110.0000' As "wml2:Longitude",--hard coded for now
    		     'cumulative' As "wml2:AggregationStatistic",--AggregationStatistic
    		     '1' As "wml2:AggregationInterval",--AggregationInterval
    		     'year' As "wml2:AggregationIntervalUnit",--unit
    		      E."ORGANIZATION_NAME" As "wml2:Organization",--Organization
    		     'http://wade.westernstateswater.org/wade-by-location/' As "wml2:SourceLink",--SourceLink
    		     'Eestimated: check MethodLink' As "wml2:MethodType",--MethodType
    		     C."METHOD_LINK" As "wml2:MethodLink",--MethodLink
    		     C."METHOD_DESC" As "wml2:MethodDescription"--MethodDescription

		     )
			 )
           )::text,''                         
	 )

	FROM 

	"WADE"."S_WATER_SUPPLY_AMOUNT" A 
	 LEFT OUTER JOIN "WADE"."METHODS" C
	 ON (A."METHOD_ID"=C."METHOD_ID")

	 LEFT OUTER JOIN "WADE_R"."CATALOG_SUMMARY" D
	 ON (D."REPORT_UNIT_ID" =A."REPORT_UNIT_ID" AND D."REPORT_ID"=A."REPORT_ID")

	 LEFT OUTER JOIN "WADE"."ORGANIZATION" E  
    	 ON (E."ORGANIZATION_ID" =D."ORGANIZATION_ID")
    	 
    	 LEFT OUTER JOIN "WADE"."REPORTING_UNIT" F 
	 ON (F."REPORT_UNIT_ID" =D."REPORT_UNIT_ID" AND F."REPORT_ID"=D."REPORT_ID")	

 	 LEFT OUTER JOIN "WADE"."SUMMARY_WATER_SUPPLY" G 
	 ON (G."REPORT_UNIT_ID" =D."REPORT_UNIT_ID" AND G."REPORT_ID"=D."REPORT_ID")

	 LEFT OUTER JOIN "WADE"."LU_WATER_SUPPLY_TYPE" H
	  ON (G."WATER_SUPPLY_TYPE"=H."LU_SEQ_NO")


	WHERE A."ORGANIZATION_ID"=orgid AND A."REPORT_UNIT_ID"=loctxt AND D."DATATYPE"=datatype 
	GROUP BY "DATATYPE");


-- Data type = AVAILABILITY
ELSEIF datatype = 'AVAILABILITY' THEN

text_output:=(SELECT STRING_AGG
	(XMLELEMENT
	  (name "wml2:WaDEWaterML", XMLATTRIBUTES(namespace as "xmlns:wml2"),
	  	XMLCONCAT(XMLFOREST
	  	    (
    	  	     '' AS "wml2:USGSSiteType",--site type as classified by the USGS water uses
	  	     E."REPORTING_UNIT_NAME" AS "wml2:SiteName",--site name
		     A."REPORT_UNIT_ID" AS "wml2:SiteCode",-- site code
      		     --(SELECT CONCAT(F."DATATYPE",'--',B."VALUE",'--',D."VALUE")) As "wml2:VariableName",--Variable Name
		     A."REPORT_ID" AS "wml2:Date", --Date
		     A."AMOUNT" AS "wml2:Value",-- Data value
		     'acre feet' AS "wml2:VarUnits",-- variable unit 
     		     F."DATATYPE" AS "wml2:WaDEDataType",-- Data type in WadE ~ parameter
    		     C."VALUE" AS "wml2:FreshSalineIndicator",--FreshSalineIndicator
		     W."SOURCE_TYPE" AS "wml2:WaterSourceType",--SourceTypeName
     		     W."AVAILABILITY_TYPE" AS "wml2:Availability_Type",--Availability_Type

		     '40.0000' As "wml2:Latitude", -- hard coded for now. Later will estimate the centroid of 
    		     '-110.0000' As "wml2:Longitude",--hard coded for now
    		     'cumulative' As "wml2:AggregationStatistic",--AggregationStatistic
    		     '1' As "wml2:AggregationInterval",--AggregationInterval
    		     'year' As "wml2:AggregationIntervalUnit",--unit
    		     I."ORGANIZATION_NAME" As "wml2:Organization",--Organization
    		     'http://wade.westernstateswater.org/wade-by-location/' As "wml2:SourceLink",--SourceLink
    		     'Eestimated: check MethodLink' As "wml2:MethodType",--MethodType
    		     H."METHOD_LINK" As "wml2:MethodLink",--MethodLink
    		     H."METHOD_DESC" As "wml2:MethodDescription"--MethodDescription

		     )
			 )
           )::text,''                         
	 )

	FROM 

	"WADE"."S_AVAILABILITY_AMOUNT" A

 	LEFT OUTER JOIN "WADE"."SUMMARY_AVAILABILITY" W 
	ON (W."REPORT_UNIT_ID" =A."REPORT_UNIT_ID" AND W."REPORT_ID"=A."REPORT_ID")

	LEFT OUTER JOIN "WADE"."LU_FRESH_SALINE_INDICATOR" C 
	ON (W."FRESH_SALINE_IND"=C."LU_SEQ_NO")

	LEFT OUTER JOIN "WADE"."REPORTING_UNIT" E 
	ON (E."REPORT_UNIT_ID" =A."REPORT_UNIT_ID" AND E."REPORT_ID"=A."REPORT_ID")

	LEFT OUTER JOIN "WADE_R"."CATALOG_SUMMARY" F
	ON (F."REPORT_UNIT_ID" =A."REPORT_UNIT_ID" AND F."REPORT_ID"=A."REPORT_ID")

    	LEFT OUTER JOIN "WADE"."METHODS" H  
    	ON (H."METHOD_ID" =A."METHOD_ID")

    	LEFT OUTER JOIN "WADE"."ORGANIZATION" I  
    	ON (I."ORGANIZATION_ID" =A."ORGANIZATION_ID")	
	
	WHERE A."ORGANIZATION_ID"=orgid AND A."REPORT_UNIT_ID"=loctxt AND F."DATATYPE"=datatype 
	GROUP BY "DATATYPE");


END IF;


RETURN;

END
  $BODY$
  LANGUAGE plpgsql STABLE
  COST 1000;
ALTER FUNCTION "WADE_R"."XML_WaterML_USEME"(character varying, character varying, character varying)
  OWNER TO postgres;
