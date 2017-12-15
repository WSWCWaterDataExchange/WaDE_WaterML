--Adel Abdalah and Sara Larsen 
--Dec 2017

-- Function: "WADE_R"."XML_WaterML_Detailed"(character varying, character varying)

-- DROP FUNCTION "WADE_R"."XML_WaterML_Detailed"(character varying, character varying);

CREATE OR REPLACE FUNCTION "WADE_R"."XML_WaterML_Detailed"(
    IN orgid character varying,
    IN diversionid character varying,
    OUT text_output xml)
  RETURNS xml AS
$BODY$

DECLARE

namespace character varying;

/*
SELECT "WADE_R"."XML_WaterML_Detailed"(
    'CODWR',  -- Organization ID
    '4306139' -- DiversionID
);

*/
BEGIN

namespace:='http://www.opengis.net/waterml/2.0';


text_output:=(SELECT STRING_AGG
	(XMLELEMENT
	  (name "wml2:WaDEWaterML", XMLATTRIBUTES(namespace as "xmlns:wml2"),
	  	XMLCONCAT(XMLFOREST
	  	    (
	  	     "DIVERSION_NAME" AS "wml2:SiteName",--site name
		     A."DIVERSION_ID" AS "wml2:SiteCode",-- site code
     		     DL."DATATYPE" As "wml2:VariableName",--Variable Name
      		     'IrigationYear' AS "wml2:YearType",-- YearType: Irrigation Year, Water Year, Calendar Year. Each has a start and end months
      		     B."AMOUNT_VOLUME" AS "wml2:VolumeValue",-- Data value
		     U."VALUE" AS "wml2:VolumeUnit",-- Volume variable unit 
		     BU."DESCRIPTION" AS "wml2:BeneficialUse",--LU_BENEFICIAL_USE

	             --These two are commented out because there is no data for them in the CO db  
      		     --B."AMOUNT_RATE" AS "wml2:FlowValue",-- Volume Data value
		     --FL."VALUE" AS "wml2:FlowUnit",-- Flow variable unit 

		     V."DESCRIPTION" AS "wml2:MethodType",-- Value Type
    		     FSI."DESCRIPTION" AS "wml2:FreshSalineIndicatoraa",--FreshSalineIndicator
    		     DF."SOURCE_NAME" AS "wml2:DiversionSourceName",--Source Name
    		     H."METHOD_LINK" As "wml2:MethodLink",--MethodLink
    		     H."METHOD_DESC" As "wml2:MethodDescription",--MethodDescription
      		     A."REPORT_ID" AS "wml2:Date",-- Date
		     '40.0000' As "wml2:Latitude", -- hard coded for now. Later will estimate the centroid of 
    		     '-110.0000' As "wml2:Longitude",--hard coded for now
    		     'cumulative' As "wml2:AggregationStatistic",--AggregationStatistic
    		     '1' As "wml2:AggregationInterval",--AggregationInterval
    		     'year' As "wml2:AggregationIntervalUnit",--unit
    		     I."ORGANIZATION_NAME" As "wml2:Organization"--Organization		
)
			 )
           )::text,''                         
	 )

	FROM 

	"WADE"."DETAIL_DIVERSION" A LEFT OUTER JOIN "WADE"."LU_STATE" F ON (A."STATE"=F."LU_SEQ_NO") 

	LEFT OUTER JOIN "WADE"."D_DIVERSION_ACTUAL" B 
	ON (B."DIVERSION_ID"=A."DIVERSION_ID" AND B."ORGANIZATION_ID" =A."ORGANIZATION_ID" AND A."REPORT_ID"=B."REPORT_ID")

    	LEFT OUTER JOIN "WADE"."METHODS" H  
    	ON (B."METHOD_ID_VOLUME" =H."METHOD_ID")

    	LEFT OUTER JOIN "WADE"."ORGANIZATION" I  
    	ON (B."ORGANIZATION_ID" =I."ORGANIZATION_ID")

	LEFT OUTER JOIN "WADE_R"."DETAIL_LOCATION" DL 
	ON (B."ALLOCATION_ID"=DL."ALLOCATION_ID"AND B."ORGANIZATION_ID" =DL."ORGANIZATION_ID" AND B."REPORT_ID"=DL."REPORT_ID")

	LEFT OUTER JOIN "WADE"."LU_UNITS" U
	ON (U."LU_SEQ_NO"=B."UNIT_VOLUME")

        --These two are commented out because there is no data for them in the CO db  
	--LEFT OUTER JOIN "WADE"."LU_UNITS" Fl
	--ON (Fl."LU_SEQ_NO"=B."UNIT_RATE")
   	
	LEFT OUTER JOIN "WADE"."LU_VALUE_TYPE" V
	ON (V."LU_SEQ_NO"=B."VALUE_TYPE_VOLUME")

	LEFT OUTER JOIN "WADE"."D_DIVERSION_FLOW" DF 
	ON (B."DIVERSION_ID"=DF."DIVERSION_ID" AND B."ORGANIZATION_ID" =DF."ORGANIZATION_ID" AND B."REPORT_ID"=DF."REPORT_ID" AND B."DETAIL_SEQ_NO"=DF."DETAIL_SEQ_NO")

	LEFT OUTER JOIN "WADE"."D_DIVERSION_USE" DU 
	ON (DF."DIVERSION_ID"=DU."DIVERSION_ID" AND DF."ORGANIZATION_ID" =DU."ORGANIZATION_ID" AND DF."REPORT_ID"=DU."REPORT_ID" AND DF."DETAIL_SEQ_NO"=DU."DETAIL_SEQ_NO")

	LEFT OUTER JOIN "WADE"."LU_BENEFICIAL_USE" BU 
	ON (DU."BENEFICIAL_USE_ID"=BU."LU_SEQ_NO") 

	LEFT OUTER JOIN "WADE"."LU_FRESH_SALINE_INDICATOR" FSI 
	ON (DF."FRESH_SALINE_IND"=FSI."LU_SEQ_NO")

	WHERE A."ORGANIZATION_ID"=orgid AND A."DIVERSION_ID" = diversionid)


RETURN;


END
  $BODY$
  LANGUAGE plpgsql STABLE
  COST 1000;
ALTER FUNCTION "WADE_R"."XML_WaterML_Detailed"(character varying, character varying)
  OWNER TO postgres;
